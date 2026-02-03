;;; init.el --- Bootstrap -*- lexical-binding: t; -*-

;; 1. Keep the custom-set-variables out of this file
(setq custom-file (locate-user-emacs-file "custom.el"))
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

