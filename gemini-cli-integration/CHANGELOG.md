# Changelog

All notable changes to the Ramparts × Gemini CLI Integration will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added
- **Initial release** of Ramparts × Gemini CLI integration
- **TOML-based slash commands** for immediate security scanning
- **MCP server integration** with advanced prompts and tools
- **Comprehensive documentation** with usage examples
- **Installation scripts** for automated setup
- **Docker support** for containerized deployment
- **Makefile** with development and deployment targets

#### TOML Slash Commands
- `/ramparts-scan <url>` - Scan specific MCP server for vulnerabilities
- `/ramparts-audit` - Comprehensive security audit of all MCP servers
- `/ramparts-quick [target]` - Quick security health check
- `/security:scan <target>` - Advanced security scanning with detailed analysis
- `/security:monitor` - Set up continuous security monitoring

#### MCP Server Features
- **Parameterized prompts** as slash commands (`/security-scan --url="..."`)
- **Direct tool access** (`ramparts_scan`, `ramparts_batch_scan`, etc.)
- **Health checking** and capability discovery
- **Structured response formats** for AI analysis

#### Security Capabilities
- **11+ vulnerability types** detected
- **Compliance assessment** (OWASP, NIST, SOC 2, GDPR, HIPAA)
- **Risk prioritization** with CVSS scoring
- **Remediation guidance** with step-by-step instructions
- **Continuous monitoring** with automated alerts

#### Installation & Distribution
- **One-line installation** script
- **Modular installation** (commands-only or MCP-only)
- **Validation script** to verify installation
- **Docker containers** for easy deployment
- **CI/CD integration** examples

#### Documentation
- **Complete user guide** with installation and usage
- **TOML commands reference** with examples
- **MCP server documentation** with API reference
- **Real-world use cases** and workflow examples
- **Sample configurations** for different scenarios

#### Developer Experience
- **Make targets** for common operations
- **Interactive demo** workflow
- **Comprehensive validation** and testing
- **Clean uninstallation** process

### Technical Details
- **Node.js 18+** support for MCP server
- **TypeScript** implementation with proper type safety
- **Zod validation** for request parameters
- **Axios** for HTTP client functionality
- **Model Context Protocol SDK** integration
- **Shell script** automation for cross-platform support

### Supported Platforms
- **macOS** (Darwin)
- **Linux** (Ubuntu, CentOS, etc.)
- **Windows** (via WSL or PowerShell)
- **Docker** containers

### Integration Points
- **Gemini CLI** native slash command integration
- **IDE configurations** automatic discovery (Cursor, VS Code, Claude Desktop)
- **CI/CD pipelines** (GitHub Actions, GitLab CI)
- **Monitoring systems** (Prometheus, Grafana, SIEM)
- **Compliance frameworks** (SOC 2, GDPR, HIPAA, PCI DSS)

---

## Future Releases

### [1.1.0] - Planned
- Enhanced vulnerability detection rules
- Additional compliance framework support
- Improved AI analysis and recommendations
- Performance optimizations
- Extended IDE support

### [1.2.0] - Planned  
- Real-time vulnerability feeds
- Advanced threat modeling capabilities
- Integration with security orchestration platforms
- Enhanced reporting and dashboards
- Multi-language support

---

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) in the main repository for contribution guidelines.

## Support

- **Issues**: [GitHub Issues](https://github.com/getjavelin/ramparts/issues)
- **Documentation**: [docs/](docs/)
- **Examples**: [examples/](examples/)
- **Discussions**: [GitHub Discussions](https://github.com/getjavelin/ramparts/discussions)