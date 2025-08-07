#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ListPromptsRequestSchema,
  GetPromptRequestSchema,
  Tool,
} from "@modelcontextprotocol/sdk/types.js";
import { RampartsClient } from "./ramparts-client.js";
import { setupTools } from "./tools/index.js";
import { setupPrompts } from "./prompts/index.js";

class RampartsMCPServer {
  private server: Server;
  private rampartsClient: RampartsClient;

  constructor() {
    this.server = new Server(
      {
        name: "ramparts-mcp-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
          prompts: {},
        },
      }
    );

    this.rampartsClient = new RampartsClient();
    this.setupHandlers();
  }

  private setupHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      const tools = await setupTools();
      return { tools };
    });

    // List available prompts
    this.server.setRequestHandler(ListPromptsRequestSchema, async () => {
      const prompts = await setupPrompts();
      return { prompts };
    });

    // Get specific prompt
    this.server.setRequestHandler(GetPromptRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;
      return await this.getPromptTemplate(name, args);
    });

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case "ramparts_scan":
            return await this.handleScan(args);
          case "ramparts_scan_config":
            return await this.handleScanConfig(args);
          case "ramparts_batch_scan":
            return await this.handleBatchScan(args);
          case "ramparts_validate_config":
            return await this.handleValidateConfig(args);
          case "ramparts_health_check":
            return await this.handleHealthCheck(args);
          case "ramparts_get_capabilities":
            return await this.handleGetCapabilities(args);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: "text",
              text: `Error executing ${name}: ${error instanceof Error ? error.message : String(error)}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  private async getPromptTemplate(name: string, args: any) {
    switch (name) {
      case "security-scan":
        return {
          description: "Scan an MCP server for security vulnerabilities",
          messages: [
            {
              role: "user",
              content: {
                type: "text",
                text: this.buildSecurityScanPrompt(args),
              },
            },
          ],
        };
      
      case "security-audit":
        return {
          description: "Comprehensive security audit of MCP servers",
          messages: [
            {
              role: "user", 
              content: {
                type: "text",
                text: this.buildSecurityAuditPrompt(args),
              },
            },
          ],
        };

      case "security-check":
        return {
          description: "Quick security health check",
          messages: [
            {
              role: "user",
              content: {
                type: "text", 
                text: this.buildSecurityCheckPrompt(args),
              },
            },
          ],
        };

      case "security-monitor":
        return {
          description: "Set up continuous security monitoring",
          messages: [
            {
              role: "user",
              content: {
                type: "text",
                text: this.buildSecurityMonitorPrompt(args),
              },
            },
          ],
        };

      case "vulnerability-analysis":
        return {
          description: "Deep vulnerability analysis and remediation guidance",
          messages: [
            {
              role: "user",
              content: {
                type: "text",
                text: this.buildVulnerabilityAnalysisPrompt(args),
              },
            },
          ],
        };

      case "compliance-check":
        return {
          description: "Security compliance assessment against standards",
          messages: [
            {
              role: "user",
              content: {
                type: "text",
                text: this.buildComplianceCheckPrompt(args),
              },
            },
          ],
        };

      default:
        throw new Error(`Unknown prompt: ${name}`);
    }
  }

  private buildSecurityScanPrompt(args: any): string {
    const url = args?.url || "{{url}}";
    const detailed = args?.detailed !== false;
    const report = args?.report === true;

    return `I need to perform a security scan of the MCP server: ${url}

Please use the ramparts_scan tool with the following parameters:
- url: "${url}"
- detailed: ${detailed}
- report: ${report}

After scanning, provide:
1. **Security Summary**: Overview of findings and overall security posture
2. **Risk Assessment**: Categorize findings by severity (Critical/High/Medium/Low)
3. **Vulnerability Details**: Specific issues found with context and impact
4. **Remediation Steps**: Actionable steps to fix each vulnerability
5. **Best Practices**: Security recommendations for MCP server management

