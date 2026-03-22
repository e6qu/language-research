(defpackage :hello-metrics
  (:use :cl)
  (:export #:make-registry #:make-counter #:make-gauge #:make-histogram
           #:counter-inc #:gauge-set #:gauge-inc #:gauge-dec
           #:histogram-observe #:render-metrics
           #:registry-register #:registry-metrics))

(in-package :hello-metrics)

;;; --- Metric types ---

(defstruct metric-base
  (name "" :type string)
  (help "" :type string)
  (labels nil :type list))  ; list of label-name strings

(defstruct (prom-counter (:include metric-base))
  (value 0 :type number)
  (lock (sb-thread:make-mutex :name "counter")))

(defstruct (prom-gauge (:include metric-base))
  (value 0 :type number)
  (lock (sb-thread:make-mutex :name "gauge")))

(defstruct (prom-histogram (:include metric-base))
  (buckets #(0.005 0.01 0.025 0.05 0.1 0.25 0.5 1.0 2.5 5.0 10.0)
           :type vector)
  (bucket-counts nil :type (or null vector))
  (sum 0.0d0 :type double-float)
  (count 0 :type integer)
  (lock (sb-thread:make-mutex :name "histogram")))

;;; --- Registry ---

(defstruct registry
  (metrics nil :type list))  ; list of metrics

(defun registry-register (registry metric)
  (push metric (registry-metrics registry))
  metric)

;;; --- Counter operations ---

(defun counter-inc (counter &optional (delta 1))
  (sb-thread:with-mutex ((prom-counter-lock counter))
    (incf (prom-counter-value counter) delta))
  counter)

;;; --- Gauge operations ---

(defun gauge-set (gauge value)
  (sb-thread:with-mutex ((prom-gauge-lock gauge))
    (setf (prom-gauge-value gauge) value))
  gauge)

(defun gauge-inc (gauge &optional (delta 1))
  (sb-thread:with-mutex ((prom-gauge-lock gauge))
    (incf (prom-gauge-value gauge) delta))
  gauge)

(defun gauge-dec (gauge &optional (delta 1))
  (sb-thread:with-mutex ((prom-gauge-lock gauge))
    (decf (prom-gauge-value gauge) delta))
  gauge)

;;; --- Histogram operations ---

(defun histogram-observe (hist value)
  (sb-thread:with-mutex ((prom-histogram-lock hist))
    (let ((buckets (prom-histogram-buckets hist))
          (counts (or (prom-histogram-bucket-counts hist)
                      (setf (prom-histogram-bucket-counts hist)
                            (make-array (length (prom-histogram-buckets hist))
                                        :initial-element 0)))))
      (loop for i below (length buckets)
            when (<= value (aref buckets i))
              do (incf (aref counts i)))
      (incf (prom-histogram-sum hist) (coerce value 'double-float))
      (incf (prom-histogram-count hist))))
  hist)

;;; --- Prometheus text format rendering ---

(defun format-metric-value (value)
  (if (floatp value)
      (format nil "~F" value)
      (format nil "~D" value)))

(defun render-counter (counter stream)
  (let ((name (metric-base-name counter))
        (help (metric-base-help counter)))
    (when (plusp (length help))
      (format stream "# HELP ~A ~A~%" name help))
    (format stream "# TYPE ~A counter~%" name)
    (format stream "~A ~A~%" name (format-metric-value (prom-counter-value counter)))))

(defun render-gauge (gauge stream)
  (let ((name (metric-base-name gauge))
        (help (metric-base-help gauge)))
    (when (plusp (length help))
      (format stream "# HELP ~A ~A~%" name help))
    (format stream "# TYPE ~A gauge~%" name)
    (format stream "~A ~A~%" name (format-metric-value (prom-gauge-value gauge)))))

(defun render-histogram (hist stream)
  (let ((name (metric-base-name hist))
        (help (metric-base-help hist))
        (buckets (prom-histogram-buckets hist))
        (counts (prom-histogram-bucket-counts hist)))
    (when (plusp (length help))
      (format stream "# HELP ~A ~A~%" name help))
    (format stream "# TYPE ~A histogram~%" name)
    (when counts
      (let ((cumulative 0))
        (loop for i below (length buckets)
              do (incf cumulative (aref counts i))
                 (format stream "~A_bucket{le=\"~A\"} ~D~%"
                         name (format-metric-value (aref buckets i)) cumulative))
        (format stream "~A_bucket{le=\"+Inf\"} ~D~%" name (prom-histogram-count hist))))
    (format stream "~A_sum ~A~%" name (format-metric-value (prom-histogram-sum hist)))
    (format stream "~A_count ~D~%" name (prom-histogram-count hist))))

(defun render-metrics (registry)
  "Render all metrics in Prometheus text exposition format."
  (with-output-to-string (out)
    (dolist (metric (reverse (registry-metrics registry)))
      (typecase metric
        (prom-counter (render-counter metric out))
        (prom-gauge (render-gauge metric out))
        (prom-histogram (render-histogram metric out))))))
