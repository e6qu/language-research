(ns hello.tui-test
  (:require [clojure.test :refer :all]
            [hello.tui :refer :all]))

(deftest make-state-test
  (let [state (make-state)]
    (is (= 0 (:selected @state)))
    (is (= 3 (count (:items @state))))))

(deftest move-down-test
  (let [state (make-state)]
    (move-down state)
    (is (= 1 (:selected @state)))
    (move-down state)
    (is (= 2 (:selected @state)))
    ;; Should not exceed max index
    (move-down state)
    (is (= 2 (:selected @state)))))

(deftest move-up-test
  (let [state (make-state)]
    ;; At 0, should stay at 0
    (move-up state)
    (is (= 0 (:selected @state)))
    (move-down state)
    (move-up state)
    (is (= 0 (:selected @state)))))

(deftest add-item-test
  (let [state (make-state)]
    (add-item state "New")
    (is (= 4 (count (:items @state))))
    (is (= "New" (last (:items @state))))))

(deftest render-test
  (let [output (render {:items ["A" "B"] :selected 0})]
    (is (.contains output "A"))
    (is (.contains output "B"))
    (is (.contains output "Hello TUI"))))
