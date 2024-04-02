;;; init.el --- Solo Emacs (no external packages) Configuration
;;; Commentary:

;;; Code:


(setq gc-cons-threshold #x40000000)
(setq read-process-output-max (* 1024 1024 4))

;;; EMACS
(use-package emacs
  :ensure nil
  :bind
  (("M-o" . other-window))
  :custom
  (treesit-font-lock-level 4)
  (initial-scratch-message "")
  (ring-bell-function 'ignore)
  (truncate-lines t)
  (delete-selection-mode 1)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-listing-switches "-lh")
  (inhibit-startup-message t)
  (make-backup-files nil)
  (ispell-dictionary "en_US")
  (create-lockfiles nil)
  (pixel-scroll-precision-mode t)
  (pixel-scroll-precision-use-momentum nil)
  :init
  ;;  (load-theme 'wombat)
  (set-face-attribute 'default nil :family "Hack" :height 100)

  (defun my-elisp-mode-hook ()
    (interactive)
    (outline-minor-mode 1)
    (outline-hide-sublevels 1))
  (add-hook 'emacs-lisp-mode-hook #'my-elisp-mode-hook)


  (global-set-key (kbd "C-c p") (lambda ()
				  (interactive)
				  (shell-command (concat "prettier --write " (shell-quote-argument (buffer-file-name))))
				  (revert-buffer t t t)))

  (global-set-key (kbd "C-v") (lambda ()
				(interactive)
				(scroll-up-command)
				(recenter)
				))
  (global-set-key (kbd "M-v") (lambda ()
				(interactive)
				(scroll-down-command)
				(unless (= (window-start) (point-min))
				  (recenter))
				(when (= (window-start) (point-min))
				  (let ((midpoint (/ (window-height) 2)))
				    (goto-char (window-start))
				    (forward-line midpoint)
				    (recenter midpoint)))))
  

  (when scroll-bar-mode
    (scroll-bar-mode -1))

  (tool-bar-mode -1)
  (menu-bar-mode -1)

  (fido-vertical-mode)

  (when (eq system-type 'darwin)
    (setq mac-command-modifier 'meta))

  (add-to-list 'display-buffer-alist
               '("^\\*eldoc for" display-buffer-at-bottom
		 (window-height . 10)))

  (add-to-list 'display-buffer-alist
               '("^\\*\*Occur" display-buffer-at-bottom
		 (window-height . 10)))

  (add-to-list 'display-buffer-alist
               '("^\\*\*Completions" display-buffer-at-bottom
		 (window-height . 10)))

  (add-hook 'prog-mode-hook 'display-line-numbers-mode)
  
  (message (emacs-init-time)))

;;; ERC
(use-package erc
  :defer t
  :custom
  (erc-hide-list '("JOIN" "PART" "QUIT"))
  (erc-timestamp-format "[%H:%M]")
  (erc-autojoin-channels-alist '((".*\\.libera\\.chat" "#emacs"))))

;;; ESHELL
(use-package eshell
  :after (:all emacs)
  :config
  (add-hook 'eshell-mode-hook
	    (lambda ()
              (local-set-key (kbd "C-l")
			     (lambda ()
                               (interactive)
                               (eshell/clear 1)
			       (eshell-send-input)
			       ))))

  (setq eshell-prompt-function
	(lambda ()
          (concat
           "┌─("
	   (if (> eshell-last-command-status 0)
	       "⛒"
	     "✓")
	   " "
	   (number-to-string eshell-last-command-status)
           ")──("
	   "Ꜫ"
	   " "
	   (user-login-name)
           ")──("
	   "⏲"
	   " "
           (format-time-string "%H:%M:%S" (current-time))
           ")──("
	   "🗁"
	   " "
           (concat (if (>= (length (eshell/pwd)) 40)
		       (concat "..." (car (last (butlast (split-string (eshell/pwd) "/") 0))))
		     (abbreviate-file-name (eshell/pwd))))
           ")\n"
	   (if (car (vc-git-branches))
	       (concat
		"├─("
		"⎇"
		" "
		(car (vc-git-branches))
		")\n"
		))
           "└─➜ ")))

  (setq eshell-prompt-regexp "└─➜ ")

  (add-hook 'eshell-mode-hook (lambda () (setenv "TERM" "xterm-256color")))

  (setq eshell-visual-commands
		'("vi" "screen" "top"  "htop" "btm" "less" "more" "lynx" "ncftp" "pine" "tin" "trn"
		  "elm" "irssi" "nmtui-connect" "nethack" "vim" "alsamixer" "nvim" "w3m"
		  "ncmpcpp" "newsbeuter" "nethack" "mutt")))

;;; ISEARCH
(use-package isearch
  :config
  (setq isearch-lazy-count t)
  (setq lazy-count-prefix-format "(%s/%s) ")
  (setq lazy-count-suffix-format nil)
  (setq search-whitespace-regexp ".*?"))

;;; VC
(use-package vc
  ;; This is not needed, but it is left here as a reminder of some of the keybindings
  :bind
  (("C-x v d" . vc-dir)
   ("C-x v =" . vc-diff)
   ("C-x v D" . vc-root-diff)
   ("C-x v v" . vc-next-action)))

;;; SMERGE
(use-package smerge-mode
  :bind (:map smerge-mode-map
              ("C-c ^ u" . smerge-keep-upper)
              ("C-c ^ l" . smerge-keep-lower)
              ("C-c ^ n" . smerge-next)
              ("C-c ^ p" . smerge-previous)))

;;; ELDOC
(use-package eldoc
  :init
  (global-eldoc-mode))

;;; EGLOT
(use-package eglot
  :hook (prog-mode . eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  (eglot-prefer-plaintext t)
  :init
  ;; (setq eglot-stay-out-of '(flymake))
  :bind (:map
         eglot-mode-map
         ("C-c l a" . eglot-code-actions)
         ("C-c l o" . eglot-code-actions-organize-imports)
         ("C-c l r" . eglot-rename)
         ("C-c l f" . eglot-format)))

;;; FLYMAKE
(use-package flymake
  :hook (prog-mode . flymake-mode)
  :bind (:map flymake-mode-map
              ("C-c ! n" . flymake-goto-next-error)
              ("C-c ! p" . flymake-goto-prev-error)
              ("C-c ! l" . flymake-show-buffer-diagnostics)))

;;; RUBY-TS-MODE
(use-package ruby-ts-mode
  :mode "\\.rb\\'"
  :mode "Rakefile\\'"
  :mode "Gemfile\\'"
  :custom
  (add-to-list 'treesit-language-source-alist '(ruby "https://github.com/tree-sitter/tree-sitter-ruby" "master" "src"))
  (ruby-indent-level 2)
  (ruby-indent-tabs-mode nil))

;;; JS-TS-MODE
(use-package js-base-mode
  :defer 't
  :ensure js ;; I care about js-base-mode but it is locked behind the feature "js"
  :custom
  (js-indent-level 2)
  :config
  (add-to-list 'treesit-language-source-alist '(javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src"))
  (unbind-key "M-." js-base-mode-map))

;;; TYPESCRIPT-TS-MODE
(use-package typescript-ts-mode
  :ensure typescript-ts-mode
  :mode "\\.tsx?\\'"
  :defer 't
  :custom
  (typescript-indent-level 2)
  :config
  (add-to-list 'treesit-language-source-alist '(typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src"))
  (add-to-list 'treesit-language-source-alist '(tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src"))
  (unbind-key "M-." typescript-ts-base-mode-map))

;;; RUST-TS-MODE
(use-package rust-ts-mode
  :ensure rust-ts-mode
  :mode "\\.rs\\'"
  :defer 't
  :custom
  (rust-indent-level 2)
  :config
  (add-to-list 'treesit-language-source-alist '(rust "https://github.com/tree-sitter/tree-sitter-rust" "master" "src"))
  (unbind-key "M-." typescript-ts-base-mode-map))

;;; TOML-TS-MODE
(use-package toml-ts-mode
  :ensure toml-ts-mode
  :mode "\\.toml\\'"
  :defer 't
  :config
  (add-to-list 'treesit-language-source-alist '(toml "https://github.com/ikatyang/tree-sitter-toml" "master" "src")))

;;; MARKDOWN-TS-MODE
(use-package markdown-ts-mode
  :ensure nil
  :mode ("\\.md\\'" . markdown-ts-mode)
  :defer 't
  :config
  (add-to-list 'major-mode-remap-alist '(markdown-mode . markdown-ts-mode))
  (add-to-list 'treesit-language-source-alist '(markdown "https://github.com/ikatyang/tree-sitter-markdown" "master" "src")))

;;; EMACS-SOLO-THEME
(defun apply-emacs-solo-theme ()
  "Theme heavily inspired by Kanagawa Theme.
Available: https://github.com/meritamen/emacs-kanagawa-theme"
  (interactive)
  (defgroup emacs-solo-theme nil
    "Emacs-Solo-theme options."
    :group 'faces)

  (defcustom emacs-solo-theme-comment-italic t
    "Enable italics for comments and also disable background."
    :type 'boolean
    :group 'emacs-solo-theme)

  (defcustom emacs-solo-theme-keyword-italic t
    "Enable italics for keywords."
    :type 'boolean
    :group 'emacs-solo-theme)

  (defcustom emacs-solo-theme-org-height t
    "Use varying text heights for org headings."
    :type 'boolean
    :group 'emacs-solo-theme)

  (defcustom emacs-solo-theme-org-bold t
    "Inherit text bold for org headings"
    :type 'boolean
    :group 'emacs-solo-theme)

  (defcustom emacs-solo-theme-org-priority-bold t
    "Inherit text bold for priority items in agenda view"
    :type 'boolean
    :group 'emacs-solo-theme)

  (defcustom emacs-solo-theme-org-highlight nil
    "Highlight org headings."
    :type 'boolean
    :group 'emacs-solo-theme)

  (defcustom emacs-solo-theme-underline-parens t
    "If non-nil, underline matching parens when using `show-paren-mode' or similar."
    :type 'boolean
    :group 'emacs-solo-theme)

  (defcustom emacs-solo-theme-custom-colors nil
    "Specify a list of custom colors."
    :type 'alist
    :group 'emacs-solo-theme)

  (defun true-color-p ()
    (or (display-graphic-p)
	(= (tty-display-color-cells) 16777216)))

  (deftheme emacs-solo "An elegant theme inspired by The Great Wave off Emacs-Solo by Katsushika Hokusa")

  (eval
    (defvar emacs-solo-dark-palette
      `((fuji-white       ,(if (true-color-p) "#DCD7BA" "#ffffff"))
	(old-white        ,(if (true-color-p) "#C8C093" "#ffffff"))
	(sumi-ink-0       ,(if (true-color-p) "#16161D" "#000000"))
	(sumi-ink-1b      ,(if (true-color-p) "#1f1f28" "#000000"))
	(sumi-ink-1       ,(if (true-color-p) "#1F1F28" "#080808"))
	(sumi-ink-2       ,(if (true-color-p) "#2A2A37" "#121212"))
	(sumi-ink-3       ,(if (true-color-p) "#363646" "#303030"))
	(sumi-ink-4       ,(if (true-color-p) "#54546D" "#303030"))
	(wave-blue-1      ,(if (true-color-p) "#223249" "#4e4e4e"))
	(wave-blue-2      ,(if (true-color-p) "#2D4F67" "#585858"))
	(wave-aqua-1      ,(if (true-color-p) "#6A9589" "#6a9589"))
	(wave-aqua-2      ,(if (true-color-p) "#7AA89F" "#717C7C"))
	(winter-green     ,(if (true-color-p) "#2B3328" "#585858"))
	(winter-yellow    ,(if (true-color-p) "#49443C" "#585858"))
	(winter-red       ,(if (true-color-p) "#43242B" "#585858"))
	(winter-blue      ,(if (true-color-p) "#252535" "#585858"))
	(autumn-green     ,(if (true-color-p) "#76946A" "#585858"))
	(autumn-red       ,(if (true-color-p) "#C34043" "#585858"))
	(autumn-yellow    ,(if (true-color-p) "#DCA561" "#585858"))
	(samurai-red      ,(if (true-color-p) "#E82424" "#585858"))
	(ronin-yellow     ,(if (true-color-p) "#FF9E3B" "#585858"))
	(dragon-blue      ,(if (true-color-p) "#658594" "#658594"))
	(fuji-gray        ,(if (true-color-p) "#727169" "#717C7C"))
	(spring-violet-1  ,(if (true-color-p) "#938AA9" "#717C7C"))
	(oni-violet       ,(if (true-color-p) "#957FB8" "#717C7C"))
	(crystal-blue     ,(if (true-color-p) "#7E9CD8" "#717C7C"))
	(spring-violet-2  ,(if (true-color-p) "#9CABCA" "#717C7C"))
	(spring-blue      ,(if (true-color-p) "#7FB4CA" "#717C7C"))
	(light-blue       ,(if (true-color-p) "#A3D4D5" "#717C7C"))
	(spring-green     ,(if (true-color-p) "#98BB6C" "#717C7C"))
	(boat-yellow-1    ,(if (true-color-p) "#938056" "#717C7C"))
	(boat-yellow-2    ,(if (true-color-p) "#C0A36E" "#717C7C"))
	(carp-yellow      ,(if (true-color-p) "#E6C384" "#717C7C"))
	(sakura-pink      ,(if (true-color-p) "#D27E99" "#717C7C"))
	(wave-red         ,(if (true-color-p) "#E46876" "#717C7C"))
	(peach-red        ,(if (true-color-p) "#FF5D62" "#717C7C"))
	(surimi-orange    ,(if (true-color-p) "#FFA066" "#717C7C"))
	(katana-gray      ,(if (true-color-p) "#717C7C" "#717C7C"))
	(comet            ,(if (true-color-p) "#54536D" "#4e4e4e")))))

  (defmacro define-emacs-solo-dark-theme (theme &rest faces)
    `(let ((class '((class color) (min-colors 89)))
           ,@emacs-solo-dark-palette)
       (cl-loop for (cvar . val) in emacs-solo-theme-custom-colors
		do (set cvar val))
       (custom-theme-set-faces ,theme ,@faces)))

  (define-emacs-solo-dark-theme
   'emacs-solo
   ;; Customize faces
   `(default                                       ((,class (:background ,sumi-ink-1b :foreground ,fuji-white))))
   `(border                                        ((,class (:background ,sumi-ink-1b :foreground ,sumi-ink-0))))
   `(button                                        ((,class (:foreground ,wave-aqua-2))))
   `(child-frame                                   ((,class (:background ,sumi-ink-0 :foreground ,sumi-ink-0))))
   `(child-frame-border                            ((,class (:background ,sumi-ink-0 :foreground ,sumi-ink-0))))
   `(cursor                                        ((,class (:background ,light-blue :foreground ,sumi-ink-0 :weight bold))))
   `(error                                         ((,class (:foreground ,samurai-red))))
   `(fringe                                        ((,class (:foreground ,sumi-ink-3))))
   `(glyph-face                                    ((,class (:background ,sumi-ink-4))))
   `(glyphless-char                                ((,class (:foreground ,sumi-ink-4))))
   `(header-line                                   ((,class (:background ,sumi-ink-0))))
   `(highlight                                     ((,class (:background ,comet :foreground ,spring-violet-1))))
   `(hl-line                                       ((,class (:background ,sumi-ink-2))))
   `(homoglyph                                     ((,class (:foreground ,light-blue))))
   `(internal-border                               ((,class (:background ,sumi-ink-1b))))
   `(line-number                                   ((,class (:foreground ,sumi-ink-4))))
   `(line-number-current-line                      ((,class (:foreground ,spring-violet-2 :background ,sumi-ink-2 :weight bold))))
   `(lv-separator                                  ((,class (:foreground ,wave-blue-2 :background ,sumi-ink-2))))
   `(match                                         ((,class (:background ,carp-yellow :foreground ,sumi-ink-0))))
   `(menu                                          ((,class (:background ,sumi-ink-0 :foreground ,fuji-white))))
   `(mode-line                                     ((,class (:background ,sumi-ink-0))))
   `(mode-line-inactive                            ((,class (:background unspecified :foreground ,sumi-ink-4))))
   `(mode-line-active                              ((,class (:background ,sumi-ink-0 :foreground ,old-white))))
   `(mode-line-highlight                           ((,class (:foreground ,boat-yellow-2))))
   `(mode-line-buffer-id                           ((,class (:foreground ,wave-aqua-2 :weight bold))))
   `(numbers                                       ((,class (:background ,sakura-pink))))
   `(region                                        ((,class (:background ,wave-blue-2))))
   `(separator-line                                ((,class (:background ,sumi-ink-0))))
   `(shadow                                        ((,class (:background ,sumi-ink-0))))
   `(success                                       ((,class (:foreground ,wave-aqua-2))))
   `(vertical-border                               ((,class (:foreground ,sumi-ink-4))))
   `(warning                                       ((,class (:foreground ,ronin-yellow))))
   `(window-border                                 ((,class (:background ,sumi-ink-1b))))
   `(window-divider                                ((,class (:foreground ,sumi-ink-2))))
   `(hi-yellow                                     ((,class (:background ,carp-yellow :foreground ,sumi-ink-1b))))

   ;; Font lock
   `(font-lock-type-face                           ((,class (:foreground ,wave-aqua-2))))
   `(font-lock-regexp-grouping-backslash           ((,class (:foreground ,boat-yellow-2))))
   `(font-lock-keyword-face                        ((,class (:foreground ,oni-violet :weight semi-bold :slant ,(if emacs-solo-theme-keyword-italic 'italic 'normal)))))
   `(font-lock-warning-face                        ((,class (:foreground ,ronin-yellow))))
   `(font-lock-string-face                         ((,class (:foreground ,spring-green :slant italic))))
   `(font-lock-builtin-face                        ((,class (:foreground ,spring-blue))))
   `(font-lock-reference-face                      ((,class (:foreground ,peach-red))))
   `(font-lock-constant-face                       ((,class (:foreground ,carp-yellow))))
   `(font-lock-function-name-face                  ((,class (:foreground ,crystal-blue))))
   `(font-lock-variable-name-face                  ((,class (:foreground ,wave-red))))
   `(font-lock-negation-char-face                  ((,class (:foreground ,peach-red))))
   `(font-lock-comment-face                        ((,class (:foreground ,fuji-gray :slant ,(if emacs-solo-theme-keyword-italic 'italic 'normal)))))
   `(font-lock-comment-delimiter-face              ((,class (:foreground ,fuji-gray :slant ,(if emacs-solo-theme-keyword-italic 'italic 'normal)))))
   `(font-lock-doc-face                            ((,class (:foreground ,comet))))
   `(font-lock-doc-markup-face                     ((,class (:foreground ,comet))))
   `(font-lock-preprocessor-face                   ((,class (:foreground ,boat-yellow-2))))
   `(elisp-shorthand-font-lock-face                ((,class (:foreground ,fuji-white))))
   `(info-xref                                     ((,class (:foreground ,carp-yellow))))
   `(minibuffer-prompt-end                         ((,class (:foreground ,autumn-red :background ,winter-red))))
   `(minibuffer-prompt                             ((,class (:foreground ,carp-yellow :background ,winter-yellow))))
   `(epa-mark                                      ((,class (:foreground ,wave-red))))
   `(dired-mark                                    ((,class (:foreground ,wave-red))))
   `(trailing-whitespace                           ((,class (:background ,comet))))
   `(mode-line                                     ((,class (:background ,sumi-ink-0 :foreground ,fuji-white :weight bold))))

   ;; message colors
   `(message-header-name                           ((,class (:foreground ,sumi-ink-4))))
   `(message-header-other                          ((,class (:foreground ,surimi-orange))))
   `(message-header-subject                        ((,class (:foreground ,carp-yellow))))
   `(message-header-to                             ((,class (:foreground ,old-white))))
   `(message-header-cc                             ((,class (:foreground ,wave-aqua-2))))
   `(message-header-xheader                        ((,class (:foreground ,old-white))))
   `(custom-link                                   ((,class (:foreground ,crystal-blue))))
   `(link                                          ((,class (:foreground ,crystal-blue))))

   ;; org-mode
   `(org-done                                      ((,class (:foreground ,dragon-blue))))
   `(org-code                                      ((,class (:background ,sumi-ink-0))))
   `(org-meta-line                                 ((,class (:background ,winter-green :foreground ,spring-green))))
   `(org-block                                     ((,class (:background ,sumi-ink-0 :foreground ,sumi-ink-4))))
   `(org-block-begin-line                          ((,class (:background ,winter-blue :foreground ,spring-blue))))
   `(org-block-end-line                            ((,class (:background ,winter-red :foreground ,peach-red))))
   `(org-headline-done                             ((,class (:foreground ,dragon-blue :strike-through t))))
   `(org-todo                                      ((,class (:foreground ,surimi-orange :weight bold))))
   `(org-headline-todo                             ((,class (:foreground ,sumi-ink-2))))
   `(org-upcoming-deadline                         ((,class (:foreground ,peach-red))))
   `(org-footnote                                  ((,class (:foreground ,wave-aqua-2))))
   `(org-indent                                    ((,class (:background ,sumi-ink-1b :foreground ,sumi-ink-1b))))
   `(org-hide                                      ((,class (:background ,sumi-ink-1b :foreground ,sumi-ink-1b))))
   `(org-date                                      ((,class (:foreground ,wave-blue-2))))
   `(org-ellipsis                                  ((,class (:foreground ,wave-blue-2 :weight bold))))
   `(org-level-1                                   ((,class (:inherit bold :foreground ,peach-red :height ,(if emacs-solo-theme-org-height 1.3 1.0) :weight ,(if emacs-solo-theme-org-bold 'unspecified 'normal)))))
   `(org-level-2                                   ((,class (:inherit bold :foreground ,spring-violet-2 :height ,(if emacs-solo-theme-org-height 1.2 1.0) :weight ,(if emacs-solo-theme-org-bold 'unspecified 'normal)))))
   `(org-level-3                                   ((,class (:foreground ,boat-yellow-2 :height ,(if emacs-solo-theme-org-height 1.1 1.0)))))
   `(org-level-4                                   ((,class (:foreground ,fuji-white))))
   `(org-level-5                                   ((,class (:foreground ,fuji-white))))
   `(org-level-6                                   ((,class (:foreground ,carp-yellow))))
   `(org-level-7                                   ((,class (:foreground ,surimi-orange))))
   `(org-level-8                                   ((,class (:foreground ,spring-green))))
   `(org-priority                                  ((,class (:foreground ,peach-red :inherit bold :weight ,(if emacs-solo-theme-org-priority-bold 'unspecified 'normal)))))

   `(info-header-xref                              ((,class (:foreground ,carp-yellow))))
   `(xref-file-header                              ((,class (:foreground ,carp-yellow))))
   `(xref-match                                    ((,class (:foreground ,carp-yellow))))

   ;; show-paren
   `(show-paren-match                              ((,class (:background ,wave-aqua-1 :foreground ,sumi-ink-0 :weight bold :underline ,(when emacs-solo-theme-underline-parens t)))))
   `(show-paren-match-expression                   ((,class (:background ,wave-aqua-1 :foreground ,sumi-ink-0 :weight bold))))
   `(show-paren-mismatch                           ((,class (:background ,peach-red :foreground ,old-white :underline ,(when emacs-solo-theme-underline-parens t)))))
   `(tooltip                                       ((,class (:foreground ,sumi-ink-0 :background ,carp-yellow :weight bold))))

   ;; term
   `(term                                          ((,class (:background ,sumi-ink-0 :foreground ,fuji-white))))
   `(term-color-blue                               ((,class (:background ,crystal-blue :foreground ,crystal-blue))))
   `(term-color-bright-blue                        ((,class (:inherit term-color-blue))))
   `(term-color-green                              ((,class (:background ,wave-aqua-2 :foreground ,wave-aqua-2))))
   `(term-color-bright-green                       ((,class (:inherit term-color-green))))
   `(term-color-black                              ((,class (:background ,sumi-ink-0 :foreground ,fuji-white))))
   `(term-color-bright-black                       ((,class (:background ,sumi-ink-1b :foreground ,sumi-ink-1b))))
   `(term-color-white                              ((,class (:background ,fuji-white :foreground ,fuji-white))))
   `(term-color-bright-white                       ((,class (:background ,old-white :foreground ,old-white))))
   `(term-color-red                                ((,class (:background ,peach-red :foreground ,peach-red))))
   `(term-color-bright-red                         ((,class (:background ,spring-green :foreground ,spring-green))))
   `(term-color-yellow                             ((,class (:background ,carp-yellow :foreground ,carp-yellow))))
   `(term-color-bright-yellow                      ((,class (:background ,carp-yellow :foreground ,carp-yellow))))
   `(term-color-cyan                               ((,class (:background ,spring-blue :foreground ,spring-blue))))
   `(term-color-bright-cyan                        ((,class (:background ,spring-blue :foreground ,spring-blue))))
   `(term-color-magenta                            ((,class (:background ,spring-violet-2 :foreground ,spring-violet-2))))
   `(term-color-bright-magenta                     ((,class (:background ,spring-violet-2 :foreground ,spring-violet-2))))

   `(ansi-color-green                              ((,class (:foreground ,spring-green))))
   `(ansi-color-black                              ((,class (:background ,sumi-ink-0))))
   `(ansi-color-cyan                               ((,class (:foreground ,wave-aqua-2))))
   `(ansi-color-magenta                            ((,class (:foreground ,sakura-pink))))
   `(ansi-color-blue                               ((,class (:foreground ,crystal-blue))))
   `(ansi-color-red                                ((,class (:foreground ,peach-red))))
   `(ansi-color-white                              ((,class (:foreground ,fuji-white))))
   `(ansi-color-yellow                             ((,class (:foreground ,autumn-yellow))))
   `(ansi-color-bright-white                       ((,class (:foreground ,old-white))))
   `(ansi-color-bright-white                       ((,class (:foreground ,old-white))))

   `(focus-unfocused                               ((,class (:foreground ,sumi-ink-4)))))

  (provide-theme 'emacs-solo)

  
  (defun emacs-solo-theme ()
    "Set emacs-solo theme"
    (interactive)
    (enable-theme 'emacs-solo))

  (emacs-solo-theme))

(apply-emacs-solo-theme)

(provide 'init)
