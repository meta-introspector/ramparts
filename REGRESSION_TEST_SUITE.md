# 🧪 Ramparts Regression Test Suite

## Overview

This comprehensive regression test suite is designed to identify critical bugs and ensure all existing functionality in the Ramparts MCP Security Scanner continues to work correctly. The test suite follows modern testing standards and implements best practices from the [Testlio regression testing guide](https://testlio.com/blog/regression-test-suite/) and [TechTarget's testing framework principles](https://www.techtarget.com/searchsoftwarequality/tip/How-to-build-a-regression-test-suite).

## 🎯 Test Categories

### 1. **Configuration Management** (Critical Priority)
Tests for MCP configuration parsing and validation across different IDE formats.

**Coverage:**
- Cursor IDE `mcpServers` format parsing
- Multi-IDE configuration compatibility (Claude Desktop, VS Code, Windsurf, etc.)
- Error handling for malformed configurations
- Configuration validation and normalization

**Key Tests:**
- `test_cursor_config_parsing_regression`
- `test_multi_ide_config_compatibility`
- `test_config_error_handling_regression`

### 2. **MCP Protocol Compliance** (Critical Priority)
Tests ensuring compliance with the latest Model Context Protocol specifications.

**Coverage:**
- Protocol version compatibility (2025-03-26, 2024-11-05, 2024-06-25)
- Capabilities negotiation (tools, resources, prompts, logging)
- Tool schema validation and security assessment
- Resource handling and URI scheme validation
- Prompt template validation
- JSON-RPC 2.0 error handling

**Key Tests:**
- `test_mcp_protocol_version_regression`
- `test_mcp_capabilities_regression`
- `test_mcp_tool_schema_regression`
- `test_mcp_resource_regression`
- `test_mcp_prompt_regression`
- `test_mcp_error_handling_regression`

### 3. **Security Scanning** (Critical Priority)
Tests for vulnerability detection and security assessment capabilities.

**Coverage:**
- YARA rule processing and compilation
- Cross-origin security validation
- Tool security risk assessment
- Vulnerability categorization and scoring
- Security recommendation generation

**Key Tests:**
- `test_yara_scanning_regression`
- `test_cross_origin_security_regression`
- `test_vulnerability_assessment_regression`

### 4. **Server Discovery** (High Priority)
Tests for MCP server discovery and connection management.

**Coverage:**
- Multi-IDE server discovery
- Connection timeout handling
- Retry logic validation
- Server health checks

**Key Tests:**
- `test_server_discovery_regression`
- `test_connection_timeout_regression`

### 5. **Integration & Performance** (Medium Priority)
End-to-end tests and performance validation.

**Coverage:**
- Complete scan workflow testing
- Performance benchmarks and scalability
- Resource utilization monitoring
- Memory management validation

**Key Tests:**
- `test_complete_scan_workflow_regression`
- `test_performance_regression`

### 6. **Error Handling** (High Priority)
Tests for graceful error handling and edge cases.

**Coverage:**
- Network failure scenarios
- Malformed response handling
- Resource cleanup validation
- Graceful degradation testing

**Key Tests:**
- `test_network_failure_handling`
- `test_malformed_response_handling`
- `test_resource_cleanup_regression`

## 🚀 Running the Test Suite

### Prerequisites

```bash
# Ensure you have Rust and Cargo installed
rustc --version  # Should be 1.70.0 or later
cargo --version

# Install required dependencies
cargo build
```

### Basic Usage

```bash
# Run the complete regression test suite
cargo test --package ramparts --test regression_test_suite

# Run MCP protocol-specific tests
cargo test --package ramparts --test mcp_protocol_tests

# Run tests with verbose output
cargo test --package ramparts --test regression_test_suite -- --nocapture

# Run only critical priority tests
cargo test --package ramparts --test regression_test_suite critical
```

### Advanced Usage

```bash
# Run with custom timeout (default: 5 minutes)
RUST_TEST_TIMEOUT=300 cargo test --package ramparts --test regression_test_suite

# Generate detailed test report
cargo test --package ramparts --test regression_test_suite -- --format json > test_report.json

# Run critical bug detection focused tests
cargo test --package ramparts --test test_runner critical_bug_detection
```

### Using the Test Runner API

```rust
use ramparts::tests::test_runner::{run_regression_tests, run_critical_bug_detection};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Run complete test suite
    let report = run_regression_tests().await?;
    println!("Success Rate: {:.1}%", report.summary.success_rate);
    
    // Run focused critical bug detection
    let bugs = run_critical_bug_detection().await?;
    println!("Critical bugs found: {}", bugs.len());
    
    Ok(())
}
```

## 📊 Test Results and Reporting

### Success Criteria

- **🏆 Excellent (95%+)**: Test suite passed with high confidence
- **✅ Good (85-94%)**: Most tests passed, minor issues detected
- **⚠️ Warning (70-84%)**: Significant issues detected, review failures
- **🚨 Critical (<70%)**: Major failures detected, immediate attention required

### Report Structure

```json
{
  "summary": {
    "total_tests": 21,
    "passed": 20,
    "failed": 1,
    "success_rate": 95.2
  },
  "categories": {
    "Configuration Management": {
      "tests_run": 3,
      "tests_passed": 3,
      "critical_failures": []
    }
  },
  "execution_time": "45.2s",
  "environment": {
    "rust_version": "1.70.0",
    "os": "macos",
    "ramparts_version": "0.6.3"
  }
}
```

### Critical Bug Detection

The test suite includes specialized detection for:

- **🚨 High Severity**: SQL injection vulnerabilities, code execution risks
- **⚠️ Medium Severity**: Configuration parsing errors, connection timeouts
- **ℹ️ Low Severity**: YARA rule warnings, performance issues

## 🔧 Test Development Guidelines

### Adding New Tests

1. **Identify Test Category**: Choose the appropriate category based on functionality
2. **Define Test Scope**: Clearly specify what the test validates
3. **Implement Test Logic**: Follow the existing patterns and naming conventions
4. **Add Security Assessment**: Include security implications where relevant
5. **Update Documentation**: Add test description to this README

### Test Structure

```rust
#[tokio::test]
async fn test_new_functionality_regression() -> Result<()> {
    // Arrange: Set up test data and fixtures
    let fixture = TestFixture::new()?;
    
    // Act: Execute the functionality being tested
    let result = execute_functionality(&test_data).await?;
    
    // Assert: Verify expected behavior
    assert!(result.is_ok(), "Functionality should work correctly");
    assert_eq!(result.value, expected_value, "Should produce expected result");
    
    // Security Assessment (if applicable)
    let security_check = assess_security_implications(&result);
    assert!(security_check.is_safe(), "Should not introduce security risks");
    
    Ok(())
}
```

### Best Practices

1. **Use Descriptive Names**: Test names should clearly indicate what is being tested
2. **Include Edge Cases**: Test boundary conditions and error scenarios
3. **Mock External Dependencies**: Use fixtures and mocks for external services
4. **Validate Security**: Include security assessments for potentially risky operations
5. **Maintain Independence**: Tests should not depend on each other
6. **Document Expectations**: Include clear assertions with descriptive messages

## 🔍 Critical Bug Detection Focus

### Security Vulnerabilities

The test suite specifically looks for:

- **SQL Injection**: Tools that accept query parameters without validation
- **Command Injection**: Tools that execute system commands
- **Path Traversal**: File operations that don't restrict directory access
- **Cross-Origin Issues**: Servers that don't properly validate origins
- **Input Validation**: Missing or insufficient input sanitization

### Configuration Issues

- **Malformed JSON**: Graceful handling of invalid configuration files
- **Missing Fields**: Proper defaults and error messages for incomplete configs
- **Type Mismatches**: Robust type checking and conversion
- **URL Validation**: Proper validation of server URLs and endpoints

### Connection Problems

- **Timeout Handling**: Proper timeout implementation and retry logic
- **Network Failures**: Graceful degradation when servers are unreachable
- **Protocol Errors**: Handling of invalid MCP responses
- **Resource Leaks**: Proper cleanup of connections and resources

## 📈 Continuous Integration

### GitHub Actions Integration

```yaml
name: Regression Tests
on: [push, pull_request]
jobs:
  regression-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
      - name: Run Regression Tests
        run: cargo test --package ramparts --test regression_test_suite
      - name: Generate Test Report
        run: |
          cargo test --package ramparts --test regression_test_suite -- --format json > test_report.json
      - name: Upload Test Results
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: test_report.json
```

### Pre-commit Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running regression tests..."
cargo test --package ramparts --test regression_test_suite --quiet

if [ $? -ne 0 ]; then
    echo "❌ Regression tests failed. Commit rejected."
    exit 1
fi

echo "✅ All regression tests passed."
```

## 🔧 Maintenance and Updates

### Regular Maintenance

- **Monthly**: Review and update test cases based on new features
- **Quarterly**: Performance benchmarks and scalability assessment
- **Releases**: Full regression suite execution before each release

### Version Control

- Test files are tracked in version control
- Test data fixtures are included in the repository
- Configuration examples are maintained alongside tests

### Documentation Updates

- Keep this README updated with new test categories
- Document any changes to test execution procedures
- Maintain examples and usage patterns

## 🤝 Contributing

To contribute to the regression test suite:

1. **Fork the Repository**: Create your own fork for development
2. **Create Feature Branch**: Use descriptive branch names (e.g., `test/mcp-protocol-v2`)
3. **Add Tests**: Follow the established patterns and guidelines
4. **Update Documentation**: Include your tests in this README
5. **Submit Pull Request**: Include test results and rationale

### Code Review Checklist

- [ ] Tests follow naming conventions
- [ ] Security implications are assessed
- [ ] Edge cases are covered
- [ ] Documentation is updated
- [ ] Tests are independent and reproducible
- [ ] Performance impact is considered

---

## 📚 References

- [Testlio Regression Testing Guide](https://testlio.com/blog/regression-test-suite/)
- [TechTarget Testing Framework](https://www.techtarget.com/searchsoftwarequality/tip/How-to-build-a-regression-test-suite)
- [Model Context Protocol Specification](https://github.com/modelcontextprotocol/typescript-sdk)
- [Rust Testing Documentation](https://doc.rust-lang.org/book/ch11-00-testing.html)
- [YARA-X Rule Writing Guide](https://virustotal.github.io/yara-x/)

**Last Updated**: January 2025
**Version**: 1.0.0
**Maintainer**: Ramparts Development Team 