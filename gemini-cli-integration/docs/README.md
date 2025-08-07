# 🛡️ Ramparts × Gemini CLI Integration

Transform your AI-powered development workflow with native security scanning capabilities. This integration brings Ramparts MCP security scanning directly into Gemini CLI through custom slash commands and MCP server integration.

## 🚀 Quick Start

### One-Line Installation
```bash
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/setup-complete-integration.sh | bash
```

### Manual Installation
```bash
# Install TOML slash commands
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/install-slash-commands.sh | bash

# Install MCP server integration
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/install-mcp-server.sh | bash
```

## 🎯 What You Get

### 📋 TOML-Based Slash Commands
Immediate, zero-dependency security commands for Gemini CLI:

- **`/ramparts-scan <url>`** - Scan specific MCP server for vulnerabilities
- **`/ramparts-audit`** - Comprehensive security audit of all MCP servers  
- **`/ramparts-quick [target]`** - Quick security health check
- **`/security:scan <target>`** - Advanced security scanning with detailed analysis
- **`/security:monitor`** - Set up continuous security monitoring

### 🔧 MCP Server Integration
Advanced integration with prompts and tools:

- **Prompts as Slash Commands**: `/security-scan --url="..." --detailed=true`
- **Tool Integration**: Direct access to `ramparts_scan`, `ramparts_batch_scan`, etc.
- **Smart AI Analysis**: Gemini understands security context and provides intelligent recommendations

## 🌟 Key Features

### ✨ Native Integration
- Commands appear as **built-in Gemini CLI features**
- **Tab completion** and help system integration
- **Consistent UX** with other Gemini CLI commands

### 🧠 AI-Powered Security Analysis
- Gemini **understands security context** through intelligent prompts
- **Analyzes scan results** and provides actionable recommendations
- **Combines multiple scans** intelligently based on context
- **Suggests follow-up actions** based on findings

### 🔄 Dual Integration Approach
- **TOML Commands**: Immediate use, no dependencies
- **MCP Server**: Advanced features with prompts and tools
- **Works together**: Commands complement each other seamlessly

## 📖 Usage Examples

### Basic Security Scanning

```bash
# Start Gemini CLI
gemini

# Quick security check of IDE configurations
> /ramparts-quick config

# Scan a specific MCP server
> /ramparts-scan https://api.githubcopilot.com/mcp/

# Comprehensive security audit
> /ramparts-audit
```

### Advanced MCP Integration

```bash
# Use MCP prompts with parameters
> /security-scan --url="https://api.example.com/mcp/" --report=true

# Compliance checking
> /compliance-check --standard="owasp"

# Vulnerability analysis
> /vulnerability-analysis --vulnerability="Path Traversal"
```

### Real-World Workflow

```bash
# 1. Quick health check
> /ramparts-quick config
✅ SECURE - No significant issues found

# 2. Detailed scan of specific server
> /ramparts-scan https://new-mcp-server.com/mcp/
🚨 CRITICAL: Command injection vulnerability found!

# 3. Get remediation guidance
> /vulnerability-analysis --vulnerability="Command Injection" --context="MCP tool parameter"

# 4. Set up monitoring after fixes
> /security:monitor --interval=30 --alert_on="high"
```

## 🛠️ Installation Guide

### Prerequisites

- **Node.js 18+** - Required for MCP server
- **Gemini CLI** - Install with `npm install -g @google/gemini-cli`
- **Ramparts** - Install with `cargo install ramparts`

### Installation Methods

#### Method 1: Complete Setup (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/setup-complete-integration.sh | bash
```

This installs:
- ✅ TOML slash commands
- ✅ MCP server integration  
- ✅ Gemini CLI configuration
- ✅ Demo and example files

#### Method 2: TOML Commands Only
```bash
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/install-slash-commands.sh | bash --user
```

For project-specific commands:
```bash
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/install-slash-commands.sh | bash --project
```

#### Method 3: MCP Server Only
```bash
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/install-mcp-server.sh | bash
```

#### Method 4: Manual Installation

**TOML Commands:**
```bash
# Create commands directory
mkdir -p ~/.gemini/commands/security

# Download command files
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/slash-commands/ramparts-scan.toml -o ~/.gemini/commands/ramparts-scan.toml
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/slash-commands/ramparts-audit.toml -o ~/.gemini/commands/ramparts-audit.toml
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/slash-commands/ramparts-quick.toml -o ~/.gemini/commands/ramparts-quick.toml
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/slash-commands/security/scan.toml -o ~/.gemini/commands/security/scan.toml
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/slash-commands/security/monitor.toml -o ~/.gemini/commands/security/monitor.toml
```

**MCP Server:**
```bash
# Install the package
npm install -g ramparts-mcp-server

# Add to Gemini CLI configuration (~/.gemini/settings.json)
{
  "mcpServers": {
    "ramparts": {
      "command": "npx",
      "args": ["-y", "ramparts-mcp-server"],
      "env": {
        "RAMPARTS_PORT": "3001"
      }
    }
  }
}
```

## 📚 Command Reference

### TOML Slash Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `/ramparts-scan` | Scan specific MCP server | `/ramparts-scan https://api.example.com/mcp/` |
| `/ramparts-audit` | Comprehensive security audit | `/ramparts-audit` |
| `/ramparts-quick` | Quick security check | `/ramparts-quick config` |
| `/security:scan` | Advanced security scanning | `/security:scan https://api.example.com/mcp/` |
| `/security:monitor` | Setup monitoring | `/security:monitor` |

### MCP Prompts (Slash Commands)

