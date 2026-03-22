(ns hello.tui
  (:gen-class))

(def esc "\033[")

(defn clear-screen []
  (str esc "2J" esc "H"))

(defn color [code text]
  (str esc code "m" text esc "0m"))

(defn make-state []
  (atom {:items ["Hello" "World" "Clojure"]
         :selected 0}))

(defn move-up [state]
  (swap! state update :selected
         (fn [s] (max 0 (dec s)))))

(defn move-down [state]
  (let [max-idx (dec (count (:items @state)))]
    (swap! state update :selected
           (fn [s] (min max-idx (inc s))))))

(defn add-item [state item]
  (swap! state update :items conj item))

(defn render [{:keys [items selected]}]
  (str (clear-screen)
       (color "1;36" "=== Hello TUI ===") "\n"
       (color "33" "j/k: move  a: add  q: quit") "\n\n"
       (apply str
              (map-indexed
               (fn [i item]
                 (if (= i selected)
                   (str (color "1;32" (str "> " item)) "\n")
                   (str "  " item "\n")))
               items))))

(defn -main [& _args]
  (let [state (make-state)]
    (print (render @state))
    (flush)
    (loop []
      (let [ch (.read System/in)]
        (when (not= ch -1)
          (case (char ch)
            \q (do (print (str esc "2J" esc "H"))
                   (println "Goodbye!")
                   (flush))
            \j (do (move-down state)
                   (print (render @state))
                   (flush)
                   (recur))
            \k (do (move-up state)
                   (print (render @state))
                   (flush)
                   (recur))
            \a (do (add-item state (str "Item-" (count (:items @state))))
                   (print (render @state))
                   (flush)
                   (recur))
            (recur)))))))
