module hello;

import std.parallelism : parallel, taskPool, task;
import std.array : array;
import std.algorithm : map, sum;
import std.range : iota;
import std.conv : to;

long computeWork(int id) {
    // Simulate CPU work: sum of squares
    long total = 0;
    foreach (i; 0 .. 100_000) {
        total += cast(long) i * i;
    }
    return total;
}

long[] runParallel(int numTasks) {
    auto ids = iota(numTasks).array;
    long[] results;
    results.length = numTasks;

    foreach (i, id; taskPool.parallel(ids)) {
        results[i] = computeWork(id);
    }

    return results;
}

long runSequential(int numTasks) {
    long total = 0;
    foreach (i; 0 .. numTasks) {
        total += computeWork(i);
    }
    return total;
}

unittest {
    auto result = computeWork(0);
    assert(result > 0);

    auto results = runParallel(4);
    assert(results.length == 4);
    foreach (r; results) {
        assert(r > 0);
    }

    // All tasks compute the same work, so results should be equal
    assert(results[0] == results[1]);
    assert(results[1] == results[2]);

    auto seqTotal = runSequential(4);
    assert(seqTotal > 0);
    assert(seqTotal == results[0] * 4);
}