| Command | Description | Parameters |
|---------|-------------|------------|
| `/security-scan` | Scan with parameters | `--url`, `--detailed`, `--report` |
| `/security-audit` | Audit with scope | `--scope`, `--report` |
| `/security-check` | Quick check | `--target` |
| `/security-monitor` | Setup monitoring | `--interval`, `--alert_on` |
| `/vulnerability-analysis` | Analyze vulnerability | `--vulnerability`, `--context` |
| `/compliance-check` | Compliance assessment | `--standard`, `--scope` |

### MCP Tools

| Tool | Description | Parameters |
|------|-------------|------------|
| `ramparts_scan` | Scan single server | `url`, `timeout`, `detailed`, `auth_headers` |
| `ramparts_scan_config` | Scan IDE configs | `timeout`, `detailed`, `auth_headers` |
| `ramparts_batch_scan` | Batch scan servers | `urls`, `timeout`, `detailed`, `auth_headers` |
| `ramparts_health_check` | Check service health | None |
| `ramparts_get_capabilities` | Get capabilities | None |

## 🔧 Configuration

### Environment Variables

- **`RAMPARTS_PORT`** - Port for Ramparts server (default: 3001)
- **`RAMPARTS_TIMEOUT`** - Scan timeout in seconds (default: 180)
- **`RAMPARTS_HTTP_TIMEOUT`** - HTTP timeout in seconds (default: 30)

### Gemini CLI Configuration

The integration automatically configures your `~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "ramparts": {
      "command": "npx",
      "args": ["-y", "ramparts-mcp-server"],
      "env": {
        "RAMPARTS_PORT": "3001",
        "RAMPARTS_TIMEOUT": "180",
        "RAMPARTS_HTTP_TIMEOUT": "30"
      }
    }
  }
}
```

### Team Configuration

For team sharing, commit TOML commands to your repository:

```bash
# Project-level commands
mkdir -p .gemini/commands
# Copy command files to .gemini/commands/
git add .gemini/commands/
git commit -m "Add Ramparts security commands"
```

Team members can then use the commands immediately after cloning.

## 🧪 Testing Your Installation

### Quick Test
```bash
gemini
> /ramparts-quick config
```

### Full Test Suite
```bash
# Test TOML commands
> /ramparts-scan --help
> /ramparts-audit --help

# Test MCP integration (if installed)
> /security-check --target="config"

# Test tools (if MCP server installed)
> Use ramparts_health_check tool
```

## 🚨 Troubleshooting

### Common Issues

**"Command not found" errors:**
- Ensure commands are in `~/.gemini/commands/` or `.gemini/commands/`
- Restart Gemini CLI after installation
- Check file permissions: `chmod +r ~/.gemini/commands/*.toml`

**"Ramparts not found" errors:**
- Install Ramparts: `cargo install ramparts`
- Verify installation: `ramparts --version`
- Ensure Ramparts is in your PATH

**MCP server connection issues:**
- Check Node.js version: `node --version` (requires 18+)
- Verify package installation: `npm list -g ramparts-mcp-server`
- Check Gemini CLI configuration: `~/.gemini/settings.json`

**Timeout errors:**
- Increase timeout values in configuration
- Check network connectivity to target MCP servers
- Verify MCP server is accessible

### Debug Mode

Enable debug logging:
```bash
# For TOML commands (shows in Gemini CLI output)
> /ramparts-scan https://api.example.com/mcp/

# For MCP server (check logs)
DEBUG=ramparts-mcp-server gemini
```

### Getting Help

1. **Check documentation**: This README and `/docs` directory
2. **Run diagnostics**: Use `/ramparts-quick config` for quick health check
3. **Check logs**: Gemini CLI shows detailed error messages
4. **GitHub Issues**: [Report issues](https://github.com/getjavelin/ramparts/issues)

## 🔄 Updating

### Update TOML Commands
```bash
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/install-slash-commands.sh | bash --update
```

### Update MCP Server
```bash
npm update -g ramparts-mcp-server
```

### Complete Update
```bash
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/setup-complete-integration.sh | bash
```

## 🗑️ Uninstalling

### Remove TOML Commands
```bash
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/install-slash-commands.sh | bash --uninstall
```

### Remove MCP Server
```bash
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/install-mcp-server.sh | bash --uninstall
```

### Manual Removal
```bash
# Remove TOML commands
rm -rf ~/.gemini/commands/ramparts-*.toml
rm -rf ~/.gemini/commands/security/

# Remove MCP server
npm uninstall -g ramparts-mcp-server

# Remove from Gemini config (edit ~/.gemini/settings.json)
# Remove the "ramparts" entry from mcpServers
```

## 🤝 Contributing

We welcome contributions! See the [main Ramparts repository](https://github.com/getjavelin/ramparts) for contribution guidelines.

### Development Setup

```bash
git clone https://github.com/getjavelin/ramparts.git
cd ramparts
git checkout feature/gemini-cli-integration
cd gemini-cli-integration
```

## 📄 License

Apache 2.0 - See [LICENSE](../LICENSE) file for details.

## 🔗 Links

- **Main Repository**: https://github.com/getjavelin/ramparts
- **Ramparts Documentation**: https://github.com/getjavelin/ramparts#readme
- **Gemini CLI**: https://github.com/google-gemini/gemini-cli
- **Model Context Protocol**: https://modelcontextprotocol.io/
- **Issues & Support**: https://github.com/getjavelin/ramparts/issues

---

**Transform your AI development workflow with security-first practices. Happy secure coding! 🛡️✨**