If critical vulnerabilities are found, highlight them prominently and suggest immediate remediation steps.`;
  }

  private buildSecurityAuditPrompt(args: any): string {
    const scope = args?.scope || "project";
    const report = args?.report !== false;

    return `I need to perform a comprehensive security audit of MCP servers.

Scope: ${scope === "global" ? "All user MCP configurations" : "Current project MCP servers"}

Please execute this audit workflow:

1. **Discovery**: Use ramparts_scan_config to find all MCP servers
2. **Individual Scans**: Scan each discovered server with ramparts_scan
3. **Risk Assessment**: Analyze all findings and categorize by severity
4. **Compliance Check**: Verify against security best practices
5. **Report Generation**: ${report ? "Generate detailed audit report" : "Provide summary findings"}

Provide:
- Executive summary of security posture
- Critical vulnerabilities requiring immediate attention
- Risk scoring for each server
- Prioritized remediation roadmap
- Security recommendations and best practices`;
  }

  private buildSecurityCheckPrompt(args: any): string {
    const target = args?.target || "config";

    return `I need a quick security health check.

Target: ${target}

Please perform a rapid security assessment:

1. **Quick Scan**: 
   ${target === "config" ? "Use ramparts_scan_config for IDE configurations" : 
     target === "all" ? "Scan both configurations and any specified URLs" :
     `Use ramparts_scan for: ${target}`}

2. **Immediate Feedback**: Focus on critical and high-priority issues only

3. **Security Status**: Provide clear status indicator:
   ✅ SECURE - No significant issues
   ⚠️ CAUTION - Medium priority issues  
   🚨 URGENT - Critical vulnerabilities

4. **Next Steps**: If issues found, recommend appropriate actions

Keep response concise but actionable.`;
  }

  private buildSecurityMonitorPrompt(args: any): string {
    const interval = args?.interval || 60;
    const alertOn = args?.alert_on || "high";

    return `I need to set up continuous security monitoring for MCP servers.

Configuration:
- Monitoring interval: ${interval} minutes
- Alert threshold: ${alertOn} severity and above

Please help me establish:

1. **Monitoring Setup**: Create a monitoring strategy for MCP servers
2. **Alert Configuration**: Set up alerts for ${alertOn} severity issues and above
3. **Automation**: Suggest ways to automate regular security scans
4. **Reporting**: Configure periodic security status reports
5. **Integration**: Recommend integration with existing monitoring systems

Provide specific steps to implement continuous MCP security monitoring.`;
  }

  private buildVulnerabilityAnalysisPrompt(args: any): string {
    const vulnerability = args?.vulnerability || "{{vulnerability}}";
    const context = args?.context || "";

    return `I need a deep analysis of this security vulnerability:

Vulnerability: ${vulnerability}
Context: ${context}

Please provide comprehensive vulnerability analysis:

1. **Vulnerability Classification**:
   - CVE/CWE identification (if applicable)
   - CVSS score and vector analysis
   - Attack complexity and prerequisites
   - Potential impact assessment

2. **Exploitation Analysis**:
   - Attack vector methodology
   - Proof of concept development
   - Required attacker capabilities
   - Exploitation likelihood assessment

3. **Impact Assessment**:
   - Technical impact (Confidentiality/Integrity/Availability)
   - Business impact and risk quantification
   - Affected systems and data
   - Cascading effects analysis

4. **Remediation Strategy**:
   - Immediate mitigation steps
   - Long-term fix recommendations
   - Implementation priority and timeline
   - Testing and validation procedures

5. **Prevention Measures**:
   - Root cause analysis
   - Similar vulnerability prevention
   - Security control improvements
   - Monitoring and detection enhancements`;
  }

  private buildComplianceCheckPrompt(args: any): string {
    const standard = args?.standard || "owasp";
    const scope = args?.scope || "all";

    return `I need to assess MCP server security compliance against standards.

Standard: ${standard.toUpperCase()}
Scope: ${scope}

Please perform compliance assessment:

1. **Standards Mapping**:
   - Map MCP security controls to ${standard.toUpperCase()} requirements
   - Identify applicable security controls
   - Assess control implementation status
   - Document compliance gaps

