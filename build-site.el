;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'htmlize)

;; Load the publishing system
(require 'ox-publish)

;; Customize the HTML output
(setq org-html-validation-link nil
      org-html-head-include-scripts nil
      org-html-head-include-default-style nil)

;; Define the publishing project
(setq org-publish-project-alist
      (list
       (list "org-site:main"
             :recursive t
             :base-directory "./content"
             :base-extension "org"
             :publishing-function 'org-html-publish-to-html
             :publishing-directory "./_site"
             :with-author nil           ;; Don't include author name
             :with-creator nil            ;; Do not include Emacs and Org versions in footer
             :with-toc nil                ;; Do not include a table of contents
             :section-numbers nil       ;; Don't include section numbers
             :time-stamp-file nil ;; Don't include time stamp in file
             :body-only t)))

;; Generate the site output
(org-publish-all t)

(message "Build complete!")
