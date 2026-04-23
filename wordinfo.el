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

(defconst wordinfo-dictionary-url "https://lingua-robot.p.rapidapi.com/language/v1/entries/en/")

(defun wordinfo-lexemes (word-json)
  "Extract array of lexemes from WORD-JSON."
  (gethash "lexemes" (aref (gethash "entries" word-json) 0)))

(defun wordinfo-senses (lexeme-json)
  "Extract array of senses from LEXEME-JSON."
  (gethash "senses" lexeme-json))

(defun wordinfo-print-definition (sense-json lemma part-of-speech)
  "Print definition for LEMMA and PART-OF-SPEECH contained in SENSE-JSON."
  (let ((definition (gethash "definition" sense-json))
        (labels (gethash "labels" sense-json)))
    (princ (concat lemma "(" part-of-speech ")" definition))))

(defun wordinfo-print-definitions (word-json)
  "Print definitions from WORD-JSON."
  (let* ((lexeme-json (aref (wordinfo-lexemes word-json) 0))
         (lemma (gethash "lemma" lexeme-json))
         (part-of-speech (gethash "partOfSpeech" lexeme-json)))
    (dolist (sense (wordinfo-senses lexeme-json))
      (wordinfo-print-definition sense lemma part-of-speech))))

(defun wordinfo-build-url (base-url word)
  "Build full query url from BASE-URL and WORD."
  (url-encode-url (concat base-url word)))

(defun wordinfo-http-end-of-headers ()
  "Set point at end of headers of an http response."
  (goto-char (point-min))
  (re-search-forward "^$" nil 'move)
  (forward-char)
  (point))

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
            ("x-rapidapi-key" . ,api-key))))
    (url-retrieve (wordinfo-build-url wordinfo-dictionary-url word)
                  (lambda (status)
                    (when (plist-get status :error)
                      (error "Failed to retrieve URL: %s" (plist-get status :error)))
                    (let ((body (buffer-substring-no-properties (wordinfo-http-end-of-headers)
                                                                (point-max))))
                      (with-help-window "*wordinfo*"
                        (wordinfo-print-definitions (json-parse-string body))))))))

(provide 'wordinfo)
;;; wordinfo.el ends here
