import { Prompt } from "@modelcontextprotocol/sdk/types.js";

export async function setupPrompts(): Promise<Prompt[]> {
  return [
    {
      name: "security-scan",
      description: "Scan an MCP server for security vulnerabilities with comprehensive analysis",
      arguments: [
        {
          name: "url",
          description: "MCP server URL to scan (e.g., https://api.example.com/mcp or stdio:npx:mcp-server)",
          required: true,
        },
        {
          name: "detailed",
          description: "Enable detailed security analysis (default: true)",
          required: false,
        },
        {
          name: "report",
          description: "Generate detailed markdown report (default: false)", 
          required: false,
        }
      ],
    },
    {
      name: "security-audit", 
      description: "Comprehensive security audit of all MCP servers in current environment",
      arguments: [
        {
          name: "scope",
          description: "Audit scope: 'project' for current project, 'global' for all user configs (default: project)",
          required: false,
        },
        {
          name: "report",
          description: "Generate comprehensive audit report (default: true)",
          required: false,
        }
      ],
    },
    {
      name: "security-check",
      description: "Quick security health check for MCP configurations",
      arguments: [
        {
          name: "target",
          description: "Target to check: URL, 'config', or 'all' (default: config)",
          required: false,
        }
      ],
    },
    {
      name: "security-monitor",
      description: "Set up continuous security monitoring for MCP servers",
      arguments: [
        {
          name: "interval",
          description: "Monitoring interval in minutes (default: 60)",
          required: false,
        },
        {
          name: "alert_on",
          description: "Alert threshold: 'critical', 'high', 'medium', 'all' (default: high)",
          required: false,
        }
      ],
    },
    {
      name: "vulnerability-analysis",
      description: "Deep vulnerability analysis and remediation guidance for specific security issues",
      arguments: [
        {
          name: "vulnerability",
          description: "Vulnerability identifier or description to analyze",
          required: true,
        },
        {
          name: "context",
          description: "Additional context about the vulnerability (component, environment, etc.)",
          required: false,
        }
      ],
    },
    {
      name: "compliance-check",
      description: "Security compliance assessment against industry standards",
      arguments: [
        {
          name: "standard",
          description: "Compliance standard: 'owasp', 'nist', 'iso27001', 'soc2', 'pci' (default: owasp)",
          required: false,
        },
        {
          name: "scope",
          description: "Assessment scope: 'all', 'critical-only', 'specific-component' (default: all)",
          required: false,
        }
      ],
    }
  ];
}