(ns hello.openapi
  (:require [clojure.data.json :as json])
  (:gen-class))

(defn make-schema
  "Build an OpenAPI 3.0 spec as a Clojure map."
  [{:keys [title version description]}]
  {:openapi "3.0.3"
   :info {:title title
          :version version
          :description description}
   :paths
   {"/"
    {:get
     {:summary "Root greeting"
      :operationId "getRoot"
      :responses
      {"200"
       {:description "Successful response"
        :content
        {"application/json"
         {:schema
          {:type "object"
           :properties
           {:message {:type "string"}}
           :required ["message"]}}}}}}}
    "/greet/{name}"
    {:get
     {:summary "Greet by name"
      :operationId "greetByName"
      :parameters
      [{:name "name"
        :in "path"
        :required true
        :schema {:type "string"}}]
      :responses
      {"200"
       {:description "Greeting response"
        :content
        {"application/json"
         {:schema
          {:type "object"
           :properties
           {:message {:type "string"}}
           :required ["message"]}}}}}}}}})

(defn schema->json
  "Serialize OpenAPI schema to JSON string."
  [schema]
  (json/write-str schema))

(defn validate-schema
  "Basic validation: check required top-level keys."
  [schema]
  (let [required-keys [:openapi :info :paths]
        missing (filter #(not (contains? schema %)) required-keys)]
    (if (empty? missing)
      {:valid true}
      {:valid false :missing (mapv name missing)})))

(defn get-operation-ids
  "Extract all operationIds from the spec."
  [schema]
  (for [[_path methods] (:paths schema)
        [_method details] methods
        :when (:operationId details)]
    (:operationId details)))

(defn -main [& _args]
  (let [schema (make-schema {:title "Hello API"
                             :version "1.0.0"
                             :description "A greeting API"})]
    (println (json/write-str schema :indent true))
    (println (str "\nValidation: " (validate-schema schema)))
    (println (str "Operations: " (vec (get-operation-ids schema))))))
