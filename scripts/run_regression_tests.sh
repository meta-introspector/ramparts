#!/bin/bash

# Ramparts Regression Test Suite Runner
# Comprehensive testing script for MCP security scanner

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default configuration
TIMEOUT=300  # 5 minutes
VERBOSE=false
OUTPUT_FORMAT="pretty"
REPORT_FILE=""
TEST_FILTER=""
CRITICAL_ONLY=false

# Function to print colored output
print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Function to show usage
usage() {
    cat << EOF
🧪 Ramparts Regression Test Suite Runner

USAGE:
    $0 [OPTIONS] [TEST_FILTER]

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    -t, --timeout SECONDS   Set test timeout (default: 300)
    -f, --format FORMAT     Output format: pretty, json, junit (default: pretty)
    -o, --output FILE       Write test report to file
    -c, --critical          Run only critical priority tests
    --list                  List available test categories
    --check-deps            Check dependencies and environment

EXAMPLES:
    # Run all regression tests
    $0

    # Run only configuration tests with verbose output
    $0 -v config

    # Run critical tests only and save JSON report
    $0 -c -f json -o test_report.json

    # Run with custom timeout
    $0 -t 600

    # Check environment and dependencies
    $0 --check-deps

TEST CATEGORIES:
    config          Configuration Management tests
    protocol        MCP Protocol Compliance tests  
    security        Security Scanning tests
    discovery       Server Discovery tests
    integration     Integration & Performance tests
    errors          Error Handling tests
    all             Run all test categories (default)

EOF
}

# Function to check dependencies
check_dependencies() {
    print_header "Checking Dependencies"
    
    # Check Rust and Cargo
    if ! command -v cargo &> /dev/null; then
        print_error "Cargo not found. Please install Rust: https://rustup.rs/"
        exit 1
    fi
    
    local rust_version=$(rustc --version 2>/dev/null | cut -d' ' -f2 || echo "unknown")
    print_info "Rust version: $rust_version"
    
    # Check if we can build the project
    print_info "Checking if project builds..."
    if cargo check --quiet; then
        print_success "Project builds successfully"
    else
        print_error "Project build failed. Please fix compilation errors first."
        exit 1
    fi
    
    # Check test dependencies
    print_info "Checking test dependencies..."
    if cargo test --no-run --quiet 2>/dev/null; then
        print_success "Test dependencies are available"
    else
        print_warning "Some test dependencies may be missing"
    fi
    
    print_success "Dependency check completed"
}

# Function to list available tests
list_tests() {
    print_header "Available Test Categories"
    
    cat << EOF
📋 Test Categories:

1. ${PURPLE}Configuration Management${NC} (Critical Priority)
   - Cursor IDE configuration parsing
   - Multi-IDE compatibility testing
   - Error handling for malformed configs
   
2. ${PURPLE}MCP Protocol Compliance${NC} (Critical Priority)
   - Protocol version compatibility
   - Capabilities negotiation
   - Tool schema validation
   - Resource and prompt handling
   
3. ${PURPLE}Security Scanning${NC} (Critical Priority)
   - YARA rule processing
   - Cross-origin security validation
   - Vulnerability assessment
   
4. ${YELLOW}Server Discovery${NC} (High Priority)
   - Multi-IDE server discovery
   - Connection timeout handling
   - Retry logic validation
   
5. ${YELLOW}Integration & Performance${NC} (Medium Priority)
   - End-to-end workflow testing
   - Performance benchmarks
   - Resource utilization
   
6. ${YELLOW}Error Handling${NC} (High Priority)
   - Network failure scenarios
   - Malformed response handling
   - Resource cleanup validation

EOF
}

# Function to run specific test category
run_test_category() {
    local category=$1
    local test_name=""
    
    case $category in
        "config")
            test_name="config_regression_tests"
            ;;
        "protocol")
            test_name="mcp_protocol_regression_tests"
            ;;
        "security")
            test_name="security_scanning_regression_tests"
            ;;
        "discovery")
            test_name="server_discovery_regression_tests"
            ;;
        "integration")
            test_name="integration_regression_tests"
            ;;
        "errors")
            test_name="error_handling_regression_tests"
            ;;
        "all"|"")
            test_name=""
            ;;
        *)
            print_error "Unknown test category: $category"
            print_info "Use --list to see available categories"
            exit 1
            ;;
    esac
    
    local cargo_args=""
    if [[ $VERBOSE == true ]]; then
        cargo_args="$cargo_args -- --nocapture"
    fi
    
    if [[ -n $test_name ]]; then
        print_info "Running $category tests..."
        cargo_args="$cargo_args $test_name"
    else
        print_info "Running all regression tests..."
    fi
    
    # Set timeout
    export RUST_TEST_TIMEOUT=$TIMEOUT
    
    # Check if timeout command is available (not on macOS by default)
    local timeout_cmd=""
    if command -v timeout &> /dev/null; then
        timeout_cmd="timeout ${TIMEOUT}s"
    elif command -v gtimeout &> /dev/null; then
        timeout_cmd="gtimeout ${TIMEOUT}s"
    else
        print_warning "Timeout command not available - running without timeout"
        timeout_cmd=""
    fi
    
    # Run the tests
    if [[ $OUTPUT_FORMAT == "json" ]]; then
        if $timeout_cmd cargo test --package ramparts --test demo_regression_test $cargo_args --format json; then
            print_success "Tests completed successfully"
            return 0
        else
            print_error "Tests failed or timed out"
            return 1
        fi
    else
        if $timeout_cmd cargo test --package ramparts --test demo_regression_test $cargo_args; then
            print_success "Tests completed successfully"
            return 0
        else
            print_error "Tests failed or timed out"
            return 1
        fi
    fi
}

