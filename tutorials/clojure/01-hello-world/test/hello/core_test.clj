(ns hello.core-test
  (:require [clojure.test :refer :all]
            [hello.core :refer :all]))

(deftest greet-test
  (is (= "Hello, world!" (greet)))
  (is (= "Hello, Alice!" (greet "Alice")))
  (is (= "Hello, world!" (greet "")))
  (is (= "Hello, world!" (greet nil))))
