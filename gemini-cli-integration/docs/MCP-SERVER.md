# 🔧 MCP Server Integration

The Ramparts MCP Server provides advanced integration with Gemini CLI and other MCP-compatible clients through standardized tools and prompts. This integration offers more sophisticated features than TOML commands, including parameterized prompts, structured tool calls, and enhanced AI understanding.

## 🎯 Overview

The MCP Server integration provides:

- **📋 Prompts as Slash Commands**: Parameterized commands with structured arguments
- **🔧 Direct Tool Access**: Programmatic access to Ramparts functionality  
- **🧠 Enhanced AI Context**: Deeper integration with AI reasoning and analysis
- **🔄 Standardized Protocol**: Works with any MCP-compatible client
- **📊 Structured Responses**: Consistent, parseable output formats

## 🚀 Quick Start

### Installation

```bash
# Install globally
npm install -g ramparts-mcp-server

# Or use the installer script
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/install-mcp-server.sh | bash
```

### Configuration

Add to your Gemini CLI configuration (`~/.gemini/settings.json`):

```json
{
  "mcpServers": {
    "ramparts": {
      "command": "npx",
      "args": ["-y", "ramparts-mcp-server"],
      "env": {
        "RAMPARTS_PORT": "3001",
        "RAMPARTS_TIMEOUT": "180"
      }
    }
  }
}
```

### First Use

```bash
gemini
> /security-scan --url="https://api.example.com/mcp/" --detailed=true
> Use ramparts_health_check tool
```

## 📋 MCP Prompts (Slash Commands)

MCP prompts automatically become slash commands in Gemini CLI with full parameter support.

### `/security-scan`

**Purpose**: Parameterized security scanning with intelligent analysis

**Parameters**:
- `--url` (required): MCP server URL to scan
- `--detailed` (optional): Enable detailed analysis (default: true)
- `--report` (optional): Generate markdown report (default: false)

**Usage**:
```bash
> /security-scan --url="https://api.githubcopilot.com/mcp/"
> /security-scan --url="stdio:npx:mcp-server" --detailed=true --report=true
> /security-scan --url="http://localhost:3000/mcp" --report=false
```

**AI Enhancement**: Gemini uses this prompt to:
- Execute structured security scans with specified parameters
- Provide intelligent analysis of scan results
- Suggest specific remediation steps based on findings
- Offer security best practices tailored to the target

### `/security-audit`

**Purpose**: Comprehensive security audit with configurable scope

**Parameters**:
- `--scope` (optional): "project" or "global" (default: project)
- `--report` (optional): Generate audit report (default: true)

**Usage**:
```bash
> /security-audit
> /security-audit --scope="global" --report=true
> /security-audit --scope="project" --report=false
```

**AI Enhancement**: Gemini performs:
- Multi-phase security audit workflow
- Risk prioritization and categorization
- Executive summary generation
- Compliance assessment and gap analysis
- Remediation roadmap creation

### `/security-check`

**Purpose**: Quick security health assessment

**Parameters**:
- `--target` (optional): "config", "all", or specific URL (default: config)

**Usage**:
```bash
> /security-check
> /security-check --target="config"
> /security-check --target="all"
> /security-check --target="https://api.example.com/mcp/"
```

**AI Enhancement**: Provides:
- Rapid security status assessment
- Clear security indicators (Secure/Caution/Urgent)
- Immediate action recommendations
- Next steps based on findings

### `/security-monitor`

**Purpose**: Set up continuous security monitoring

**Parameters**:
- `--interval` (optional): Monitoring interval in minutes (default: 60)
- `--alert_on` (optional): Alert threshold - "critical", "high", "medium", "all" (default: high)

**Usage**:
```bash
> /security-monitor
> /security-monitor --interval=30 --alert_on="critical"
> /security-monitor --interval=120 --alert_on="high"
```

**AI Enhancement**: Helps establish:
- Automated monitoring strategies
- Alert configuration and thresholds
- Integration with existing systems
- Incident response workflows

### `/vulnerability-analysis`

