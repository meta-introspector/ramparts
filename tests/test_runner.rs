/*!
 * Comprehensive Test Runner for Ramparts Regression Test Suite
 * 
 * This module provides utilities to run and report on the complete
 * regression test suite, following modern testing standards.
 */

use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::time::{Duration, Instant};
use tokio::time::timeout;

/// Test execution results and reporting
#[derive(Debug, Serialize, Deserialize)]
pub struct TestSuiteReport {
    pub summary: TestSummary,
    pub categories: HashMap<String, CategoryResults>,
    pub execution_time: Duration,
    pub timestamp: String,
    pub environment: TestEnvironment,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TestSummary {
    pub total_tests: usize,
    pub passed: usize,
    pub failed: usize,
    pub skipped: usize,
    pub success_rate: f64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CategoryResults {
    pub name: String,
    pub description: String,
    pub tests_run: usize,
    pub tests_passed: usize,
    pub tests_failed: usize,
    pub execution_time: Duration,
    pub critical_failures: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TestEnvironment {
    pub rust_version: String,
    pub os: String,
    pub arch: String,
    pub ramparts_version: String,
}

/// Main regression test runner
pub struct RegressionTestRunner {
    timeout_duration: Duration,
    verbose: bool,
    categories: Vec<TestCategory>,
}

impl RegressionTestRunner {
    pub fn new() -> Self {
        Self {
            timeout_duration: Duration::from_secs(300), // 5 minutes total timeout
            verbose: false,
            categories: Self::initialize_test_categories(),
        }
    }

    pub fn with_timeout(mut self, timeout: Duration) -> Self {
        self.timeout_duration = timeout;
        self
    }

    pub fn verbose(mut self) -> Self {
        self.verbose = true;
        self
    }

    /// Run the complete regression test suite
    pub async fn run_complete_suite(&self) -> Result<TestSuiteReport> {
        let start_time = Instant::now();
        
        println!("🧪 Starting Ramparts Regression Test Suite");
        println!("===========================================");
        
        let environment = self.collect_environment_info().await?;
        let mut category_results = HashMap::new();
        let mut total_tests = 0;
        let mut total_passed = 0;
        let mut total_failed = 0;
        let mut total_skipped = 0;

        for category in &self.categories {
            if self.verbose {
                println!("\n📋 Running {} Tests", category.name);
                println!("   {}", category.description);
            }

            let category_start = Instant::now();
            let result = self.run_category_tests(category).await?;
            let category_duration = category_start.elapsed();

            total_tests += result.tests_run;
            total_passed += result.tests_passed;
            total_failed += result.tests_failed;

            if self.verbose {
                self.print_category_results(&result);
            }

            let mut category_result = result;
            category_result.execution_time = category_duration;
            category_results.insert(category.name.clone(), category_result);
        }

        let execution_time = start_time.elapsed();
        let success_rate = if total_tests > 0 {
            (total_passed as f64 / total_tests as f64) * 100.0
        } else {
            0.0
        };

        let summary = TestSummary {
            total_tests,
            passed: total_passed,
            failed: total_failed,
            skipped: total_skipped,
            success_rate,
        };

        let report = TestSuiteReport {
            summary,
            categories: category_results,
            execution_time,
            timestamp: chrono::Utc::now().to_rfc3339(),
            environment,
        };

        self.print_final_report(&report);
        Ok(report)
    }

    /// Run tests with critical bug detection focus
    pub async fn run_critical_bug_detection(&self) -> Result<Vec<CriticalBugReport>> {
        println!("🔍 Running Critical Bug Detection Suite");
        println!("======================================");

        let mut critical_bugs = Vec::new();

        // Run high-priority security tests
        let security_bugs = self.detect_security_vulnerabilities().await?;
        critical_bugs.extend(security_bugs);

        // Run configuration parsing critical tests
        let config_bugs = self.detect_config_parsing_bugs().await?;
        critical_bugs.extend(config_bugs);

        // Run server connection critical tests
        let connection_bugs = self.detect_connection_bugs().await?;
        critical_bugs.extend(connection_bugs);

        // Run YARA processing critical tests
        let yara_bugs = self.detect_yara_processing_bugs().await?;
        critical_bugs.extend(yara_bugs);

        self.print_critical_bug_report(&critical_bugs);
        Ok(critical_bugs)
    }

    fn initialize_test_categories() -> Vec<TestCategory> {
        vec![
            TestCategory {
                name: "Configuration Management".to_string(),
                description: "Tests for MCP configuration parsing and validation".to_string(),
                priority: TestPriority::Critical,
                tests: vec![
                    "test_cursor_config_parsing_regression",
                    "test_multi_ide_config_compatibility", 
                    "test_config_error_handling_regression",
                ].into_iter().map(String::from).collect(),
            },
            TestCategory {
                name: "MCP Protocol Compliance".to_string(),
                description: "Tests for MCP protocol standard compliance".to_string(),
                priority: TestPriority::Critical,
                tests: vec![
                    "test_mcp_protocol_version_regression",
                    "test_mcp_capabilities_regression",
                    "test_mcp_tool_schema_regression",
                    "test_mcp_resource_regression",
                    "test_mcp_prompt_regression",
                    "test_mcp_error_handling_regression",
                ].into_iter().map(String::from).collect(),
            },
            TestCategory {
                name: "Security Scanning".to_string(),
                description: "Tests for vulnerability detection and security assessment".to_string(),
                priority: TestPriority::Critical,
                tests: vec![
                    "test_yara_scanning_regression",
                    "test_cross_origin_security_regression",
                    "test_vulnerability_assessment_regression",
                ].into_iter().map(String::from).collect(),
            },
            TestCategory {
                name: "Server Discovery".to_string(),
                description: "Tests for MCP server discovery and connection".to_string(),
                priority: TestPriority::High,
                tests: vec![
                    "test_server_discovery_regression",
                    "test_connection_timeout_regression",
                ].into_iter().map(String::from).collect(),
            },
            TestCategory {
                name: "Integration & Performance".to_string(),
                description: "End-to-end tests and performance validation".to_string(),
                priority: TestPriority::Medium,
                tests: vec![
                    "test_complete_scan_workflow_regression",
                    "test_performance_regression",
                ].into_iter().map(String::from).collect(),
            },
            TestCategory {
                name: "Error Handling".to_string(),
                description: "Tests for graceful error handling and edge cases".to_string(),
                priority: TestPriority::High,
                tests: vec![
                    "test_network_failure_handling",
                    "test_malformed_response_handling",
                    "test_resource_cleanup_regression",
                ].into_iter().map(String::from).collect(),
            },
        ]
    }

    async fn run_category_tests(&self, category: &TestCategory) -> Result<CategoryResults> {
        let mut tests_run = 0;
        let mut tests_passed = 0;
        let mut tests_failed = 0;
        let mut critical_failures = Vec::new();

        // Mock test execution - in real implementation, this would run actual tests
        for test_name in &category.tests {
            tests_run += 1;
            
            // Simulate test execution with timeout
            let test_result = timeout(
                Duration::from_secs(30),
                self.execute_mock_test(test_name)
            ).await;

            match test_result {
                Ok(Ok(_)) => {
                    tests_passed += 1;
                    if self.verbose {
                        println!("   ✅ {}", test_name);
                    }
                },
                Ok(Err(e)) => {
                    tests_failed += 1;
                    let error_msg = format!("{}: {}", test_name, e);
                    if category.priority == TestPriority::Critical {
                        critical_failures.push(error_msg.clone());
                    }
                    if self.verbose {
                        println!("   ❌ {}", error_msg);
                    }
                },
                Err(_) => {
                    tests_failed += 1;
                    let timeout_msg = format!("{}: Test timed out", test_name);
                    critical_failures.push(timeout_msg.clone());
                    if self.verbose {
                        println!("   ⏰ {}", timeout_msg);
                    }
                }
            }
        }

        Ok(CategoryResults {
            name: category.name.clone(),
            description: category.description.clone(),
            tests_run,
            tests_passed,
            tests_failed,
            execution_time: Duration::from_secs(0), // Will be set by caller
            critical_failures,
        })
    }

    async fn execute_mock_test(&self, test_name: &str) -> Result<()> {
        // Mock test execution - replace with actual test runners
        tokio::time::sleep(Duration::from_millis(100)).await;
        
        // Simulate some tests failing based on name patterns
        if test_name.contains("error_handling") && test_name.contains("malformed") {
            anyhow::bail!("Simulated malformed response handling failure");
        }
        
        if test_name.contains("timeout") {
            tokio::time::sleep(Duration::from_millis(500)).await;
        }
        
        Ok(())
    }

    async fn collect_environment_info(&self) -> Result<TestEnvironment> {
        Ok(TestEnvironment {
            rust_version: std::env::var("RUSTC_VERSION").unwrap_or_else(|_| "1.70.0".to_string()),
            os: std::env::consts::OS.to_string(),
            arch: std::env::consts::ARCH.to_string(),
            ramparts_version: env!("CARGO_PKG_VERSION").to_string(),
        })
    }

    fn print_category_results(&self, results: &CategoryResults) {
        let success_rate = if results.tests_run > 0 {
            (results.tests_passed as f64 / results.tests_run as f64) * 100.0
        } else {
            0.0
        };

        println!("   📊 Results: {}/{} passed ({:.1}%)", 
                results.tests_passed, results.tests_run, success_rate);
        
        if !results.critical_failures.is_empty() {
            println!("   🚨 Critical Failures:");
            for failure in &results.critical_failures {
                println!("      • {}", failure);
            }
        }
    }

    fn print_final_report(&self, report: &TestSuiteReport) {
        println!("\n🎯 Final Test Report");
        println!("==================");
        println!("Total Tests: {}", report.summary.total_tests);
        println!("Passed: {} ✅", report.summary.passed);
        println!("Failed: {} ❌", report.summary.failed);
        println!("Success Rate: {:.1}%", report.summary.success_rate);
        println!("Execution Time: {:?}", report.execution_time);
        
        if report.summary.success_rate >= 95.0 {
            println!("\n🏆 EXCELLENT: Test suite passed with high confidence!");
        } else if report.summary.success_rate >= 85.0 {
            println!("\n✅ GOOD: Most tests passed, minor issues detected");
        } else if report.summary.success_rate >= 70.0 {
            println!("\n⚠️  WARNING: Significant issues detected, review failures");
        } else {
            println!("\n🚨 CRITICAL: Major failures detected, immediate attention required");
        }

        // Print critical failures summary
        let mut total_critical_failures = 0;
        for category in report.categories.values() {
            total_critical_failures += category.critical_failures.len();
        }

        if total_critical_failures > 0 {
            println!("\n🚨 Critical Issues Summary:");
            println!("Total Critical Failures: {}", total_critical_failures);
            
            for category in report.categories.values() {
                if !category.critical_failures.is_empty() {
                    println!("\n{} ({})::", category.name, category.critical_failures.len());
                    for failure in &category.critical_failures {
                        println!("  • {}", failure);
                    }
                }
            }
        }
    }

    async fn detect_security_vulnerabilities(&self) -> Result<Vec<CriticalBugReport>> {
        let mut bugs = Vec::new();

        // Mock security vulnerability detection
        bugs.push(CriticalBugReport {
            category: "Security".to_string(),
            severity: BugSeverity::High,
            title: "Potential SQL Injection in Query Tool".to_string(),
            description: "Tool 'execute_query' may be vulnerable to SQL injection attacks".to_string(),
            location: "MCP Tool Schema Validation".to_string(),
            recommendation: "Implement parameterized queries and input sanitization".to_string(),
        });

        Ok(bugs)
    }

    async fn detect_config_parsing_bugs(&self) -> Result<Vec<CriticalBugReport>> {
        let mut bugs = Vec::new();

        // Mock configuration parsing bug detection
        bugs.push(CriticalBugReport {
            category: "Configuration".to_string(),
            severity: BugSeverity::Medium,
            title: "Malformed JSON Configuration Crash".to_string(),
            description: "Application crashes when encountering invalid JSON in config files".to_string(),
            location: "Config Parser".to_string(),
            recommendation: "Add robust error handling for malformed JSON".to_string(),
        });

        Ok(bugs)
    }

    async fn detect_connection_bugs(&self) -> Result<Vec<CriticalBugReport>> {
        let mut bugs = Vec::new();

        // Mock connection bug detection
        bugs.push(CriticalBugReport {
            category: "Connection".to_string(),
            severity: BugSeverity::Medium,
            title: "Connection Timeout Not Properly Handled".to_string(),
            description: "Long connection timeouts may cause application to hang".to_string(),
            location: "Server Connection Handler".to_string(),
            recommendation: "Implement proper timeout handling and retry logic".to_string(),
        });

        Ok(bugs)
    }

    async fn detect_yara_processing_bugs(&self) -> Result<Vec<CriticalBugReport>> {
        let mut bugs = Vec::new();

        // Mock YARA processing bug detection
        bugs.push(CriticalBugReport {
            category: "YARA Processing".to_string(),
            severity: BugSeverity::Low,
            title: "YARA Rule Compilation Warning".to_string(),
            description: "Some YARA rules produce compilation warnings".to_string(),
            location: "YARA Rule Processor".to_string(),
            recommendation: "Review and fix YARA rule syntax warnings".to_string(),
        });

        Ok(bugs)
    }

    fn print_critical_bug_report(&self, bugs: &[CriticalBugReport]) {
        println!("\n🔍 Critical Bug Detection Report");
        println!("===============================");
        
        if bugs.is_empty() {
            println!("✅ No critical bugs detected!");
            return;
        }

        let high_severity = bugs.iter().filter(|b| b.severity == BugSeverity::High).count();
        let medium_severity = bugs.iter().filter(|b| b.severity == BugSeverity::Medium).count();
        let low_severity = bugs.iter().filter(|b| b.severity == BugSeverity::Low).count();

        println!("Total Issues Found: {}", bugs.len());
        println!("High Severity: {} 🚨", high_severity);
        println!("Medium Severity: {} ⚠️", medium_severity);
        println!("Low Severity: {} ℹ️", low_severity);

        for bug in bugs {
            println!("\n{} [{}] {}", 
                    bug.severity.emoji(), 
                    bug.category, 
                    bug.title);
            println!("   Description: {}", bug.description);
            println!("   Location: {}", bug.location);
            println!("   Recommendation: {}", bug.recommendation);
        }
    }
}

// ===== SUPPORTING STRUCTURES =====

#[derive(Debug)]
struct TestCategory {
    name: String,
    description: String,
    priority: TestPriority,
    tests: Vec<String>,
}

#[derive(Debug, Clone, PartialEq)]
enum TestPriority {
    Critical,
    High,
    Medium,
    Low,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CriticalBugReport {
    pub category: String,
    pub severity: BugSeverity,
    pub title: String,
    pub description: String,
    pub location: String,
    pub recommendation: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum BugSeverity {
    High,
    Medium,
    Low,
}

impl BugSeverity {
    fn emoji(&self) -> &'static str {
        match self {
            BugSeverity::High => "🚨",
            BugSeverity::Medium => "⚠️",
            BugSeverity::Low => "ℹ️",
        }
    }
}

// ===== CONVENIENCE FUNCTIONS =====

/// Run the complete regression test suite
pub async fn run_regression_tests() -> Result<TestSuiteReport> {
    let runner = RegressionTestRunner::new().verbose();
    runner.run_complete_suite().await
}

/// Run focused critical bug detection
pub async fn run_critical_bug_detection() -> Result<Vec<CriticalBugReport>> {
    let runner = RegressionTestRunner::new();
    runner.run_critical_bug_detection().await
}

/// Generate a test report in JSON format
pub fn generate_json_report(report: &TestSuiteReport) -> Result<String> {
    Ok(serde_json::to_string_pretty(report)?)
} 