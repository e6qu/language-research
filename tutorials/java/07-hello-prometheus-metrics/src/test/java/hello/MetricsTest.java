package hello;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class MetricsTest {

    @Test
    void counterIncrements() {
        var c = new Counter("test_total", "Test counter");
        assertEquals(0, c.get());
        c.inc();
        c.inc();
        assertEquals(2, c.get());
    }

    @Test
    void counterIncByAmount() {
        var c = new Counter("test_total", "Test");
        c.inc(5);
        assertEquals(5, c.get());
    }

    @Test
    void counterPrometheusFormat() {
        var c = new Counter("req_total", "Total requests");
        c.inc();
        String output = c.toPrometheus();
        assertTrue(output.contains("# HELP req_total Total requests"));
        assertTrue(output.contains("# TYPE req_total counter"));
        assertTrue(output.contains("req_total 1"));
    }

    @Test
    void histogramObserve() {
        var h = new Histogram("dur", "Duration", 0.1, 0.5, 1.0);
        h.observe(0.05);
        h.observe(0.3);
        h.observe(2.0);
        assertEquals(3, h.count());
        assertTrue(h.sum() > 2.3);
    }

    @Test
    void histogramPrometheusFormat() {
        var h = new Histogram("dur_seconds", "Duration", 0.1, 0.5, 1.0);
        h.observe(0.05);
        h.observe(0.3);
        String output = h.toPrometheus();
        assertTrue(output.contains("# TYPE dur_seconds histogram"));
        assertTrue(output.contains("dur_seconds_bucket{le=\"0.1\"} 1"));
        assertTrue(output.contains("dur_seconds_bucket{le=\"0.5\"} 2"));
        assertTrue(output.contains("dur_seconds_bucket{le=\"+Inf\"} 2"));
        assertTrue(output.contains("dur_seconds_count 2"));
    }

    @Test
    void registryCollectsAll() {
        var reg = new MetricsRegistry();
        var c = reg.counter("c_total", "Counter");
        var h = reg.histogram("h_seconds", "Hist", 1.0);
        c.inc();
        h.observe(0.5);
        String output = reg.toPrometheus();
        assertTrue(output.contains("c_total 1"));
        assertTrue(output.contains("h_seconds_count 1"));
    }
}
