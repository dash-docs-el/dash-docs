;;; dash-docs-test.el --- dash-docs tests
;; Copyright (C) 2013-2014  Raimon Grau
;; Copyright (C) 2013-2014  Toni Reina

;; Author: Raimon Grau <raimonster@gmail.com>
;;         Toni Reina  <areina0@gmail.com>
;; Version: 0.1
;; Keywords: docs

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:

;;; Code:

;;;; dash-docs-maybe-narrow-docsets

(ert-deftest dash-docs-maybe-narrow-docsets-test/filtered ()
  "Should return a list with filtered connections."
  (let ((pattern "Go ")
        (dash-docs-docsets-path "/tmp/.docsets")
        (dash-docs-common-docsets '("Redis" "Go" "CSS" "C" "C++"))
        (dash-docs--connections
         '(("Redis" "/tmp/.docsets/Redis.docset/Contents/Resources/docSet.dsidx" "DASH")
           ("Go" "/tmp/.docsets/Go.docset/Contents/Resources/docSet.dsidx" "DASH")
           ("C" "/tmp/.docsets/C.docset/Contents/Resources/docSet.dsidx" "DASH")
           ("C++" "/tmp/.docsets/C++.docset/Contents/Resources/docSet.dsidx" "DASH")
           ("CSS" "/tmp/.docsets/CSS.docset/Contents/Resources/docSet.dsidx" "ZDASH"))))
    (should (equal (dash-docs-maybe-narrow-docsets pattern)
                   '(("Go" "/tmp/.docsets/Go.docset/Contents/Resources/docSet.dsidx" "DASH"))))

    (should (equal "C" (caar (dash-docs-maybe-narrow-docsets "C foo"))))
    (should (equal "C++" (caar (dash-docs-maybe-narrow-docsets "C++ foo"))))
    (should (equal "C" (caar (dash-docs-maybe-narrow-docsets "c foo"))))))

(ert-deftest dash-docs-maybe-narrow-docsets-test/not-filtered ()
  "Should return all current connections because the pattern doesn't match with any connection."
  (let ((pattern "FOOOO ")
	(dash-docs-docsets-path "/tmp/.docsets")
	(dash-docs-common-docsets '("Redis" "Go" "CSS"))
	(dash-docs--connections
	 '(("Redis" "/tmp/.docsets/Redis.docset/Contents/Resources/docSet.dsidx" "DASH")
	   ("Go" "/tmp/.docsets/Go.docset/Contents/Resources/docSet.dsidx" "DASH")
	   ("CSS" "/tmp/.docsets/CSS.docset/Contents/Resources/docSet.dsidx" "ZDASH"))))
    (should (equal (dash-docs-maybe-narrow-docsets pattern) dash-docs--connections))))


;;;; dash-docs-sub-docset-name-in-pattern

(ert-deftest dash-docs-sub-docset-name-in-pattern-test/with-docset-name ()
  ""
  (let ((pattern "Redis BLPOP")
	(docset "Redis"))
    (should (equal (dash-docs-sub-docset-name-in-pattern pattern docset) "BLPOP"))))

(ert-deftest dash-docs-sub-docset-name-in-pattern-test/without-docset-name ()
  ""
  (let ((pattern "BLPOP")
	(docset "Redis"))
    (should (equal (dash-docs-sub-docset-name-in-pattern pattern docset) pattern))))

(ert-deftest dash-docs-sub-docset-name-in-pattern-test/with-special-docset-name ()
  ""
  (let ((pattern "C++ printf")
	(docset "C++"))
    (should (equal (dash-docs-sub-docset-name-in-pattern pattern docset) "printf"))))

;;;; dash-docs-result-url

(ert-deftest dash-docs-result-url/checks-docset-types ()
  (should (string-match-p "Documents/three#anchor$"
                          (dash-docs-result-url "Python 3" "three" "anchor")))
  (should (string-match-p "Documents/three#anchor$"
                          (dash-docs-result-url "Css" "three#anchor" nil)))
  (should (string-match-p "Documents/three#anchor$"
                          (dash-docs-result-url "Redis" "three#anchor"))))

(ert-deftest dash-docs-result-url/remove-dash-entry-tag-from-url ()
  (should (string-match-p "Documents/three#anchor$"
                          (dash-docs-result-url "Python 3" "three<dash_entry_menuDescription=android.provider.ContactsContract.CommonDataKinds.Website>" "anchor"))))

;;;; dash-docs-docsets-path

(ert-deftest dash-docs-docsets-path-test/relative-path ()
  "Should return the absolute path."
  (let ((dash-docs-docsets-path "~/.emacs.d/dash-docs-docsets")
	(home-path (getenv "HOME")))
    (should (equal (dash-docs-docsets-path)
		   (format "%s/.emacs.d/dash-docs-docsets" home-path)))))

;;;; dash-docs-add-to-kill-ring

(ert-deftest dash-docs-add-to-kill-ring-test ()
  "Should add to kill ring a string with a call to `dash-docs-browse-url'"
  (let ((results '(Redis ("func" "Documents/blpop.html"))))
    (dash-docs-add-to-kill-ring results))
  (should (equal (current-kill 0 t)
		 "(dash-docs-browse-url '(Redis (\"func\" \"Documents/blpop.html\")))")))

;;;; dash-docs-official-docsets

(ert-deftest dash-docs-official-docsets-test ()
  "Should return a list of available docsets."
  (let ((docsets (dash-docs-official-docsets)))
    (should (member "Ruby" docsets))
    ;; ignored docset:
    (should-not (member "Man_Pages" docsets))))

;;;; dash-docs-activate-docset

(ert-deftest dash-docs-activate-docset ()
  (let ((dash-docs-common-docsets '("Redis" "Go" "CSS"))
	(dash-docs--connections
	 '(("Redis" "/tmp/.docsets/Redis.docset/Contents/Resources/docSet.dsidx" "DASH")
	   ("Go" "/tmp/.docsets/Go.docset/Contents/Resources/docSet.dsidx" "DASH")
	   ("CSS" "/tmp/.docsets/CSS.docset/Contents/Resources/docSet.dsidx" "ZDASH"))))
    (dash-docs-activate-docset "Clojure")
    (should (equal'("Clojure" "Redis" "Go" "CSS") dash-docs-common-docsets))
    (should (equal nil dash-docs--connections))))

;; dash-docs-buffer-local-docsets

(ert-deftest dash-docs-buffer-local-docsets-narrowing ()
  (let ((c-buffer nil)
        (dash-docs--connections
         '(("Go" "/tmp/.docsets/Go.docset/Contents/Resources/docSet.dsidx" "DASH")
           ("C" "/tmp/.docsets/C.docset/Contents/Resources/docSet.dsidx" "DASH")
           ("CSS" "/tmp/.docsets/CSS.docset/Contents/Resources/docSet.dsidx" "ZDASH"))))
    (with-temp-buffer
      (setq c-buffer (current-buffer))
      (setq-local dash-docs-docsets (list "C"))

      (with-temp-buffer
        (setq-local dash-docs-docsets (list "Go"))
        (should (equal (dash-docs-maybe-narrow-docsets "*")
                       '(("Go" "/tmp/.docsets/Go.docset/Contents/Resources/docSet.dsidx" "DASH"))))

        (with-current-buffer c-buffer
          (should (equal (dash-docs-maybe-narrow-docsets "*")
                         '(("C" "/tmp/.docsets/C.docset/Contents/Resources/docSet.dsidx" "DASH"))))
          )))))

;; dash-docs-sql-query

(ert-deftest dash-docs-sql-query/DASH-docset-type ()
  (should (equal "SELECT t.type, t.name, t.path FROM searchIndex t WHERE t.name like '%blpop%' ORDER BY LENGTH(t.name), LOWER(t.name) LIMIT 1000"
		 (dash-docs-sql-query "DASH" "blpop"))))

(ert-deftest dash-docs-sql-query/ZDASH-docset-type ()
  (should (equal "SELECT ty.ZTYPENAME, t.ZTOKENNAME, f.ZPATH, m.ZANCHOR FROM ZTOKEN t, ZTOKENTYPE ty, ZFILEPATH f, ZTOKENMETAINFORMATION m WHERE ty.Z_PK = t.ZTOKENTYPE AND f.Z_PK = m.ZFILE AND m.ZTOKEN = t.Z_PK AND t.ZTOKENNAME like '%blpop%' ORDER BY LENGTH(t.ZTOKENNAME), LOWER(t.ZTOKENNAME) LIMIT 1000"
		 (dash-docs-sql-query "ZDASH" "blpop"))))

(ert-deftest dash-docs-sql-query/UNKNOWN-docset-type ()
  (should (equal nil (dash-docs-sql-query "FOO" "blpop"))))

(provide 'dash-docs-test)

;;; dash-docs-test ends here
