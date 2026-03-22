(defproject hello-openapi "0.1.0"
  :description "Hello OpenAPI Schema"
  :dependencies [[org.clojure/clojure "1.12.0"]
                 [org.clojure/data.json "2.5.1"]]
  :main hello.openapi
  :aot [hello.openapi]
  :profiles {:uberjar {:aot :all}})