**Purpose**: Deep analysis of specific security vulnerabilities

**Parameters**:
- `--vulnerability` (required): Vulnerability to analyze
- `--context` (optional): Additional context about the vulnerability

**Usage**:
```bash
> /vulnerability-analysis --vulnerability="SQL Injection"
> /vulnerability-analysis --vulnerability="Path Traversal" --context="MCP file tool"
> /vulnerability-analysis --vulnerability="XSS" --context="Web-based MCP server"
```

**AI Enhancement**: Provides:
- CVE/CWE identification and CVSS scoring
- Exploitation scenario analysis
- Technical and business impact assessment
- Step-by-step remediation guidance
- Prevention strategies

### `/compliance-check`

**Purpose**: Security compliance assessment against industry standards

**Parameters**:
- `--standard` (optional): "owasp", "nist", "iso27001", "soc2", "pci" (default: owasp)
- `--scope` (optional): "all", "critical-only", "specific-component" (default: all)

**Usage**:
```bash
> /compliance-check
> /compliance-check --standard="owasp" --scope="all"
> /compliance-check --standard="nist" --scope="critical-only"
> /compliance-check --standard="soc2"
```

**AI Enhancement**: Delivers:
- Standards mapping and control assessment
- Compliance gap analysis
- Risk assessment of non-compliance
- Remediation timeline and priorities

## 🔧 MCP Tools

Direct programmatic access to Ramparts functionality through standardized tool interfaces.

### `ramparts_scan`

**Purpose**: Scan a single MCP server

**Parameters**:
```json
{
  "url": "string (required)",
  "timeout": "number (default: 180)",
  "http_timeout": "number (default: 30)",
  "detailed": "boolean (default: true)",
  "auth_headers": "object (optional)"
}
```

**Usage in Gemini CLI**:
```bash
> Use ramparts_scan tool with url="https://api.example.com/mcp/" and detailed=true
```

**Response Format**:
```json
{
  "server_info": {
    "name": "Server Name",
    "url": "https://api.example.com/mcp/",
    "scan_time": "2024-01-01T12:00:00Z"
  },
  "summary": {
    "tools_count": 25,
    "resources_count": 5,
    "prompts_count": 3,
    "security_findings_count": 2
  },
  "security_findings": [
    {
      "severity": "HIGH",
      "title": "Path Traversal Vulnerability",
      "component_type": "tool",
      "component_name": "file_reader",
      "description": "Tool accepts path parameter without validation",
      "recommendation": "Implement path validation and sanitization"
    }
  ]
}
```

### `ramparts_scan_config`

**Purpose**: Scan MCP servers from IDE configurations

**Parameters**:
```json
{
  "timeout": "number (default: 180)",
  "http_timeout": "number (default: 30)",
  "detailed": "boolean (default: true)",
  "auth_headers": "object (optional)"
}
```

**Usage**:
```bash
> Use ramparts_scan_config tool with detailed=true
```

**Discovery Process**:
- Finds MCP configurations in IDE settings files
- Supports Cursor, VS Code, Claude Desktop, Windsurf
- Scans each discovered server individually
- Aggregates results across all configurations

### `ramparts_batch_scan`

**Purpose**: Scan multiple MCP servers in parallel

**Parameters**:
```json
{
  "urls": "array of strings (required)",
  "timeout": "number (default: 180)",
  "http_timeout": "number (default: 30)",
  "detailed": "boolean (default: true)",
  "auth_headers": "object (optional)"
}
```

**Usage**:
```bash
> Use ramparts_batch_scan tool with urls=["https://server1.com/mcp/", "https://server2.com/mcp/"]
```

**Features**:
- Parallel scanning for efficiency
- Individual result tracking per server
- Aggregated security assessment
- Failure handling per server

### `ramparts_health_check`

**Purpose**: Check Ramparts service status

**Parameters**: None

**Usage**:
```bash
> Use ramparts_health_check tool
```

