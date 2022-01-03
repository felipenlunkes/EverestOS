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

;; Macros e funções importantes para a portabilidade de funções da HAL do PX-DOS
 
;;***************************************************************************** 


section .text

%include "HAL\impressora.asm"
%include "HAL\memx86.asm"
%include "HAL\procx86.asm"
%include "HAL\video.asm"
%include "HAL\serial.asm"

 
HAL_INICIALIZAR:

call IMPRESSORA_INICIALIZAR  ;; Detectar e instalar impressoras instaladas

 
ret

;;*****************************************************************************
 
delay:

	pusha
	cmp ax, 0
	je .tempo_para			

	mov cx, 0
	mov [.var_contar], cx		

	mov bx, ax
	mov ax, 0
	mov al, 2			; 2 * 55ms = 110mS
	mul bx				
	mov [.delay_original], ax	

	mov ah, 0
	int 1Ah				

	mov [.contagem_anterior], dx

.checarLoop:
	mov ah,0
	int 1Ah				

	cmp [.contagem_anterior], dx	

	jne .na_hora			
	jmp .checarLoop			

.tempo_para:
	popa
	ret

.na_hora:
	mov ax, [.var_contar]		; Incrementar var_contar
	inc ax
	mov [.var_contar], ax

	cmp ax, [.delay_original]	
	jge .tempo_para		

	mov [.contagem_anterior], dx	

	jmp .checarLoop		


	.delay_original		dw	0
	.var_contar		dw	0
	.contagem_anterior	dw	0
	
;;*****************************************************************************

paraString:


        pusha
        mov cx, 0
        mov bx, 10
        mov di, .tmp
		
.empurrar:

        mov dx, 0
        div bx
        inc cx
        push dx
        test ax,ax
        jnz .empurrar
		
.puxar:
        pop dx
        add dl, '0'
        mov [di], dl
		inc di
        dec cx
        jnz .puxar

        mov byte [di], 0
        popa
        mov ax, .tmp
		ret
		
        .tmp times 7 db 0
 
