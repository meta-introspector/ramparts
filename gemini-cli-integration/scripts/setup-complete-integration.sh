#!/bin/bash

# Complete Ramparts Gemini CLI Integration Setup
# This script installs both TOML slash commands and MCP server integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="https://github.com/getjavelin/ramparts"

print_header() {
    echo -e "${PURPLE}🛡️ Ramparts × Gemini CLI Complete Integration Setup${NC}"
    echo -e "${PURPLE}===================================================${NC}"
    echo ""
    echo -e "${BLUE}This script will install both:${NC}"
    echo -e "${BLUE}1. TOML-based slash commands for immediate use${NC}"
    echo -e "${BLUE}2. MCP server for advanced integration${NC}"
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

print_step() {
    echo -e "${PURPLE}🔄 $1${NC}"
}

check_prerequisites() {
    print_step "Checking system prerequisites..."
    
    local missing_deps=()
    
    # Check for required tools
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if ! command -v node &> /dev/null; then
        missing_deps+=("node")
    fi
    
    if ! command -v npm &> /dev/null; then
        missing_deps+=("npm")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Please install the missing dependencies and run this script again."
        exit 1
    fi
    
    # Check Node.js version
    local node_version=$(node --version | cut -d'v' -f2)
    local major_version=$(echo "$node_version" | cut -d'.' -f1)
    
    if [ "$major_version" -lt 18 ]; then
        print_error "Node.js 18+ is required. Current version: v$node_version"
        exit 1
    fi
    
    # Check if Gemini CLI is available
    if ! command -v gemini &> /dev/null && ! command -v npx &> /dev/null; then
        print_warning "Gemini CLI is not installed. Install it with:"
        echo "  npm install -g @google/gemini-cli"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    print_success "Prerequisites check passed"
}

check_ramparts() {
    print_step "Checking Ramparts installation..."
    
    if command -v ramparts &> /dev/null; then
        local version=$(ramparts --version 2>/dev/null | head -1 || echo "unknown")
        print_success "Ramparts is installed: $version"
        return 0
    else
        print_warning "Ramparts is not installed."
        print_info "Ramparts is required for the security scanning functionality."
        print_info "Install it with: cargo install ramparts"
        echo ""
        read -p "Install integration anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        return 1
    fi
}

download_installer_scripts() {
    print_step "Downloading installer scripts..."
    
    local temp_dir="/tmp/ramparts-gemini-setup"
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    
    # Download installer scripts
    local scripts=(
        "install-slash-commands.sh"
        "install-mcp-server.sh"
    )
    
    for script in "${scripts[@]}"; do
        local url="${REPO_URL}/raw/feature/gemini-cli-integration/gemini-cli-integration/scripts/${script}"
        print_info "Downloading $script..."
        
        if curl -fsSL "$url" -o "$temp_dir/$script"; then
            chmod +x "$temp_dir/$script"
            print_success "Downloaded $script"
        else
            print_error "Failed to download $script"
            exit 1
        fi
    done
    
    export INSTALLER_SCRIPTS_DIR="$temp_dir"
}

install_slash_commands() {
    print_step "Installing TOML-based slash commands..."
    
    if [ -f "$INSTALLER_SCRIPTS_DIR/install-slash-commands.sh" ]; then
        "$INSTALLER_SCRIPTS_DIR/install-slash-commands.sh" --user
    else
        print_error "Slash commands installer not found"
        exit 1
    fi
}

install_mcp_server() {
    print_step "Installing MCP server integration..."
    
    if [ -f "$INSTALLER_SCRIPTS_DIR/install-mcp-server.sh" ]; then
        "$INSTALLER_SCRIPTS_DIR/install-mcp-server.sh"
    else
        print_error "MCP server installer not found"
        exit 1
    fi
}

create_demo_commands() {
    print_step "Creating demo and example files..."
    
    local demo_dir="$HOME/.ramparts-gemini-demo"
    mkdir -p "$demo_dir"
    
    # Create a demo script
    cat > "$demo_dir/demo.sh" << 'EOF'
#!/bin/bash

echo "🛡️ Ramparts × Gemini CLI Demo"
echo "============================="
echo ""
echo "Available TOML Commands:"
echo "  /ramparts-scan <url>     - Scan MCP server"
echo "  /ramparts-audit          - Full security audit"
echo "  /ramparts-quick [target] - Quick security check"
echo "  /security:scan <target>  - Advanced scanning"
echo "  /security:monitor        - Setup monitoring"
echo ""
echo "Available MCP Prompts:"
echo "  /security-scan --url=\"https://example.com/mcp\""
echo "  /security-audit --scope=\"project\""
echo "  /security-check --target=\"config\""
echo ""
echo "Try these commands in Gemini CLI!"
EOF
    
    chmod +x "$demo_dir/demo.sh"
    
    # Create example configuration
    cat > "$demo_dir/example-mcp-config.json" << 'EOF'
{
  "mcpServers": {
    "example-server": {
      "command": "npx",
      "args": ["some-mcp-server"],
      "env": {}
    },
    "ramparts": {
      "command": "npx",
      "args": ["-y", "ramparts-mcp-server"],
      "env": {
        "RAMPARTS_PORT": "3001"
      }
    }
  }
}
EOF
    
    print_success "Demo files created in $demo_dir"
}

run_integration_test() {
    print_step "Running integration test..."
    
    # Test TOML commands
    local commands_dir="$HOME/.gemini/commands"
    if [ -d "$commands_dir" ]; then
        local found_commands=$(find "$commands_dir" -name "*.toml" | wc -l)
        if [ "$found_commands" -gt 0 ]; then
            print_success "Found $found_commands TOML commands installed"
        else
            print_warning "No TOML commands found"
        fi
    else
        print_warning "Gemini commands directory not found"
    fi
    
    # Test MCP server package
    if npm list -g ramparts-mcp-server &> /dev/null; then
        print_success "MCP server package installed globally"
    elif npm list ramparts-mcp-server &> /dev/null; then
        print_success "MCP server package installed locally"
    else
        print_warning "MCP server package not found"
    fi
    
    # Test Gemini configuration
    local gemini_config="$HOME/.gemini/settings.json"
    if [ -f "$gemini_config" ]; then
        if grep -q "ramparts" "$gemini_config"; then
            print_success "Ramparts found in Gemini configuration"
        else
            print_warning "Ramparts not found in Gemini configuration"
        fi
    else
        print_warning "Gemini configuration file not found"
    fi
}

show_completion_summary() {
    echo ""
    print_success "🎉 Complete Integration Setup Finished!"
    echo ""
    print_info "What was installed:"
    echo "✅ TOML-based slash commands in ~/.gemini/commands/"
    echo "✅ Ramparts MCP server (ramparts-mcp-server)"
    echo "✅ Gemini CLI configuration updated"
    echo "✅ Demo and example files created"
    echo ""
    print_info "Available Commands:"
    echo ""
    echo "📋 TOML Commands (immediate use):"
    echo "  /ramparts-scan <url>     - Scan specific MCP server"
    echo "  /ramparts-audit          - Comprehensive security audit"
    echo "  /ramparts-quick [target] - Quick security health check"
    echo "  /security:scan <target>  - Advanced security scanning"
    echo "  /security:monitor        - Setup continuous monitoring"
    echo ""
    echo "🔧 MCP Prompts (advanced features):"
    echo "  /security-scan --url=\"https://api.example.com/mcp/\""
    echo "  /security-audit --scope=\"global\""
    echo "  /security-check --target=\"all\""
    echo "  /vulnerability-analysis --vulnerability=\"XSS\""
    echo "  /compliance-check --standard=\"owasp\""
    echo ""
    print_info "Next Steps:"
    echo "1. 🛠️  Install Ramparts if not already done:"
    echo "   cargo install ramparts"
    echo ""
    echo "2. 🚀 Start Gemini CLI:"
    echo "   gemini"
    echo ""
    echo "3. 🧪 Try a quick test:"
    echo "   > /ramparts-quick config"
    echo ""
    echo "4. 📖 View demo commands:"
    echo "   $HOME/.ramparts-gemini-demo/demo.sh"
    echo ""
    print_info "Documentation & Support:"
    echo "🌐 GitHub: https://github.com/getjavelin/ramparts"
    echo "📚 Docs: https://github.com/getjavelin/ramparts#gemini-cli-integration"
    echo "🐛 Issues: https://github.com/getjavelin/ramparts/issues"
    echo ""
    print_success "Happy secure coding! 🛡️✨"
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "This script installs complete Ramparts integration for Gemini CLI"
    echo ""
    echo "Options:"
    echo "  --skip-checks   Skip prerequisite checks"
    echo "  --no-demo       Don't create demo files"
    echo "  --help          Show this help message"
    echo ""
    echo "What gets installed:"
    echo "  • TOML-based slash commands"
    echo "  • MCP server integration"
    echo "  • Gemini CLI configuration"
    echo "  • Demo and example files"
}

cleanup() {
    # Clean up temporary files
    if [ -n "$INSTALLER_SCRIPTS_DIR" ] && [ -d "$INSTALLER_SCRIPTS_DIR" ]; then
        rm -rf "$INSTALLER_SCRIPTS_DIR"
    fi
}

# Trap cleanup on exit
trap cleanup EXIT

# Main execution
main() {
    local skip_checks=false
    local create_demo=true
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-checks)
                skip_checks=true
                shift
                ;;
            --no-demo)
                create_demo=false
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
    
    if [ "$skip_checks" = false ]; then
        check_prerequisites
        check_ramparts
    fi
    
    download_installer_scripts
    install_slash_commands
    install_mcp_server
    
    if [ "$create_demo" = true ]; then
        create_demo_commands
    fi
    
    run_integration_test
    show_completion_summary
}

# Run main function with all arguments
main "$@"