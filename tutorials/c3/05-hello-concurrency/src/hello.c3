module hello_concurrency;
import std::io;
import std::thread;
import std::time;

struct Task {
    int id;
    char[] label;
    int duration_ms;
}

fn void worker(void* arg) {
    Task* task = (Task*)arg;
    io::printfn("[Task %d] Starting: %s", task.id, task.label);
    time::sleep(time::ms(task.duration_ms));
    io::printfn("[Task %d] Done: %s (%d ms)", task.id, task.label, task.duration_ms);
}

fn void run_tasks(Task[] tasks) {
    // Spawn a thread per task, then join all.
    Thread[16] threads;
    usz count = tasks.len;
    if (count > 16) count = 16;

    for (usz i = 0; i < count; i++) {
        threads[i] = thread::create(&worker, &tasks[i]);
    }
    for (usz i = 0; i < count; i++) {
        threads[i].join();
    }
}
