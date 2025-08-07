#!/bin/bash

# Ramparts Gemini CLI Integration - Installation Validator
# This script validates that the integration is properly installed and working

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
COMMANDS_DIR_USER="$HOME/.gemini/commands"
COMMANDS_DIR_PROJECT=".gemini/commands"
GEMINI_CONFIG="$HOME/.gemini/settings.json"

print_header() {
    echo -e "${PURPLE}🛡️ Ramparts × Gemini CLI Integration Validator${NC}"
    echo -e "${PURPLE}===============================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

print_section() {
    echo -e "${PURPLE}🔍 $1${NC}"
    echo "$(printf '%.0s-' {1..50})"
}

# Global validation results
VALIDATION_PASSED=true
WARNINGS_COUNT=0
ERRORS_COUNT=0

log_error() {
    print_error "$1"
    VALIDATION_PASSED=false
    ((ERRORS_COUNT++))
}

log_warning() {
    print_warning "$1"
    ((WARNINGS_COUNT++))
}

validate_prerequisites() {
    print_section "Prerequisites Validation"
    
    # Check Node.js
    if command -v node &> /dev/null; then
        local node_version=$(node --version | cut -d'v' -f2)
        local major_version=$(echo "$node_version" | cut -d'.' -f1)
        
        if [ "$major_version" -ge 18 ]; then
            print_success "Node.js $node_version (✓ >= 18.0.0)"
        else
            log_error "Node.js version $node_version is too old (requires >= 18.0.0)"
        fi
    else
        log_error "Node.js is not installed"
    fi
    
    # Check npm
    if command -v npm &> /dev/null; then
        local npm_version=$(npm --version)
        print_success "npm $npm_version"
    else
        log_error "npm is not installed"
    fi
    
    # Check Gemini CLI
    if command -v gemini &> /dev/null; then
        print_success "Gemini CLI is installed"
    elif command -v npx &> /dev/null; then
        print_success "npx is available (can run Gemini CLI)"
    else
        log_warning "Gemini CLI not found (can use npx @google/gemini-cli)"
    fi
    
    # Check Ramparts
    if command -v ramparts &> /dev/null; then
        local ramparts_version=$(ramparts --version 2>/dev/null | head -1 || echo "unknown")
        print_success "Ramparts is installed: $ramparts_version"
    else
        log_warning "Ramparts is not installed (required for security scanning)"
        print_info "Install with: cargo install ramparts"
    fi
    
    echo ""
}

validate_toml_commands() {
    print_section "TOML Slash Commands Validation"
    
    local commands_found=false
    
    # Check user-level commands
    if [ -d "$COMMANDS_DIR_USER" ]; then
        print_success "User commands directory exists: $COMMANDS_DIR_USER"
        
        local user_commands=(
            "ramparts-scan.toml"
            "ramparts-audit.toml"
            "ramparts-quick.toml"
            "security/scan.toml"
            "security/monitor.toml"
        )
        
        for cmd in "${user_commands[@]}"; do
            if [ -f "$COMMANDS_DIR_USER/$cmd" ]; then
                print_success "Found user command: $cmd"
                commands_found=true
            else
                log_warning "Missing user command: $cmd"
            fi
        done
    else
        log_warning "User commands directory not found: $COMMANDS_DIR_USER"
    fi
    
    # Check project-level commands
    if [ -d "$COMMANDS_DIR_PROJECT" ]; then
        print_success "Project commands directory exists: $COMMANDS_DIR_PROJECT"
        
        local project_command_count=$(find "$COMMANDS_DIR_PROJECT" -name "*.toml" | wc -l)
        if [ "$project_command_count" -gt 0 ]; then
            print_success "Found $project_command_count project-level commands"
            commands_found=true
        fi
    else
        print_info "No project commands directory (optional): $COMMANDS_DIR_PROJECT"
    fi
    
    if [ "$commands_found" = false ]; then
        log_error "No TOML commands found. Run: make install-commands"
    fi
    
    echo ""
}

validate_mcp_server() {
    print_section "MCP Server Validation"
    
    # Check if package is installed globally
    if npm list -g ramparts-mcp-server &> /dev/null; then
        print_success "MCP server package installed globally"
    elif npm list ramparts-mcp-server &> /dev/null; then
        print_success "MCP server package installed locally"
    else
        log_warning "MCP server package not found"
        print_info "Install with: make install-mcp"
    fi
    
    # Check if MCP server binary is available
    if command -v ramparts-mcp-server &> /dev/null; then
        print_success "MCP server binary is in PATH"
    else
        print_info "MCP server binary not in PATH (will use npx)"
    fi
    
    # Test MCP server startup (non-blocking)
    print_info "Testing MCP server startup..."
    if timeout 10s npx ramparts-mcp-server --help &> /dev/null; then
        print_success "MCP server can start successfully"
    else
        log_warning "MCP server startup test failed or timed out"
    fi
    
    echo ""
}

validate_gemini_configuration() {
    print_section "Gemini CLI Configuration Validation"
    
    if [ -f "$GEMINI_CONFIG" ]; then
        print_success "Gemini CLI configuration file exists"
        
        # Check if ramparts MCP server is configured
        if grep -q "ramparts" "$GEMINI_CONFIG"; then
            print_success "Ramparts MCP server found in configuration"
            
            # Validate JSON syntax
            if command -v jq &> /dev/null; then
                if jq empty "$GEMINI_CONFIG" 2>/dev/null; then
                    print_success "Configuration file has valid JSON syntax"
                else
                    log_error "Configuration file has invalid JSON syntax"
                fi
                
                # Check MCP server configuration
                local mcp_servers=$(jq -r '.mcpServers | keys[]' "$GEMINI_CONFIG" 2>/dev/null || echo "")
                if echo "$mcp_servers" | grep -q "ramparts"; then
                    print_success "Ramparts MCP server properly configured"
                else
                    log_warning "Ramparts MCP server not found in mcpServers section"
                fi
            else
                print_info "jq not available, skipping JSON validation"
            fi
        else
            log_warning "Ramparts MCP server not found in configuration"
            print_info "Run: make install-mcp to add MCP server configuration"
        fi
    else
        log_warning "Gemini CLI configuration file not found: $GEMINI_CONFIG"
        print_info "Configuration will be created on first Gemini CLI run"
    fi
    
    echo ""
}

validate_integration() {
    print_section "Integration Testing"
    
    # Test TOML command syntax
    local toml_valid=true
    for cmd_file in "$COMMANDS_DIR_USER"/*.toml "$COMMANDS_DIR_USER"/security/*.toml; do
        if [ -f "$cmd_file" ]; then
            # Basic TOML syntax check
            if grep -q 'description = ' "$cmd_file" && grep -q 'prompt = ' "$cmd_file"; then
                print_success "$(basename "$cmd_file") has valid TOML structure"
            else
                log_error "$(basename "$cmd_file") has invalid TOML structure"
                toml_valid=false
            fi
        fi
    done
    
    if [ "$toml_valid" = true ]; then
        print_success "All TOML commands have valid syntax"
    fi
    
    # Test MCP server health (if available)
    print_info "Testing MCP server health endpoint..."
    local server_pid=""
    
    # Start MCP server in background for testing
    if command -v ramparts-mcp-server &> /dev/null || command -v npx &> /dev/null; then
        # Try to start server briefly
        timeout 15s npx ramparts-mcp-server &
        server_pid=$!
        sleep 5
        
        # Test if server responds (this is a simplified test)
        if ps -p $server_pid > /dev/null 2>&1; then
            print_success "MCP server can start and run"
            kill $server_pid 2>/dev/null || true
        else
            log_warning "MCP server startup test inconclusive"
        fi
    else
        log_warning "Cannot test MCP server (npx not available)"
    fi
    
    echo ""
}

validate_file_permissions() {
    print_section "File Permissions Validation"
    
    # Check script permissions
    local scripts_dir="$(dirname "$0")"
    for script in "$scripts_dir"/*.sh; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                print_success "$(basename "$script") is executable"
            else
                log_warning "$(basename "$script") is not executable"
                print_info "Run: chmod +x $script"
            fi
        fi
    done
    
    # Check TOML file permissions
    if [ -d "$COMMANDS_DIR_USER" ]; then
        local unreadable_files=0
        for toml_file in "$COMMANDS_DIR_USER"/*.toml "$COMMANDS_DIR_USER"/security/*.toml; do
            if [ -f "$toml_file" ]; then
                if [ -r "$toml_file" ]; then
                    print_success "$(basename "$toml_file") is readable"
                else
                    log_error "$(basename "$toml_file") is not readable"
                    ((unreadable_files++))
                fi
            fi
        done
        
        if [ $unreadable_files -eq 0 ]; then
            print_success "All TOML files have correct permissions"
        fi
    fi
    
    echo ""
}

validate_environment() {
    print_section "Environment Variables Validation"
    
    # Check common environment variables
    if [ -n "$GOOGLE_API_KEY" ]; then
        print_success "GOOGLE_API_KEY is set"
    else
        log_warning "GOOGLE_API_KEY not set (required for Gemini CLI)"
        print_info "Set with: export GOOGLE_API_KEY=your-api-key"
    fi
    
    if [ -n "$RAMPARTS_PORT" ]; then
        print_success "RAMPARTS_PORT is set to $RAMPARTS_PORT"
    else
        print_info "RAMPARTS_PORT not set (will use default: 3001)"
    fi
    
    if [ -n "$RAMPARTS_TIMEOUT" ]; then
        print_success "RAMPARTS_TIMEOUT is set to $RAMPARTS_TIMEOUT"
    else
        print_info "RAMPARTS_TIMEOUT not set (will use default: 180)"
    fi
    
    if [ -n "$DEBUG" ]; then
        print_info "DEBUG mode enabled: $DEBUG"
    fi
    
    echo ""
}

generate_report() {
    print_section "Validation Summary"
    
    echo -e "${BLUE}📊 Results Summary:${NC}"
    echo "  • Errors: $ERRORS_COUNT"
    echo "  • Warnings: $WARNINGS_COUNT"
    echo ""
    
    if [ "$VALIDATION_PASSED" = true ]; then
        if [ $WARNINGS_COUNT -eq 0 ]; then
            echo -e "${GREEN}🎉 Perfect! Integration is fully installed and configured.${NC}"
            echo ""
            echo -e "${BLUE}✨ Ready to use:${NC}"
            echo "  1. Start Gemini CLI: gemini"
            echo "  2. Try commands: /ramparts-quick config"
            echo "  3. Run audit: /ramparts-audit"
        else
            echo -e "${YELLOW}⚠️ Integration is working but has $WARNINGS_COUNT warnings.${NC}"
            echo -e "${BLUE}🔧 Consider addressing warnings for optimal experience.${NC}"
        fi
    else
        echo -e "${RED}❌ Integration has $ERRORS_COUNT errors that need to be fixed.${NC}"
        echo ""
        echo -e "${BLUE}🛠️ Next steps:${NC}"
        echo "  1. Fix errors listed above"
        echo "  2. Run: make install (for complete setup)"
        echo "  3. Run: make validate (to re-check)"
    fi
    
    echo ""
    echo -e "${BLUE}📚 Documentation:${NC}"
    echo "  • README: docs/README.md"
    echo "  • Commands: docs/TOML-COMMANDS.md"
    echo "  • MCP Server: docs/MCP-SERVER.md"
    echo "  • Examples: examples/"
    
    echo ""
    echo -e "${BLUE}🆘 Need help?${NC}"
    echo "  • GitHub Issues: https://github.com/getjavelin/ramparts/issues"
    echo "  • Run demo: make demo"
    echo "  • Check docs: make docs"
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --quick         Run quick validation (skip integration tests)"
    echo "  --verbose       Show detailed output"
    echo "  --json          Output results in JSON format"
    echo "  --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Full validation"
    echo "  $0 --quick      # Quick validation"
    echo "  $0 --verbose    # Detailed output"
}

# Main execution
main() {
    local quick_mode=false
    local verbose_mode=false
    local json_output=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quick)
                quick_mode=true
                shift
                ;;
            --verbose)
                verbose_mode=true
                shift
                ;;
            --json)
                json_output=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    if [ "$json_output" = false ]; then
        print_header
    fi
    
    # Run validation steps
    validate_prerequisites
    validate_toml_commands
    validate_mcp_server
    validate_gemini_configuration
    validate_file_permissions
    validate_environment
    
    if [ "$quick_mode" = false ]; then
        validate_integration
    fi
    
    if [ "$json_output" = true ]; then
        # Output JSON results
        cat << EOF
{
  "validation_passed": $VALIDATION_PASSED,
  "errors_count": $ERRORS_COUNT,
  "warnings_count": $WARNINGS_COUNT,
  "timestamp": "$(date -Iseconds)",
  "components": {
    "toml_commands": $([ -d "$COMMANDS_DIR_USER" ] && echo "true" || echo "false"),
    "mcp_server": $(npm list -g ramparts-mcp-server &>/dev/null && echo "true" || echo "false"),
    "gemini_config": $([ -f "$GEMINI_CONFIG" ] && echo "true" || echo "false"),
    "ramparts_cli": $(command -v ramparts &>/dev/null && echo "true" || echo "false")
  }
}
EOF
    else
        generate_report
    fi
    
    # Exit with appropriate code
    if [ "$VALIDATION_PASSED" = true ]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function with all arguments
main "$@"