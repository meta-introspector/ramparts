// tests/integration_clean_mcp.rs

use std::process::{Command, Stdio};
use std::thread;
use std::time::Duration;
use std::net::TcpListener;
use std::io::{Read, Write};

/// Helper to find an available TCP port
fn find_free_port() -> u16 {
    TcpListener::bind("127.0.0.1:0")
        .unwrap()
        .local_addr()
        .unwrap()
        .port()
}

/// Starts a clean mock MCP server with only benign content.
fn start_clean_mock_server(port: u16) -> std::thread::JoinHandle<()> {
    thread::spawn(move || {
        let listener = TcpListener::bind(("127.0.0.1", port)).unwrap();
        for mut stream in listener.incoming().flatten() {
            let mut buf = [0u8; 4096];
            let n = match stream.read(&mut buf) {
                Ok(n) => n,
                Err(_) => continue,
            };
            let req = String::from_utf8_lossy(&buf[..n]);
            let json_start = req.find("\r\n\r\n").map(|i| i + 4).unwrap_or(0);
            let body = &req[json_start..];
            let mut method = String::new();
            let mut id = 1;
            if let Ok(val) = serde_json::from_str::<serde_json::Value>(body) {
                method = val["method"].as_str().unwrap_or("").to_string();
                id = val["id"].as_i64().unwrap_or(1);
            }
            let response = match method.as_str() {
                "initialize" => format!(
                    r#"{{"jsonrpc":"2.0","id":{},"result":{{"serverInfo":{{"name":"Clean Server","version":"1.0"}},"capabilities":{{"tools":{{}},"resources":{{}},"prompts":{{}}}}}}}}"#, id),
                "tools/list" => format!(
                    r#"{{"jsonrpc":"2.0","id":{},"result":{{"tools":[{{"name":"benign_tool","description":"Adds numbers"}}]}}}}"#, id),
                "resources/list" => format!(
                    r#"{{"jsonrpc":"2.0","id":{},"result":{{"resources":[]}}}}"#, id),
                "prompts/list" => format!(
                    r#"{{"jsonrpc":"2.0","id":{},"result":{{"prompts":[{{"name":"greeting","content":"Say hello"}}]}}}}"#, id),
                _ => format!(
                    r#"{{"jsonrpc":"2.0","id":{},"error":{{"code":-32601,"message":"Method not found"}}}}"#, id),
            };
            let http_resp = format!(
                "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: {}\r\n\r\n{}",
                response.len(), response
            );
            let _ = stream.write_all(http_resp.as_bytes());
        }
    })
}

#[test]
fn integration_no_risks_detected() {
    let port = find_free_port();
    let _handle = start_clean_mock_server(port);
    thread::sleep(Duration::from_millis(200));

    let output = Command::new("cargo")
        .args(["run", "--", "scan", &format!("http://127.0.0.1:{}", port)])
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output()
        .expect("Failed to execute ramparts scan");

    let stdout = String::from_utf8_lossy(&output.stdout).to_lowercase();
    let stderr = String::from_utf8_lossy(&output.stderr).to_lowercase();

    // The output should NOT contain any warning/critical status
    assert!(!stdout.contains("warning"), "stdout should not contain warnings");
    assert!(!stdout.contains("critical"), "stdout should not contain critical issues");
    assert!(!stderr.contains("warning"), "stderr should not contain warnings");
    assert!(!stderr.contains("critical"), "stderr should not contain critical issues");

    // It should mention the benign tool
    assert!(stdout.contains("benign_tool") || stderr.contains("benign_tool"), "Output should mention benign_tool");
} 