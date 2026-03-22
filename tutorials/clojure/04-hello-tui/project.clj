(defproject hello-tui "0.1.0"
  :description "Hello TUI"
  :dependencies [[org.clojure/clojure "1.12.0"]]
  :main hello.tui
  :aot [hello.tui]
  :profiles {:uberjar {:aot :all}})
