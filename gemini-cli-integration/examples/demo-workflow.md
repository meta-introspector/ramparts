# 🧪 Ramparts × Gemini CLI Demo Workflow

This demo showcases the complete integration of Ramparts security scanning with Gemini CLI, demonstrating both TOML commands and MCP server features.

## 🎯 Demo Scenario

**Scenario**: A developer is setting up a new AI-powered application that uses multiple MCP servers. They want to ensure all MCP integrations are secure before going to production.

## 🚀 Step-by-Step Demo

### Step 1: Initial Security Assessment

**Objective**: Get a quick overview of the current security posture

```bash
# Start Gemini CLI
gemini

# Quick security check of all IDE configurations
> /ramparts-quick config
```

**Expected Output**:
```
🛡️ SECURITY STATUS: CAUTION
• 3 medium-priority issues detected
• No critical vulnerabilities found
• Review recommended within 7 days
• Issues: Path validation, Authentication headers, Error handling

📋 PLAN: Include in next security review cycle
🔍 DETAIL: Run full audit: /ramparts-audit
📊 BASELINE: Document current security posture
```

### Step 2: Detailed Security Audit

**Objective**: Get comprehensive security analysis of all MCP servers

```bash
> /ramparts-audit
```

**Expected Output**:
```
# 🛡️ Comprehensive Security Audit Results

## 📊 Executive Summary
- Total MCP servers discovered: 4
- Security posture overview: At Risk
- Critical vulnerabilities found: 1
- Overall risk score: Medium

## 🔍 Detailed Findings by Server:

### 🚨 GitHub Copilot MCP Server
- **Status**: 🚨 Vulnerable
- **URL**: https://api.githubcopilot.com/mcp/
- **Vulnerabilities**: 1 Critical, 2 High
- **Key Issues**: 
  - CRITICAL: Authentication bypass in admin tools
  - HIGH: Environment variable leakage
  - HIGH: Path traversal in file operations

### ⚠️ Local Commands Server  
- **Status**: ⚠️ Issues Found
- **Command**: stdio:npx:mcp-server-commands
- **Vulnerabilities**: 3 Medium
- **Key Issues**:
  - Command injection potential
  - Insufficient input validation
  - Missing error handling

## 🚨 CRITICAL (Fix Immediately):
1. **Authentication Bypass** - GitHub Copilot admin tools
   - Impact: Complete system compromise possible
   - Timeline: Fix within 4 hours
   - Action: Disable admin tools until patched

## ⚠️ HIGH (Fix Within 48 Hours):
1. **Environment Variable Leakage** - Secrets exposure
2. **Path Traversal** - File system access

## 📋 Remediation Roadmap:

### Phase 1 - Immediate Actions (0-4 hours):
- Disable vulnerable admin tools
- Implement emergency access controls
- Set up monitoring for exploitation attempts

### Phase 2 - Short-term (1-7 days):
- Patch authentication vulnerabilities
- Implement input validation
- Update error handling

### Phase 3 - Long-term (1-4 weeks):
- Security architecture review
- Implement continuous monitoring
- Team security training
```

### Step 3: Specific Server Analysis

**Objective**: Deep dive into the most critical server

```bash
> /ramparts-scan https://api.githubcopilot.com/mcp/
```

**Expected Output**:
```
# 🛡️ Ramparts Security Scan Results

**Server:** GitHub Copilot MCP Server
**URL:** https://api.githubcopilot.com/mcp/
**Scan Time:** 2024-01-15T14:30:00Z

## 📊 Scan Summary
- **Tools scanned:** 83
- **Resources scanned:** 12
- **Prompts scanned:** 5
- **Security findings:** 8

## 🚨 Security Findings

### 🚨 CRITICAL Issues (1)
#### Authentication Bypass in Admin Tools
**Component:** tool - admin_user_management
**Description:** Tool bypasses authentication checks for administrative functions
**Immediate Action:** Disable tool immediately and implement proper authentication

### ⚠️ HIGH Priority Issues (2)
#### Environment Variable Leakage
**Component:** tool - get_secret_scanning_alert
**Description:** Tool exposes sensitive environment variables and API keys
**Recommendation:** Implement secure credential handling and access controls

#### Path Traversal Vulnerability
**Component:** tool - file_operations
**Description:** Tool accepts path parameters without proper validation
**Recommendation:** Implement path sanitization and restrict file access scope

### 📋 MEDIUM Priority Issues (3)
- **Input Validation Bypass** (tool: search_repositories)
- **Information Disclosure** (resource: user_profile_data)
- **Insufficient Logging** (multiple components)

### ℹ️ LOW Priority Items (2)
- 2 informational findings and recommendations

## 🛡️ Security Recommendations

1. **Immediate Actions**:
   - Disable admin_user_management tool
   - Implement emergency monitoring
   - Review access logs for exploitation

2. **Short-term Fixes**:
   - Patch authentication vulnerabilities
   - Implement input validation
   - Add comprehensive logging

3. **Long-term Improvements**:
   - Security architecture review
   - Implement zero-trust model
   - Regular security assessments
```

