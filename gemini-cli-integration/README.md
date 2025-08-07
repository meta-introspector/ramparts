# 🛡️ Ramparts × Gemini CLI Integration

**Transform your AI-powered development workflow with native security scanning capabilities.**

This integration brings Ramparts MCP security scanning directly into Gemini CLI through custom slash commands and MCP server integration, making security scanning as natural as asking your AI assistant a question.

## 🚀 Quick Start

### One-Line Installation
```bash
curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/setup-complete-integration.sh | bash
```

### Or use Make
```bash
git clone https://github.com/getjavelin/ramparts.git
cd ramparts/gemini-cli-integration
make install
```

### Try It Out
```bash
gemini
> /ramparts-quick config
> /ramparts-scan https://api.example.com/mcp/
> /ramparts-audit
```

## ✨ What You Get

### 📋 TOML-Based Slash Commands
**Zero-dependency security commands for immediate use:**

- **`/ramparts-scan <url>`** - Scan specific MCP server for vulnerabilities
- **`/ramparts-audit`** - Comprehensive security audit of all MCP servers  
- **`/ramparts-quick [target]`** - Quick security health check
- **`/security:scan <target>`** - Advanced security scanning with detailed analysis
- **`/security:monitor`** - Set up continuous security monitoring

### 🔧 MCP Server Integration
**Advanced integration with prompts and tools:**

- **Parameterized Prompts**: `/security-scan --url="..." --detailed=true`
- **Direct Tool Access**: `ramparts_scan`, `ramparts_batch_scan`, `ramparts_health_check`
- **AI-Enhanced Analysis**: Gemini understands security context and provides intelligent recommendations

## 🌟 Key Benefits

- **🧠 AI-Powered Security**: Gemini analyzes scan results and provides actionable recommendations
- **⚡ Zero Friction**: Commands appear as built-in Gemini CLI features
- **🔄 Dual Approach**: TOML commands for simplicity + MCP server for advanced features
- **📊 Comprehensive Coverage**: From quick checks to deep compliance assessments
- **🔔 Continuous Monitoring**: Set up automated security scanning workflows

## 📖 Documentation

- **[Complete Guide](docs/README.md)** - Comprehensive documentation
- **[TOML Commands](docs/TOML-COMMANDS.md)** - Slash command reference
- **[MCP Server](docs/MCP-SERVER.md)** - Advanced integration guide
- **[Examples](examples/)** - Real-world usage examples

## 🛠️ Installation Options

### Complete Setup (Recommended)
```bash
make install          # Install everything
make validate         # Verify installation
make demo             # Run interactive demo
```

### Individual Components
```bash
make install-commands # TOML commands only
make install-mcp      # MCP server only
```

### Docker
```bash
make docker           # Run with Docker
```

## 🧪 Quick Demo

```bash
# Start Gemini CLI
gemini

# Quick security check
> /ramparts-quick config
✅ SECURE - No significant issues found

# Scan specific server  
> /ramparts-scan https://api.githubcopilot.com/mcp/
🚨 CRITICAL: Authentication bypass found!
⚠️ HIGH: Environment variable leakage detected

# Get detailed analysis
> /vulnerability-analysis --vulnerability="Authentication Bypass"
# Provides CVE details, exploitation scenarios, remediation steps

# Set up monitoring
> /security:monitor --interval=30 --alert_on="high"
# Creates automated monitoring with alerts
```

## 🔧 Available Commands

### Make Targets
```bash
make help             # Show all available commands
make install          # Complete installation
make test             # Run tests
make validate         # Validate installation
make demo             # Interactive demo
make docs             # Serve documentation
make docker           # Docker deployment
make clean            # Clean build artifacts
make uninstall        # Remove installation
```

### Security Commands (in Gemini CLI)
```bash
/ramparts-scan <url>     # Scan MCP server
/ramparts-audit          # Full security audit  
/ramparts-quick [target] # Quick security check
/security:scan <target>  # Advanced scanning
/security:monitor        # Setup monitoring
```

## 📊 What Gets Scanned

Ramparts detects **11+ types of security vulnerabilities** in MCP servers:

- **🚨 Critical**: Command injection, authentication bypass, path traversal
- **⚠️ High**: SQL injection, XSS, secrets leakage, privilege escalation
- **📋 Medium**: Input validation issues, information disclosure
- **ℹ️ Low**: Security best practice violations, hardening opportunities

## 🏢 Enterprise Features

- **Compliance Assessment**: OWASP, NIST, SOC 2, GDPR, HIPAA
- **CI/CD Integration**: GitHub Actions, GitLab CI, Jenkins
- **Monitoring & Alerting**: Automated scanning with notifications
- **Team Collaboration**: Shared security commands and workflows
- **Audit Trails**: Comprehensive security reporting and documentation

## 🤝 Contributing

We welcome contributions! See the [main repository](https://github.com/getjavelin/ramparts) for guidelines.

## 📄 License

Apache 2.0 - See [LICENSE](../LICENSE) file for details.

## 🔗 Links

- **[Main Repository](https://github.com/getjavelin/ramparts)**
- **[Ramparts Documentation](https://github.com/getjavelin/ramparts#readme)**
- **[Gemini CLI](https://github.com/google-gemini/gemini-cli)**
- **[Model Context Protocol](https://modelcontextprotocol.io/)**
- **[Issues & Support](https://github.com/getjavelin/ramparts/issues)**

---

**🛡️ Transform your AI development workflow with security-first practices. Happy secure coding! ✨**