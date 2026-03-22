(defproject hello-cli "0.1.0"
  :description "Hello CLI"
  :dependencies [[org.clojure/clojure "1.12.0"]]
  :main hello.cli
  :aot [hello.cli]
  :profiles {:uberjar {:aot :all}})
