use ramparts_common::{anyhow::Result, tracing::{info, debug, warn, error}};
use crate::{JavelinClient, ProxyConfig, get_license_status, GuardedMcpServer, ValidationService};
use axum::{
    extract::{State, Path},
    http::{StatusCode, HeaderMap},
    response::Json,
    routing::{get, post, any_service},
    Router,
};
use rmcp::{
    transport::{
        StreamableHttpServerConfig, StreamableHttpService, streamable_http_server::session::never::NeverSessionManager,
    },
};
use serde_json::{json, Value};
use std::{sync::Arc, time::Duration};
use tokio::net::TcpListener;
use tower_http::cors::CorsLayer;

/// Security-first AI Gateway for MCP - competitive alternative to Nexus, LiteLLM, and Cloudflare AI Gateway
pub struct MCPProxy {
    config: ProxyConfig,
    mcp_server: GuardedMcpServer,
}

/// Proxy state shared across handlers
#[derive(Clone)]
pub struct ProxyState {
    validation_service: Arc<ValidationService>,
}

impl MCPProxy {
    pub fn new(listen_address: String) -> Result<Self> {
        // Load configuration from environment
        let mut config = ProxyConfig::from_env()?;
        config.listen_address = listen_address;
        config.validate()?;

        // Initialize Javelin client with configuration
        let javelin_client = Arc::new(JavelinClient::with_config(
            config.javelin.api_key.clone(),
            config.javelin.base_url.clone(),
            config.javelin.timeout_seconds,
        ));

        // Create the MCP server with Javelin integration
        let mcp_server = GuardedMcpServer::new(config.clone(), javelin_client);

        Ok(Self {
            config,
            mcp_server,
        })
    }

    pub fn with_config(config: ProxyConfig) -> Result<Self> {
        config.validate()?;

        let javelin_client = Arc::new(JavelinClient::with_config(
            config.javelin.api_key.clone(),
            config.javelin.base_url.clone(),
            config.javelin.timeout_seconds,
        ));

        // Create the MCP server with Javelin integration
        let mcp_server = GuardedMcpServer::new(config.clone(), javelin_client);

        Ok(Self {
            config,
            mcp_server,
        })
    }

    pub async fn start(&self) -> Result<()> {
        info!("Starting Ramparts AI Gateway on {} (security-first MCP proxy)", self.config.listen_address);

        // Create the MCP service with enterprise security
        let mcp_service = StreamableHttpService::new(
            {
                let server = self.mcp_server.clone();
                move || Ok(server.clone())
            },
            Arc::new(NeverSessionManager::default()),
            StreamableHttpServerConfig {
                sse_keep_alive: Some(Duration::from_secs(5)),
                stateful_mode: false,
            },
        );

        // Create shared state with unified validation service
        let validation_service = Arc::new(ValidationService::new(
            self.mcp_server.get_javelin_client(),
            self.config.clone(),
        ));

        let state = ProxyState {
            validation_service,
        };

        // Build the router with both MCP and management endpoints
        let app = Router::new()
            // Management endpoints
            .route("/", get(health_check))
            .route("/health", get(health_check))
            .route("/license", get(license_status))
            .route("/validate", post(validate_request))
            // Legacy proxy endpoint for backward compatibility
            .route("/proxy/:target", post(proxy_mcp_request))
            // MCP endpoint with enterprise security validation
            .route("/mcp", any_service(mcp_service))
            .layer(CorsLayer::permissive())
            .with_state(state);

        // Parse the listen address
        let listener = TcpListener::bind(&self.config.listen_address).await
            .map_err(|e| ramparts_common::anyhow::anyhow!("Failed to bind to {}: {}", self.config.listen_address, e))?;

        info!("Ramparts AI Gateway listening on {} with endpoints:", self.config.listen_address);
        info!("  - /mcp (Secure MCP protocol with Javelin Guardrails)");
        info!("  - /health (Health check)");
        info!("  - /license (License status)");
        info!("  - /validate (Enterprise request validation)");
        info!("  - /proxy/:target (Legacy proxy endpoint)");

        // Start the server
        axum::serve(listener, app).await
            .map_err(|e| ramparts_common::anyhow::anyhow!("Server error: {}", e))?;

        Ok(())
    }
}

/// Health check endpoint
async fn health_check() -> Json<Value> {
    Json(json!({
        "status": "healthy",
        "service": "ramparts-proxy",
        "version": env!("CARGO_PKG_VERSION")
    }))
}

/// License status endpoint
async fn license_status() -> Json<Value> {
    let license_status = get_license_status().unwrap_or_else(|e| format!("Error: {}", e));

    Json(json!({
        "license": {
            "status": license_status,
            "component": "ramparts-proxy",
            "license_type": "Javelin Proprietary License",
            "requires_api_key": true,
            "contact": "legal@getjavelin.com"
        },
        "timestamp": chrono::Utc::now().to_rfc3339()
    }))
}

