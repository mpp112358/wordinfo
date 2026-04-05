(load-file "~/gredos/1projects/define/define.el")

(global-set-key (kbd "s-r") (lambda ()
                              (interactive)
                              (load-file "~/gredos/1projects/define/define.el")
                              (message "Reloaded!")))
