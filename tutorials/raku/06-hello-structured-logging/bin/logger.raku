use lib 'lib';
use Logger;

say log-info("application started", :version("1.0"), :pid(42));
say log-warn("high memory usage", :percent(85));
say log-error("connection failed", :host("db.local"));
