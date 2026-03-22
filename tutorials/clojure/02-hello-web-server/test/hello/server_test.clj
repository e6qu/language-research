(ns hello.server-test
  (:require [clojure.test :refer :all]
            [hello.server :refer :all]
            [clojure.data.json :as json]))

(deftest root-route-test
  (let [response (app {:request-method :get :uri "/"})]
    (is (= 200 (:status response)))
    (is (.contains (:body response) "Hello, world!"))))

(deftest greet-route-test
  (let [response (app {:request-method :get :uri "/greet/Alice"})]
    (is (= 200 (:status response)))
    (is (.contains (:body response) "Hello, Alice!"))))

(deftest not-found-test
  (let [response (app {:request-method :get :uri "/unknown"})]
    (is (= 404 (:status response)))
    (is (.contains (:body response) "not found"))))
