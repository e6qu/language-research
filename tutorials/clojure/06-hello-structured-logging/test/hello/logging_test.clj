(ns hello.logging-test
  (:require [clojure.test :refer :all]
            [hello.logging :refer :all]
            [clojure.data.json :as json]))

(deftest log-entry-test
  (let [entry (log-entry :info "test message" :key "val")]
    (is (= "info" (:level entry)))
    (is (= "test message" (:message entry)))
    (is (= "val" (:key entry)))
    (is (contains? entry :timestamp))))

(deftest should-log-test
  (binding [*min-level* :info]
    (is (true? (should-log? :info)))
    (is (true? (should-log? :error)))
    (is (false? (should-log? :debug)))))

(deftest log-json-output-test
  (let [output (with-out-str (log-info "hello" :k "v"))
        parsed (json/read-str output :key-fn keyword)]
    (is (= "info" (:level parsed)))
    (is (= "hello" (:message parsed)))
    (is (= "v" (:k parsed)))))

(deftest log-json-filtering-test
  (binding [*min-level* :warn]
    (is (= "" (with-out-str (log-info "filtered"))))
    (is (not= "" (with-out-str (log-warn "visible"))))))
