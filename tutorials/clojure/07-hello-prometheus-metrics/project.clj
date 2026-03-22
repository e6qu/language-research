(defproject hello-metrics "0.1.0"
  :description "Hello Prometheus Metrics"
  :dependencies [[org.clojure/clojure "1.12.0"]
                 [ring/ring-core "1.13.0"]
                 [ring/ring-jetty-adapter "1.13.0"]
                 [compojure "1.7.1"]]
  :main hello.metrics
  :aot [hello.metrics]
  :profiles {:uberjar {:aot :all}})
