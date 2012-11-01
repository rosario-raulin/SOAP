(defpackage :de-raulin-rosario-soap
  (:use cl
	s-xml
	drakma)
  (:export get-wsdl-dom))

(in-package :de-raulin-rosario-soap)

(defparameter *wsdl-url* "http://azuremd2.cloudapp.net/Service1.svc?wsdl")

(defun name-selector (x)
  (if (consp (car x)) (caar x) (car x)))

(defun get-wsdl-dom (url)
  (parse-xml-string (http-request url :method :get)))

(defun get-soap-action (wsdl-dom)
  (let ((tag (car (find '|soap|:|operation|
			 (find '|wsdl|:|operation|
			       (find '|wsdl|:|binding| (cdr wsdl-dom)
				     :key #'name-selector)
			       :key #'name-selector)
			 :key #'name-selector))))
    (when tag (nth (1+ (position ':|soapAction| tag)) tag))))
