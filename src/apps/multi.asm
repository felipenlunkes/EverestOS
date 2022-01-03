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
;; #$@$%&*%$#@#!$@@#@#$%!$#!$!#%#      |        Aplicativos do Sistema
;; !#@$EVEREST#%@#!$%#!¨%#!$#!¨#$      | 
;; $#%@$#!@#$#!$%#EVEREST#$@¨!@$¨      |
;; #@%¨$@$#!@&%#$@¨#@&%$@%¨$@&¨$@      |  
;;
;;*****************************************************************************

[BITS 16]

org 0h

mov ax, cs
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax

jmp inicio

;;*****************************************************************************

cabecalho:

.assinatura db "EVO",0

;;*****************************************************************************

String:	db "     >>> Sistema Operacional Everest - Teste de multitarefa! <<<     ", 0

Aviso_Display db 10,13,"O aplicativo foi aberto em uma nova area de trabalho virtual.",10,13
              db 10,13,"Utilize a combinacao fornecida acima para acessa-lo.",0

;;*****************************************************************************

inicio:

mov si, Aviso_Display
int 80h

	mov dx, 100

;;*****************************************************************************
	
loop_Principal:

	dec dx
	jz pronto
	
	mov si, String
	int 97h						;; Imprimir string
	
	mov cx, 1					;; Delay em um intervalo de tempo
	
	int 85h						
	int 37h						
	
	int 85h						
	int 37h						
	
	int 85h						
	int 37h						
	
	int 85h						
	int 37h						
	
	
	jmp loop_Principal				

;;*****************************************************************************
	
pronto:

	int 20h						;; Sair