### Step 4: Vulnerability Deep Dive

**Objective**: Understand specific vulnerabilities and remediation

```bash
> /vulnerability-analysis --vulnerability="Authentication Bypass" --context="GitHub Copilot admin tools"
```

**Expected Output**:
```
# 🔍 Deep Vulnerability Analysis: Authentication Bypass

## Vulnerability Classification
- **CVE Reference**: Not yet assigned (0-day vulnerability)
- **CWE Classification**: CWE-287 (Improper Authentication)
- **CVSS Score**: 9.8 (Critical)
- **Attack Complexity**: Low
- **Required Privileges**: None

## Exploitation Analysis
- **Attack Vector**: Network-based via MCP protocol
- **Proof of Concept**: 
  ```json
  {
    "method": "tools/call",
    "params": {
      "name": "admin_user_management", 
      "arguments": {
        "action": "create_admin",
        "username": "attacker"
      }
    }
  }
  ```
- **Required Capabilities**: Basic MCP client access
- **Exploitation Likelihood**: Very High (trivial to exploit)

## Impact Assessment
- **Technical Impact**: 
  - Complete administrative access (C: High, I: High, A: High)
  - User data access and manipulation
  - System configuration changes
- **Business Impact**: 
  - Data breach potential: High
  - Service disruption: High
  - Compliance violations: Critical
- **Affected Systems**: All GitHub Copilot MCP integrations
- **Data at Risk**: User repositories, personal data, API keys

## Remediation Strategy

### Immediate Mitigation (0-4 hours):
1. **Disable Tool**: Remove admin_user_management from available tools
   ```json
   // In MCP server configuration
   "tools": {
     "admin_user_management": {
       "enabled": false,
       "reason": "Critical security vulnerability"
     }
   }
   ```

2. **Emergency Monitoring**: Set up alerts for admin tool usage attempts
   ```bash
   # Monitor MCP logs for admin tool calls
   tail -f /var/log/mcp-server.log | grep "admin_user_management"
   ```

### Long-term Fix (1-7 days):
1. **Implement Authentication**: Add proper auth checks
   ```python
   def admin_user_management(request):
       # Add authentication check
       if not verify_admin_token(request.auth_token):
           raise AuthenticationError("Admin access required")
       
       # Add authorization check  
       if not has_admin_permission(request.user_id):
           raise AuthorizationError("Insufficient privileges")
       
       # Proceed with admin operation
       return perform_admin_action(request.arguments)
   ```

2. **Input Validation**: Validate all admin operations
3. **Audit Logging**: Log all administrative actions
4. **Rate Limiting**: Implement admin operation throttling

### Prevention Measures:
- **Security Code Review**: All admin tools require security review
- **Penetration Testing**: Regular security assessments
- **Principle of Least Privilege**: Minimize admin tool scope
- **Multi-factor Authentication**: Require MFA for admin operations

## Monitoring and Detection

### Detection Rules:
```yaml
# SIEM rule for admin tool abuse
rule_name: "MCP Admin Tool Unauthorized Access"
conditions:
  - tool_name: "admin_user_management"
  - authentication_status: "missing" OR "invalid"
  - source_ip: NOT in admin_ip_whitelist
action: "immediate_alert"
severity: "critical"
```

### Key Metrics to Monitor:
- Admin tool invocation frequency
- Failed authentication attempts
- Unusual admin operations
- Access from unknown IP addresses
```

### Step 5: Compliance Assessment

**Objective**: Check compliance against security standards

```bash
> /compliance-check --standard="owasp" --scope="all"
```

