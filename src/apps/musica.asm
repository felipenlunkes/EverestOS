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
	
	;; Array de notas para tocar, terminado em 0
	;;                D     A     B    F#     G     D     G     A
	
NotasCanonemD: dw 4063, 5423, 4831, 6449, 6087, 8126, 6087, 5423, 0

Mensagem: db 10,13,"Tocando Canon de Pachelbel em D:  ", 0

StringNotas: db "D  ", 0, "A  ", 0, "B  ", 0, "F# ", 0, "G  ", 0, "D  ", 0, "G  ", 0, "A  ", 0 

;;*****************************************************************************
	
inicio:

	mov si, Mensagem
	int 80h
	
	mov di, StringNotas
	mov si, NotasCanonemD
	
;;*****************************************************************************
	
tocar_loop:	

	lodsw
	
	cmp ax, 0
	je pronto			;; Sse a nota for 0, terminar
	
	push si
	mov si, di
	
	int 80h			;; Imprimir nota
	
	add di, 4		;; Mover para a próxima string
	pop si
	
	int 89h			;; Tocar nota em AX
	
	mov cx, 12
	int 85h			;; Manter nota por um tempo
	
	int 8Ah			;; Para som
	
	mov cx, 3
	int 85h			;; Silenciar por algum tempo
	
	jmp tocar_loop	;; Próxima nota

;;*****************************************************************************
	
pronto:

	int 20h						;; Finalizar
