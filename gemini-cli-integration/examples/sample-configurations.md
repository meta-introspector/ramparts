# ⚙️ Sample Configurations

Complete configuration examples for different deployment scenarios and use cases.

## 🏠 Individual Developer Setup

### Basic User Configuration

**File**: `~/.gemini/settings.json`
```json
{
  "selectedAuthType": "vertex-ai",
  "theme": "Default",
  "preferredEditor": "vscode",
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

**TOML Commands**: `~/.gemini/commands/`
```bash
~/.gemini/commands/
├── ramparts-scan.toml
├── ramparts-audit.toml
├── ramparts-quick.toml
└── security/
    ├── scan.toml
    └── monitor.toml
```

**Environment Variables**: `~/.bashrc` or `~/.zshrc`
```bash
# Ramparts configuration
export RAMPARTS_TIMEOUT=300
export RAMPARTS_HTTP_TIMEOUT=60
export RAMPARTS_PORT=3001

# Enable debug mode (optional)
# export DEBUG=ramparts-mcp-server
```

### Advanced Developer Setup

**File**: `~/.gemini/settings.json`
```json
{
  "selectedAuthType": "api-key",
  "theme": "Dark",
  "preferredEditor": "cursor",
  "mcpServers": {
    "ramparts-security": {
      "command": "ramparts-mcp-server",
      "env": {
        "RAMPARTS_PORT": "3001",
        "RAMPARTS_TIMEOUT": "300",
        "RAMPARTS_HTTP_TIMEOUT": "60",
        "RAMPARTS_AUTH_CACHE": "/home/user/.cache/ramparts",
        "DEBUG": "ramparts-mcp-server:verbose"
      },
      "timeout": 120000,
      "cwd": "/home/user/projects/security-tools"
    },
    "local-mcp-tools": {
      "command": "npx",
      "args": ["mcp-server-commands"],
      "env": {}
    }
  }
}
```

**Custom TOML Commands**: `~/.gemini/commands/custom/`
```toml
# ~/.gemini/commands/custom/security-deep-scan.toml
description = "Deep security scan with custom rules"
prompt = """
Perform comprehensive security analysis of: {{args}}

Custom security focus areas:
1. API security vulnerabilities
2. Data privacy compliance (GDPR/CCPA)
3. Container security (if applicable)
4. Supply chain security

Execute: ramparts scan "{{args}}" --detailed --custom-rules=/path/to/custom-rules.yml

Provide analysis with:
- Executive summary for stakeholders
- Technical details for developers
- Compliance mapping to regulations
- Remediation timeline with priorities
"""
```

## 👥 Team Project Configuration

### Shared Project Setup

**File**: `.gemini/settings.json`
```json
{
  "mcpServers": {
    "ramparts-team": {
      "command": "npx",
      "args": ["-y", "ramparts-mcp-server"],
      "env": {
        "RAMPARTS_PORT": "3002",
        "RAMPARTS_TIMEOUT": "240",
        "RAMPARTS_TEAM_MODE": "true"
      }
    },
    "project-mcp-tools": {
      "command": "node",
      "args": ["./scripts/mcp-server.js"],
      "cwd": "./tools",
      "env": {
        "NODE_ENV": "development",
        "MCP_PORT": "3003"
      }
    }
  }
}
```

**Team Security Commands**: `.gemini/commands/`
```bash
.gemini/commands/
├── team-audit.toml          # Team-specific audit process
├── pre-commit-check.toml    # Pre-commit security validation
├── release-security.toml    # Release security checklist
└── compliance/
    ├── soc2-check.toml     # SOC 2 compliance validation
    ├── gdpr-check.toml     # GDPR compliance check
    └── hipaa-check.toml    # HIPAA compliance (if applicable)
