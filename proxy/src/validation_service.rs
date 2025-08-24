use ramparts_common::{anyhow::Result, tracing::{debug, info, warn, error}};
use serde_json::{json, Value};
use std::sync::Arc;
use crate::{JavelinClient, ProxyConfig};

/// Unified validation service that handles all request/response validation
pub struct ValidationService {
    javelin_client: Arc<JavelinClient>,
    config: ProxyConfig,
}

/// Validation result with detailed information
#[derive(Debug, Clone)]
pub struct ValidationResult {
    pub allowed: bool,
    pub reason: Option<String>,
    pub confidence: Option<f64>,
    pub request_id: String,
    pub timestamp: String,
}

/// Validation error with proper JSON-RPC formatting
#[derive(Debug)]
pub struct ValidationError {
    pub code: i32,
    pub message: String,
    pub data: Option<Value>,
}

impl ValidationService {
    pub fn new(javelin_client: Arc<JavelinClient>, config: ProxyConfig) -> Self {
        Self {
            javelin_client,
            config,
        }
    }

    /// Validate a request with consistent error handling
    pub async fn validate_request(&self, request: &Value) -> Result<ValidationResult> {
        debug!("Validating request with unified validation service");

        let request_id = uuid::Uuid::new_v4().to_string();
        let timestamp = chrono::Utc::now().to_rfc3339();

        match self.javelin_client.validate_request(request).await {
            Ok(is_valid) => {
                let result = ValidationResult {
                    allowed: is_valid,
                    reason: if is_valid {
                        Some("Request approved by Javelin Guardrails".to_string())
                    } else {
                        Some("Request blocked by Javelin Guardrails".to_string())
                    },
                    confidence: Some(if is_valid { 0.9 } else { 0.1 }),
                    request_id,
                    timestamp,
                };

                if is_valid {
                    info!("Request {} approved by validation service", result.request_id);
                } else {
                    warn!("Request {} blocked by validation service", result.request_id);
                }

                Ok(result)
            }
            Err(e) => {
                error!("Validation error for request {}: {}", request_id, e);

                // Apply fail-open/fail-closed policy
                let allowed = self.config.javelin.fail_open;
                let reason = if allowed {
                    format!("Validation service unavailable, failing open: {}", e)
                } else {
                    format!("Validation service unavailable, failing closed: {}", e)
                };

                if allowed {
                    warn!("Request {} allowed due to fail-open policy", request_id);
                } else {
                    error!("Request {} blocked due to fail-closed policy", request_id);
                }

                Ok(ValidationResult {
                    allowed,
                    reason: Some(reason),
                    confidence: Some(0.0),
                    request_id,
                    timestamp,
                })
            }
        }
    }

    /// Validate a response (optional, for response filtering)
    pub async fn validate_response(&self, response: &Value) -> Result<ValidationResult> {
        debug!("Validating response with unified validation service");

        // For responses, we might want different validation logic
        // For now, reuse the same validation but with different logging
        let mut result = self.validate_request(response).await?;
        
        // Update the reason to indicate this was response validation
        if let Some(ref mut reason) = result.reason {
            *reason = reason.replace("Request", "Response");
        }

        Ok(result)
    }

    /// Create a JSON-RPC error response for blocked requests
    pub fn create_blocked_response(&self, original_request: &Value, validation_result: &ValidationResult) -> Value {
        json!({
            "jsonrpc": "2.0",
            "id": original_request.get("id"),
            "error": {
                "code": -32600,
                "message": "Request blocked by Javelin Guardrails",
                "data": {
                    "reason": validation_result.reason,
                    "confidence": validation_result.confidence,
                    "request_id": validation_result.request_id,
                    "timestamp": validation_result.timestamp,
                    "blocked_by": "ramparts-proxy"
                }
            }
        })
    }

    /// Create a JSON-RPC error response for validation failures
    pub fn create_error_response(&self, original_request: &Value, error_message: &str) -> Value {
        json!({
            "jsonrpc": "2.0",
            "id": original_request.get("id"),
            "error": {
                "code": -32603,
                "message": "Internal validation error",
                "data": {
                    "error": error_message,
                    "timestamp": chrono::Utc::now().to_rfc3339(),
                    "service": "ramparts-proxy"
                }
            }
        })
    }

    /// Validate and handle request with automatic error response generation
    pub async fn validate_and_handle(&self, request: &Value) -> Result<ValidationResult, Value> {
        match self.validate_request(request).await {
            Ok(result) => {
                if result.allowed {
                    Ok(result)
                } else {
                    Err(self.create_blocked_response(request, &result))
                }
            }
            Err(e) => {
                error!("Validation service error: {}", e);
                Err(self.create_error_response(request, &e.to_string()))
            }
        }
    }

    /// Get validation service health status
    pub async fn health_check(&self) -> Result<bool> {
        self.javelin_client.health_check().await
    }

    /// Get cache statistics from the underlying client
    pub async fn cache_stats(&self) -> crate::cache::CacheStats {
        self.javelin_client.cache_stats().await
    }

    /// Clear validation cache
    pub async fn clear_cache(&self) {
        self.javelin_client.clear_cache().await;
    }
}

/// Helper function to extract request ID from JSON-RPC request
pub fn extract_request_id(request: &Value) -> Option<Value> {
    request.get("id").cloned()
}

/// Helper function to check if a request is a JSON-RPC request
pub fn is_jsonrpc_request(request: &Value) -> bool {
    request.get("jsonrpc").and_then(|v| v.as_str()) == Some("2.0")
}

/// Helper function to create a success response
pub fn create_success_response(request_id: Option<Value>, result: Value) -> Value {
    json!({
        "jsonrpc": "2.0",
        "id": request_id,
        "result": result
    })
}
