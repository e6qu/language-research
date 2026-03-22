local metrics = require("src.metrics")
metrics.counter_inc("hello_total")
metrics.counter_inc("hello_total")
print(metrics.format())