```

**Team Audit Command**: `.gemini/commands/team-audit.toml`
```toml
description = "Team security audit with standardized reporting"
prompt = """
Execute team security audit for project: {{args}}

Team Security Checklist:
1. **Discovery Phase**:
   - Scan all MCP configurations: ramparts scan-config --detailed
   - Identify third-party integrations
   - Document security dependencies

2. **Assessment Phase**:
   - Run comprehensive scans on all servers
   - Check for common team vulnerabilities
   - Validate security policies compliance

3. **Reporting Phase**:
   - Generate team security scorecard
   - Identify shared security debt
   - Prioritize team-wide security improvements
   - Create action items with ownership

4. **Team Recommendations**:
   - Security training needs assessment
   - Tool and process improvements
   - Policy updates required
   - Next audit schedule

Focus on team collaboration and shared security responsibility.
"""
```

### CI/CD Integration

**GitHub Actions**: `.github/workflows/mcp-security.yml`
```yaml
name: MCP Security Assessment
on:
  pull_request:
    paths:
      - '.gemini/settings.json'
      - '.cursor/mcp.json'
      - 'mcp-config.json'
  push:
    branches: [main, develop]
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday 2 AM

jobs:
  security-scan:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
        
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          
      - name: Install Ramparts
        run: |
          # Install Rust and Ramparts
          curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
          source ~/.cargo/env
          cargo install ramparts
          
      - name: Install Ramparts MCP Server
        run: |
          npm install -g ramparts-mcp-server
          
      - name: Install Gemini CLI
        run: |
          npm install -g @google/gemini-cli
          
      - name: Setup Ramparts Integration
        run: |
          mkdir -p ~/.gemini/commands
          curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/install-slash-commands.sh | bash --user
          
      - name: Configure Authentication
        env:
          GOOGLE_API_KEY: ${{ secrets.GOOGLE_API_KEY }}
        run: |
          echo "GOOGLE_API_KEY=${GOOGLE_API_KEY}" >> ~/.gemini/.env
          
      - name: Run Security Audit
        run: |
          # Run team security audit
          timeout 20m gemini --non-interactive "/team-audit $(pwd)" > security-audit-results.txt
          
      - name: Process Results
        run: |
          # Check for critical issues
          if grep -q "CRITICAL" security-audit-results.txt; then
            echo "::error::Critical security vulnerabilities found"
            grep "CRITICAL" security-audit-results.txt
            exit 1
          fi
          
          # Check for high priority issues
          HIGH_COUNT=$(grep -c "HIGH" security-audit-results.txt || echo "0")
          if [ "$HIGH_COUNT" -gt 5 ]; then
            echo "::warning::$HIGH_COUNT high-priority security issues found"
          fi
          
      - name: Upload Security Report
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: security-audit-report
          path: |
            security-audit-results.txt
            scan_*.md
            
      - name: Comment on PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const results = fs.readFileSync('security-audit-results.txt', 'utf8');
            
            // Extract summary for PR comment
            const summary = results.split('\n').slice(0, 20).join('\n');
            
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## 🛡️ MCP Security Audit Results\n\n\`\`\`\n${summary}\n\`\`\`\n\nFull results available in workflow artifacts.`
            });
```

**GitLab CI**: `.gitlab-ci.yml`
```yaml
stages:
  - security-scan
  - security-report

variables:
  RAMPARTS_TIMEOUT: "300"
  RAMPARTS_PORT: "3001"

mcp-security-scan:
  stage: security-scan
  image: node:18
  before_script:
    - apt-get update && apt-get install -y curl build-essential
    - curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    - source ~/.cargo/env
    - cargo install ramparts
    - npm install -g @google/gemini-cli ramparts-mcp-server
  script:
    - curl -fsSL https://raw.githubusercontent.com/getjavelin/ramparts/feature/gemini-cli-integration/gemini-cli-integration/scripts/install-slash-commands.sh | bash --user
    - echo "GOOGLE_API_KEY=${GOOGLE_API_KEY}" > ~/.gemini/.env
    - timeout 20m gemini --non-interactive "/team-audit ${CI_PROJECT_DIR}" > security-results.json
  artifacts:
    reports:
      junit: security-results.xml
    paths:
      - security-results.json
      - scan_*.md
    expire_in: 30 days
  rules:
    - if: $CI_MERGE_REQUEST_ID
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_PIPELINE_SOURCE == "schedule"

