;;; wordinfo.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Manuel Pérez
;;
;; Author: Manuel Pérez <manu@Vega.local>
;; Maintainer: Manuel Pérez <manu@Vega.local>
;; Created: April 05, 2026
;; Modified: April 05, 2026
;; Version: 0.0.1
;; Keywords: convenience
;; Homepage: https://github.com/mpp112358/wordinfo
;; Package-Requires: ((emacs "27.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Retrieve definitions from lingua-robot RapidAPI.
;;
;;; Code:
(require 'auth-source)
(add-to-list 'auth-sources 'macos-keychain-internet)
;; The script needs credentials to access lingua-robot API.
;; It will automatically get the credentials from a macOS keychain entry
;; with host 'rapidapi.com' and 'user' wordinfo', which can be added by:
;; 'security add-internet-password -s "rapidapi.com" -a "wordinfo" -w "your-api-key"'
;; If not such an entry is present, it will ask for credentials.

(require 'wordinfo-get)

(defconst wordinfo-dictionary-url "https://lingua-robot.p.rapidapi.com/language/v1/entries/en/")

(defun wordinfo-build-url (base-url word)
  "Build full query url from BASE-URL and WORD."
  (url-encode-url (concat base-url word)))

(defun wordinfo-http-end-of-headers ()
  "Set point at end of headers of an http response."
  (goto-char (point-min))
  (re-search-forward "^$" nil 'move)
  (forward-char)
  (point))

(defun wordinfo-print-definitions (wordinfo-struct)
  "Print definitions from WORDINFO-STRUCT."
  (let* ((entry (wordinfo-get-first-entry wordinfo-struct)))
    (seq-do
     (lambda (elt) (princ (format "%s\n" elt)))
     (seq-map-indexed (lambda (elt idx)
                        (format "%2d. (%s) %s" (1+ idx) (car elt) (cdr elt)))
                      (wordinfo-get-entry-definitions-with-part-of-speech entry)))))

(defun wordinfo-print-pronuntiation (wordinfo-struct)
  "Print first UK pronuntiation from WORDINFO-STRUCT."
  (princ (format "%s\n" (wordinfo-get-first-transcription wordinfo-struct))))

(defun wordinfo-retrieve-json (word)
  "Look up WORD in dictionaryapi.dev and put json into '*wordinfo-response-json*'."
  (interactive "sWORD: ")
  (message "Retrieving %s" (wordinfo-build-url wordinfo-dictionary-url word))
  (let* ((credentials (auth-source-search :host "rapidapi.com"
                                          :user "wordinfo"
                                          :require '(:secret)))
         (api-key (when credentials
                    (funcall (plist-get (car credentials) :secret))))
         (url-request-extra-headers
          `(("Content-Type" . "application/json")
            ("x-rapidapi-host" . "lingua-robot.p.rapidapi.com")
            ("x-rapidapi-key" . ,api-key)))
         (coding-system-for-read 'binary))
    (url-retrieve (wordinfo-build-url wordinfo-dictionary-url word)
                  (lambda (status)
                    (when (plist-get status :error)
                      (error "Failed to retrieve URL: %s" (plist-get status :error)))
                    (let ((body (decode-coding-string
                                 (buffer-substring-no-properties (wordinfo-http-end-of-headers)
                                                                 (point-max))
                                 'utf-8)))
                      (get-buffer-create "*wordinfo-response-json*")
                      (with-current-buffer "*wordinfo-response-json*"
                        (erase-buffer)
                        (insert body)
                        (json-mode)
                        (json-pretty-print-buffer)))))))

(defun wordinfo (word)
  "Look up WORD in dictionaryapi.dev."
  (interactive "sWORD: ")
  (message "Retrieving %s" (wordinfo-build-url wordinfo-dictionary-url word))
  (let* ((credentials (auth-source-search :host "rapidapi.com"
                                          :user "wordinfo"
                                          :require '(:secret)))
         (api-key (when credentials
                    (funcall (plist-get (car credentials) :secret))))
         (url-request-extra-headers
          `(("Content-Type" . "application/json")
            ("x-rapidapi-host" . "lingua-robot.p.rapidapi.com")
            ("x-rapidapi-key" . ,api-key)))
         (coding-system-for-read 'binary))
    (url-retrieve (wordinfo-build-url wordinfo-dictionary-url word)
                  (lambda (status)
                    (when (plist-get status :error)
                      (error "Failed to retrieve URL: %s" (plist-get status :error)))
                    (let* ((body (decode-coding-string
                                  (buffer-substring-no-properties (wordinfo-http-end-of-headers)
                                                                  (point-max))
                                  'utf-8))
                           (wordinfo-struct (json-parse-string body)))
                      (with-help-window "*wordinfo*"
                        (wordinfo-print-pronuntiation wordinfo-struct)
                        (wordinfo-print-definitions wordinfo-struct)))))))

(defun wordinfo-at-point ()
  "Look up word at point in lingua-robot api."
  (interactive)
  (let ((word (thing-at-point 'word)))
    (wordinfo word)))

(provide 'wordinfo)
;;; wordinfo.el ends here
