(defproject hello-web "0.1.0"
  :description "Hello Web Server"
  :dependencies [[org.clojure/clojure "1.12.0"]
                 [ring/ring-core "1.13.0"]
                 [ring/ring-jetty-adapter "1.13.0"]
                 [compojure "1.7.1"]
                 [org.clojure/data.json "2.5.1"]]
  :main hello.server
  :aot [hello.server]
  :profiles {:uberjar {:aot :all}})
