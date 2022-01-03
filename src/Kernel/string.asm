;;*****************************************************************************
;;
;; #$@$%&*%$#@#!$@@#@#$%!$#!$!#%#
;; !#@$@$EVEREST@#!$%#!�%#!$#!�#$
;; $#%@$#!@#$#!$%#W@�#!!@#$@�!@$�          Sistema Operacional Everest�
;; #@%�$@$#!@&%#$@�#@&%$@%�$@&�$@
;; #@$@%�#!$#                        Copyright � 2016 Felipe Miguel Nery Lunkes
;; #EVEREST#$                               Todos os direitos reservados
;; #@#$!@$@#!
;; #@$@!#!@#@
;; #!@$@!$@!#
;; @$!@!@#$$$
;; @!@$%@#$@$@#@@$#!@#!#!#!!@#
;; @!#@!$#$@#@$@##%#%#%%%#!@#!
;; #$@$@$@EVEREST$%#!#$!@#!!##         |    Sistema Operacional Everest� 
;; #@$%!$@%!#e@$%#!@�#@$%%�!#!         | 
;; !$@#$%�@#@#@$@$%%#$%#%$@$!@         | Sistema desenvolvido em linguagem 
;; �@!#$@$@#@                          |   Assembly x86 para uso em PCs
;; @!@$%@#$@$                          |          Intel/AMD 386+
;; @!#@!$#$@$                          | 
;; #EVEREST@%                          |
;; #@$%!$@%!%                          |  
;; !$@#$%�@#$                          |
;; �@!#$@$@##                          |
;; #$@$%&*%$#@#!$@@#@#$%!$#!$!#%#      | 
;; !#@$EVEREST#%@#!$%#!�%#!$#!�#$      | 
;; $#%@$#!@#$#!$%#EVEREST#$@�!@$�      |
;; #@%�$@$#!@&%#$@�#@&%$@%�$@&�$@      |  
;;
;;*****************************************************************************

;; COnverte String para mai�sculo
;;
;; Entrada:
;;
;;			Ponteiro da String em DS:SI

STRING_para_maiusculo:

	pusha
	
	mov bx, 0xFFFF						;; In�cio em -1
	
STRING_para_maiusculo_loop:	

	inc bx
	mov al, byte [ds:si+bx]				;; AL = caractere atual
	
	cmp al, 0							;; Se no fim da String, tudo pronto
	je STRING_para_maiusculo_pronto		
	
	cmp al, 'a'
	jb STRING_para_maiusculo_loop ;; C�digo ASCII muito pequeno para ser min�sculo
	
	cmp al, 'z'
	ja STRING_para_maiusculo_loop ;; C�digo ASCII muito grande para ser min�sculo
	
	sub al, 'a'-'A'
	mov byte [ds:si+bx], al				;; Subtrai o min�sculo do mai�sculo
	
	jmp STRING_para_maiusculo_loop ;; Pr�ximo caractere
	
STRING_para_maiusculo_pronto:	

	popa
	ret
	