2. **Compliance Testing**:
   - Execute relevant security scans
   - Validate security control effectiveness
   - Test compliance requirements
   - Document evidence of compliance

3. **Gap Analysis**:
   - Identify non-compliant areas
   - Assess risk of compliance gaps
   - Prioritize remediation efforts
   - Estimate compliance achievement timeline

4. **Compliance Report**:
   - Executive compliance summary
   - Detailed findings by requirement
   - Remediation roadmap
   - Ongoing compliance maintenance plan

Standards supported:
- OWASP Top 10 / OWASP ASVS
- NIST Cybersecurity Framework
- ISO 27001/27002
- SOC 2 Type II
- PCI DSS (if applicable)`;
  }

  private async handleScan(args: any) {
    const result = await this.rampartsClient.scan(args);
    return {
      content: [
        {
          type: "text",
          text: this.formatScanResult(result),
        },
      ],
    };
  }

  private async handleScanConfig(args: any) {
    const result = await this.rampartsClient.scanConfig(args);
    return {
      content: [
        {
          type: "text",
          text: this.formatScanConfigResult(result),
        },
      ],
    };
  }

  private async handleBatchScan(args: any) {
    const result = await this.rampartsClient.batchScan(args);
    return {
      content: [
        {
          type: "text",
          text: this.formatBatchScanResult(result),
        },
      ],
    };
  }

  private async handleValidateConfig(args: any) {
    const result = await this.rampartsClient.validateConfig(args);
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  }

  private async handleHealthCheck(args: any) {
    const result = await this.rampartsClient.healthCheck();
    return {
      content: [
        {
          type: "text",
          text: `Ramparts Health: ${result.status}\nVersion: ${result.version}\nProtocol: ${result.protocol_version}`,
        },
      ],
    };
  }

  private async handleGetCapabilities(args: any) {
    const result = await this.rampartsClient.getCapabilities();
    return {
      content: [
        {
          type: "text",
          text: this.formatCapabilities(result),
        },
      ],
    };
  }

  private formatScanResult(result: any): string {
    let output = `# 🛡️ Ramparts Security Scan Results\n\n`;
    
    if (result.server_info) {
      output += `**Server:** ${result.server_info.name || 'Unknown'}\n`;
      output += `**URL:** ${result.server_info.url}\n`;
      output += `**Scan Time:** ${new Date().toISOString()}\n\n`;
    }

    if (result.summary) {
      output += `## 📊 Scan Summary\n`;
      output += `- **Tools scanned:** ${result.summary.tools_count || 0}\n`;
      output += `- **Resources scanned:** ${result.summary.resources_count || 0}\n`;
      output += `- **Prompts scanned:** ${result.summary.prompts_count || 0}\n`;
      output += `- **Security findings:** ${result.summary.security_findings_count || 0}\n\n`;
    }

    if (result.security_findings && result.security_findings.length > 0) {
      output += `## 🚨 Security Findings\n\n`;
      
      const criticalFindings = result.security_findings.filter((f: any) => f.severity === 'CRITICAL');
      const highFindings = result.security_findings.filter((f: any) => f.severity === 'HIGH');
      const mediumFindings = result.security_findings.filter((f: any) => f.severity === 'MEDIUM');
      const lowFindings = result.security_findings.filter((f: any) => f.severity === 'LOW');

      if (criticalFindings.length > 0) {
        output += `### 🚨 CRITICAL Issues (${criticalFindings.length})\n`;
        for (const finding of criticalFindings) {
          output += `#### ${finding.title}\n`;
          output += `**Component:** ${finding.component_type} - ${finding.component_name}\n`;
          output += `**Description:** ${finding.description}\n`;
          if (finding.recommendation) {
            output += `**Immediate Action:** ${finding.recommendation}\n`;
          }
          output += `\n`;
        }
      }

      if (highFindings.length > 0) {
        output += `### ⚠️ HIGH Priority Issues (${highFindings.length})\n`;
        for (const finding of highFindings) {
          output += `#### ${finding.title}\n`;
          output += `**Component:** ${finding.component_type} - ${finding.component_name}\n`;
          output += `**Description:** ${finding.description}\n`;
          if (finding.recommendation) {
            output += `**Recommendation:** ${finding.recommendation}\n`;
          }
          output += `\n`;
        }
      }

      if (mediumFindings.length > 0) {
        output += `### 📋 MEDIUM Priority Issues (${mediumFindings.length})\n`;
        for (const finding of mediumFindings) {
          output += `- **${finding.title}** (${finding.component_type}: ${finding.component_name})\n`;
        }
        output += `\n`;
      }

      if (lowFindings.length > 0) {
        output += `### ℹ️ LOW Priority Items (${lowFindings.length})\n`;
        output += `- ${lowFindings.length} informational findings and recommendations\n\n`;
      }

    } else {
      output += `## ✅ No Security Issues Found\n\nAll scanned components passed security checks.\n`;
    }

    // Add security recommendations
    output += `## 🛡️ Security Recommendations\n\n`;
    output += `1. **Regular Scanning**: Schedule periodic security scans\n`;
    output += `2. **Monitor Changes**: Set up alerts for MCP configuration changes\n`;
    output += `3. **Access Control**: Implement proper authentication and authorization\n`;
    output += `4. **Keep Updated**: Regularly update MCP servers and dependencies\n`;
    output += `5. **Incident Response**: Have a plan for addressing security findings\n`;

    return output;
  }

  private formatScanConfigResult(result: any): string {
    let output = `# 🔍 IDE Configuration Scan Results\n\n`;
    
    if (result.configs_found) {
      output += `**Configurations found:** ${result.configs_found.length}\n\n`;
      for (const config of result.configs_found) {
        output += `- **${config.ide}:** ${config.path}\n`;
      }
      output += `\n`;
    }

    if (result.scan_results) {
      output += `## 📊 Scan Summary\n`;
      output += `- **Total servers:** ${result.scan_results.length}\n`;
      const successfulScans = result.scan_results.filter((r: any) => r.success).length;
      output += `- **Successful scans:** ${successfulScans}\n`;
      output += `- **Failed scans:** ${result.scan_results.length - successfulScans}\n\n`;

      for (const scanResult of result.scan_results) {
        if (scanResult.success) {
          output += this.formatScanResult(scanResult.result);
          output += `\n---\n\n`;
        } else {
          output += `**❌ Failed to scan ${scanResult.url}:** ${scanResult.error}\n\n`;
        }
      }
    }

    return output;
  }

  private formatBatchScanResult(result: any): string {
    let output = `# 🔄 Batch Scan Results\n\n`;
    
    if (result.results) {
      output += `**Total servers scanned:** ${result.results.length}\n\n`;
      
      for (const scanResult of result.results) {
        if (scanResult.success) {
          output += this.formatScanResult(scanResult.result);
          output += `\n---\n\n`;
        } else {
          output += `**❌ Failed to scan ${scanResult.url}:** ${scanResult.error}\n\n`;
        }
      }
    }

    return output;
  }

  private formatCapabilities(result: any): string {
    let output = `# 🔧 Ramparts Capabilities\n\n`;
    
    if (result.protocol) {
      output += `## Protocol Support\n`;
      output += `- **Version:** ${result.protocol.version}\n`;
      output += `- **Transports:** ${result.protocol.transport ? Object.keys(result.protocol.transport).join(', ') : 'Unknown'}\n`;
      if (result.protocol.capabilities) {
        output += `- **Capabilities:** ${result.protocol.capabilities.join(', ')}\n`;
      }
      output += `\n`;
    }

    if (result.server) {
      output += `## Server Information\n`;
      output += `- **Version:** ${result.server.version}\n`;
      output += `- **STDIO Support:** ${result.server.stdio_support ? 'Yes' : 'No'}\n`;
      output += `- **MCP Compliance:** ${result.server.mcp_compliance}\n`;
    }

    return output;
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("🛡️ Ramparts MCP Server running on stdio");
  }
}

// Start the server
const server = new RampartsMCPServer();
server.run().catch(console.error);