security-report:
  stage: security-report
  dependencies:
    - mcp-security-scan
  script:
    - python3 scripts/process-security-results.py security-results.json
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
```

## 🏢 Enterprise Configuration

### Multi-Environment Setup

**Development Environment**: `environments/dev/.gemini/settings.json`
```json
{
  "selectedAuthType": "vertex-ai",
  "mcpServers": {
    "ramparts-dev": {
      "command": "npx",
      "args": ["-y", "ramparts-mcp-server"],
      "env": {
        "RAMPARTS_PORT": "3001",
        "RAMPARTS_TIMEOUT": "180",
        "RAMPARTS_ENV": "development",
        "RAMPARTS_LOG_LEVEL": "debug"
      }
    },
    "dev-mcp-tools": {
      "command": "node",
      "args": ["./dev-mcp-server.js"],
      "env": {
        "NODE_ENV": "development",
        "MCP_SECURITY_MODE": "permissive"
      }
    }
  }
}
```

**Staging Environment**: `environments/staging/.gemini/settings.json`
```json
{
  "selectedAuthType": "service-account",
  "mcpServers": {
    "ramparts-staging": {
      "command": "ramparts-mcp-server",
      "env": {
        "RAMPARTS_PORT": "3001",
        "RAMPARTS_TIMEOUT": "240",
        "RAMPARTS_ENV": "staging",
        "RAMPARTS_LOG_LEVEL": "info",
        "RAMPARTS_COMPLIANCE_MODE": "strict"
      },
      "timeout": 180000
    },
    "staging-mcp-gateway": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--network", "mcp-staging",
        "company/mcp-gateway:staging"
      ],
      "env": {
        "MCP_SECURITY_MODE": "strict",
        "COMPLIANCE_CHECKS": "enabled"
      }
    }
  }
}
```

**Production Environment**: `environments/prod/.gemini/settings.json`
```json
{
  "selectedAuthType": "service-account",
  "mcpServers": {
    "ramparts-prod": {
      "command": "/opt/ramparts/bin/ramparts-mcp-server",
      "env": {
        "RAMPARTS_PORT": "3001",
        "RAMPARTS_TIMEOUT": "300",
        "RAMPARTS_ENV": "production",
        "RAMPARTS_LOG_LEVEL": "warn",
        "RAMPARTS_COMPLIANCE_MODE": "strict",
        "RAMPARTS_AUDIT_LOG": "/var/log/ramparts/audit.log",
        "RAMPARTS_METRICS_ENDPOINT": "https://metrics.company.com/ramparts"
      },
      "timeout": 300000
    }
  }
}
```

### Enterprise Security Commands

**Compliance Commands**: `enterprise-commands/compliance/`

**SOC 2 Compliance**: `compliance/soc2-audit.toml`
```toml
description = "SOC 2 Type II compliance audit for MCP infrastructure"
prompt = """
Execute SOC 2 Type II compliance audit for MCP servers: {{args}}

SOC 2 Trust Service Criteria Assessment:

1. **Security (CC6.0)**:
   - Access controls and authentication
   - System security monitoring
   - Data protection measures
   - Incident response procedures

2. **Availability (A1.0)**:
   - System uptime and reliability
   - Disaster recovery capabilities
   - Performance monitoring
   - Capacity management

3. **Processing Integrity (PI1.0)**:
   - Data processing accuracy
   - Input validation controls
   - Error handling procedures
   - Data integrity checks

4. **Confidentiality (C1.0)**:
   - Data classification and handling
   - Encryption at rest and in transit
   - Access logging and monitoring
   - Data retention policies

5. **Privacy (P1.0)** (if applicable):
   - Personal data handling
   - Consent management
   - Data subject rights
   - Cross-border data transfers

Execute comprehensive scan: ramparts scan-config --compliance soc2 --detailed

Generate SOC 2 compliance report with:
- Control effectiveness assessment
- Gap analysis and remediation plan
- Evidence collection requirements
- Audit readiness checklist
"""
```

**GDPR Compliance**: `compliance/gdpr-check.toml`
```toml
description = "GDPR compliance assessment for MCP data processing"
prompt = """
Assess GDPR compliance for MCP servers processing personal data: {{args}}

GDPR Article Compliance Assessment:

1. **Lawfulness of Processing (Art. 6)**:
   - Legal basis for data processing
   - Consent management mechanisms
   - Legitimate interest assessments

2. **Data Subject Rights (Art. 12-23)**:
   - Right to information and access
   - Right to rectification and erasure
   - Right to data portability
   - Right to object to processing

3. **Data Protection by Design (Art. 25)**:
   - Privacy-preserving technologies
   - Data minimization principles
   - Purpose limitation controls

4. **Security of Processing (Art. 32)**:
   - Technical and organizational measures
   - Encryption and pseudonymization
   - Regular security testing
   - Incident response procedures

5. **Data Transfer Safeguards (Art. 44-49)**:
   - Adequacy decisions
   - Standard contractual clauses
   - Binding corporate rules

Execute privacy-focused scan: ramparts scan "{{args}}" --privacy-mode --detailed

Generate GDPR compliance assessment with:
- Data processing inventory
- Privacy risk assessment
- Data subject rights implementation
- Cross-border transfer analysis
- Breach notification procedures
"""
```

### Monitoring and Alerting

**Production Monitoring**: `monitoring/prod-monitor.toml`
```toml
description = "Production MCP security monitoring with enterprise alerting"
prompt = """
Set up enterprise-grade security monitoring for production MCP infrastructure.

Monitoring Configuration:
- Environment: Production
- Alert Channels: PagerDuty, Slack, Email, SIEM
- Compliance Requirements: SOC 2, GDPR, ISO 27001
- SLA: 99.9% uptime, <5min incident response

Enterprise Monitoring Setup:

1. **Continuous Security Scanning**:
   - Interval: Every 15 minutes
   - Deep scan: Every 4 hours
   - Compliance check: Daily
   - Full audit: Weekly

2. **Alert Thresholds**:
   - CRITICAL: Immediate PagerDuty + SMS
   - HIGH: PagerDuty + Slack within 5 minutes
   - MEDIUM: Slack + Email within 1 hour
   - LOW: Daily digest email

3. **Integration Points**:
   - SIEM: Splunk Enterprise Security
   - Monitoring: Datadog/New Relic
   - Ticketing: ServiceNow/Jira
   - Communication: Slack Enterprise Grid

4. **Compliance Automation**:
   - Automated evidence collection
   - Compliance dashboard updates
   - Regulatory reporting
   - Audit trail maintenance

5. **Incident Response**:
   - Automated containment procedures
   - Escalation matrix
   - Communication templates
   - Post-incident review process

Execute monitoring setup with enterprise integrations and compliance automation.
"""
```

### Docker Compose Setup

**Development Stack**: `docker-compose.dev.yml`
```yaml
version: '3.8'
services:
  ramparts-mcp-server:
    image: node:18-alpine
    working_dir: /app
    volumes:
      - ./gemini-cli-integration/mcp-server:/app
      - ~/.gemini:/root/.gemini
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=development
      - RAMPARTS_PORT=3001
      - RAMPARTS_TIMEOUT=180
      - DEBUG=ramparts-mcp-server
    command: npm run dev
    depends_on:
      - ramparts-backend
      
  ramparts-backend:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - RUST_LOG=debug
      - RAMPARTS_HOST=0.0.0.0
      - RAMPARTS_PORT=3000
    volumes:
      - ./config.yaml:/app/config.yaml
      - ./rules:/app/rules
      
  gemini-cli:
    image: node:18-alpine
    working_dir: /workspace
    volumes:
      - .:/workspace
      - ~/.gemini:/root/.gemini
    environment:
      - GOOGLE_API_KEY=${GOOGLE_API_KEY}
    command: tail -f /dev/null
    depends_on:
      - ramparts-mcp-server
