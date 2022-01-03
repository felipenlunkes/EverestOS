;;*****************************************************************************
;;
;; #$@$%&*%$#@#!$@@#@#$%!$#!$!#%#
;; !#@$@$EVEREST@#!$%#!¨%#!$#!¨#$
;; $#%@$#!@#$#!$%#W@¨#!!@#$@¨!@$¨          Sistema Operacional Everest®
;; #@%¨$@$#!@&%#$@¨#@&%$@%¨$@&¨$@
;; #@$@%¨#!$#                        Copyright © 2016 Felipe Miguel Nery Lunkes
;; #EVEREST#$                               Todos os direitos reservados
;; #@#$!@$@#!
;; #@$@!#!@#@
;; #!@$@!$@!#
;; @$!@!@#$$$
;; @!@$%@#$@$@#@@$#!@#!#!#!!@#
;; @!#@!$#$@#@$@##%#%#%%%#!@#!
;; #$@$@$@EVEREST$%#!#$!@#!!##         |    Sistema Operacional Everest® 
;; #@$%!$@%!#e@$%#!@¨#@$%%¨!#!         | 
;; !$@#$%¨@#@#@$@$%%#$%#%$@$!@         | Sistema desenvolvido em linguagem 
;; ¨@!#$@$@#@                          |   Assembly x86 para uso em PCs
;; @!@$%@#$@$                          |          Intel/AMD 386+
;; @!#@!$#$@$                          | 
;; #EVEREST@%                          |
;; #@$%!$@%!%                          |  
;; !$@#$%¨@#$                          |
;; ¨@!#$@$@##                          |
;; #$@$%&*%$#@#!$@@#@#$%!$#!$!#%#      | 
;; !#@$EVEREST#%@#!$%#!¨%#!$#!¨#$      | 
;; $#%@$#!@#$#!$%#EVEREST#$@¨!@$¨      |
;; #@%¨$@$#!@&%#$@¨#@&%$@%¨$@&¨$@      |  
;;
;;*****************************************************************************

;; COnverte String para maiúsculo
;;
;; Entrada:
;;
;;			Ponteiro da String em DS:SI

STRING_para_maiusculo:

	pusha
	
	mov bx, 0xFFFF						;; Início em -1
	
STRING_para_maiusculo_loop:	

	inc bx
	mov al, byte [ds:si+bx]				;; AL = caractere atual
	
	cmp al, 0							;; Se no fim da String, tudo pronto
	je STRING_para_maiusculo_pronto		
	
	cmp al, 'a'
	jb STRING_para_maiusculo_loop ;; Código ASCII muito pequeno para ser minúsculo
	
	cmp al, 'z'
	ja STRING_para_maiusculo_loop ;; Código ASCII muito grande para ser minúsculo
	
	sub al, 'a'-'A'
	mov byte [ds:si+bx], al				;; Subtrai o minúsculo do maiúsculo
	
	jmp STRING_para_maiusculo_loop ;; Próximo caractere
	
STRING_para_maiusculo_pronto:	

	popa
	ret
	