# 📋 TOML-Based Slash Commands

TOML-based slash commands provide immediate, zero-dependency security scanning capabilities for Gemini CLI. These commands work by defining prompts in `.toml` files that Gemini CLI automatically recognizes and makes available as slash commands.

## 🎯 Overview

TOML commands are the **fastest way** to get Ramparts security scanning into your Gemini CLI workflow. They require no additional installations beyond copying `.toml` files to the right directory.

### How It Works

1. **Command Definition**: Each `.toml` file defines a command with description and prompt template
2. **Auto-Discovery**: Gemini CLI automatically finds and loads commands from `~/.gemini/commands/`
3. **Intelligent Execution**: Gemini uses the prompt template to understand context and execute appropriate actions
4. **AI Analysis**: Gemini analyzes security scan results and provides intelligent recommendations

## 📁 Command Structure

### File Locations

**User-level commands** (available in all projects):
```
~/.gemini/commands/
├── ramparts-scan.toml
├── ramparts-audit.toml
├── ramparts-quick.toml
└── security/
    ├── scan.toml
    └── monitor.toml
```

**Project-level commands** (specific to current project):
```
.gemini/commands/
├── ramparts-scan.toml
├── ramparts-audit.toml
└── ...
```

### Command Naming

- **File name** determines command name: `ramparts-scan.toml` → `/ramparts-scan`
- **Subdirectories** create namespaces: `security/scan.toml` → `/security:scan`
- **Case sensitive**: Command names match file names exactly

## 🔧 Available Commands

### `/ramparts-scan <url>`

**Purpose**: Scan a specific MCP server for security vulnerabilities

**Usage**:
```bash
> /ramparts-scan https://api.githubcopilot.com/mcp/
> /ramparts-scan stdio:npx:mcp-server-commands
> /ramparts-scan http://localhost:3000/mcp
```

**What it does**:
- Determines scan type based on URL format
- Executes appropriate Ramparts scan command
- Provides comprehensive security analysis
- Categorizes findings by severity (Critical/High/Medium/Low)
- Suggests immediate remediation steps
- Offers security best practices

**Example Output**:
```
🛡️ Ramparts Security Scan Results

Server: GitHub Copilot MCP Server
URL: https://api.githubcopilot.com/mcp/

📊 Scan Summary:
- Tools scanned: 83
- Resources scanned: 0
- Security findings: 2

🚨 Security Findings:

HIGH - Environment Variable Leakage
Component: tool - get_secret_scanning_alert
Description: Detects exposure of sensitive environment variables
Recommendation: Review tool implementation for proper data protection

🛡️ Security Recommendations:
1. Regular Scanning: Schedule periodic security scans
2. Monitor Changes: Set up alerts for configuration changes
3. Access Control: Implement proper authentication
```

### `/ramparts-audit`

**Purpose**: Comprehensive security audit of all MCP servers in your environment

**Usage**:
```bash
> /ramparts-audit
> /ramparts-audit global  # Audit all user configurations
```

**What it does**:
- Discovers all MCP configurations in your environment
- Scans each server individually
- Provides executive summary of security posture
- Creates risk prioritization matrix
- Generates remediation roadmap
- Offers compliance assessment
- Suggests monitoring and alerting strategies

**Audit Phases**:
1. **Environment Discovery** - Find all MCP configurations
2. **Individual Analysis** - Scan each server in detail
3. **Risk Assessment** - Categorize and prioritize findings
4. **Compliance Check** - Verify against security standards
5. **Remediation Planning** - Create actionable roadmap
6. **Monitoring Setup** - Suggest ongoing security measures

### `/ramparts-quick [target]`

**Purpose**: Quick security health check for immediate feedback

**Usage**:
```bash
> /ramparts-quick              # Quick check of IDE configs
> /ramparts-quick config       # Same as above
> /ramparts-quick https://api.example.com/mcp/  # Quick check of specific server
> /ramparts-quick all          # Check everything
```

**What it does**:
- Performs rapid security assessment
- Focuses on critical and high-priority issues only
- Provides immediate security status indicator
- Suggests next steps based on findings

**Status Indicators**:
- ✅ **SECURE** - No significant issues found
- ⚠️ **CAUTION** - Medium priority issues detected  
- 🚨 **URGENT** - Critical vulnerabilities found

### `/security:scan <target>`

**Purpose**: Advanced security scanning with detailed vulnerability analysis

**Usage**:
```bash
> /security:scan https://api.example.com/mcp/
> /security:scan stdio:python3:/path/to/server.py
```

**What it does**:
- Pre-scan analysis and target assessment
- Advanced security scan with all modules enabled
- Detailed vulnerability classification (CVSS scoring)
- Exploitation scenario analysis
- Security architecture review
- Threat modeling and attack surface mapping
- Compliance and standards assessment
- Executive security reporting

**Advanced Features**:
- **CVSS Scoring**: Vulnerabilities rated 0-10 scale
- **Threat Modeling**: Analysis of potential attack vectors
- **Architecture Review**: Security design assessment
- **Compliance Mapping**: Standards alignment (OWASP, NIST, etc.)

### `/security:monitor`

**Purpose**: Set up continuous security monitoring for MCP servers

**Usage**:
```bash
> /security:monitor
> /security:monitor 30 high    # Monitor every 30 minutes, alert on high+ issues
```

**What it does**:
- Designs comprehensive monitoring strategy
- Sets up automated scanning schedules
- Configures alert thresholds and channels
- Creates security metrics dashboard
- Establishes automated response actions
- Integrates with CI/CD pipelines
- Sets up incident response workflows

