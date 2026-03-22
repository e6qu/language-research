(ns hello.cli
  (:gen-class))

(defn parse-args
  "Parse command-line arguments into an options map."
  [args]
  (loop [args args
         opts {:name "world" :shout false}]
    (if (empty? args)
      opts
      (case (first args)
        "--name" (recur (drop 2 args) (assoc opts :name (second args)))
        "--shout" (recur (rest args) (assoc opts :shout true))
        "--help" (assoc opts :help true)
        (recur (rest args) opts)))))

(defn format-greeting
  "Format a greeting from parsed options."
  [{:keys [name shout]}]
  (let [msg (str "Hello, " name "!")]
    (if shout (.toUpperCase msg) msg)))

(defn -main [& args]
  (let [opts (parse-args args)]
    (if (:help opts)
      (println "Usage: hello-cli [--name NAME] [--shout] [--help]")
      (println (format-greeting opts)))))
