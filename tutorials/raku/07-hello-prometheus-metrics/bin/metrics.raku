use lib 'lib';
use Metrics;

counter-inc("http_requests_total", 1e0, :method("GET"), :path("/"));
counter-inc("http_requests_total", 1e0, :method("GET"), :path("/"));
counter-inc("http_requests_total", 1e0, :method("POST"), :path("/api"));
histogram-observe("request_duration_seconds", 0.12e0, :path("/"));
histogram-observe("request_duration_seconds", 0.45e0, :path("/"));

say metrics-format();