**Monitoring Components**:
- **Automated Scanning**: Scheduled security scans
- **Alert System**: Multi-channel notifications
- **Dashboard**: Security metrics and trends
- **Integration**: CI/CD and monitoring systems
- **Incident Response**: Automated containment actions

## 🛠️ Customization

### Modifying Commands

You can customize any command by editing its `.toml` file:

```toml
# ~/.gemini/commands/my-custom-scan.toml
description = "My custom MCP security scan"
prompt = """
I need to perform a custom security scan with these requirements:
- Target: {{args}}
- Focus on SQL injection and XSS vulnerabilities
- Generate executive summary
- Include compliance mapping to SOC 2

Execute: ramparts scan "{{args}}" --detailed --format json
Then provide custom analysis focusing on web security issues.
"""
```

### Creating New Commands

1. **Create new `.toml` file** in commands directory
2. **Define description** and **prompt template**
3. **Use `{{args}}`** placeholder for user input
4. **Include shell commands** with `!{command}` syntax
5. **Test the command** in Gemini CLI

### Command Templates

**Basic scan template**:
```toml
description = "Description of what this command does"
prompt = """
I need to perform a security scan of: {{args}}

Steps:
1. Execute: ramparts scan "{{args}}" --detailed
2. Analyze results for [specific focus area]
3. Provide [specific type of recommendations]

Focus on: [your specific requirements]
"""
```

**Advanced analysis template**:
```toml
description = "Advanced security analysis"
prompt = """
Perform advanced security analysis of: {{args}}

Analysis Framework:
1. Pre-scan assessment
2. Detailed vulnerability analysis  
3. Risk quantification
4. Remediation prioritization
5. Compliance mapping

Execute comprehensive scan and provide detailed security assessment.
"""
```

## 🚀 Best Practices

### Command Organization

**User vs Project Commands**:
- **User commands** (`~/.gemini/commands/`): Personal security workflows
- **Project commands** (`.gemini/commands/`): Team-shared security processes

**Namespacing**:
- Use subdirectories for related commands: `security/`, `compliance/`, `monitoring/`
- Keep command names descriptive but concise
- Group similar functionality together

### Prompt Design

**Effective Prompts**:
- **Clear instructions**: Specify exactly what should be done
- **Structured output**: Request organized, actionable results
- **Context awareness**: Include relevant background information
- **Error handling**: Address potential failure scenarios

**Prompt Structure**:
```toml
prompt = """
[Context and objective]

[Step-by-step instructions]
1. Execute command
2. Analyze results
3. Provide recommendations

[Output format requirements]

[Specific focus areas or requirements]
"""
```

### Team Sharing

**Repository Integration**:
```bash
# Add to version control
git add .gemini/commands/
git commit -m "Add team security commands"

# Team members get commands automatically
git pull
# Commands are immediately available in Gemini CLI
```

**Documentation**:
- Document custom commands in project README
- Include usage examples and expected outputs
- Maintain command descriptions and help text

## 🔍 Troubleshooting

### Common Issues

**Commands not appearing**:
- Check file location: `~/.gemini/commands/` or `.gemini/commands/`
- Verify file extension: Must be `.toml`
- Restart Gemini CLI after adding commands
- Check file permissions: Files must be readable

**Command execution errors**:
- Verify Ramparts installation: `ramparts --version`
- Check command syntax in `.toml` file
- Test Ramparts commands separately first
- Review Gemini CLI error messages

**Prompt issues**:
- Ensure `{{args}}` placeholder is used correctly
- Test shell commands with `!{command}` syntax
- Verify prompt template syntax
- Check for TOML formatting errors

### Debug Tips

**Testing Commands**:
```bash
# Test TOML syntax
cat ~/.gemini/commands/ramparts-scan.toml

# Test Ramparts separately
ramparts scan https://api.example.com/mcp/

# Check Gemini CLI command loading
gemini
> /help
# Should show your custom commands
```

**Verbose Output**:
- Commands inherit Gemini CLI's verbose mode
- Use detailed prompts for comprehensive output
- Include error handling in prompt templates

## 📈 Advanced Usage

### Conditional Logic

```toml
prompt = """
Analyze target: {{args}}

If target starts with "http":
  - Execute: ramparts scan "{{args}}" --detailed
If target equals "config":
  - Execute: ramparts scan-config --detailed
If target contains multiple URLs:
  - Execute batch scan for each URL

Provide analysis based on scan type and results.
"""
```

### Integration with Other Tools

```toml
prompt = """
Security scan with additional context: {{args}}

1. Git context: !{git log --oneline -5}
2. Recent changes: !{git diff --name-only HEAD~1}
3. Ramparts scan: ramparts scan "{{args}}" --detailed
4. Security analysis incorporating code changes

Provide comprehensive security assessment with change impact analysis.
"""
```

### Custom Output Formats

```toml
prompt = """
Generate security report for: {{args}}

Execute scan and format output as:

## Executive Summary
[High-level security status]

## Technical Findings  
[Detailed vulnerability analysis]

## Action Items
[Prioritized remediation steps]

## Compliance Status
[Standards alignment assessment]
"""
```

## 🔗 Related Documentation

- [MCP Server Integration](MCP-SERVER.md) - Advanced features with tools and prompts
- [Installation Guide](README.md#installation-guide) - Setup instructions
- [Configuration Reference](CONFIGURATION.md) - Detailed configuration options
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues and solutions

---

**TOML commands provide the fastest path to security-enhanced AI development. Start scanning in minutes! 🛡️⚡**