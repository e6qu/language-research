use hello_structured_logging::{do_work, init_logging};

fn main() {
    init_logging();
    do_work("compute", 42);
    do_work("validate", -1);
}
