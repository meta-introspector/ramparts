#!/bin/bash

# Ramparts MCP Server Installer
# This script installs and configures the Ramparts MCP server for Gemini CLI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PACKAGE_NAME="ramparts-mcp-server"
GEMINI_CONFIG_DIR="$HOME/.gemini"
GEMINI_SETTINGS_FILE="$GEMINI_CONFIG_DIR/settings.json"

print_header() {
    echo -e "${BLUE}🛡️ Ramparts MCP Server Installer${NC}"
    echo -e "${BLUE}=================================${NC}"
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

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        print_error "Node.js is required but not installed."
        print_info "Please install Node.js 18+ from https://nodejs.org/"
        exit 1
    fi
    
    # Check Node.js version
    local node_version=$(node --version | cut -d'v' -f2)
    local major_version=$(echo "$node_version" | cut -d'.' -f1)
    
    if [ "$major_version" -lt 18 ]; then
        print_error "Node.js 18+ is required. Current version: v$node_version"
        exit 1
    fi
    
    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        print_error "npm is required but not installed."
        exit 1
    fi
    
    # Check if Gemini CLI is installed
    if ! command -v gemini &> /dev/null && ! command -v npx &> /dev/null; then
        print_warning "Gemini CLI is not installed. Install it with:"
        echo "  npm install -g @google/gemini-cli"
        echo "  or use: npx @google/gemini-cli"
    fi
    
    print_success "Prerequisites check passed (Node.js v$node_version)"
}

install_mcp_server() {
    print_info "Installing Ramparts MCP Server..."
    
    # Install the package globally
    if npm install -g "$PACKAGE_NAME"; then
        print_success "Ramparts MCP Server installed successfully"
    else
        print_error "Failed to install Ramparts MCP Server"
        print_info "Trying local installation..."
        
        if npm install "$PACKAGE_NAME"; then
            print_success "Ramparts MCP Server installed locally"
            export RAMPARTS_MCP_LOCAL=true
        else
            print_error "Failed to install Ramparts MCP Server"
            exit 1
        fi
    fi
}

create_gemini_config() {
    print_info "Configuring Gemini CLI integration..."
    
    # Create .gemini directory if it doesn't exist
    mkdir -p "$GEMINI_CONFIG_DIR"
    
    # Determine the command to use
    local mcp_command="npx"
    local mcp_args='["-y", "ramparts-mcp-server"]'
    
    if [ "${RAMPARTS_MCP_LOCAL:-false}" = "true" ]; then
        mcp_command="node"
        mcp_args='["./node_modules/ramparts-mcp-server/dist/index.js"]'
    fi
    
    # Create or update settings.json
    local config_content='{
  "mcpServers": {
    "ramparts": {
      "command": "'$mcp_command'",
      "args": '$mcp_args',
      "env": {
        "RAMPARTS_PORT": "3001",
        "RAMPARTS_TIMEOUT": "180",
        "RAMPARTS_HTTP_TIMEOUT": "30"
      }
    }
  }
}'
    
    if [ -f "$GEMINI_SETTINGS_FILE" ]; then
        # Backup existing config
        cp "$GEMINI_SETTINGS_FILE" "$GEMINI_SETTINGS_FILE.backup"
        print_info "Backed up existing Gemini configuration"
        
        # Try to merge with existing config using jq if available
        if command -v jq &> /dev/null; then
            local temp_file=$(mktemp)
            echo "$config_content" > "$temp_file"
            
            # Merge the configurations
            jq -s '.[0] * .[1]' "$GEMINI_SETTINGS_FILE" "$temp_file" > "$GEMINI_SETTINGS_FILE.new"
            mv "$GEMINI_SETTINGS_FILE.new" "$GEMINI_SETTINGS_FILE"
            rm "$temp_file"
            
            print_success "Merged Ramparts MCP server with existing Gemini configuration"
        else
            print_warning "jq not available - manual configuration merge may be needed"
            echo "$config_content" > "$GEMINI_SETTINGS_FILE.ramparts"
            print_info "Ramparts configuration saved to $GEMINI_SETTINGS_FILE.ramparts"
            print_info "Please manually merge this with your existing $GEMINI_SETTINGS_FILE"
        fi
    else
        # Create new config file
        echo "$config_content" > "$GEMINI_SETTINGS_FILE"
        print_success "Created Gemini CLI configuration with Ramparts MCP server"
    fi
}

