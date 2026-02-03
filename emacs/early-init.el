;;; early-init.el --- Early Initialization -*- lexical-binding: t; -*-

;; 1. Speed up startup by disabling the package system (we init it manually later)
(setq package-enable-at-startup nil)

;; 2. Speed up startup by pausing Garbage Collection (GC)
;;    We allow 50MB of memory allocation before the GC runs.
(setq gc-cons-threshold (* 50 1024 1024))

;; 3. Disable GUI elements early
;;    Doing this here prevents the UI from "flickering" or resizing after the window appears.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)
