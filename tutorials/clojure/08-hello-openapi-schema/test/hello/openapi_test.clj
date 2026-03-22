(ns hello.openapi-test
  (:require [clojure.test :refer :all]
            [hello.openapi :refer :all]
            [clojure.data.json :as json]))

(def test-schema
  (make-schema {:title "Test" :version "0.1.0" :description "Test API"}))

(deftest make-schema-test
  (is (= "3.0.3" (:openapi test-schema)))
  (is (= "Test" (get-in test-schema [:info :title])))
  (is (contains? (:paths test-schema) "/"))
  (is (contains? (:paths test-schema) "/greet/{name}")))

(deftest schema-json-roundtrip-test
  (let [json-str (schema->json test-schema)
        parsed (json/read-str json-str :key-fn keyword)]
    (is (= "3.0.3" (:openapi parsed)))
    (is (string? json-str))))

(deftest validate-schema-test
  (is (true? (:valid (validate-schema test-schema))))
  (is (false? (:valid (validate-schema {:openapi "3.0.3"})))))

(deftest get-operation-ids-test
  (let [ops (set (get-operation-ids test-schema))]
    (is (contains? ops "getRoot"))
    (is (contains? ops "greetByName"))))