/// Validate a request against Javelin Guardrails
async fn validate_request(
    State(state): State<ProxyState>,
    Json(request): Json<Value>,
) -> Result<Json<Value>, StatusCode> {
    debug!("Validating request: {}", serde_json::to_string_pretty(&request).unwrap_or_default());

    match state.validation_service.validate_request(&request).await {
        Ok(result) => {
            let response = json!({
                "valid": result.allowed,
                "reason": result.reason,
                "confidence": result.confidence,
                "request_id": result.request_id,
                "timestamp": result.timestamp
            });
            Ok(Json(response))
        }
        Err(e) => {
            error!("Validation error: {}", e);
            Err(StatusCode::INTERNAL_SERVER_ERROR)
        }
    }
}

/// Proxy MCP requests through Javelin Guardrails to target servers
async fn proxy_mcp_request(
    State(state): State<ProxyState>,
    Path(target): Path<String>,
    headers: HeaderMap,
    Json(request): Json<Value>,
) -> Result<Json<Value>, StatusCode> {
    debug!("Proxying MCP request to target: {}", target);
    debug!("Request: {}", serde_json::to_string_pretty(&request).unwrap_or_default());

    // Validate request using unified validation service
    match state.validation_service.validate_and_handle(&request).await {
        Ok(_validation_result) => {
            info!("Request validated successfully, forwarding to target");

            // Forward the request to the actual MCP server
            match forward_to_target(&target, &request, &headers).await {
                Ok(response) => {
                    debug!("Received response from target: {}", serde_json::to_string_pretty(&response).unwrap_or_default());

                    // Optionally validate the response as well
                    match state.validation_service.validate_response(&response).await {
                        Ok(result) if result.allowed => {
                            info!("Response validated successfully");
                            Ok(Json(response))
                        }
                        Ok(result) => {
                            warn!("Response failed validation: {:?}", result.reason);
                            let error_response = state.validation_service.create_blocked_response(&response, &result);
                            Ok(Json(error_response))
                        }
                        Err(e) => {
                            warn!("Response validation error: {}, allowing response", e);
                            Ok(Json(response))
                        }
                    }
                }
                Err(e) => {
                    error!("Failed to forward request to target {}: {}", target, e);
                    let error_response = state.validation_service.create_error_response(
                        &request,
                        &format!("Failed to forward request to target {}: {}", target, e)
                    );
                    Ok(Json(error_response))
                }
            }
        }
        Err(error_response) => {
            // Request was blocked - return the pre-formatted error response
            Ok(Json(error_response))
        }
    }
}

/// Forward request to target MCP server
async fn forward_to_target(
    target: &str,
    request: &Value,
    headers: &HeaderMap,
) -> Result<Value, ramparts_common::anyhow::Error> {
    use ramparts_common::anyhow::anyhow;

    // Parse target URL - support both full URLs and simple hostnames
    let target_url = if target.starts_with("http://") || target.starts_with("https://") {
        target.to_string()
    } else {
        // Assume HTTP for simple hostnames/IPs
        format!("http://{}", target)
    };

    debug!("Forwarding request to: {}", target_url);

    // Create HTTP client with timeout
    let client = reqwest::Client::builder()
        .timeout(Duration::from_secs(30))
        .build()
        .map_err(|e| anyhow!("Failed to create HTTP client: {}", e))?;

    // Prepare headers for forwarding
    let mut forward_headers = reqwest::header::HeaderMap::new();
    forward_headers.insert(
        reqwest::header::CONTENT_TYPE,
        reqwest::header::HeaderValue::from_static("application/json"),
    );

    // Forward relevant headers from the original request
    for (name, value) in headers.iter() {
        if let Ok(header_name) = reqwest::header::HeaderName::from_bytes(name.as_str().as_bytes()) {
            if let Ok(header_value) = reqwest::header::HeaderValue::from_bytes(value.as_bytes()) {
                // Forward authorization and other relevant headers
                if name.as_str().to_lowercase().starts_with("authorization") ||
                   name.as_str().to_lowercase().starts_with("x-") {
                    forward_headers.insert(header_name, header_value);
                }
            }
        }
    }

    // Send the request
    let response = client
        .post(&target_url)
        .headers(forward_headers)
        .json(request)
        .send()
        .await
        .map_err(|e| anyhow!("Failed to send request to target: {}", e))?;

    // Check response status
    if !response.status().is_success() {
        return Err(anyhow!(
            "Target server returned error status: {}",
            response.status()
        ));
    }

    // Parse response as JSON
    let response_text = response
        .text()
        .await
        .map_err(|e| anyhow!("Failed to read response from target: {}", e))?;

    serde_json::from_str(&response_text)
        .map_err(|e| anyhow!("Failed to parse JSON response from target: {}", e))
}
