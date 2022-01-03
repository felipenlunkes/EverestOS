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

RetornoMensagem: db 13, 0
MensagemPrompt: db " segundos restantes", 0

;;*****************************************************************************

;; Exibe mensagem e conta
;;
;; Entrada:
;;
;;		DS:SI - apontando para a mensagem
;;		BH - código ASCII para a primeira tecla possível
;;		BL - código ASCII para a segunda tecla possível
;;		DL - nnúmero de segundos para aguardar
;;
;; Saída:
;;
;;		AL - 1 se a tecla pressionada, 0 se não

UTILIDADE_contar_prompt_usuario:

	call TECLADO_limpar_buffer
	
	mov dh, 0					;; DX = DL
	
UTILIDADE_contar_prompt_usuario_loop:

	push dx
	push si
	
	mov si, RetornoMensagem
	call DEBUG_imprimir_string		;; Move cursor para o começo da linha
	
	pop si
	
	call DEBUG_imprimir_string		;; Exibe a string
	
	mov al, dl
	
	call DEBUG_imprimir_byte		;; Exibe a contagem de segundos
	
	push si
	mov si, MensagemPrompt
	
	call DEBUG_imprimir_string		
	
	pop si
	
	mov cx, 18					;; Espera um segundo

;;*****************************************************************************
	
UTILIDADE_contar_prompt_usuario_delay:

	push cx
	
	;; Checar pressionamento de tecla
	
	mov ah, 1
	int 16h 					;; Alguma pressionada?
	
	jz UTILIDADE_contar_prompt_usuario_delay_sem_tecla ;; Não
	
	mov ah, 0					;; Sim
	int 16h						;; Ler tecla
	
	cmp al, bh					;; Primeira tecla pressionada?
	je UTILIDADE_contar_prompt_usuario_delay_pressionada ;; Sim
	
	cmp al, bl					;; Segunda tecla pressionada?
	je UTILIDADE_contar_prompt_usuario_delay_pressionada ;; Sim
	
	;; Tecla não reconhecida

;;*****************************************************************************
	
UTILIDADE_contar_prompt_usuario_delay_sem_tecla:	

	mov cx, 1					
	call TIMER_delay			;; 18 = 1 sgundo
	
	pop cx						;; Restaurar contador
	dec cx
	
	cmp cx, 0
	jne UTILIDADE_contar_prompt_usuario_delay	;; Próximo delay
	
	;; Mantido um segundo
	
	pop dx
	dec dx
	
	cmp dx, -1					;; Segundo?
	jne UTILIDADE_contar_prompt_usuario_loop	;; Não
	
	mov al, 0					;; usuário não pressionou nada
	ret
	
UTILIDADE_contar_prompt_usuario_delay_pressionada:

	pop cx						
	pop dx						
	mov al, 1					;; Pressionou!
	ret

;;*****************************************************************************
	
UTILIDADE_para_string:

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