;; Style -----------------------------------------------------------------------

(define-configuration (buffer web-buffer)
  "Adds dark-mode to buffers"
  ((default-modes (append '(dark-mode) %slot-default))))

(define-configuration  web-buffer
  "Darkens webpages without dark modes"
  ((darken)))

;; Keymaps ---------------------------------------------------------------------

(define-configuration (buffer web-buffer)
  "Adds emacs-mode to buffers"
  ((default-modes (append '(emacs-mode) %slot-default))))

(define-configuration buffer
  ((override-map (let ((map (make-keymap "override-map")))
                   (define-key map
                     "M-x" 'execute-command)))))

