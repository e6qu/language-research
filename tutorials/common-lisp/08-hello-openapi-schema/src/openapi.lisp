(defpackage :hello-openapi
  (:use :cl)
  (:export #:make-spec #:add-path #:add-schema #:render-json
           #:make-schema #:make-operation #:make-response #:make-parameter))

(in-package :hello-openapi)

;;; --- JSON serializer for nested alists ---

(defun json-escape (string)
  (with-output-to-string (out)
    (loop for ch across string
          do (case ch
               (#\" (write-string "\\\"" out))
               (#\\ (write-string "\\\\" out))
               (#\Newline (write-string "\\n" out))
               (otherwise (write-char ch out))))))

(defun render-json (value &optional (stream nil))
  "Render a Lisp value as JSON. Alists become objects, lists become arrays."
  (let ((result
          (with-output-to-string (out)
            (render-json-value value out))))
    (if stream
        (write-string result stream)
        result)))

(defun alist-p (list)
  "Check if a list looks like an alist (list of conses with string/symbol keys)."
  (and (consp list)
       (every (lambda (item)
                (and (consp item)
                     (or (stringp (car item)) (symbolp (car item)))))
              list)))

(defun render-json-value (value stream)
  (cond
    ((null value) (write-string "null" stream))
    ((eq value t) (write-string "true" stream))
    ((integerp value) (format stream "~D" value))
    ((floatp value) (format stream "~F" value))
    ((stringp value)
     (write-char #\" stream)
     (write-string (json-escape value) stream)
     (write-char #\" stream))
    ((keywordp value)
     (write-char #\" stream)
     (write-string (string-downcase (symbol-name value)) stream)
     (write-char #\" stream))
    ((alist-p value)
     (write-char #\{ stream)
     (loop for (key . val) in value
           for first = t then nil
           do (unless first (write-char #\, stream))
              (write-char #\" stream)
              (write-string (if (stringp key) key (string-downcase (symbol-name key))) stream)
              (write-string "\":" stream)
              (render-json-value val stream))
     (write-char #\} stream))
    ((listp value)
     (write-char #\[ stream)
     (loop for item in value
           for first = t then nil
           do (unless first (write-char #\, stream))
              (render-json-value item stream))
     (write-char #\] stream))
    (t (format stream "\"~A\"" value))))

;;; --- OpenAPI spec builder ---

(defun make-spec (&key (title "API") (version "1.0.0") (description ""))
  "Create a base OpenAPI 3.0 spec as an alist."
  `(("openapi" . "3.0.3")
    ("info" . (("title" . ,title)
               ("version" . ,version)
               ,@(when (plusp (length description))
                   `(("description" . ,description)))))
    ("paths" . ())
    ("components" . (("schemas" . ())))))

(defun make-parameter (&key name (in "query") (required nil) (type "string") description)
  `(("name" . ,name)
    ("in" . ,in)
    ,@(when required `(("required" . t)))
    ,@(when description `(("description" . ,description)))
    ("schema" . (("type" . ,type)))))

(defun make-response (&key (description "") content-type schema)
  `(("description" . ,description)
    ,@(when (and content-type schema)
        `(("content" . ((,content-type . (("schema" . ,schema)))))))))

(defun make-operation (&key summary (method "get") parameters responses operation-id)
  (let ((op `(,@(when operation-id `(("operationId" . ,operation-id)))
              ,@(when summary `(("summary" . ,summary)))
              ,@(when parameters `(("parameters" . ,parameters)))
              ("responses" . ,(or responses
                                  `(("200" . (("description" . "OK")))))))))
    (cons method op)))

(defun make-schema (&key type properties required)
  `(("type" . ,(or type "object"))
    ,@(when properties `(("properties" . ,properties)))
    ,@(when required `(("required" . ,required)))))

(defun add-path (spec path &rest operations)
  "Add a path with operations to the spec. Returns new spec."
  (let ((new-spec (copy-tree spec))
        (path-item (mapcar (lambda (op) (cons (car op) (cdr op))) operations)))
    (let ((paths-entry (assoc "paths" new-spec :test #'equal)))
      (if paths-entry
          (push (cons path path-item) (cdr paths-entry))
          (nconc new-spec `(("paths" . ((,path . ,path-item)))))))
    new-spec))

(defun add-schema (spec name schema)
  "Add a component schema. Returns new spec."
  (let ((new-spec (copy-tree spec)))
    (let* ((components (assoc "components" new-spec :test #'equal))
           (schemas (and components (assoc "schemas" (cdr components) :test #'equal))))
      (if schemas
          (push (cons name schema) (cdr schemas))
          (if components
              (push `("schemas" . ((,name . ,schema))) (cdr components))
              (nconc new-spec `(("components" . (("schemas" . ((,name . ,schema))))))))))
    new-spec))
