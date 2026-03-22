(ns hello.cli-test
  (:require [clojure.test :refer :all]
            [hello.cli :refer :all]))

(deftest parse-args-test
  (is (= {:name "world" :shout false} (parse-args [])))
  (is (= {:name "Alice" :shout false} (parse-args ["--name" "Alice"])))
  (is (= {:name "world" :shout true} (parse-args ["--shout"])))
  (is (= {:name "Bob" :shout true} (parse-args ["--name" "Bob" "--shout"]))))

(deftest format-greeting-test
  (is (= "Hello, world!" (format-greeting {:name "world" :shout false})))
  (is (= "Hello, Alice!" (format-greeting {:name "Alice" :shout false})))
  (is (= "HELLO, BOB!" (format-greeting {:name "Bob" :shout true}))))