**Expected Output**:
```
# 🛡️ OWASP Compliance Assessment

## Standards Mapping
Assessing MCP servers against OWASP Top 10 2023:

## Compliance Testing Results

### ❌ A01: Broken Access Control
- **Status**: NON-COMPLIANT
- **Findings**: 
  - Authentication bypass in admin tools (Critical)
  - Missing authorization checks (High)
  - Insufficient access logging (Medium)
- **Risk Level**: Critical
- **Remediation Priority**: Immediate

### ❌ A02: Cryptographic Failures  
- **Status**: NON-COMPLIANT
- **Findings**:
  - Secrets stored in environment variables (High)
  - API keys transmitted in plain text (Medium)
- **Risk Level**: High
- **Remediation Priority**: 48 hours

### ❌ A03: Injection
- **Status**: NON-COMPLIANT  
- **Findings**:
  - Command injection in system tools (High)
  - Path traversal vulnerabilities (High)
  - SQL injection potential (Medium)
- **Risk Level**: High
- **Remediation Priority**: 72 hours

### ⚠️ A04: Insecure Design
- **Status**: PARTIALLY COMPLIANT
- **Findings**:
  - Missing threat modeling (Medium)
  - Insufficient security controls (Medium)
- **Risk Level**: Medium
- **Remediation Priority**: 2 weeks

### ✅ A05: Security Misconfiguration
- **Status**: COMPLIANT
- **Findings**: No significant misconfigurations detected

### ❌ A06: Vulnerable Components
- **Status**: NON-COMPLIANT
- **Findings**:
  - Outdated MCP SDK version (Medium)
  - Unpatched dependencies (Low)
- **Risk Level**: Medium
- **Remediation Priority**: 1 week

### ⚠️ A07: Identity/Authentication Failures
- **Status**: PARTIALLY COMPLIANT
- **Findings**:
  - Weak session management (Medium)
  - Missing rate limiting (Low)
- **Risk Level**: Medium
- **Remediation Priority**: 1 week

### ✅ A08: Software/Data Integrity Failures
- **Status**: COMPLIANT
- **Findings**: Adequate integrity controls in place

### ❌ A09: Logging/Monitoring Failures
- **Status**: NON-COMPLIANT
- **Findings**:
  - Insufficient security logging (High)
  - Missing intrusion detection (Medium)
- **Risk Level**: High  
- **Remediation Priority**: 1 week

### ⚠️ A10: Server-Side Request Forgery
- **Status**: PARTIALLY COMPLIANT
- **Findings**:
  - Limited URL validation (Medium)
  - Missing SSRF protections (Low)
- **Risk Level**: Medium
- **Remediation Priority**: 2 weeks

## Compliance Summary
- **Overall Compliance**: 30% (3/10 categories fully compliant)
- **Critical Issues**: 1 (Authentication bypass)
- **High Priority Issues**: 5
- **Medium Priority Issues**: 8

## Remediation Roadmap

### Phase 1 - Critical (0-48 hours):
1. Fix broken access control (A01)
2. Secure cryptographic implementations (A02)
3. Patch injection vulnerabilities (A03)

### Phase 2 - High Priority (1-2 weeks):
1. Implement comprehensive logging (A09)
2. Update vulnerable components (A06)
3. Strengthen authentication (A07)

### Phase 3 - Medium Priority (2-4 weeks):
1. Security architecture review (A04)
2. Implement SSRF protections (A10)
3. Security monitoring enhancement

## Compliance Certification Timeline
- **Target Compliance Date**: 4 weeks
- **Re-assessment Schedule**: Quarterly
- **Continuous Monitoring**: Implemented
```

### Step 6: Set Up Monitoring

**Objective**: Establish ongoing security monitoring

```bash
> /security:monitor --interval=30 --alert_on="high"
```

**Expected Output**:
```
# 🔔 Security Monitoring Setup

## Monitoring Strategy Design

### 📊 Monitoring Scope:
- 4 configured MCP servers in environment
- Real-time configuration change detection
- Security posture drift monitoring
- New vulnerability discovery

### ⏰ Monitoring Schedule:
- **Scan Interval**: 30 minutes
- **Deep Scan**: Every 4 hours
- **Full Audit**: Weekly
- **Compliance Check**: Monthly

## Automated Scanning Configuration

Created monitoring script: ~/.local/bin/ramparts-monitor.sh
```bash
#!/bin/bash
# Ramparts Security Monitor - Auto-generated

INTERVAL=30
ALERT_LEVEL="high"
LOG_FILE="/var/log/ramparts-security.log"

