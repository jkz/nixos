;;; commentary:
;;; i started with spacemacs, went to doom and now find myself writing my own

;; Without this, and with a symlinked .emacs.d, autoloads in elpa break
;; https://github.com/radian-software/straight.el/issues/944
(setq find-file-visit-truename nil)

;; This directory will become littered with emacs stuff, check .gitignore for what we want to check in to git
(defvar *EMACS-CONFIG-DIR* (file-name-directory (file-truename (or load-file-name (buffer-file-name)))))

;; Run emacs as a server and connect to it with emacsclient
(server-start)

;;; Code:
(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

;; Set up the visible bell
(setq visible-bell t)

;; Let's start by setting up the package manager, MELPA
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; This file both installs and initialises packages, using use-package
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

;; Some config

;; Open this file on load if none is specified
(setq initial-buffer-choice
  (lambda ()
    (if (buffer-file-name)
      (current-buffer)
      (find-file (concat (file-name-as-directory *EMACS-CONFIG-DIR*) "init.el")))))

;; Show line numbers
(setq display-line-numbers-type 'relative)
(setq display-line-numbers-width 3)
(global-display-line-numbers-mode)

;; Highlight the current line
(global-hl-line-mode 1)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Packages follow

;; General makes defining keybindings nicer
(use-package general
  :ensure t)

;; Loads a font that accentuates comments rather than deemphasising them.
;; (find-file (load-file (concat (file-name-as-directory *EMACS-CONFIF-DIR*) "themes/comments-only-theme.el")))


;; Magit might be the main reason I use emacs at all
(use-package magit
  :ensure t
  :config
  ;; Inspired by doom-emacs
  ;; Clean up after magit by killing leftover magit buffers and reverting
  ;; affected buffers (or at least marking them as need-to-be-reverted).
  (define-key magit-mode-map "q" #'+magit/quit)
  (define-key magit-mode-map "Q" #'+magit/quit-all)

  ;; Close transient with ESC
  (define-key transient-map [escape] #'transient-quit-one)
  

  ;; these numbered keys mask the numerical prefkix keys. Since they've already
  ;; been replaced with z1, z2, z3, etc (and 0 with g=), there's no need to keep
  ;; them around:
  (general-unbind magit-mode-map "M-1" "M-2" "M-3" "M-4" "1" "2" "3" "4" "0" "SPC")
  ;; TODO figure out if this is needed, or the general-unbind above is sufficient
  (define-key magit-status-mode-map (kbd "SPC") nil)

  ;; Always open in fullscreen
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
  ;; And open magit on project open
  (setq projectile-switch-project-action 'magit-status)


;; This lets us swap buffers
(require 'buffer-move)

;; Now include the command menu popup
(require' which-key)
(setq which-key-idle-delay 0.01)
(which-key-mode)


(setq jkz/highlight-comments-flag nil)

;; Respond to light/dark mode OS changes
(defun my/apply-theme (appearance)
  "Load theme, taking current system APPEARANCE into consideration."
  (mapc #'disable-theme custom-enabled-themes)
  ;; (if jkz/highlight-comments-flag
    (pcase appearance
	('light (load-theme 'gruvbox-light-hard t))
	('dark (load-theme 'gruvbox-dark-medium t))))
    ;; (pcase appearance
    ;; 	('light (load-theme 'gruvbox-light-hard t))
    ;; 	('dark (load-theme 'comments-only t)))))

;; Required to play with themes
;;(setq custom--inhibit-theme-enable nil)

(defun jkz/toggle-comment-font ()
  "Toggle between fonts that highlight code and comments respectively."
  (interactive)
  (setq jkz/highlight-comments-flag (not jkz/highlight-comments-flag))
  (my/apply-theme ns-system-appearance))


;; Set up our theme
(require 'gruvbox-theme)
(load-theme 'gruvbox-dark-medium t)
  (add-hook 'ns-system-appearance-change-functions #'my/apply-theme))

;; Search/completion
(require 'vertico)
(vertico-mode)

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :ensure t
  :init
  (savehist-mode))

(use-package emacs
  :ensure t
  :init
  ;; Emacs 28 and newer: Hide commands in M-x which do not work in the current
  ;; mode.  Vertico commands are hidden in normal buffers. This setting is
  ;; useful beyond Vertico.
  (setq read-extended-command-predicate #'command-completion-default-include-p))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :ensure t
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :ensure t
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

;; Search/completion
;; (use-package ivy
;;   :ensure t
;;   :bind (:map ivy-mode-map
;; 	 ("C-j" . ivy-next-line)
;; 	 ("C-k" . ivy-previous-line)
;; 	 :map ivy-minibuffer-map
;;          ("C-k" . ivy-previous-line)
;;          :map ivy-switch-buffer-map
;;          ("C-k" . ivy-previous-line)
;;          :map ivy-reverse-i-search-map
;;          ("C-k" . ivy-previous-line))
;;   :config
;;   (ivy-mode 1))

(use-package ivy-rich
  :ensure t
  :after counsel
  :init (ivy-rich-mode 1))

;; Project management
(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  ;; Only have one project per emacs window
  (add-hook 'projectile-after-switch-project-hook 'treemacs-display-current-project-exclusively))

;; Tree browser
(use-package treemacs
  :ensure t
  :config
  ;; Highlight the file of the current buffer in the tree
  (setq treemacs-show-hidden-files t)
  (treemacs-follow-mode 1)
  (treemacs-git-mode 1))

(use-package treemacs-projectile
  :ensure t
  :after (treemacs projectile))


;; (use-package treemacs-evil
;;   :after (treemacs evil)
;;   :ensure t
;;   :config
;;   (define-key evil-treemacs-state-map "o v" 'treemacs-visit-node-horizontal-split)
;;   (define-key evil-treemacs-state-map "o s" 'treemacs-visit-node-vertical-split))

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package treemacs-persp
  :after (treemacs perspective)
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package undo-tree
  :ensure t
  :config (global-undo-tree-mode))

;; Now let's support some languages

(use-package python
  :ensure t
  :mode ("\\.py\\'" . python-mode)
  :interpreter ("python" . python-mode))

;; Modular in-buffer completion framework for Emacs
(use-package company
  :ensure t
  :init (global-company-mode))

;; Syntax checker
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; Typescript language support
(use-package typescript-mode
  :ensure t)

;; Typescript Interactive Develop Environment
(use-package tide
  :ensure t
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)))

;; Trying this out. Don't think I like it.
;; (use-package centered-cursor-mode
;;  :ensure t
;;  :config
;;  (centered-cursor-mode 1)
;;  :custom
;;  (setq ccm-vpos-init 1) ;; Golden ratio
;; )

(use-package perspective
  :ensure t
  :config
  (persp-mode))

(use-package persp-projectile
  :ensure t)

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package svelte-mode
  :ensure t)

;; LLMs! One thing that makes vscode sticky is its excellent copilot experience.
(use-package copilot
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("*.el"))
  :ensure t)

;; And now the keybindings

;; (define-key evil-normal-state-map (kbd "<left>") nil)
;; (define-key evil-normal-state-map (kbd "<right>") nil)
;; (define-key evil-normal-state-map (kbd "<down>") nil)
;; (define-key evil-normal-state-map (kbd "<up>") nil)

;; (evil-global-set-key 'motion (kbd "<left>") nil)
;; (evil-global-set-key 'motion (kbd "<right>") nil)
;; (evil-global-set-key 'motion (kbd "<down>") nil)
;; (evil-global-set-key 'motion (kbd "<up>") 'nil)

(general-define-key "<up>"     'windmove-up)
(general-define-key "<down>"   'windmove-down)
(general-define-key "<left>"   'windmove-left)
(general-define-key "<right>"  'windmove-right)

(general-define-key "S-<up>"     'buf-move-up)
(general-define-key "S-<down>"   'buf-move-down)
(general-define-key "S-<left>"   'buf-move-left)
(general-define-key "S-<right>"  'buf-move-right)

(general-define-key "s-/" 'comment-or-uncomment-region)

(general-define-key
   :prefix "<leader>"
   "SPC" '(projectile-find-file :wk "find file")
   "/"   '(projectile-grep	:wk "grep")
   "g"   '(magit-status         :wk "ma[g]it")
   "u"   '(undo-tree-visualize  :wk "[u]ndo tree"))

(general-define-key
   :prefix "<leader> p"
   ""  '(nil					:wk "[p]rojects")
   "a" '(projectile-add-known-project		:wk "[a]dd project")
   "d" '(projectile-remove-known-project	:wk "remove project")
   "p" '(projectile-persp-switch-project	:wk "switch [p]roject"))

(general-define-key
   :prefix "<leader> o"
   ""  '(nil         :wk "[o]rg")
   "a" '(org-agenda  :wk "[a]genda")
   "c" '(org-capture :wk "[c]apture")
   "t" '(org-todo    :wk "[t]odo"))

(defun jkz/kill-all-buffers ()
  "Kill all buffers."
    (interactive)
    (mapc 'kill-buffer (buffer-list)))

(defun jkz/format-code ()
  "Run a code formatter for the current buffer"
  ;; Case statement on language of current buffer
  ;; Run the appropriate formatter
  ;; Maybe have some sort of hint/convention/emacsfile in the directory
  )

(setq which-key-add-column-padding 2)
(setq which-key-separator " ")

(define-prefix-command 'jkz/my-keymap)
(defvar jkz/dmy-keymap (make-sparse-map))

(setq org-llm/provider
  (make-llm-openai
   :key my-openai-key
   :chat-model "gpt-4o"))

(keymap-global-set "C-c l" org-llm/map)

;; Convenience
(setq org-confirm-babel-evaluate nil)
(setq llm-warn-on-nonfree nil)

;; Write generated custom stuff to a separate file
(setq custom-file (concat (file-name-as-directory *EMACS-CONFIG-DIR*) "custom.el"))
(load custom-file)




(defun hly/eval-print-full ()
  "Evaluate the sexp at point and insert it at point, no truncation"
  (interactive)
  (let ((eval-expression-print-length nil)
        (eval-expression-print-level nil))
    (eval-print-last-sexp)))
