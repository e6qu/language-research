import hello;
import std.stdio;
import std.datetime.stopwatch : StopWatch;

void main() {
    enum numTasks = 8;

    StopWatch sw;

    sw.start();
    auto seqResult = runSequential(numTasks);
    sw.stop();
    auto seqTime = sw.peek.total!"msecs";

    sw.reset();
    sw.start();
    auto parResults = runParallel(numTasks);
    sw.stop();
    auto parTime = sw.peek.total!"msecs";

    long parTotal = 0;
    foreach (r; parResults) parTotal += r;

    writefln("Sequential: %d ms (total=%d)", seqTime, seqResult);
    writefln("Parallel:   %d ms (total=%d)", parTime, parTotal);
    writefln("Tasks: %d", numTasks);
}
