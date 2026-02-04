;;; init.el --- Bootstrap -*- lexical-binding: t; -*-

;; 1. Cache & generated files (keep repo clean)
(defconst my/emacs-cache-dir
  (expand-file-name "emacs/" (or (getenv "XDG_CACHE_HOME") "~/.cache/")))
(unless (file-directory-p my/emacs-cache-dir)
  (make-directory my/emacs-cache-dir t))

;; Packages, customizations, and autosaves go to cache
(setq package-user-dir (expand-file-name "elpa/" my/emacs-cache-dir))
(setq custom-file (expand-file-name "custom.el" my/emacs-cache-dir))
(setq auto-save-list-file-prefix
      (expand-file-name "auto-save-list/.saves-" my/emacs-cache-dir))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" my/emacs-cache-dir) t)))
(setq backup-directory-alist
      `(("." . ,(expand-file-name "backup/" my/emacs-cache-dir))))

(dolist (dir '("elpa" "auto-save" "auto-save-list" "backup"))
  (let ((path (expand-file-name dir my/emacs-cache-dir)))
    (unless (file-directory-p path)
      (make-directory path t))))

(when (file-exists-p custom-file)
  (load custom-file))

;; 2. Package Archives (Modernized: GNU + MELPA)
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;; 3. Ensure use-package is ready
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))
(setq use-package-always-ensure t) ;; Always download missing packages

;; 4. Load the Main Config
(org-babel-load-file (expand-file-name "config.org" user-emacs-directory))

;; 5. Reset Garbage Collection to a sane default (2MB) after startup
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 2 1024 1024))))