while true; do
    echo "$(date): Starting security scan..." | tee -a $LOG_FILE
    
    # Run security scan
    SCAN_RESULT=$(ramparts scan-config --format json)
    
    # Check for high/critical issues
    CRITICAL_COUNT=$(echo "$SCAN_RESULT" | jq '.security_findings | map(select(.severity == "CRITICAL")) | length')
    HIGH_COUNT=$(echo "$SCAN_RESULT" | jq '.security_findings | map(select(.severity == "HIGH")) | length')
    
    if [ "$CRITICAL_COUNT" -gt 0 ] || [ "$HIGH_COUNT" -gt 0 ]; then
        # Send alert
        echo "SECURITY ALERT: $CRITICAL_COUNT critical, $HIGH_COUNT high severity issues found" | tee -a $LOG_FILE
        
        # Trigger notifications
        curl -X POST https://hooks.slack.com/your-webhook \
             -H 'Content-type: application/json' \
             --data "{\"text\":\"🚨 MCP Security Alert: $CRITICAL_COUNT critical issues found\"}"
    fi
    
    sleep $((INTERVAL * 60))
done
```

## Alert System Configuration

### 🔔 Alert Channels:
- **Critical Issues**: Immediate SMS + Email + Slack
- **High Priority**: Email + Slack within 15 minutes  
- **Medium Priority**: Daily digest email
- **Monitoring Health**: Weekly status report

### 📈 Security Metrics Dashboard:
```
MCP Security Dashboard - Live Status
=====================================

🛡️ Overall Security Score: 72/100 (Improving ↗️)

🚨 Critical Vulnerabilities: 0 (Target: 0) ✅
⚠️ High Priority Issues: 2 (Target: <3) ⚠️  
📋 Medium Priority Items: 5 (Target: <10) ✅
ℹ️ Informational Findings: 12

📈 30-Day Trend Analysis:
- Security score: +15 points (improving)
- New vulnerabilities: 3 detected, 5 resolved
- Mean time to resolution: 18 hours
- Compliance improvement: 45% → 72%

🎯 Compliance Status:
- OWASP Top 10: 72% compliant (improving)
- Security best practices: 18/25 checks passed
- Last full audit: 2 days ago
- Next scheduled audit: 5 days

🔄 Monitoring Health:
- Last scan: 5 minutes ago ✅
- Scanner uptime: 99.2%  
- Alert system: Operational ✅
- Integration status: All systems connected ✅
```

## Integration Setup

### CI/CD Pipeline Integration:
```yaml
# .github/workflows/security-monitoring.yml
name: Continuous MCP Security Monitoring
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  push:
    paths: ['.gemini/settings.json', '.cursor/mcp.json']

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Security Scan
        run: |
          # Install and run Ramparts
          cargo install ramparts
          ramparts scan-config --report --format json > security-report.json
          
      - name: Process Results
        run: |
          # Check for critical issues
          CRITICAL=$(jq '.[] | select(.security_findings[].severity == "CRITICAL") | length' security-report.json)
          if [ "$CRITICAL" -gt 0 ]; then
            echo "::error::Critical security vulnerabilities found"
            exit 1
          fi
          
      - name: Upload Security Report
        uses: actions/upload-artifact@v3
        with:
          name: security-scan-results
          path: security-report.json
```

✅ **Monitoring Setup Complete!**

Your MCP servers are now under continuous security monitoring with:
- Automated scanning every 30 minutes
- Immediate alerts for high/critical issues  
- Comprehensive security dashboard
- CI/CD integration for change detection
- Compliance tracking and reporting
```

## 🎉 Demo Conclusion

This demo showed how Ramparts × Gemini CLI integration provides:

1. **🚀 Quick Assessment** - Immediate security status in seconds
2. **🔍 Deep Analysis** - Comprehensive vulnerability discovery and analysis  
3. **🧠 AI-Powered Insights** - Intelligent remediation guidance
4. **📊 Compliance Tracking** - Standards-based security assessment
5. **🔔 Continuous Monitoring** - Ongoing security posture management

### Key Benefits Demonstrated:

- **Native Integration**: Security scanning feels like a built-in Gemini CLI feature
- **AI Understanding**: Gemini provides contextual security analysis and recommendations
- **Workflow Integration**: Security becomes part of the natural development conversation
- **Comprehensive Coverage**: From quick checks to deep compliance assessments
- **Actionable Results**: Clear priorities and specific remediation guidance

### Next Steps:

1. **Install the integration** using the provided scripts
2. **Run through this demo** in your own environment
3. **Customize commands** for your specific security requirements
4. **Set up monitoring** for continuous security assurance
5. **Share with your team** for collaborative security practices

**Transform your AI development workflow with security-first practices! 🛡️✨**