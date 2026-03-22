(defproject hello "0.1.0"
  :description "Hello World"
  :dependencies [[org.clojure/clojure "1.12.0"]]
  :main hello.core
  :aot [hello.core]
  :profiles {:uberjar {:aot :all}})