**Response**:
```json
{
  "status": "healthy",
  "version": "0.6.9",
  "protocol_version": "2025-06-18",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

### `ramparts_get_capabilities`

**Purpose**: Get Ramparts capabilities and protocol information

**Parameters**: None

**Usage**:
```bash
> Use ramparts_get_capabilities tool
```

**Response**:
```json
{
  "protocol": {
    "version": "2025-06-18",
    "transport": {
      "http": "supported",
      "stdio": "supported"
    },
    "capabilities": ["tools/list", "resources/list", "prompts/list"]
  },
  "server": {
    "version": "0.6.9",
    "stdio_support": true,
    "mcp_compliance": "2025-06-18"
  }
}
```

## 🧠 AI Integration Benefits

### Enhanced Context Understanding

The MCP server provides structured data that helps AI understand:

- **Security Context**: What vulnerabilities mean and their implications
- **Remediation Strategies**: How to fix specific security issues
- **Risk Assessment**: How to prioritize security findings
- **Compliance Requirements**: What standards apply and how to meet them

### Intelligent Analysis

AI can perform sophisticated analysis:

**Pattern Recognition**:
```bash
> Use ramparts_batch_scan tool with multiple servers
# AI recognizes common vulnerability patterns across servers
# Suggests systematic fixes for recurring issues
```

**Contextual Recommendations**:
```bash
> /vulnerability-analysis --vulnerability="Command Injection" --context="Python MCP server"
# AI provides Python-specific remediation guidance
# Includes code examples and security libraries
```

**Risk Correlation**:
```bash
> /security-audit --scope="global"
# AI correlates findings across different servers
# Identifies systemic security issues
# Suggests architectural improvements
```

### Workflow Integration

**Automated Workflows**:
```bash
# AI can chain multiple operations intelligently
> /security-check --target="config"
# If issues found, AI automatically suggests:
> /security-scan --url="problematic-server" --detailed=true
# Then provides specific remediation guidance
```

## 🔧 Configuration

### Environment Variables

Configure the MCP server behavior:

```bash
# Server configuration
export RAMPARTS_PORT=3001
export RAMPARTS_TIMEOUT=180
export RAMPARTS_HTTP_TIMEOUT=30

# Authentication
export RAMPARTS_AUTH_CACHE=/path/to/auth/cache

# Debug mode
export DEBUG=ramparts-mcp-server
```

### Gemini CLI Integration

**Basic Configuration**:
```json
{
  "mcpServers": {
    "ramparts": {
      "command": "npx",
      "args": ["-y", "ramparts-mcp-server"]
    }
  }
}
```

**Advanced Configuration**:
```json
{
  "mcpServers": {
    "ramparts": {
      "command": "ramparts-mcp-server",
      "env": {
        "RAMPARTS_PORT": "3001",
        "RAMPARTS_TIMEOUT": "300",
        "RAMPARTS_HTTP_TIMEOUT": "60",
        "DEBUG": "ramparts-mcp-server"
      },
      "timeout": 60000
    }
  }
}
```

**Local Development**:
```json
{
  "mcpServers": {
    "ramparts": {
      "command": "node",
      "args": ["/path/to/ramparts-mcp-server/dist/index.js"],
      "cwd": "/path/to/ramparts-mcp-server"
    }
  }
}
```

## 🚨 Troubleshooting

### Common Issues

**MCP server not starting**:
```bash
# Check if package is installed
npm list -g ramparts-mcp-server

# Test server directly
npx ramparts-mcp-server

# Check Gemini CLI configuration
cat ~/.gemini/settings.json
```

**Ramparts not found**:
```bash
# Install Ramparts
cargo install ramparts

# Verify installation
ramparts --version

# Check PATH
which ramparts
```

**Connection timeouts**:
```bash
# Increase timeout in configuration
{
  "mcpServers": {
    "ramparts": {
      "timeout": 120000,  // 2 minutes
      "env": {
        "RAMPARTS_TIMEOUT": "300"
      }
    }
  }
}
```

**Tool execution errors**:
```bash
# Enable debug mode
export DEBUG=ramparts-mcp-server
gemini

