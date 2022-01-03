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
              
;; Retornar a posição do cursor na área de trabalho virtual
;;
;; Entrada:
;;
;;		AX - ID (offset) do display a que se deseja
;;
;; Saída:
;;
;;		BH - Linha do cursor
;;		BL - Coluna do cursor

DISPLAY_obter_posicao_atual:

	push si
	push ds
	
	push cs
	pop ds
	
	mov si, TabelaDisplay
	add si, ax
	mov bh, byte [ds:si+2]
	mov bl, byte [ds:si+3]
	
	pop ds
	pop si

	ret

;;*****************************************************************************	

;; Escrever uma terminação em zero no display selecionado
;;
;;
;; Entrada:
;;
;;		DS:SI - ponteiro para o primeiro caractere da string
;;		AX - ID do display virtual

DISPLAY_saida_string:

	pusha
	push es
	
	push cs
	pop es
	
	mov di, TabelaDisplay
	add di, ax				;; DI aponta para o início do slot de display virtual
							
	push di					;; Salvar ponteiro
							
	mov al, NUM_COLUNAS
	mul byte [es:di+2]		;; AX = NUM_COLUNAS * linha do cursor
	mov bh, 0
	mov bl, byte [es:di+3]	;; BX = coluna do cursor
	add ax, bx				;; AX = (NUM_COLUNAS * linha do cursor) + coluna do cursor
	
	shl ax, 1				;; Multiplicar por 2 (2 bytes por caractere)
	
	;; AX agora contêm o offset da memória onde será impressa a mensagem
	
	mov bh, byte [es:di+2]	;; BH = linha do cursor
							;; BL = coluna do cursor
	
	;; ES:DI aponta para o slot da tarefa atual
	
	add di, 100				;; ES:DI aponta para o início do buffer
	add di, ax				;; ES:DI aponta para onde será impressa a mensagem

;;*****************************************************************************
	
DISPLAY_exibir_string_loop:

	mov al, byte [ds:si]	;; Ler um caractere da string
	inc si					;; Próximo caractere
	
	cmp al, 0				;; Terminou?
	je DISPLAY_exibir_string_pronto	;; Sim

;;*****************************************************************************
	
DISPLAY_exibir_string_tentar_carriage_return:

	cmp al, ASCII_CARRIAGE_RETURN	 ;; Carriage return?
	jne DISPLAY_exibir_string_tentar_BS ;; Não
									 ;; Sim, retornar para o início da linha
	shl bl, 1						 ;; cada posição do cursor = 2 bytes
	mov ah, 0
	mov al, bl						 ;; AX = 2*coluna do cursor
	sub di, ax						 ;; Move o ponteiro do buffer para o início da linha
	mov bl, 0						 ;; Move o cursor para o início da linha
	jmp DISPLAY_exibir_string_loop	 ;; Pronto, então exiba o próximo caractere

;;*****************************************************************************
	
DISPLAY_exibir_string_tentar_BS:

	cmp al, ASCII_BACKSPACE					;; É backspace?
	jne DISPLAY_exibir_string_tentar_LF	;; Não
	
	cmp bl, 0								
	je DISPLAY_exibir_string_tentar_LF	
	
	sub di, 2								;; Mover uma posição (2-byte) a esquerda
	mov al, ASCII_ESPACO_VAZIO				;; Limpar o atual caractere na posição
	mov byte [es:di], al					;; Armazenar caractere
	
	dec bl									;; Mover o cursor a esquerda
	
	jmp DISPLAY_vram_exibir_string_loop	 ;; Pronto, então exiba o próximo caractere

;;*****************************************************************************
	
DISPLAY_exibir_string_tentar_LF:

	cmp al, ASCII_LINE_FEED						;; É LF?
	jne DISPLAY_exibir_string_caractere_pleno	;; Não
	
	inc bh										;; Sim, mover o cursor para baixo
	add di, NUM_COLUNAS*2					    ;; Mover o ponteiro uma posição abaixo
											    ;; (2 bytes por caractere)
	jmp DISPLAY_exibir_string_loop_checar_rolagem ;; Deve ter sido rolada a tela

;;*****************************************************************************
	
DISPLAY_exibir_string_caractere_pleno:

	;; Imprimir o caractere no buffer da área de trabalho virtual
	
	mov byte [es:di], al	;; Armazenar caractere
	add di, 2				;; Próximo caractere do buffer
							;; Pulando o byte de atributo
	inc bl					;; Avançar o cursor uma posiçã a direita
	
	cmp bl, NUM_COLUNAS		;; Está passando do limite da tela?
	jne DISPLAY_exibir_string_loop	;; Não, então continue para o próximo caractere
	
	mov bl, 0				;; Sim, então volte para o início da linha
	inc bh					;; E mova para a próxima linha
	

;;*****************************************************************************
	
DISPLAY_exibir_string_loop_checar_rolagem:

	cmp bh, NUM_LINHAS		;; Estamos passando da última linha?
	jne DISPLAY_exibir_string_loop	;; Não, então continue para o próximo caractere
									;; Sim, então role a tela
	
	mov cx, di						;; Salvar DI em CX
	
	pop di							;; DI = início do slot de display
	add di, 100						;; Mover DI para o início do buffer
	
	call BufferRolagemDisplay
	
	sub di, 100						;; Retornar DI para o início do slot
	push di							;; Colocar o início do slot novamente
	
	mov di, cx						;; Restaurar DI de CX
	dec bh							;; E colocar o cursor na última linha
	
	sub di, NUM_COLUNAS*2			;; Mover o ponteiro de buffer uma linha acima
									;; (2 bytes por caractere)
	
	jmp DISPLAY_exibir_string_loop	;; Exibir próximo caractere
	
;;*****************************************************************************
	
DISPLAY_exibir_string_pronto:

	;; aqui, BH = linha do cursor após a string ter sido exibida
	;;       BL = coluna do cursor após a string ter sido exibida
	
	;; Salvar a posição do cursor dentro do slot de display virtual
	
	pop di					;; Restaurar ponteiro para o início do slot
	
	mov byte [es:di+2], bh	;; Armazenar nova linha do cursor
	mov byte [es:di+3], bl	;; Armazenar nova coluna do cursor
	
	pop es
	
	popa
	
	ret

;;*****************************************************************************
	
DISPLAY_imprimir_sem_display_virtual:

call escrever

ret

;;*****************************************************************************
