(defproject hello-logging "0.1.0"
  :description "Hello Structured Logging"
  :dependencies [[org.clojure/clojure "1.12.0"]
                 [org.clojure/data.json "2.5.1"]]
  :main hello.logging
  :aot [hello.logging]
  :profiles {:uberjar {:aot :all}})
