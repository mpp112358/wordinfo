(load-file "~/gredos/1projects/wordinfo/wordinfo.el")

(global-set-key (kbd "s-r") (lambda ()
                              (interactive)
                              (load-file "~/gredos/1projects/wordinfo/wordinfo.el")
                              (message "Reloaded!")))
