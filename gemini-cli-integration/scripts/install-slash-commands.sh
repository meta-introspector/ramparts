#!/bin/bash

# Ramparts Gemini CLI Integration - Slash Commands Installer
# This script installs TOML-based slash commands for Gemini CLI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/getjavelin/ramparts"
COMMANDS_DIR_USER="$HOME/.gemini/commands"
COMMANDS_DIR_PROJECT=".gemini/commands"
TEMP_DIR="/tmp/ramparts-gemini-install"

print_header() {
    echo -e "${BLUE}🛡️ Ramparts Gemini CLI Integration Installer${NC}"
    echo -e "${BLUE}=============================================${NC}"
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
    
    # Check if Gemini CLI is installed
    if ! command -v gemini &> /dev/null && ! command -v npx &> /dev/null; then
        print_error "Gemini CLI is not installed. Please install it first:"
        echo "  npm install -g @google/gemini-cli"
        echo "  or use: npx @google/gemini-cli"
        exit 1
    fi
    
    # Check if git is available
    if ! command -v git &> /dev/null; then
        print_error "Git is required but not installed."
        exit 1
    fi
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --user          Install commands for current user only (default)"
    echo "  --project       Install commands for current project only"
    echo "  --both          Install commands for both user and project"
    echo "  --uninstall     Remove installed commands"
    echo "  --update        Update existing commands"
    echo "  --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Install user-level commands"
    echo "  $0 --project          # Install project-level commands"
    echo "  $0 --both             # Install both user and project commands"
    echo "  $0 --update           # Update existing commands"
    echo "  $0 --uninstall        # Remove all installed commands"
}

download_commands() {
    local dest_dir="$1"
    
    print_info "Downloading Ramparts slash commands..."
    
    # Create temporary directory
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    # Download the commands
    local commands=(
        "ramparts-scan.toml"
        "ramparts-audit.toml" 
        "ramparts-quick.toml"
        "security/scan.toml"
        "security/monitor.toml"
    )
    
    for cmd in "${commands[@]}"; do
        local url="${REPO_URL}/raw/feature/gemini-cli-integration/gemini-cli-integration/slash-commands/${cmd}"
        local dest_file="${TEMP_DIR}/${cmd}"
        
        # Create directory if needed
        mkdir -p "$(dirname "$dest_file")"
        
        print_info "Downloading $cmd..."
        if curl -fsSL "$url" -o "$dest_file"; then
            print_success "Downloaded $cmd"
        else
            print_error "Failed to download $cmd"
            return 1
        fi
    done
    
    return 0
}

install_commands() {
    local install_type="$1"
    local dest_dir=""
    
    case "$install_type" in
        "user")
            dest_dir="$COMMANDS_DIR_USER"
            print_info "Installing user-level commands to $dest_dir"
            ;;
        "project")
            dest_dir="$COMMANDS_DIR_PROJECT"
            print_info "Installing project-level commands to $dest_dir"
            ;;
        *)
            print_error "Invalid install type: $install_type"
            return 1
            ;;
    esac
    
    # Create destination directory
    mkdir -p "$dest_dir"
    mkdir -p "$dest_dir/security"
    
    # Download commands
    if ! download_commands "$dest_dir"; then
        print_error "Failed to download commands"
        return 1
    fi
    
    # Copy commands to destination
    print_info "Installing commands..."
    
    cp "$TEMP_DIR/ramparts-scan.toml" "$dest_dir/"
    cp "$TEMP_DIR/ramparts-audit.toml" "$dest_dir/"
    cp "$TEMP_DIR/ramparts-quick.toml" "$dest_dir/"
    cp "$TEMP_DIR/security/scan.toml" "$dest_dir/security/"
    cp "$TEMP_DIR/security/monitor.toml" "$dest_dir/security/"
    
    print_success "Commands installed to $dest_dir"
    
    # Show installed commands
    echo ""
    print_info "Installed commands:"
    echo "  /ramparts-scan <url>     - Scan MCP server for vulnerabilities"
    echo "  /ramparts-audit          - Comprehensive security audit"
    echo "  /ramparts-quick [target] - Quick security check"
    echo "  /security:scan <target>  - Advanced security scanning"
    echo "  /security:monitor        - Set up continuous monitoring"
    
    # Cleanup
    rm -rf "$TEMP_DIR"
    
    return 0
}

