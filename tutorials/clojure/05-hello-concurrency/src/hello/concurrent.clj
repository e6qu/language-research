(ns hello.concurrent
  (:gen-class))

(defn fetch-url
  "Simulate fetching a URL with a delay."
  [url]
  (Thread/sleep 10)
  {:url url :status 200 :body (str "Response from " url)})

(defn fetch-all
  "Fetch all URLs concurrently using futures."
  [urls]
  (if (empty? urls)
    []
    (let [futures (mapv #(future (fetch-url %)) urls)]
      (mapv deref futures))))

(defn parallel-sum
  "Sum numbers in parallel using pmap."
  [numbers]
  (if (empty? numbers)
    0
    (reduce + (pmap #(do (Thread/sleep 1) %) numbers))))

(defn counter-demo
  "Demonstrate atom-based concurrent counter."
  [n-threads n-increments]
  (let [counter (atom 0)
        threads (mapv (fn [_]
                        (future
                          (dotimes [_ n-increments]
                            (swap! counter inc))))
                      (range n-threads))]
    (run! deref threads)
    @counter))

(defn -main [& _args]
  (println "=== Concurrent URL Fetch ===")
  (let [urls ["http://example.com/a" "http://example.com/b" "http://example.com/c"]
        results (fetch-all urls)]
    (doseq [r results]
      (println (str "  " (:url r) " -> " (:status r)))))

  (println "\n=== Parallel Sum ===")
  (let [nums (range 1 11)]
    (println (str "  sum(1..10) = " (parallel-sum nums))))

  (println "\n=== Atomic Counter ===")
  (let [result (counter-demo 4 1000)]
    (println (str "  4 threads x 1000 increments = " result))))
