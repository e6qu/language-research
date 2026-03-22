(ns hello.metrics
  (:require [ring.adapter.jetty :as jetty]
            [compojure.core :refer [defroutes GET]]
            [compojure.route :as route])
  (:gen-class))

;; --- Metrics registry (atom-based) ---

(def counters (atom {}))
(def histograms (atom {}))

(defn inc-counter!
  "Increment a counter metric."
  ([name] (inc-counter! name {}))
  ([name labels]
   (swap! counters update [name labels] (fnil inc 0))))

(defn observe-histogram!
  "Record a value in a histogram bucket."
  ([name value] (observe-histogram! name value {}))
  ([name value labels]
   (swap! histograms update [name labels]
          (fnil conj []) value)))

(defn reset-metrics! []
  (reset! counters {})
  (reset! histograms {}))

(defn get-counter [name labels]
  (get @counters [name labels] 0))

;; --- Prometheus text format ---

(defn format-labels [labels]
  (if (empty? labels)
    ""
    (str "{"
         (clojure.string/join ","
           (map (fn [[k v]] (str (name k) "=\"" v "\"")) labels))
         "}")))

(defn format-counters []
  (apply str
    (for [[[metric-name labels] value] @counters]
      (str metric-name (format-labels labels) " " value "\n"))))

(defn format-histograms []
  (apply str
    (for [[[metric-name labels] values] @histograms
          :let [sorted (sort values)
                cnt (clojure.core/count sorted)
                total (reduce + 0.0 sorted)
                buckets [0.005 0.01 0.025 0.05 0.1 0.25 0.5 1.0 5.0 10.0]]]
      (str
        (apply str
          (for [b buckets
                :let [le-count (count (filter #(<= % b) sorted))]]
            (str metric-name "_bucket"
                 (format-labels (assoc labels :le (str b)))
                 " " le-count "\n")))
        metric-name "_bucket"
          (format-labels (assoc labels :le "+Inf"))
          " " cnt "\n"
        metric-name "_sum" (format-labels labels) " " total "\n"
        metric-name "_count" (format-labels labels) " " count "\n"))))

(defn metrics-text []
  (str (format-counters) (format-histograms)))

;; --- HTTP handler ---

(defroutes app
  (GET "/work" []
    (inc-counter! "work_total")
    {:status 200 :headers {"Content-Type" "text/plain"} :body "work done"})
  (GET "/metrics" []
    (inc-counter! "metrics_scrapes_total")
    {:status 200
     :headers {"Content-Type" "text/plain; version=0.0.4"}
     :body (metrics-text)})
  (GET "/" []
    (inc-counter! "http_requests_total" {:method "GET" :path "/"})
    {:status 200 :headers {"Content-Type" "text/plain"} :body "OK"})
  (route/not-found "not found"))

(defn -main [& args]
  (let [port (Integer/parseInt (or (first args) "4101"))]
    ;; Seed some demo metrics
    (inc-counter! "http_requests_total" {:method "GET" :path "/"})
    (observe-histogram! "http_request_duration_seconds" 0.042 {:path "/"})
    (println (str "Listening on port " port))
    (jetty/run-jetty app {:port port :join? true})))