```

**Production Stack**: `docker-compose.prod.yml`
```yaml
version: '3.8'
services:
  ramparts-mcp-server:
    image: ramparts/mcp-server:latest
    restart: unless-stopped
    ports:
      - "127.0.0.1:3001:3001"
    environment:
      - NODE_ENV=production
      - RAMPARTS_PORT=3001
      - RAMPARTS_TIMEOUT=300
      - RAMPARTS_LOG_LEVEL=warn
      - RAMPARTS_METRICS_ENDPOINT=http://prometheus:9090
    volumes:
      - /var/log/ramparts:/var/log/ramparts
      - /etc/ssl/certs:/etc/ssl/certs:ro
    networks:
      - mcp-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      
  ramparts-backend:
    image: ramparts/server:latest
    restart: unless-stopped
    ports:
      - "127.0.0.1:3000:3000"
    environment:
      - RUST_LOG=warn
      - RAMPARTS_HOST=0.0.0.0
      - RAMPARTS_PORT=3000
    volumes:
      - ./config.prod.yaml:/app/config.yaml:ro
      - ./rules:/app/rules:ro
      - /var/log/ramparts:/var/log/ramparts
    networks:
      - mcp-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "127.0.0.1:9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    networks:
      - mcp-network

networks:
  mcp-network:
    driver: bridge
