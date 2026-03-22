(ns hello.health-test
  (:require [clojure.test :refer :all]
            [hello.health :refer :all]
            [clojure.data.json :as json]))

(defn reset-state! []
  (reset! alive true)
  (reset! ready true)
  (reset! dependencies {:database {:healthy true :latency-ms 5}
                        :cache    {:healthy true :latency-ms 2}
                        :queue    {:healthy true :latency-ms 8}}))

(deftest healthz-alive-test
  (reset-state!)
  (let [resp (app {:request-method :get :uri "/healthz"})]
    (is (= 200 (:status resp)))
    (is (.contains (:body resp) "alive"))))

(deftest healthz-dead-test
  (reset-state!)
  (reset! alive false)
  (let [resp (app {:request-method :get :uri "/healthz"})]
    (is (= 503 (:status resp)))))

(deftest readyz-ready-test
  (reset-state!)
  (let [resp (app {:request-method :get :uri "/readyz"})]
    (is (= 200 (:status resp)))))

(deftest readyz-not-ready-test
  (reset-state!)
  (set-dependency-status! :database false)
  (let [resp (app {:request-method :get :uri "/readyz"})]
    (is (= 503 (:status resp)))))

(deftest health-full-test
  (reset-state!)
  (let [resp (app {:request-method :get :uri "/health"})
        body (json/read-str (:body resp) :key-fn keyword)]
    (is (= 200 (:status resp)))
    (is (= "healthy" (:status body)))
    (is (contains? (:dependencies body) :database))))

(deftest health-degraded-test
  (reset-state!)
  (set-dependency-status! :cache false)
  (let [resp (app {:request-method :get :uri "/health"})
        body (json/read-str (:body resp) :key-fn keyword)]
    (is (= 503 (:status resp)))
    (is (= "degraded" (:status body)))))
