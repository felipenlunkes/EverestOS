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
              
;; Retornar a posi��o do cursor na �rea de trabalho virtual
;;
;; Entrada:
;;
;;		AX - ID (offset) do display a que se deseja
;;
;; Sa�da:
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

;; Escrever uma termina��o em zero no display selecionado
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
	add di, ax				;; DI aponta para o in�cio do slot de display virtual
							
	push di					;; Salvar ponteiro
							
	mov al, NUM_COLUNAS
	mul byte [es:di+2]		;; AX = NUM_COLUNAS * linha do cursor
	mov bh, 0
	mov bl, byte [es:di+3]	;; BX = coluna do cursor
	add ax, bx				;; AX = (NUM_COLUNAS * linha do cursor) + coluna do cursor
	
	shl ax, 1				;; Multiplicar por 2 (2 bytes por caractere)
	
	;; AX agora cont�m o offset da mem�ria onde ser� impressa a mensagem
	
	mov bh, byte [es:di+2]	;; BH = linha do cursor
							;; BL = coluna do cursor
	
	;; ES:DI aponta para o slot da tarefa atual
	
	add di, 100				;; ES:DI aponta para o in�cio do buffer
	add di, ax				;; ES:DI aponta para onde ser� impressa a mensagem

;;*****************************************************************************
	
DISPLAY_exibir_string_loop:

	mov al, byte [ds:si]	;; Ler um caractere da string
	inc si					;; Pr�ximo caractere
	
	cmp al, 0				;; Terminou?
	je DISPLAY_exibir_string_pronto	;; Sim

;;*****************************************************************************
	
DISPLAY_exibir_string_tentar_carriage_return:

	cmp al, ASCII_CARRIAGE_RETURN	 ;; Carriage return?
	jne DISPLAY_exibir_string_tentar_BS ;; N�o
									 ;; Sim, retornar para o in�cio da linha
	shl bl, 1						 ;; cada posi��o do cursor = 2 bytes
	mov ah, 0
	mov al, bl						 ;; AX = 2*coluna do cursor
	sub di, ax						 ;; Move o ponteiro do buffer para o in�cio da linha
	mov bl, 0						 ;; Move o cursor para o in�cio da linha
	jmp DISPLAY_exibir_string_loop	 ;; Pronto, ent�o exiba o pr�ximo caractere

;;*****************************************************************************
	
DISPLAY_exibir_string_tentar_BS:

	cmp al, ASCII_BACKSPACE					;; � backspace?
	jne DISPLAY_exibir_string_tentar_LF	;; N�o
	
	cmp bl, 0								
	je DISPLAY_exibir_string_tentar_LF	
	
	sub di, 2								;; Mover uma posi��o (2-byte) a esquerda
	mov al, ASCII_ESPACO_VAZIO				;; Limpar o atual caractere na posi��o
	mov byte [es:di], al					;; Armazenar caractere
	
	dec bl									;; Mover o cursor a esquerda
	
	jmp DISPLAY_vram_exibir_string_loop	 ;; Pronto, ent�o exiba o pr�ximo caractere

;;*****************************************************************************
	
DISPLAY_exibir_string_tentar_LF:

	cmp al, ASCII_LINE_FEED						;; � LF?
	jne DISPLAY_exibir_string_caractere_pleno	;; N�o
	
	inc bh										;; Sim, mover o cursor para baixo
	add di, NUM_COLUNAS*2					    ;; Mover o ponteiro uma posi��o abaixo
											    ;; (2 bytes por caractere)
	jmp DISPLAY_exibir_string_loop_checar_rolagem ;; Deve ter sido rolada a tela

;;*****************************************************************************
	
DISPLAY_exibir_string_caractere_pleno:

	;; Imprimir o caractere no buffer da �rea de trabalho virtual
	
	mov byte [es:di], al	;; Armazenar caractere
	add di, 2				;; Pr�ximo caractere do buffer
							;; Pulando o byte de atributo
	inc bl					;; Avan�ar o cursor uma posi�� a direita
	
	cmp bl, NUM_COLUNAS		;; Est� passando do limite da tela?
	jne DISPLAY_exibir_string_loop	;; N�o, ent�o continue para o pr�ximo caractere
	
	mov bl, 0				;; Sim, ent�o volte para o in�cio da linha
	inc bh					;; E mova para a pr�xima linha
	

;;*****************************************************************************
	
DISPLAY_exibir_string_loop_checar_rolagem:

	cmp bh, NUM_LINHAS		;; Estamos passando da �ltima linha?
	jne DISPLAY_exibir_string_loop	;; N�o, ent�o continue para o pr�ximo caractere
									;; Sim, ent�o role a tela
	
	mov cx, di						;; Salvar DI em CX
	
	pop di							;; DI = in�cio do slot de display
	add di, 100						;; Mover DI para o in�cio do buffer
	
	call BufferRolagemDisplay
	
	sub di, 100						;; Retornar DI para o in�cio do slot
	push di							;; Colocar o in�cio do slot novamente
	
	mov di, cx						;; Restaurar DI de CX
	dec bh							;; E colocar o cursor na �ltima linha
	
	sub di, NUM_COLUNAS*2			;; Mover o ponteiro de buffer uma linha acima
									;; (2 bytes por caractere)
	
	jmp DISPLAY_exibir_string_loop	;; Exibir pr�ximo caractere
	
;;*****************************************************************************
	
DISPLAY_exibir_string_pronto:

	;; aqui, BH = linha do cursor ap�s a string ter sido exibida
	;;       BL = coluna do cursor ap�s a string ter sido exibida
	
	;; Salvar a posi��o do cursor dentro do slot de display virtual
	
	pop di					;; Restaurar ponteiro para o in�cio do slot
	
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
