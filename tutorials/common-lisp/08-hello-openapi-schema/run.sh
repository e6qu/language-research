#!/usr/bin/env bash
set -euo pipefail
sbcl --noinform --non-interactive --load src/openapi.lisp \
     --eval '(let* ((spec (hello-openapi:make-spec
                           :title "Greeting API"
                           :version "1.0.0"
                           :description "A simple greeting service"))
                    (spec (hello-openapi:add-schema spec "Greeting"
                            (hello-openapi:make-schema
                             :type "object"
                             :properties (quote (("message" . (("type" . "string")))))
                             :required (quote ("message")))))
                    (spec (hello-openapi:add-path spec "/greet"
                            (hello-openapi:make-operation
                             :method "get"
                             :summary "Get a greeting"
                             :operation-id "getGreeting"
                             :parameters (list (hello-openapi:make-parameter
                                                :name "name" :in "query"
                                                :type "string"
                                                :description "Name to greet"))
                             :responses (quote (("200" . (("description" . "A greeting")
                                                          ("content" . (("application/json" .
                                                                         (("schema" . (("$ref" . "#/components/schemas/Greeting")))))))))
                                                ("404" . (("description" . "Not found")))))))))
               (format t "~A~%" (hello-openapi:render-json spec)))' \
     --eval '(quit)'
