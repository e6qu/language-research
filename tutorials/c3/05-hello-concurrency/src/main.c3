module hello_concurrency;
import std::io;

fn int main(String[] args) {
    io::printn("=== C3 Concurrency Demo ===");
    io::printn("Spawning 4 tasks concurrently...\n");

    Task[4] tasks = {
        { .id = 1, .label = "fetch-users",   .duration_ms = 200 },
        { .id = 2, .label = "fetch-orders",  .duration_ms = 150 },
        { .id = 3, .label = "fetch-products",.duration_ms = 300 },
        { .id = 4, .label = "fetch-config",  .duration_ms = 100 },
    };

    run_tasks(tasks[..]);

    io::printn("\nAll tasks complete.");
    return 0;
}
