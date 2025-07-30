// tests/integration_risk_cases.rs
// One file containing multiple independent tests, one per risk scenario.
use std::process::{Command, Stdio};
use std::time::Duration;

use ramparts::test_utils::{start_mock_server, Risk};

const BIN: &str = "cargo"; // we use `cargo run --` to invoke Ramparts CLI

fn run_scan(url: &str) -> (String, String) {
    println!("[integration] scanning {url}");
    let output = Command::new(BIN)
        .args(["run", "--", "scan", url])
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output()
        .expect("Failed to run ramparts scan");
    (
        String::from_utf8_lossy(&output.stdout).to_string(),
        String::from_utf8_lossy(&output.stderr).to_string(),
    )
}

macro_rules! risk_test {
    ($name:ident, $risk:expr, $expect:expr, $desc:expr) => {
        #[test]
        #[doc = $desc]
        fn $name() {
            // Start mock server with the given risk
            let (_handle, port) = start_mock_server(vec![$risk]);
            std::thread::sleep(Duration::from_millis(200));
            let url = format!("http://127.0.0.1:{port}");

            // Execute scan and capture output
            let (stdout_raw, stderr_raw) = run_scan(&url);
            let stdout = stdout_raw.to_lowercase();
            let stderr = stderr_raw.to_lowercase();

            // Print captured output for debugging when test fails
            println!("===== Test: {} =====", $desc);
            println!("Request URL: {url}");
            println!("----- STDOUT -----\n{stdout_raw}");
            println!("----- STDERR -----\n{stderr_raw}");

            assert!(stdout.contains($expect) || stderr.contains($expect),
                "Expected to find '{}' in output (risk: {})", $expect, stringify!($risk));
        }
    };
}

// Generate tests with detailed descriptions
risk_test!(detect_tool_poisoning, Risk::ToolPoisoning, "dangerous_tool", "Tool Poisoning – malicious tool description bypassing safety");
risk_test!(detect_rug_pull, Risk::RugPull, "benign_tool", "MCP Rug Pull – tool description changes after initial approval");
risk_test!(detect_cross_origin, Risk::CrossOriginEscalation, "cors", "Cross-Origin Escalation – resource across multiple domains");
risk_test!(detect_data_exfiltration, Risk::DataExfiltration, "secret_dump", "Data Exfiltration – resource leaking sensitive information");
risk_test!(detect_privilege_escalation, Risk::PrivilegeEscalation, "rooter", "Privilege Escalation – tool attempting to gain root access");
risk_test!(detect_path_traversal, Risk::PathTraversal, "leaky", "Path Traversal – resource accessing files outside intended directory");
risk_test!(detect_command_injection, Risk::CommandInjection, "cmd_exec", "Command Injection – tool executing unauthorized system commands");
risk_test!(detect_sql_injection, Risk::SqlInjection, "sql_injector", "SQL Injection – tool manipulating database queries"); 