# Function to run critical bug detection
run_critical_detection() {
    print_header "Running Critical Bug Detection"
    
    print_info "Focusing on high-priority security and stability issues..."
    
    # Run critical tests only
    local critical_tests=(
        "test_cursor_config_parsing_demo"
        "test_multi_ide_compatibility_demo"
        "test_security_vulnerability_detection_demo"
        "test_complete_workflow_demo"
        "test_performance_and_timeout_demo"
    )
    
    local failed_tests=0
    local total_tests=${#critical_tests[@]}
    
    for test in "${critical_tests[@]}"; do
        print_info "Running critical test: $test"
        if cargo test --package ramparts --test demo_regression_test $test --quiet; then
            print_success "$test"
        else
            print_error "$test"
            ((failed_tests++))
        fi
    done
    
    print_header "Critical Test Summary"
    print_info "Total critical tests: $total_tests"
    print_info "Passed: $((total_tests - failed_tests))"
    
    if [[ $failed_tests -eq 0 ]]; then
        print_success "All critical tests passed! 🎉"
        return 0
    else
        print_error "$failed_tests critical tests failed!"
        return 1
    fi
}

# Function to generate test report
generate_report() {
    if [[ -n $REPORT_FILE ]]; then
        print_info "Generating test report: $REPORT_FILE"
        
        case $OUTPUT_FORMAT in
            "json")
                cargo test --package ramparts --test demo_regression_test -- --format json > "$REPORT_FILE" 2>/dev/null || true
                ;;
            "junit")
                # Note: Rust doesn't natively support JUnit format, but we can simulate it
                print_warning "JUnit format not natively supported by Rust tests"
                print_info "Using JSON format instead"
                cargo test --package ramparts --test demo_regression_test -- --format json > "$REPORT_FILE" 2>/dev/null || true
                ;;
            *)
                cargo test --package ramparts --test demo_regression_test > "$REPORT_FILE" 2>&1 || true
                ;;
        esac
        
        if [[ -f $REPORT_FILE ]]; then
            print_success "Report saved to: $REPORT_FILE"
        else
            print_warning "Failed to generate report file"
        fi
    fi
}

# Main execution function
main() {
    local start_time=$(date +%s)
    
    print_header "🧪 Ramparts Regression Test Suite"
    print_info "Starting comprehensive testing..."
    print_info "Test timeout: ${TIMEOUT}s"
    print_info "Output format: $OUTPUT_FORMAT"
    
    if [[ $VERBOSE == true ]]; then
        print_info "Verbose mode enabled"
    fi
    
    # Run the appropriate test suite
    local exit_code=0
    
    if [[ $CRITICAL_ONLY == true ]]; then
        run_critical_detection || exit_code=$?
    else
        run_test_category "$TEST_FILTER" || exit_code=$?
    fi
    
    # Generate report if requested
    generate_report
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_header "Test Execution Summary"
    print_info "Total execution time: ${duration}s"
    
    if [[ $exit_code -eq 0 ]]; then
        print_success "🎉 Regression test suite completed successfully!"
        print_info "All functionality verified and no critical bugs detected."
    else
        print_error "💥 Regression test suite failed!"
        print_info "Please review the failed tests and fix any issues."
        
        if [[ $VERBOSE != true ]]; then
            print_info "Run with -v/--verbose for detailed output"
        fi
    fi
    
    exit $exit_code
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -o|--output)
            REPORT_FILE="$2"
            shift 2
            ;;
        -c|--critical)
            CRITICAL_ONLY=true
            shift
            ;;
        --list)
            list_tests
            exit 0
            ;;
        --check-deps)
            check_dependencies
            exit 0
            ;;
        -*)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            TEST_FILTER="$1"
            shift
            ;;
    esac
done

# Validate timeout
if ! [[ "$TIMEOUT" =~ ^[0-9]+$ ]] || [[ $TIMEOUT -lt 30 ]]; then
    print_error "Invalid timeout value. Must be a number >= 30"
    exit 1
fi

# Validate output format
case $OUTPUT_FORMAT in
    "pretty"|"json"|"junit")
        ;;
    *)
        print_error "Invalid output format. Must be: pretty, json, or junit"
        exit 1
        ;;
esac

# Run the main function
main 