(ns hello.concurrent-test
  (:require [clojure.test :refer :all]
            [hello.concurrent :refer :all]))

(deftest fetch-url-test
  (let [result (fetch-url "http://example.com")]
    (is (= 200 (:status result)))
    (is (= "http://example.com" (:url result)))))

(deftest fetch-all-empty-test
  (is (= [] (fetch-all []))))

(deftest fetch-all-concurrent-test
  (let [urls ["http://a.com" "http://b.com" "http://c.com"]
        start (System/currentTimeMillis)
        results (fetch-all urls)
        elapsed (- (System/currentTimeMillis) start)]
    (is (= 3 (count results)))
    (is (every? #(= 200 (:status %)) results))
    ;; Concurrent should be faster than sequential (3 * 10ms)
    (is (< elapsed 100))))

(deftest parallel-sum-test
  (is (= 0 (parallel-sum [])))
  (is (= 55 (parallel-sum (range 1 11)))))

(deftest counter-demo-test
  (is (= 4000 (counter-demo 4 1000)))
  (is (= 0 (counter-demo 0 100))))