# Check Ramparts server logs
ramparts server --port 3001 --host 127.0.0.1
```

### Debug Mode

Enable comprehensive debugging:

```bash
# Environment variable
export DEBUG=ramparts-mcp-server

# Or in Gemini CLI config
{
  "mcpServers": {
    "ramparts": {
      "env": {
        "DEBUG": "ramparts-mcp-server"
      }
    }
  }
}
```

### Health Checks

Verify system health:

```bash
# Check MCP server
> Use ramparts_health_check tool

# Check Ramparts backend
> Use ramparts_get_capabilities tool

# Test basic scanning
> /security-check --target="config"
```

## 🔄 Development

### Local Development Setup

```bash
# Clone repository
git clone https://github.com/getjavelin/ramparts.git
cd ramparts/gemini-cli-integration/mcp-server

# Install dependencies
npm install

# Build
npm run build

# Test
npm run test

# Development mode
npm run dev
```

### Custom MCP Server

Extend the server with custom functionality:

```typescript
// src/custom-tools.ts
export const customTools = [
  {
    name: "custom_security_check",
    description: "Custom security validation",
    inputSchema: {
      type: "object",
      properties: {
        target: { type: "string" },
        rules: { type: "array" }
      }
    }
  }
];

// Add to main server
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  
  if (name === "custom_security_check") {
    return await handleCustomCheck(args);
  }
  // ... existing handlers
});
```

### Testing

```bash
# Unit tests
npm test

# Integration tests
npm run test:integration

# Manual testing
echo '{"method": "tools/list"}' | node dist/index.js
```

## 📊 Performance

### Optimization Tips

**Server Performance**:
- Use local Ramparts installation for faster startup
- Configure appropriate timeouts for your environment
- Enable connection pooling for batch operations

**Scan Performance**:
- Use batch scanning for multiple servers
- Configure optimal timeout values
- Cache authentication tokens when possible

**Memory Management**:
- The MCP server automatically manages Ramparts process lifecycle
- Large scan results are streamed to avoid memory issues
- Connection cleanup happens automatically

### Monitoring

Track MCP server performance:

```bash
# Process monitoring
ps aux | grep ramparts-mcp-server

# Resource usage
top -p $(pgrep -f ramparts-mcp-server)

# Connection status
netstat -tulpn | grep :3001
```

## 🔗 Integration Examples

### CI/CD Integration

```yaml
# .github/workflows/security-scan.yml
name: MCP Security Scan
on:
  pull_request:
    paths: ['.gemini/settings.json']

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install Ramparts MCP Server
        run: npm install -g ramparts-mcp-server
      
      - name: Install Ramparts
        run: cargo install ramparts
      
      - name: Run Security Scan
        run: |
          # Use MCP server programmatically
          echo '{"method": "tools/call", "params": {"name": "ramparts_scan_config", "arguments": {"detailed": true}}}' | \
          npx ramparts-mcp-server
```

### Monitoring Integration

```javascript
// monitoring/ramparts-monitor.js
const { spawn } = require('child_process');

async function monitorSecurity() {
  const server = spawn('ramparts-mcp-server');
  
  // Send scan request
  server.stdin.write(JSON.stringify({
    method: 'tools/call',
    params: {
      name: 'ramparts_scan_config',
      arguments: { detailed: true }
    }
  }));
  
  // Process results
  server.stdout.on('data', (data) => {
    const result = JSON.parse(data.toString());
    if (result.security_findings?.length > 0) {
      // Send alert
      sendSecurityAlert(result);
    }
  });
}
```

## 🔗 Related Documentation

- [TOML Commands](TOML-COMMANDS.md) - Simpler slash command integration
- [Installation Guide](README.md) - Complete setup instructions
- [Configuration Reference](CONFIGURATION.md) - Detailed configuration options
- [API Reference](API-REFERENCE.md) - Complete API documentation

---

**The MCP Server integration provides the most powerful and flexible way to integrate Ramparts with AI-powered development workflows. 🔧✨**