```

### Kubernetes Deployment

**Production Kubernetes**: `k8s/ramparts-mcp-server.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ramparts-mcp-server
  namespace: security-tools
  labels:
    app: ramparts-mcp-server
    version: v1.0.0
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ramparts-mcp-server
  template:
    metadata:
      labels:
        app: ramparts-mcp-server
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "3001"
        prometheus.io/path: "/metrics"
    spec:
      serviceAccountName: ramparts-mcp-server
      containers:
      - name: ramparts-mcp-server
        image: ramparts/mcp-server:1.0.0
        ports:
        - containerPort: 3001
          name: http
        env:
        - name: NODE_ENV
          value: "production"
        - name: RAMPARTS_PORT
          value: "3001"
        - name: RAMPARTS_TIMEOUT
          value: "300"
        - name: RAMPARTS_LOG_LEVEL
          value: "info"
        - name: RAMPARTS_BACKEND_URL
          value: "http://ramparts-backend:3000"
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3001
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3001
          initialDelaySeconds: 5
          periodSeconds: 5
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
            - ALL
---
apiVersion: v1
kind: Service
metadata:
  name: ramparts-mcp-server
  namespace: security-tools
spec:
  selector:
    app: ramparts-mcp-server
  ports:
  - name: http
    port: 3001
    targetPort: 3001
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ramparts-mcp-server-netpol
  namespace: security-tools
spec:
  podSelector:
    matchLabels:
      app: ramparts-mcp-server
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: gemini-cli
    ports:
    - protocol: TCP
      port: 3001
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: security-tools
    ports:
    - protocol: TCP
      port: 3000  # Ramparts backend