uninstall_commands() {
    local removed_any=false
    
    print_info "Removing Ramparts slash commands..."
    
    # Remove user commands
    if [ -d "$COMMANDS_DIR_USER" ]; then
        local user_commands=(
            "$COMMANDS_DIR_USER/ramparts-scan.toml"
            "$COMMANDS_DIR_USER/ramparts-audit.toml"
            "$COMMANDS_DIR_USER/ramparts-quick.toml"
            "$COMMANDS_DIR_USER/security/scan.toml"
            "$COMMANDS_DIR_USER/security/monitor.toml"
        )
        
        for cmd in "${user_commands[@]}"; do
            if [ -f "$cmd" ]; then
                rm "$cmd"
                print_success "Removed $(basename "$cmd") from user commands"
                removed_any=true
            fi
        done
        
        # Remove security directory if empty
        if [ -d "$COMMANDS_DIR_USER/security" ] && [ -z "$(ls -A "$COMMANDS_DIR_USER/security")" ]; then
            rmdir "$COMMANDS_DIR_USER/security"
        fi
    fi
    
    # Remove project commands
    if [ -d "$COMMANDS_DIR_PROJECT" ]; then
        local project_commands=(
            "$COMMANDS_DIR_PROJECT/ramparts-scan.toml"
            "$COMMANDS_DIR_PROJECT/ramparts-audit.toml"
            "$COMMANDS_DIR_PROJECT/ramparts-quick.toml"
            "$COMMANDS_DIR_PROJECT/security/scan.toml"
            "$COMMANDS_DIR_PROJECT/security/monitor.toml"
        )
        
        for cmd in "${project_commands[@]}"; do
            if [ -f "$cmd" ]; then
                rm "$cmd"
                print_success "Removed $(basename "$cmd") from project commands"
                removed_any=true
            fi
        done
        
        # Remove security directory if empty
        if [ -d "$COMMANDS_DIR_PROJECT/security" ] && [ -z "$(ls -A "$COMMANDS_DIR_PROJECT/security")" ]; then
            rmdir "$COMMANDS_DIR_PROJECT/security"
        fi
    fi
    
    if [ "$removed_any" = true ]; then
        print_success "Ramparts slash commands removed"
    else
        print_warning "No Ramparts slash commands found to remove"
    fi
}

check_ramparts_installation() {
    print_info "Checking Ramparts installation..."
    
    if command -v ramparts &> /dev/null; then
        local version=$(ramparts --version 2>/dev/null | head -1 || echo "unknown")
        print_success "Ramparts is installed: $version"
        return 0
    else
        print_warning "Ramparts is not installed. Install it with:"
        echo "  cargo install ramparts"
        echo ""
        print_warning "Commands will be installed but won't work until Ramparts is available."
        return 1
    fi
}

show_post_install_instructions() {
    echo ""
    print_info "🎉 Installation complete!"
    echo ""
    print_info "Next steps:"
    echo "1. Make sure Ramparts is installed: cargo install ramparts"
    echo "2. Start Gemini CLI: gemini"
    echo "3. Try the new security commands:"
    echo "   > /ramparts-quick config"
    echo "   > /ramparts-scan https://api.example.com/mcp/"
    echo "   > /ramparts-audit"
    echo ""
    print_info "For advanced integration, consider installing the MCP server:"
    echo "   npm install -g ramparts-mcp-server"
    echo ""
    print_info "Documentation: https://github.com/getjavelin/ramparts#gemini-cli-integration"
}

# Main execution
main() {
    local install_type="user"
    local action="install"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --user)
                install_type="user"
                shift
                ;;
            --project)
                install_type="project"
                shift
                ;;
            --both)
                install_type="both"
                shift
                ;;
            --uninstall)
                action="uninstall"
                shift
                ;;
            --update)
                action="update"
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
            uninstall_commands
            exit 0
            ;;
        "install"|"update")
            check_prerequisites
            check_ramparts_installation
            
            case "$install_type" in
                "user")
                    install_commands "user"
                    ;;
                "project")
                    install_commands "project"
                    ;;
                "both")
                    install_commands "user"
                    install_commands "project"
                    ;;
            esac
            
            show_post_install_instructions
            ;;
    esac
}

# Run main function with all arguments
main "$@"