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

ContagemAtual:		dw 0	;; Incrementa
delayInicioContagem:		dw 0	

ultimoNumeroAleatorio:		dw 0	;; Último número gerado


TIMER_chamar_de_volta:

	pusha
	push ds
	
	push cs
	pop ds
	
	mov ax, word [ContagemAtual]
	inc ax
	mov word [ContagemAtual], ax
	
	pop ds
	popa
	ret

;;*****************************************************************************
	
;; Retornar a contagem atual
;;
; Saída:
;;
;; Contagem em AX

TIMER_obter_contagem_atual:

	push ds
	
	push cs
	pop ds
	
	mov ax, word [ContagemAtual]
	
	pop ds
	ret

;;*****************************************************************************
	
;; Entrada: 
;;
;; Número para contar em CX

TIMER_delay:

	pushf
	pusha
	push ds
	
	push cs
	pop ds
	
	sti			
	
TIMER_delay_aguardar_um:	

	mov bx, word [ContagemAtual]
	
TIMER_delay_aguardar_mudanca:

	cmp bx, word [ContagemAtual]
	je TIMER_delay_aguardar_mudanca	
									
	dec cx
	cmp cx, 0
	ja TIMER_delay_aguardar_um			
	
	pop ds
	popa
	popf	
	ret

;;*****************************************************************************
	
;; Retorna o próximo número aleatório
;;
;; Saída:
;;
;;			Próximo número em AX

ALEATORIO_obter_proximo:

	push ds
	push bx
	push dx
	
	push cs
	pop ds
	
	mov al, 0		;; Registrador de segundos
	out 0x70, al	;; Selecionar
	in al, 0x71		;; Ler valor do registrador
	mov dl, al		;; Manter em DL
					
	
	mov ax, word [ultimoNumeroAleatorio]
	mov bl, 31
	mul bl
	add ax, word [ContagemAtual]
	mov bl, 13
	mul bl
	add ax, 98
	rol ax, 3
	add ax, word [ultimoNumeroAleatorio]
	add ax, word [ContagemAtual]
	add ax, dx						;; baseado na contagem de segundos RTC
	
	mov word [ultimoNumeroAleatorio], ax		;; Armazenar novo valor randômico
	
	pop dx
	pop bx
	pop ds
	ret
	
;;*****************************************************************************
	
;; Inicializar o gerador de números aleatórios baseado em valores CMOS RTC 

ALEATORIOS_inicializar:

	pusha
	
	mov ah, 0
	
	mov al, 0		;; Registrador de segundos
	out 0x70, al	;; Selecionar
	in al, 0x71		;; Ler valor do registrador
	mov bx, ax
	shl bx, 8
	add bx, ax
	
	mov al, 2		;; Registrador de minutos
	out 0x70, al	;; Selecionar
	in al, 0x71		;; Ler valor do registrador
	add bx, ax
	
	mov al, 4		;; Registrador de horas
	out 0x70, al	;; Selecionar
	in al, 0x71		;; Ler valor do registrador
	add bx, ax
	
	mov al, 8		;; Registrador de mês
	out 0x70, al	;; Selecionar
	in al, 0x71		;; Ler valor do registrador
	add bx, ax
	
	mov al, 9		;; Registrador de ano
	out 0x70, al	;; Selecionar
	in al, 0x71		;; Ler valor do registrador
	add bx, ax

	mov word [ultimoNumeroAleatorio], bx	;; Alimentar com o valor
	
	popa
	
	ret
	
;;*****************************************************************************
	
TIMER_delay_seguro: ;; Utiliza o RTC, mais eficiente e confiável

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