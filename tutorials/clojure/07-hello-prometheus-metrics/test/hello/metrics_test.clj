(ns hello.metrics-test
  (:require [clojure.test :refer :all]
            [hello.metrics :refer :all]))

(deftest counter-test
  (reset-metrics!)
  (inc-counter! "test_total")
  (inc-counter! "test_total")
  (is (= 2 (get-counter "test_total" {}))))

(deftest counter-labels-test
  (reset-metrics!)
  (inc-counter! "req_total" {:method "GET"})
  (inc-counter! "req_total" {:method "POST"})
  (inc-counter! "req_total" {:method "GET"})
  (is (= 2 (get-counter "req_total" {:method "GET"})))
  (is (= 1 (get-counter "req_total" {:method "POST"}))))

(deftest histogram-test
  (reset-metrics!)
  (observe-histogram! "duration" 0.1)
  (observe-histogram! "duration" 0.5)
  (let [text (format-histograms)]
    (is (.contains text "duration_bucket"))
    (is (.contains text "duration_sum"))
    (is (.contains text "duration_count"))))

(deftest format-labels-test
  (is (= "" (format-labels {})))
  (is (.contains (format-labels {:method "GET"}) "method=\"GET\"")))

(deftest metrics-endpoint-test
  (reset-metrics!)
  (inc-counter! "test_counter")
  (let [response (app {:request-method :get :uri "/metrics"})]
    (is (= 200 (:status response)))
    (is (.contains (:body response) "test_counter"))))
