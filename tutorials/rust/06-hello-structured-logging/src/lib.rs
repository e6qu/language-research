use tracing::{info, warn};

/// Initialize the tracing subscriber with JSON output.
pub fn init_logging() {
    tracing_subscriber::fmt()
        .json()
        .with_target(true)
        .with_level(true)
        .init();
}

/// Initialize logging that writes to a specific writer (for testing).
pub fn init_logging_with_writer<W: std::io::Write + Send + Sync + 'static>(writer: W) {
    let writer = std::sync::Arc::new(std::sync::Mutex::new(writer));
    tracing_subscriber::fmt()
        .json()
        .with_target(true)
        .with_level(true)
        .with_writer(move || -> MutexWriter<W> { MutexWriter(writer.clone()) })
        .init();
}

/// A writer wrapper around Arc<Mutex<W>> that implements std::io::Write.
pub struct MutexWriter<W>(std::sync::Arc<std::sync::Mutex<W>>);

impl<W: std::io::Write> std::io::Write for MutexWriter<W> {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        self.0.lock().unwrap().write(buf)
    }
    fn flush(&mut self) -> std::io::Result<()> {
        self.0.lock().unwrap().flush()
    }
}

/// Perform some work and emit structured log events.
pub fn do_work(task: &str, value: i32) {
    info!(task = task, value = value, "Starting work");
    if value < 0 {
        warn!(task = task, value = value, "Negative value detected");
    }
    info!(task = task, result = value * 2, "Work complete");
}

#[cfg(test)]
mod tests {
    use std::io::BufRead;
    use std::process::Command;

    #[test]
    fn test_log_output_is_valid_json() {
        // Build the binary first, then run it.
        let build = Command::new(env!("CARGO"))
            .args(["build", "--bin", "hello-structured-logging"])
            .output()
            .expect("failed to build binary");
        assert!(build.status.success(), "cargo build failed");

        let mut bin_path = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"));
        bin_path.push("target");
        bin_path.push("debug");
        bin_path.push("hello-structured-logging");

        let output = Command::new(&bin_path)
            .output()
            .expect("failed to run binary");

        // tracing_subscriber with .json() writes to stdout by default.
        let out = String::from_utf8_lossy(&output.stdout);
        let lines: Vec<&str> = out.lines().filter(|l| !l.is_empty()).collect();

        assert!(!lines.is_empty(), "Expected log output on stderr");

        for line in &lines {
            let parsed: Result<serde_json::Value, _> = serde_json::from_str(line);
            assert!(
                parsed.is_ok(),
                "Line is not valid JSON: {}",
                line
            );
            let obj = parsed.unwrap();
            assert!(obj.get("level").is_some(), "Missing 'level' field");
        }
    }
}
