(ns hello.core
  (:gen-class))

(defn greet
  "Return a greeting string."
  ([] "Hello, world!")
  ([name] (if (or (nil? name) (empty? name))
            "Hello, world!"
            (str "Hello, " name "!"))))

(defn -main [& args]
  (println (greet (first args))))
