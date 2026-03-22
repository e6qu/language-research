use clap::Parser;

#[derive(Parser, Debug)]
#[command(name = "hello-cli", about = "A friendly greeter")]
struct Args {
    /// Name to greet
    #[arg(short, long, default_value = "World")]
    name: String,

    /// Shout the greeting in uppercase
    #[arg(short, long)]
    shout: bool,
}

fn format_greeting(name: &str, shout: bool) -> String {
    let msg = format!("Hello, {}!", name);
    if shout {
        msg.to_uppercase()
    } else {
        msg
    }
}

fn main() {
    let args = Args::parse();
    println!("{}", format_greeting(&args.name, args.shout));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_greeting_default() {
        assert_eq!(format_greeting("World", false), "Hello, World!");
    }

    #[test]
    fn test_greeting_custom_name() {
        assert_eq!(format_greeting("Rust", false), "Hello, Rust!");
    }

    #[test]
    fn test_greeting_shout() {
        assert_eq!(format_greeting("Rust", true), "HELLO, RUST!");
    }
}
