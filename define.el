;;; define.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Manuel Pérez
;;
;; Author: Manuel Pérez <manu@Vega.local>
;; Maintainer: Manuel Pérez <manu@Vega.local>
;; Created: April 05, 2026
;; Modified: April 05, 2026
;; Version: 0.0.1
;; Keywords: convenience
;; Homepage: https://github.com/mpp112358/define
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Retrieve definitions from dictionaryapi.dev.
;;
;;; Code:

(defvar define-dictionary-url "https://dictionaryapi.dev/api/v2/entries/")

(defun define-build-url (base-url word)
  "Build full query url from BASE-URL and WORD."
  (url-encode-url (concat base-url word)))

(defun define (word)
  "Looks up INFO about WORD in dictionaryapi.dev"
  (interactive "sWORD: \nsINFO: ")
  (url-retrieve (define-build-url define-dictionary-url word)
                (lambda (status)
                  (when (plist-get status :error)
                    (error "Failed to retrieve URL: %s" (plist-get status :error))))))

(provide 'define)
;;; define.el ends here
