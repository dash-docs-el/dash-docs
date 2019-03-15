(require 'undercover)
(require 'f)

(unless (version< emacs-version "27")
    (defalias 'ert--print-backtrace 'backtrace-to-string))

(defvar dash-docs-test-path
  (f-dirname (f-this-file)))

(defvar dash-docs-code-path
  (f-parent dash-docs-test-path))

(defun dash-docs-ends-with (string suffix)
  "Return t if STRING ends with SUFFIX."
  (and (string-match (format "%s$" suffix)
                     string)
       t))

(undercover "*.el" "dash-docs/*.el" (:exclude "*-test.el"))
(require 'dash-docs (f-expand "dash-docs.el" dash-docs-code-path))
