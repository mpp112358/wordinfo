;;; wordinfo-get.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Manuel Pérez
;;
;; Author: Manuel Pérez <manu@Vega.local>
;; Maintainer: Manuel Pérez <manu@Vega.local>
;; Created: April 26, 2026
;; Modified: April 26, 2026
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex text tools unix vc wp
;; Homepage: https://github.com/mpp112358/wordinfo-parse
;; Package-Requires: ((emacs "27.6"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

(defun wordinfo-get-null (wordinfo-struct)
  "Get the whole WORDINFO-STRUCT."
  wordinfo-struct)

(defun wordinfo-get-entries (wordinfo-struct)
  "Get sequence of entries out of WORDINFO-STRUCT."
  (gethash "entries" wordinfo-struct))

(defun wordinfo-get-first-entry (wordinfo-struct)
  "Get first entry out of WORDINFO-STRUCT."
  (elt (wordinfo-get-entries wordinfo-struct) 0))

(defun wordinfo-get-first-entry-pronunciations (wordinfo-struct)
  "Get first entry's sequence of pronunciations out of WORDINFO-STRUCT."
  (gethash "pronunciations" (wordinfo-get-first-entry wordinfo-struct)))

(defun wordinfo-get-first-pronunciation (wordinfo-struct)
  "Get first entry's first pronunciation out of WORDINFO-STRUCT."
  (elt (wordinfo-get-first-entry-pronunciations wordinfo-struct) 0))

(defun wordinfo-get-first-pronunciation-transcriptions (wordinfo-struct)
  "Get first pronunciation's sequence of transcriptions out of WORDINFO-STRUCT."
  (gethash "transcriptions" (wordinfo-get-first-pronunciation wordinfo-struct)))

(defun wordinfo-get-first-transcription (wordinfo-struct)
  "Get first pronunciation's first transcription out of WORDINFO-STRUCT."
  (gethash "transcription"
           (elt (wordinfo-get-first-pronunciation-transcriptions wordinfo-struct) 0)))

(defun wordinfo-get-first-pronunciation-context (wordinfo-struct)
  "Get first pronunciation's context out of WORDINFO-STRUCT."
  (gethash "context" (wordinfo-get-first-pronunciation wordinfo-struct)))

(defun wordinfo-get-first-uk-pronunciation (wordinfo-struct)
  "Get first UK pronunciation transcription from WORDINFO-STRUCT."
  (elt (seq-filter
        (lambda (elt)
          (let* ((context (gethash "context" elt))
                 (regions (gethash "regions" context)))
            (seq-contains-p regions "United Kingdom")))
        (wordinfo-get-first-entry-pronunciations wordinfo-struct))
       0))

(defun wordinfo-get-first-uk-transcription (wordinfo-struct)
  "Get first UK transcription from WORDINFO-STRUCT."
  (gethash "transcription"
           (elt (gethash "transcriptions" (wordinfo-get-first-uk-pronunciation wordinfo-struct))
                0)))

(defun wordinfo-get-first-entry-interpretations (wordinfo-struct)
  "Get first entry's sequence of interpretations from WORDINFO-STRUCT."
  (gethash "interpretations" (wordinfo-get-first-entry wordinfo-struct)))

(defun wordinfo-get-first-entry-lexemes (wordinfo-struct)
  "Get first entry's sequence of lexemes from WORDINFO-STRUCT."
  (gethash "lexemes" (wordinfo-get-first-entry wordinfo-struct)))

(defun wordinfo-get-first-lexeme (wordinfo-struct)
  "Get first entry's first lexeme from WORDINFO-STRUCT."
  (elt (wordinfo-get-first-entry-lexemes wordinfo-struct) 0))

(defun wordinfo-get-first-lexeme-senses (wordinfo-struct)
  "Get first lexeme's sequence of senses from WORDINFO-STRUCT."
  (gethash "senses" (wordinfo-get-first-lexeme wordinfo-struct)))

(defun wordinfo-get-first-lexeme-definitions (wordinfo-struct)
  "Get first lexeme's sequence of definitions from WORDINFO-STRUCT."
  (let* ((senses (wordinfo-get-first-lexeme-senses wordinfo-struct))
         (defnum (length senses)))
    (vconcat (seq-reduce (lambda (acc cur) (cons (gethash "definition" cur) acc))
                         senses nil)
             nil)))

(defun wordinfo-get-entry-lexemes (entry)
  "Get lexemes from ENTRY."
  (gethash "lexemes" entry))

(defun wordinfo-get-lexeme-senses (lexeme)
  "Get senses of a LEXEME."
  (gethash "senses" lexeme))

(defun wordinfo-get-lexeme-part-of-speech (lexeme)
  "Get part of speech of a LEXEME."
  (gethash "partOfSpeech" lexeme))

(defun wordinfo-get-lexeme-definitions (lexeme)
  "Get all definitions inside a LEXEME."
  (let* ((senses (gethash "senses" lexeme)))
    (vconcat (seq-reduce (lambda (acc cur) (cons (gethash "definition" cur) acc))
                         senses nil)
             nil)))

(defun wordinfo-get-lexeme-definitions-with-part-of-speech (lexeme)
  "Get (partOfSpeech . definition) for every definition inside a LEXEME."
  (let* ((part-of-speech (wordinfo-get-lexeme-part-of-speech lexeme))
         (senses (wordinfo-get-lexeme-senses lexeme)))
    (vconcat (seq-reduce (lambda (acc cur)
                           (cons (cons part-of-speech (gethash "definition" cur)) acc))
                         senses nil)
             nil)))

(defun wordinfo-get-entry-definitions-with-part-of-speech (entry)
  "Get (partOfSpeech . definition) for every definition inside an ENTRY."
  (seq-reduce (lambda (acc cur) (vconcat acc cur))
              (seq-map #'wordinfo-get-lexeme-definitions-with-part-of-speech
                       (wordinfo-get-entry-lexemes entry))
              nil))

(defun wordinfo-get-parse-response (what)
  "Get WHAT from JSON response body from buffer named '*wordinfo-response-json*'."
  (interactive "sWhat to parse? ")
  (with-current-buffer "*wordinfo-response-json*"
    (let ((body (buffer-substring-no-properties (point-min) (point-max))))
      (let ((wordinfo-struct (json-parse-string body)))
        (get-buffer-create "*wordinfo-parse-json*")
        (with-current-buffer "*wordinfo-parse-json*"
          (erase-buffer)
          (json-mode)
          (insert (json-serialize
                   (funcall
                    (cond ((string= what "entries") #'wordinfo-get-entries)
                          ((string= what "first-entry") #'wordinfo-get-first-entry)
                          ((string= what "first-entry-pronunciations")
                           #'wordinfo-get-first-entry-pronunciations)
                          ((string= what "first-pronunciation")
                           #'wordinfo-get-first-pronunciation)
                          ((string= what "first-pronunciation-transcriptions")
                           #'wordinfo-get-first-pronunciation-transcriptions)
                          ((string= what "first-transcription")
                           #'wordinfo-get-first-transcription)
                          ((string= what "first-pronunciation-context")
                           #'wordinfo-get-first-pronunciation-context)
                          ((string= what "first-uk-transcription")
                           #'wordinfo-get-first-uk-transcription)
                          ((string= what "first-entry-interpretations")
                           #'wordinfo-get-first-entry-interpretations)
                          ((string= what "first-entry-lexemes")
                           #'wordinfo-get-first-entry-lexemes)
                          ((string= what "first-lexeme")
                           #'wordinfo-get-first-lexeme)
                          ((string= what "first-lexeme-definitions")
                           #'wordinfo-get-first-lexeme-definitions)
                          (t #'wordinfo-get-null))
                    wordinfo-struct)))
          (json-pretty-print-buffer))))))


(provide 'wordinfo-get)
;;; wordinfo-get.el ends here
