(defproject hello-concurrency "0.1.0"
  :description "Hello Concurrency"
  :dependencies [[org.clojure/clojure "1.12.0"]]
  :main hello.concurrent
  :aot [hello.concurrent]
  :profiles {:uberjar {:aot :all}})
