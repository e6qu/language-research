(load "src/openapi.lisp")

(in-package :cl-user)

(defvar *tests-passed* 0)
(defvar *tests-failed* 0)

(defmacro test-equal (description expected actual)
  `(if (equal ,expected ,actual)
       (progn (incf *tests-passed*)
              (format t "  PASS: ~A~%" ,description))
       (progn (incf *tests-failed*)
              (format t "  FAIL: ~A~%    expected: ~S~%    actual:   ~S~%"
                      ,description ,expected ,actual))))

(defmacro test-contains (description substring value)
  `(if (search ,substring ,value)
       (progn (incf *tests-passed*)
              (format t "  PASS: ~A~%" ,description))
       (progn (incf *tests-failed*)
              (format t "  FAIL: ~A~%    expected to contain: ~S~%    actual: ~S~%"
                      ,description ,substring ,value))))

(format t "~%Running tests...~%")

;; JSON rendering
(test-equal "null" "null" (hello-openapi:render-json nil))
(test-equal "true" "true" (hello-openapi:render-json t))
(test-equal "integer" "42" (hello-openapi:render-json 42))
(test-equal "string" "\"hello\"" (hello-openapi:render-json "hello"))
(test-equal "array" "[1,2,3]" (hello-openapi:render-json '(1 2 3)))
(test-equal "object" "{\"a\":1}" (hello-openapi:render-json '(("a" . 1))))

;; Spec creation
(let* ((spec (hello-openapi:make-spec :title "Test API" :version "2.0.0"))
       (json (hello-openapi:render-json spec)))
  (test-contains "has openapi version" "\"openapi\":\"3.0.3\"" json)
  (test-contains "has title" "\"title\":\"Test API\"" json)
  (test-contains "has version" "\"version\":\"2.0.0\"" json))

;; Add path
(let* ((spec (hello-openapi:make-spec :title "Test"))
       (op (hello-openapi:make-operation
            :method "get"
            :summary "Get greeting"
            :parameters (list (hello-openapi:make-parameter
                               :name "name" :in "query" :type "string"))))
       (spec (hello-openapi:add-path spec "/greet" op))
       (json (hello-openapi:render-json spec)))
  (test-contains "has path" "\"/greet\"" json)
  (test-contains "has method" "\"get\"" json)
  (test-contains "has summary" "\"summary\":\"Get greeting\"" json)
  (test-contains "has param name" "\"name\":\"name\"" json))

;; Add schema
(let* ((spec (hello-openapi:make-spec :title "Test"))
       (schema (hello-openapi:make-schema
                :type "object"
                :properties '(("name" . (("type" . "string")))
                              ("age" . (("type" . "integer"))))
                :required '("name")))
       (spec (hello-openapi:add-schema spec "User" schema))
       (json (hello-openapi:render-json spec)))
  (test-contains "has schema name" "\"User\"" json)
  (test-contains "has property" "\"name\":{\"type\":\"string\"}" json)
  (test-contains "has required" "\"required\"" json))

;; Make response
(let* ((resp (hello-openapi:make-response
              :description "Success"
              :content-type "application/json"
              :schema '(("$ref" . "#/components/schemas/User"))))
       (json (hello-openapi:render-json resp)))
  (test-contains "response desc" "\"description\":\"Success\"" json)
  (test-contains "response ref" "#/components/schemas/User" json))

(format t "~%~D passed, ~D failed~%" *tests-passed* *tests-failed*)
(when (> *tests-failed* 0) (sb-ext:exit :code 1))
(sb-ext:exit :code 0)
