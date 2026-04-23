;;; wordinfo-tests.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Manuel Pérez
;;
;; Author: Manuel Pérez <manu@Vega.local>
;; Maintainer: Manuel Pérez <manu@Vega.local>
;; Created: April 05, 2026
;; Modified: April 05, 2026
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/mpp112358/wordinfo-tests
;; Package-Requires: ((emacs "27.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Test wordinfo.el
;;
;;; Code:

(require 'ert)

(load-file "~/gredos/1projects/wordinfo/wordinfo.el")

(defun hashtable-equal (ht1 ht2)
  "Compare HT1 and HT2 for equality."
  (and (= (hash-table-count ht1) (hash-table-count ht2))
       (seq-reduce (lambda (x y) (and x y))
                   (maphash (lambda (key val)
                              (let ((val2 (gethash key ht2)))
                                (if (and (hash-table-p val) (hash-table-p val2))
                                    (hashtable-equal val val2)
                                  (equal val val2))))
                            ht1)
                   t)))

(ert-deftest wordinfo-tests-build-url-word ()
  (should (equal (wordinfo-build-url wordinfo-dictionary-url "hustle") "https://api.dictionaryapi.dev/api/v2/entries/en/hustle")))

(ert-deftest wordinfo-tests-build-url-many-words ()
  (should (equal (wordinfo-build-url wordinfo-dictionary-url "hustle and bustle") "https://api.dictionaryapi.dev/api/v2/entries/en/hustle%20and%20bustle")))

(ert-deftest wordinfo-tests-lexemes ()
  (should (equal (with-current-buffer "example-response.json"
                   (goto-char (point-min))
                   (wordinfo-lexemes (json-parse-buffer)))
                 (with-current-buffer "example-response-lexemes.json"
                   (goto-char (point-min))
                   (json-parse-buffer)))))

(provide 'wordinfo-tests)
;;; wordinfo-tests.el ends here