```

## 🔧 Custom Configurations

### Development Team Specialization

**Frontend Team**: `.gemini/commands/frontend/`
```toml
# frontend/web-security-scan.toml
description = "Web-focused MCP security scan for frontend applications"
prompt = """
Execute web security assessment for MCP servers used by frontend applications: {{args}}

Frontend-Specific Security Focus:
1. **XSS Prevention**: Cross-site scripting vulnerabilities
2. **CSRF Protection**: Cross-site request forgery defenses
3. **Content Security Policy**: CSP header implementation
4. **Same-Origin Policy**: Origin validation and enforcement
5. **Input Sanitization**: User input validation and encoding
6. **Authentication Flow**: OAuth/OIDC implementation security
7. **Session Management**: Token handling and storage
8. **API Security**: REST/GraphQL endpoint security

Execute scan with web security focus: ramparts scan "{{args}}" --web-security --detailed

Provide frontend-specific recommendations for:
- Browser security controls
- JavaScript security best practices
- API integration security
- User data protection
"""
```

**Backend Team**: `.gemini/commands/backend/`
```toml
# backend/api-security-scan.toml
description = "API and backend-focused MCP security assessment"
prompt = """
Execute backend security assessment for MCP servers: {{args}}

Backend-Specific Security Focus:
1. **API Security**: REST/GraphQL/gRPC endpoint security
2. **Authentication & Authorization**: JWT, OAuth, RBAC implementation
3. **Database Security**: SQL injection, data encryption, access controls
4. **Server Security**: System hardening, service configuration
5. **Network Security**: TLS/SSL, firewall rules, network segmentation
6. **Data Protection**: Encryption at rest/transit, key management
7. **Logging & Monitoring**: Security event logging, SIEM integration
8. **Infrastructure Security**: Container/VM security, secrets management

Execute backend security scan: ramparts scan "{{args}}" --backend-security --detailed

Provide backend-specific guidance for:
- Secure API design patterns
- Database security hardening
- Infrastructure security controls
- Monitoring and alerting setup
"""
```

### Industry-Specific Configurations

**Healthcare/HIPAA**: `.gemini/commands/healthcare/`
```toml
# healthcare/hipaa-compliance.toml
description = "HIPAA compliance assessment for healthcare MCP applications"
prompt = """
Assess HIPAA compliance for MCP servers handling Protected Health Information (PHI): {{args}}

HIPAA Security Rule Compliance Assessment:

1. **Access Control (§164.312(a))**:
   - Unique user identification
   - Automatic logoff procedures
   - Encryption and decryption controls

2. **Audit Controls (§164.312(b))**:
   - Activity logging and monitoring
   - Audit trail integrity
   - Regular audit reviews

3. **Integrity (§164.312(c))**:
   - PHI alteration/destruction protection
   - Data integrity verification
   - Electronic signature controls

4. **Person or Entity Authentication (§164.312(d))**:
   - User identity verification
   - Multi-factor authentication
   - Access credential management

5. **Transmission Security (§164.312(e))**:
   - End-to-end encryption
   - Network transmission controls
   - Secure communication protocols

Execute HIPAA-focused scan: ramparts scan "{{args}}" --hipaa-mode --detailed

Generate HIPAA compliance report with:
- Technical safeguards assessment
- PHI handling evaluation
- Risk assessment and mitigation
- Breach notification procedures
- Business Associate Agreement requirements
"""
```

**Financial/PCI DSS**: `.gemini/commands/financial/`
```toml
# financial/pci-dss-compliance.toml
description = "PCI DSS compliance assessment for payment processing MCP servers"
prompt = """
Assess PCI DSS compliance for MCP servers handling cardholder data: {{args}}

PCI DSS Requirements Assessment:

1. **Build and Maintain Secure Networks (Req 1-2)**:
   - Firewall configuration standards
   - Default password elimination
   - Network segmentation controls

2. **Protect Cardholder Data (Req 3-4)**:
   - Data encryption requirements
   - Secure transmission protocols
   - Key management procedures

3. **Maintain Vulnerability Management (Req 5-6)**:
   - Anti-virus software deployment
   - Secure system development
   - Vulnerability scanning programs

4. **Implement Strong Access Controls (Req 7-8)**:
   - Need-to-know access principles
   - Unique ID assignment
   - Multi-factor authentication

5. **Monitor and Test Networks (Req 9-10)**:
   - Physical access restrictions
   - Activity monitoring and logging
   - Log analysis procedures

6. **Maintain Information Security Policy (Req 11-12)**:
   - Security testing procedures
   - Information security policies
   - Incident response procedures

Execute PCI DSS scan: ramparts scan "{{args}}" --pci-dss --detailed

Generate PCI DSS assessment with:
- Compliance gap analysis
- Cardholder data flow mapping
- Compensating controls evaluation
- Remediation roadmap
- SAQ/ROC preparation guidance
"""
```

---

**These sample configurations provide templates for different deployment scenarios, team structures, and compliance requirements. Customize them based on your specific needs and environment. 🛡️⚙️**