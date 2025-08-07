import { Tool } from "@modelcontextprotocol/sdk/types.js";

export async function setupTools(): Promise<Tool[]> {
  return [
    {
      name: "ramparts_scan",
      description: "Scan a single MCP server for security vulnerabilities using Ramparts. This tool performs comprehensive security analysis including tool poisoning, path traversal, command injection, SQL injection, cross-origin escalation, secrets leakage, and other security issues.",
      inputSchema: {
        type: "object",
        properties: {
          url: {
            type: "string",
            description: "MCP server URL to scan (e.g., 'https://api.example.com/mcp', 'http://localhost:3000', or 'stdio:npx:mcp-server-commands')",
          },
          timeout: {
            type: "number",
            description: "Scan timeout in seconds (default: 180)",
            default: 180,
          },
          http_timeout: {
            type: "number", 
            description: "HTTP request timeout in seconds (default: 30)",
            default: 30,
          },
          detailed: {
            type: "boolean",
            description: "Enable detailed analysis and reporting (default: true)",
            default: true,
          },
          auth_headers: {
            type: "object",
            description: "Authentication headers for the MCP server (e.g., {'Authorization': 'Bearer token', 'X-API-Key': 'key'})",
            additionalProperties: {
              type: "string"
            },
          },
        },
        required: ["url"],
      },
    },
    {
      name: "ramparts_scan_config",
      description: "Scan MCP servers from IDE configuration files (Cursor, VS Code, Claude Desktop, etc.). This automatically discovers and scans all MCP servers configured in your development environment.",
      inputSchema: {
        type: "object",
        properties: {
          timeout: {
            type: "number",
            description: "Scan timeout in seconds (default: 180)",
            default: 180,
          },
          http_timeout: {
            type: "number",
            description: "HTTP request timeout in seconds (default: 30)", 
            default: 30,
          },
          detailed: {
            type: "boolean",
            description: "Enable detailed analysis and reporting (default: true)",
            default: true,
          },
          auth_headers: {
            type: "object",
            description: "Authentication headers for the MCP servers",
            additionalProperties: {
              type: "string"
            },
          },
        },
        required: [],
      },
    },
    {
      name: "ramparts_batch_scan",
      description: "Scan multiple MCP servers in parallel for security vulnerabilities. Useful for auditing multiple servers or endpoints at once.",
      inputSchema: {
        type: "object",
        properties: {
          urls: {
            type: "array",
            items: {
              type: "string"
            },
            description: "Array of MCP server URLs to scan",
          },
          timeout: {
            type: "number",
            description: "Scan timeout in seconds (default: 180)",
            default: 180,
          },
          http_timeout: {
            type: "number",
            description: "HTTP request timeout in seconds (default: 30)",
            default: 30,
          },
          detailed: {
            type: "boolean", 
            description: "Enable detailed analysis and reporting (default: true)",
            default: true,
          },
          auth_headers: {
            type: "object",
            description: "Authentication headers for the MCP servers",
            additionalProperties: {
              type: "string"
            },
          },
        },
        required: ["urls"],
      },
    },
    {
      name: "ramparts_validate_config",
      description: "Validate scan configuration parameters before running a scan. Useful for checking if your scan parameters are valid.",
      inputSchema: {
        type: "object",
        properties: {
          url: {
            type: "string",
            description: "MCP server URL to validate",
          },
          timeout: {
            type: "number",
            description: "Scan timeout in seconds",
          },
          http_timeout: {
            type: "number",
            description: "HTTP request timeout in seconds",
          },
          auth_headers: {
            type: "object",
            description: "Authentication headers to validate",
            additionalProperties: {
              type: "string"
            },
          },
        },
        required: [],
      },
    },
    {
      name: "ramparts_health_check",
      description: "Check if the Ramparts security scanner service is running and available. Returns service status and version information.",
      inputSchema: {
        type: "object",
        properties: {},
        required: [],
      },
    },
    {
      name: "ramparts_get_capabilities",
      description: "Get information about Ramparts capabilities, supported protocols, and available security checks. Useful for understanding what Ramparts can scan and detect.",
      inputSchema: {
        type: "object",
        properties: {},
        required: [],
      },
    },
  ];
}