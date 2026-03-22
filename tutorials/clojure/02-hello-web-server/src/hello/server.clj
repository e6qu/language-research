(ns hello.server
  (:require [ring.adapter.jetty :as jetty]
            [compojure.core :refer [defroutes GET]]
            [compojure.route :as route]
            [clojure.data.json :as json])
  (:gen-class))

(defn json-response [status body]
  {:status status
   :headers {"Content-Type" "application/json"}
   :body (json/write-str body)})

(defroutes app
  (GET "/" [] (json-response 200 {:message "Hello, world!"}))
  (GET "/greet/:name" [name] (json-response 200 {:message (str "Hello, " name "!")}))
  (route/not-found (json-response 404 {:error "not found"})))

(defn -main [& args]
  (let [port (Integer/parseInt (or (first args) "4020"))]
    (println (str "Listening on port " port))
    (jetty/run-jetty app {:port port :join? true})))
