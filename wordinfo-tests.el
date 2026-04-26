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

(ert-deftest wordinfo-tests-build-url-word ()
  (should (equal (wordinfo-build-url wordinfo-dictionary-url "hustle") "https://api.dictionaryapi.dev/api/v2/entries/en/hustle")))

(ert-deftest wordinfo-tests-build-url-many-words ()
  (should (equal (wordinfo-build-url wordinfo-dictionary-url "hustle and bustle") "https://api.dictionaryapi.dev/api/v2/entries/en/hustle%20and%20bustle")))

(provide 'wordinfo-tests)
;;; wordinfo-tests.el ends here