test_installation() {
    print_info "Testing installation..."
    
    # Test if the package can be found
    if [ "${RAMPARTS_MCP_LOCAL:-false}" = "true" ]; then
        if [ -f "./node_modules/ramparts-mcp-server/dist/index.js" ]; then
            print_success "Local MCP server installation verified"
        else
            print_error "Local MCP server installation not found"
            return 1
        fi
    else
        if command -v ramparts-mcp-server &> /dev/null; then
            print_success "Global MCP server installation verified"
        else
            print_warning "Global MCP server command not found, but package may still work with npx"
        fi
    fi
    
    # Test if Ramparts is available
    if command -v ramparts &> /dev/null; then
        local version=$(ramparts --version 2>/dev/null | head -1 || echo "unknown")
        print_success "Ramparts CLI is available: $version"
    else
        print_warning "Ramparts CLI is not installed. Install it with:"
        echo "  cargo install ramparts"
        print_warning "MCP server will be installed but won't work until Ramparts is available"
    fi
    
    return 0
}

show_post_install_instructions() {
    echo ""
    print_info "🎉 Ramparts MCP Server installation complete!"
    echo ""
    print_info "Available slash commands (via MCP prompts):"
    echo "  /security-scan --url=\"https://api.example.com/mcp/\""
    echo "  /security-audit --scope=\"project\""
    echo "  /security-check --target=\"config\""
    echo "  /security-monitor --interval=60"
    echo "  /vulnerability-analysis --vulnerability=\"XSS\""
    echo "  /compliance-check --standard=\"owasp\""
    echo ""
    print_info "Available tools (via MCP tools):"
    echo "  - ramparts_scan"
    echo "  - ramparts_scan_config"
    echo "  - ramparts_batch_scan"
    echo "  - ramparts_health_check"
    echo "  - ramparts_get_capabilities"
    echo ""
    print_info "Next steps:"
    echo "1. Make sure Ramparts is installed: cargo install ramparts"
    echo "2. Start Gemini CLI: gemini"
    echo "3. Try the MCP integration:"
    echo "   > /security-check --target=\"config\""
    echo "   > Use ramparts_scan tool with a URL"
    echo ""
    print_info "Configuration file: $GEMINI_SETTINGS_FILE"
    print_info "Documentation: https://github.com/getjavelin/ramparts#mcp-integration"
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --local         Install package locally instead of globally"
    echo "  --uninstall     Remove the MCP server installation"
    echo "  --test          Test the installation"
    echo "  --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Install globally"
    echo "  $0 --local      # Install locally"
    echo "  $0 --test       # Test installation"
    echo "  $0 --uninstall  # Remove installation"
}

uninstall_mcp_server() {
    print_info "Uninstalling Ramparts MCP Server..."
    
    local removed_any=false
    
    # Try to remove global installation
    if npm uninstall -g "$PACKAGE_NAME" 2>/dev/null; then
        print_success "Removed global installation"
        removed_any=true
    fi
    
    # Try to remove local installation
    if [ -f "./package.json" ] && npm uninstall "$PACKAGE_NAME" 2>/dev/null; then
        print_success "Removed local installation"
        removed_any=true
    fi
    
    # Remove from Gemini config
    if [ -f "$GEMINI_SETTINGS_FILE" ]; then
        if command -v jq &> /dev/null; then
            # Use jq to remove the ramparts MCP server
            local temp_file=$(mktemp)
            jq 'del(.mcpServers.ramparts)' "$GEMINI_SETTINGS_FILE" > "$temp_file"
            mv "$temp_file" "$GEMINI_SETTINGS_FILE"
            print_success "Removed from Gemini CLI configuration"
            removed_any=true
        else
            print_warning "Manual removal from $GEMINI_SETTINGS_FILE may be needed"
            print_info "Remove the 'ramparts' entry from mcpServers section"
        fi
    fi
    
    if [ "$removed_any" = true ]; then
        print_success "Ramparts MCP Server uninstalled"
    else
        print_warning "No Ramparts MCP Server installation found"
    fi
}

# Main execution
main() {
    local action="install"
    local install_local=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --local)
                install_local=true
                shift
                ;;
            --uninstall)
                action="uninstall"
                shift
                ;;
            --test)
                action="test"
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
    
    print_header
    
    case "$action" in
        "uninstall")
            uninstall_mcp_server
            exit 0
            ;;
        "test")
            test_installation
            exit 0
            ;;
        "install")
            check_prerequisites
            
            if [ "$install_local" = true ]; then
                export RAMPARTS_MCP_LOCAL=true
            fi
            
            install_mcp_server
            create_gemini_config
            test_installation
            show_post_install_instructions
            ;;
    esac
}

# Run main function with all arguments
main "$@"