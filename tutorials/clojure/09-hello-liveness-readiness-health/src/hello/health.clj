(ns hello.health
  (:require [ring.adapter.jetty :as jetty]
            [compojure.core :refer [defroutes GET]]
            [compojure.route :as route]
            [clojure.data.json :as json])
  (:gen-class))

;; --- Dependency tracking ---

(def dependencies (atom {:database {:healthy true :latency-ms 5}
                         :cache    {:healthy true :latency-ms 2}
                         :queue    {:healthy true :latency-ms 8}}))

(def alive (atom true))
(def ready (atom true))

(defn set-dependency-status! [dep healthy & {:keys [latency-ms]}]
  (swap! dependencies assoc-in [dep :healthy] healthy)
  (when latency-ms
    (swap! dependencies assoc-in [dep :latency-ms] latency-ms)))

(defn all-healthy? []
  (every? :healthy (vals @dependencies)))

(defn check-health []
  (let [deps @dependencies
        healthy (all-healthy?)]
    {:status (if healthy "healthy" "degraded")
     :dependencies
     (into {} (map (fn [[k v]]
                     [(name k) {:healthy (:healthy v)
                                :latency_ms (:latency-ms v)}])
                   deps))}))

;; --- JSON helper ---

(defn json-response [status body]
  {:status status
   :headers {"Content-Type" "application/json"}
   :body (json/write-str body)})

;; --- Routes ---

(defroutes app
  (GET "/healthz" []
    (if @alive
      (json-response 200 {:status "alive"})
      (json-response 503 {:status "dead"})))
  (GET "/readyz" []
    (if (and @ready (all-healthy?))
      (json-response 200 {:status "ready"})
      (json-response 503 {:status "not ready"})))
  (GET "/health" []
    (let [report (check-health)
          code (if (= "healthy" (:status report)) 200 503)]
      (json-response code report)))
  (route/not-found (json-response 404 {:error "not found"})))

(defn -main [& args]
  (let [port (Integer/parseInt (or (first args) "4103"))]
    (println (str "Listening on port " port))
    (jetty/run-jetty app {:port port :join? true})))
