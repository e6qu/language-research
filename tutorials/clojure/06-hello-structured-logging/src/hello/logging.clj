(ns hello.logging
  (:require [clojure.data.json :as json])
  (:gen-class))

(def log-level-order {:debug 0 :info 1 :warn 2 :error 3})

(def ^:dynamic *min-level* :info)

(defn should-log? [level]
  (>= (get log-level-order level 0)
      (get log-level-order *min-level* 0)))

(defn log-entry
  "Build a structured log entry map."
  [level message & {:as extra}]
  (merge {:timestamp (str (java.time.Instant/now))
          :level (name level)
          :message message}
         extra))

(defn log-json
  "Emit a JSON log line to *out*."
  [level message & {:as extra}]
  (when (should-log? level)
    (println (json/write-str (apply log-entry level message (mapcat identity extra))))))

(defn log-info  [msg & {:as extra}] (apply log-json :info msg (mapcat identity extra)))
(defn log-warn  [msg & {:as extra}] (apply log-json :warn msg (mapcat identity extra)))
(defn log-error [msg & {:as extra}] (apply log-json :error msg (mapcat identity extra)))
(defn log-debug [msg & {:as extra}] (apply log-json :debug msg (mapcat identity extra)))

(defn -main [& _args]
  (log-info "Application started" :component "main" :version "0.1.0")
  (log-debug "Debug details" :trace-id "abc123")
  (log-warn "Disk space low" :disk-pct 92)
  (log-error "Connection failed" :host "db.local" :retries 3))
