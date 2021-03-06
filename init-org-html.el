(defvar sydi/base-directory "~/sydi.org/org/"
  "base org files directory")
(defvar sydi/base-code-directory "~/sydi.org/html/code/")
;; (defvar sydi/base-color-themes-directory "~/sydi.org/worg/color-themes/")
(defvar sydi/base-images-directory "~/sydi.org/html/images/")
(defvar sydi/publish-directory "~/sydi.org/html/")
(defvar sydi/site-url "http://sydi.org/")
(defvar sydi/google-id "112098239943590093765")
(defvar sydi/site-name "MiScratch")

(defvar sydi/comment-box-p t "Should add commnet box for this page")
(defvar sydi/homepage-p nil "Indicate whether the page is home page")
(defvar sydi/single-p t "Indicate whether a single post page or not")

(defvar sydi/atom-exclude-file-list '("douban\\.org$") "exclude files exporting to atom file")
(defvar sydi/atom-max-export-files-num 10 "max files to export")

(require 'ox)

(add-to-list 'org-export-options-alist '(:comment-box nil "comment-box" t sydi/comment-box-p))
(add-to-list 'org-export-options-alist '(:homepage nil "homepage" nil sydi/homepage-p))
(add-to-list 'org-export-options-alist '(:single nil "single" t sydi/single-p))
(add-to-list 'org-export-options-alist '(:js-style nil nil nil))

(eval-after-load 'ox-html
  '(progn
;;; add a horizontal line before footnotes
     (setq org-export-htmlize-output-type "css")
     (setq org-export-htmlize-css-font-prefix "")
     (setq org-export-allow-BIND t)
     (setq org-export-html-style-include-scripts nil) ; 不加载默认js
     (setq org-export-html-style-include-default nil) ; 不加载默认css
     (setq org-export-html-link-home sydi/site-url)
     (setq org-export-with-section-numbers nil)
     (setq org-export-page-keywords "施宇迪 sydi.org")
     (setq org-export-page-description "施宇迪 sydi.org")
     (setq org-export-html-preamble (lambda () "<g:plusone></g:plusone>"))
     (setq org-html-footnotes-section "<div id=\"footnotes\">
<h2 class=\"footnotes\">%s: </h2>
<span id=\"text-footnotes\">
%s
</span>
</div>")))

;;;###autoload
(defun sydi/sync-server ()
  (message "sync file to server")
  ;; (async-shell-command "update_sydi_org.sh")
  (message "sync file to server complete"))

(setq org-export-filter-final-output-functions '(sydi/final-export))

(defun sydi/final-export (contents backend info)
  "Filter to indent the HTML and convert HTML entities."
  (if (eq backend 'html)
      (sydi/final-html-export-filter contents info)))

;;;###autoload
;;; The hook is run after org-html export html done and
;;; still stay on the output html file.
(defun sydi/final-html-export-filter (contents info)
  (defun get-string-from-file (filePath)
    "Return filePath's file content."
    (with-temp-buffer
      (insert-file-contents filePath t)
      (buffer-string)))
  (let ((content-no-script)
        (script ""))
    ;; extract javascript
    (if (not (string-match "<script.*>\\(.\\|\n\\)*</script>" contents))
        (setq content-no-script contents)
      (setq script (match-string-no-properties 0 contents))
      (setq content-no-script (concat (substring contents 0 (match-beginning 0))
                                        (substring contents (match-end 0)))))
    ;; format html contents
    (let* ((title (plist-get info :title))
           (email (plist-get info :email))
           (author (plist-get info :author))
           (body-only (plist-get info :body-only))
           (date (plist-get info :date))
           (language    (plist-get info :language))
           (keywords    (plist-get info :keywords))
           (description (plist-get info :description))
           (style (plist-get info :style))
           (js-style (plist-get info :js-style))
           (charset (and org-html-coding-system
                         (fboundp 'coding-system-get)
                         (coding-system-get org-html-coding-system 'mime-charset)))
           (sidebar-html (if (plist-get info :base-directory)
                           (get-string-from-file (concat (plist-get info :base-directory) "/sidebar.div"))
                          ""))
           (comment-box (if (plist-get info :comment-box)
                            "<div class=\"comments ds-thread\"></div>" ""))
           (head (concat (plist-get info :html-head) "\n" (plist-get info :html-head-extra)))
           (header (if (plist-get info :homepage) ""
                     (format "<div id=\"header\">
                                <div id=\"header-menu\"></div>
                                <div id=\"page-title\"><div id=\"page-title-text\">%s</div></div>
                                <div id=\"breadcrumbs\"></div>
                              </div>"
                             title))))
      (if body-only
        (format "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"%s\" xml:lang=\"%s\">
<head>
<title>%s</title>
<meta http-equiv=\"Content-Type\" content=\"text/html;charset=%s\"/>
<meta name=\"title\" content=\"%s\"/>
<meta name=\"generator\" content=\"Org-mode modify by Yudi Shi\"/>
<meta name=\"generated\" content=\"%s\"/>
<meta name=\"author\" content=\"%s\"/>
<meta name=\"description\" content=\"%s\"/>
<meta name=\"keywords\" content=\"%s\"/>
%s
%s
</head>
<body>
<div id=\"wrapper\">
  <div id=\"sidebar\">%s</div>
  <div id=\"main\">
    %s
    <div id=\"content\">
      <div id=\"page-content\">
        <div class=\"post single\">
          <ul class=\"meta\"></ul>
          <div class=\"feature-image\"></div>
          <div class=\"the-content\">
            <!-- content -->
           %s
            <!-- comment box -->
            %s
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<!-- ENS WRAPPER -->
<div id=\"footer\"></div>
%s
%s
</body></html>"
                      language
                      language
                      title
                      charset
                      title
                      date
                      author
                      description
                      keywords
                      style
                      head
                      sidebar-html
                      header
                      content-no-script
                      comment-box
                      script
                      js-style
                      ;; sydi/google-id
                      ;; author
                      ;; date
                      ;; sydi/site-name
                      )))))

(defun sydi/publish-org-sitemap (project &optional sitemap-filename)
  "Create a sitemap of pages in set defined by PROJECT.
Optionally set the filename of the sitemap with SITEMAP-FILENAME.
Default for SITEMAP-FILENAME is 'sitemap.org'."
  (let* ((project-plist (cdr project))
	 (dir (file-name-as-directory
	       (plist-get project-plist :base-directory)))
	 (localdir (file-name-directory dir))
	 (indent-str "")
	 (exclude-regexp (plist-get project-plist :exclude))
	 (files (nreverse (org-publish-get-base-files project exclude-regexp)))
	 (sitemap-filename (concat dir (or sitemap-filename "sitemap.org")))
	 (sitemap-title (or (plist-get project-plist :sitemap-title)
			    (concat "Sitemap for project " (car project))))
	 (sitemap-sans-extension (plist-get project-plist :sitemap-sans-extension))
	 (visiting (find-buffer-visiting sitemap-filename))
	 (ifn (file-name-nondirectory sitemap-filename))
	 file sitemap-buffer)
    (with-current-buffer (setq sitemap-buffer
			       (or visiting (find-file sitemap-filename)))
      (message "Generating tree-style sitemap for %s" sitemap-title)
      (erase-buffer)
      (insert (concat "#+TITLE: " sitemap-title "\n\n"))
      (insert "#+BEGIN_HTML\n<div class=\"panes\">\n#+END_HTML\n")
      (while (setq file (pop files))
	(let ((fn (file-name-nondirectory file))
	      (link (file-relative-name file dir))
	      (oldlocal localdir))
	  (when sitemap-sans-extension
	    (setq link (file-name-sans-extension link)))
	  ;; sitemap shouldn't list itself
	  (unless (equal (file-truename sitemap-filename)
			 (file-truename file))
            (setq localdir (concat (file-name-as-directory dir)
                                   (file-name-directory link)))
            (unless (string= localdir oldlocal)
              (if (string= localdir dir)
                  (insert (concat "\n* Top\n"))
                (let* ((subdirs
                        (split-string
                         (directory-file-name
                          (file-name-directory
                           (file-relative-name localdir dir))) "/"))
                       (subdir "")
                       (old-subdirs (split-string
                                     (file-relative-name oldlocal dir) "/"))
                       (level-between (- (length subdirs)
                                         (length (split-string dir))))
                       (indent-str (make-string (* level-between 2) ?\ )))
                  ;; (setq indent-str (make-string 2 ?\ ))
                  (while (string= (car old-subdirs) (car subdirs))
                    (pop old-subdirs)
                    (pop subdirs))
                  (dolist (d subdirs)
                    (setq subdir (concat subdir d "/"))
                    ;; (insert (concat indent-str " + " d "\n"))
                    (insert (concat "\n* " d "\n")))))
              )
	    ;; This is common to 'flat and 'tree
	    (let ((entry
		   (org-publish-format-file-entry "%t" file project-plist))
		  (regexp "\\(.*\\)\\[\\([^][]+\\)\\]\\(.*\\)"))
	      (cond ((string-match-p regexp entry)
		     (string-match regexp entry)
		     (insert (concat indent-str " + " (match-string 1 entry)
				     "[[file:" link "]["
				     (match-string 2 entry)
				     "]]" (match-string 3 entry) "\n")))
		    (t
		     (insert (concat indent-str " + [[file:" link "]["
				     entry
				     "]]\n"))))))))
      (insert "\n#+BEGIN_HTML\n</div>\n#+END_HTML\n")
      (save-buffer))
    (or visiting (kill-buffer sitemap-buffer))))

;;;###autoload
(defun set-org-publish-project-alist ()
  (setq org-publish-project-alist
        `(("sydi"
           :components ("sydi-pages" "sydi-static"))
          ("sydi-static"
           :base-directory "~/sydi.org/org/"
           :base-extension "xml\\|css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf\\|html\\|div\\|pl\\|template\\|txt"
           :publishing-directory "~/sydi.org/html"
           :recursive t
           :publishing-function org-publish-attachment)
          ("sydi-rss"
              :base-directory ,sydi/base-directory
              :base-extension "org"
              :rss-image-url "http://lumiere.ens.fr/~guerry/images/faces/15.png"
              :html-link-home "http://sydi.org/"
              :rss-extension "xml"
              :publishing-directory ,sydi/publish-directory
              :publishing-function (org-rss-publish-to-rss)
              :section-numbers nil
              :exclude ".*"            ;; To exclude all files...
              :include ("index.xml")   ;; ... except index.org.
              :table-of-contents nil)
          ("sydi-pages"
           :base-directory ,sydi/base-directory
           :base-extension "org"
           :publishing-directory ,sydi/publish-directory
           :html-extension "html"
           :recursive t
           :makeindex nil
           :auto-sitemap t
           :sitemap-ignore-case t
           :sitemap-filename "sitemap.org"
           :sitemap-function sydi/publish-org-sitemap
           :htmlized-source t
           :with-toc nil
           :auto-preamble t
           :exclude ".*my-wife.*\.org"
           :sitemap-title "站点地图 for 本网站"
           :author "施宇迪"
           :email "a@sydi.org"
           :language "zh-CN"
           :style "
<link rel=\"stylesheet\" href=\"/css/site.css\" />
<link rel=\"stylesheet\" href=\"/css/style.css\" />
<link href=\"/images/logo.png\" rel=\"icon\" type=\"image/x-icon\" />
<link href=\"/atom.xml\" type=\"application/atom+xml\" rel=\"alternate\" title=\"sydi.org atom\" />
"
           :js-style "<script type=\"text/javascript\" src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js\"></script>
<script type=\"text/javascript\" src=\"/js/site.js\"></script>
"
           :publishing-function (org-html-publish-to-html org-org-publish-to-org)
           :body-only t
           :completion-function (sydi/sync-server)))))

(defun sydi/publish ()
  "Publish Worg in htmlized pages."
  (interactive)
  (let ((org-format-latex-signal-error nil)
        (org-startup-folded nil))
    (set-org-publish-project-alist)
    (message "Emacs %s" emacs-version)
    (org-version)
    (sydi/generate-sitemap)
    (org-publish-project "sydi")))

(add-hook 'org-mode-hook 'inhibit-autopair)

;; external browser should be chromium
(setq browse-url-generic-program
      (executable-find "chromium"))

(defadvice org-open-at-point (around org-open-at-point-choose-browser activate)
  (let ((browse-url-browser-function
         (cond ((equal (ad-get-arg 0) '(4))
                'browse-url-generic)
               ((equal (ad-get-arg 0) '(16))
                'choose-browser)
               (t
                (lambda (url &optional new)
                  (w3m-browse-url url t))))))
    ad-do-it))

(defun sydi/generate-atom ()
  (interactive)
  (generate-atom "~/sydi.org/org" "~/sydi.org/org/atom.xml"))

;;;###autoload
(defun generate-atom (root-dir atom-file)
  "generate a atom style page"
  (defun web-time-string (&optional TIME)
    (concat (format-time-string "%Y-%m-%dT%T" TIME)
            ((lambda (x) (concat (substring x 0 3) ":" (substring x 3 5)))
             (format-time-string "%z"))))
  (save-excursion
    (let* ((org-export-allow-BIND t)
           (org-files (subseq (sydi/get-sorted-org-files root-dir) 0 sydi/atom-max-export-files-num))
           (atom-filename atom-file)
           (visiting (find-buffer-visiting atom-filename))
           (atom-buffer (or visiting (find-file atom-filename)))
           (title "MiScratch")
           (subtitle "About Linux, Distributed System, Data Base, High Performance System")
           (self-link "http://sydi.org/atom.xml")
           (link "http://sydi.org/")
           (id "http://sydi.org")
           (author "施宇迪")
           (email "a@sydi.org"))
      (with-current-buffer atom-buffer
        (kill-region (point-min) (point-max))
        (insert (format
                 "<?xml version=\"1.0\" encoding=\"utf-8\" ?>
<feed xmlns=\"http://www.w3.org/2005/Atom\">
  <title>%s</title>
  <subtitle>%s</subtitle>
  <link href=\"%s\" rel=\"self\"/>
  <link href=\"%s\"/>
  <updated>%s</updated>
  <id>%s</id>
  <author>
    <name><![CDATA[%s]]></name><email>%s</email>
  </author>
  <generator uri=\"%s\">orgmode4sydi</generator>"
                 title subtitle self-link link
                 (web-time-string)
                 id author email sydi/site-url))
        (dolist (file org-files)
          (let ((org-file-buffer (find-file file)))
            (set-buffer org-file-buffer)
            (let* ((plist (org-infile-export-plist))
                   (title (or
                           (plist-get plist :title)
                           "UNTITLED"))
                   (date (web-time-string
                          (org-time-string-to-time (or
                                                    (plist-get plist :date)
                                                    (format-time-string
                                                     (org-time-stamp-format)
                                                     (cons 0 0))))))
                   (url (concat
                         (replace-regexp-in-string
                          (file-truename sydi/base-directory)
                          sydi/site-url
                          (file-name-sans-extension (buffer-file-name)))
                         ".html"))
                   (entry (format
                           "<entry>
  <title>%s</title>
  <link href=\"%s\" />
  <updated>%s</updated>
  <id>%s</id>
  <content type=\"html\"><![CDATA[%s]]></content></entry>"
                           title
                           url
                           date
                           url
                           (org-export-as 'html nil nil t)
                           )))
              (kill-buffer org-file-buffer)
              (set-buffer atom-buffer)
              (insert entry))))
        (insert "</feed>")
        (save-buffer)
        (kill-buffer)))))

(defun sydi/get-org-file-date (file &optional other)
  "Return org file date in #+date header line using `current-time' format.

If #+date keyword is not set and `other' equals to \"modify\", return the file system's modification time instead, if `other' equals to \"change\" return the file system's last change time instead, if `other' equals to \"access\" return the file systems's access time instead, otherwise return 0 as 1970-01-01 00:00:00, the minimal time.
"
  (let ((visiting (find-buffer-visiting file)))
    (save-excursion
      (org-pop-to-buffer-same-window (or visiting (find-file-noselect file nil t)))
      (let* ((plist (org-infile-export-plist))
	     (date (plist-get plist :date)))
	(unless visiting
	  (kill-buffer (current-buffer)))
	(if date
	    (org-time-string-to-time date)
	  (when (file-exists-p file)
            (cond ((equal other "access") (nth 4 (file-attributes file)))
                  ((equal other "modify") (nth 5 (file-attributes file)))
                  ((equal other "change") (nth 6 (file-attributes file)))
                  (t '(0 0)))))))))

(require 'find-lisp)
(defun sydi/get-sorted-org-files (root-dir)
  "return a sorted org files list"
  (let ((org-files (remove-if
                    (lambda (ele) (member-if
                              (lambda (match-reg) (string-match-p match-reg ele))
                              sydi/atom-exclude-file-list))
                    (find-lisp-find-files root-dir "\\.org$")))
        (org-alist))
    (mapc
     (lambda (file)
       (set 'org-alist (cons
                        (cons file (sydi/get-org-file-date file))
                        org-alist)))
     org-files)
    (mapcar 'car
            (sort org-alist
                  (lambda (a b)
                    (let* ((adate (sydi/get-org-file-date (car a)))
                           (bdate (sydi/get-org-file-date (car b)))
                           (A (+ (lsh (car adate) 16) (cadr adate)))
                           (B (+ (lsh (car bdate) 16) (cadr bdate))))
                      (>= A B)))))))

;;; for sitemap.xml
(defun sydi/all-urls (root-dir prefix)
  (let* ((all-files (find-lisp-find-files root-dir ""))
         (all-org-files (remove-if-not
                         (lambda (file) (string-match ".org$" file)) all-files)))
    (concatenate 'list
                 (mapcar
                  (lambda (file) (replace-regexp-in-string
                             (concat root-dir "\\(.*\\).org")
                             (concat prefix "\\1.html")
                             file))
                  all-org-files)
                 (mapcar
                  (lambda (file) (replace-regexp-in-string
                             (concat root-dir "\\(.*\\)")
                             (concat prefix "\\1.html")
                             file))
                  all-org-files))))

(defun sydi/generate-sitemap-ex (sitemap-filename root-dir prefix)
  (with-temp-buffer
    (kill-region (point-min) (point-max))
    (insert
     (concat
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">
"
      (mapconcat (lambda (url) (format "<url><loc>%s</loc><priority>0.5000</priority></url>" url))
                 (sydi/all-urls root-dir prefix) "\n")
      "</urlset>"))
    (write-file (concat root-dir sitemap-filename))
    (kill-buffer)))

(defun sydi/generate-sitemap ()
  (interactive)
  (sydi/generate-sitemap-ex "sitemap.xml" "/home/ryan/sydi.org/org/" "http://sydi.org/"))

(provide 'init-org-html)
