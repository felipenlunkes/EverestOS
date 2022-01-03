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

vramBufferSaidaCaractere: db ' ', 0 

;;*****************************************************************************

;; Ler posi��o do cursor do controlador 6845 CRT
;;
;; Sa�da:
;;
;;		BH - Linha
;;		BL - Coluna

DISPLAY_obter_hardware_posicao_cursor:

	push ax
	push dx
	
	mov al, 0Eh
	mov dx, 3D4h
	out dx, al			;; Escrever o registro de �ndice 3D4h no 
						;; registrador de sele��o 0Eh "cursor position MSB register"
	
	mov dx, 3D5h
	in al, dx			;; Ler byte mais significante de "cursor position MSB register"
	
	xchg ah, al			;; AH = byte mais significante da posi��o do cursor
	
	mov al, 0Fh
	mov dx, 3D4h
	out dx, al			;; Escrever o registro de �ndice 3D4h no 
						;; registrador de sele��o 0Fh "cursor position LSB register"

	mov dx, 3D5h
	in al, dx			;; Ler byte menos significante de "cursor position LSB register"
						;; AL = byte menos significante da posi��o do cursor
	;; AX agora cont�m a posi��o do cursor (offset)					
	
	mov bl, NUM_COLUNAS
	div bl				;; AL = AX / NUM_COLUNAS
						;; AH = AX % NUM_COLUNAS
	
	mov bh, al			;; Linha (para retornar)
	mov bl, ah			;; Coluna (para retornar)
	
	pop dx
	pop ax
	ret

;;*****************************************************************************

;; Reposicionar o cursor de hardware via controlador 6845 CRT
;;
;; Entrada:
;;
;;		BH - linha
;;		BL - coluna

DISPLAY_mover_cursor_de_hardware:

	pusha
	
	mov al, NUM_COLUNAS
	mul bh				;; AX = NUM_COLUNAS * linha do cursor
	mov bh, 0			;; BX = coluna do cursor
	add bx, ax			;; BX = (NUM_COLUNAS * linha do cursor) + coluna do cursor
	
	mov al, 0Fh
	mov dx, 3D4h
	out dx, al			;; Escrever o registro 3D4h no 
						;; registrador de sele��o 0Fh "cursor position LSB register"

	mov al, bl			;; Byte menos significante (NUM_COLUNAS * linha do cursor)+coluna do cursor
	mov dx, 3D5h
	out dx, al			;; Escrever byte menos significante em "cursor position LSB register"
	
	mov al, 0Eh
	mov dx, 3D4h
	out dx, al			;; Escrever o registro 3D4h no
						;; registrador de sele��o 0Eh "cursor position MSB register"
	
	mov al, bh			;; Byte mais significante (NUM_COLUNAS * linha do cursor)+coluna do cursor
	mov dx, 3D5h
	out dx, al			;; Escrever byte mais significante em "cursor position MSB register"
	
	popa
	ret
	
;;*****************************************************************************
	
;; Exibir uma string terminada em zero diretamente na mem�ria de v�deo
;;
;; Entrada:
;;
;;		DS:SI - Ponteiro para o primeiro caractere

DISPLAY_vram_exibir_string:

	pusha
	push es
	
	push word 0B800h
	pop es

	call DISPLAY_obter_hardware_posicao_cursor ;; BH - Linha do cursor
											   ;; BL - Coluna do cursor
	push bx					;; Salvar posi��o do cursor
	mov al, NUM_COLUNAS
	mul bh				;; AX = NUM_COLUNAS * linha do cursor
	mov bh, 0			;; BX = coluna do cursor
	add ax, bx			;; AX = (NUM_COLUNAS * linha do cursor) + coluna do cursor
	shl ax, 1			;; Multiplicar por 2 (2 bytes por caractere)
	
	;; AX agora tem o buffer da mem�ria para onde a mensagem ser� enviada
	
	pop bx					;; Restaurar posi��o do cursor
	
	mov di, ax				;; ES:DI agora aponta para onde a mensagem ser� enviada

;;*****************************************************************************
	
DISPLAY_vram_exibir_string_loop:

	mov al, byte [ds:si]	;; Ler um caractere da string
	inc si					;; Pr�ximo caractere
	
	cmp al, 0				;; Termina aqui?
	je DISPLAY_vram_exibir_string_pronto	;; Sim

;;*****************************************************************************
	
DISPLAY_vram_exibir_string_tentar_carriage_return:

	cmp al, ASCII_CARRIAGE_RETURN	 ;; � um carriage return?
	jne DISPLAY_vram_exibir_string_tentar_BS ;; N�o
									 ;; Sim, mover o cursor para o in�cio da linha
	shl bl, 1						 ;; Cada posi��o do cursor = 2 bytes
	mov ah, 0
	mov al, bl						 ;; AX = 2*coluna do cursor
	sub di, ax						 ;; Mover ponteiro de buffer para o in�cio da linha
	mov bl, 0						 ;; Mover cursor para o in�cio da linha
	jmp DISPLAY_vram_exibir_string_loop	 ;; Pronto, ent�o exiba o pr�ximo caractere

;;*****************************************************************************
	
DISPLAY_vram_exibir_string_tentar_BS:

	cmp al, ASCII_BACKSPACE					;; � um Backspace?
	jne DISPLAY_vram_exibir_string_tentar_LF	;; N�o
	
	cmp bl, 0								;; Estamos na �ltima coluna?
	je DISPLAY_vram_exibir_string_tentar_LF	;; Sim
	
	sub di, 2								;; Mover uma posi��o a esquerda
	mov al, ASCII_ESPACO_VAZIO				;; Limpar o caractere na posi��o
	mov byte [es:di], al					;; Armazenar caractere
	
	dec bl									;; Mover cursor a esquerda
	
	jmp DISPLAY_vram_exibir_string_loop	 	;; Pronto, ent�o exiba o pr�ximo caractere

;;*****************************************************************************
	
DISPLAY_vram_exibir_string_tentar_LF:

	cmp al, ASCII_LINE_FEED					     	;; � um LF?
	jne DISPLAY_vram_exibir_string_caractere_pleno	;; N�o
	
	inc bh										    ;; Sim, mover o cursor para baixo
	add di, NUM_COLUNAS*2					        ;; Mover o ponteiro de buffer para baixo
											        ;; (2 bytes por caractere)
	jmp DISPLAY_vram_exibir_string_loop_checar_rolagem 

;;*****************************************************************************
	
DISPLAY_vram_exibir_string_caractere_pleno:

	;; Agora, imprimir o caractere na �rea atual
	
	mov byte [es:di], al	;; Armazenar caractere
	add di, 2				;; Pr�ximo caractere
							;; Pulando o byte de atributo
	inc bl					;; Avan�ar o cursor uma posi��o para a direita
	
	cmp bl, NUM_COLUNAS		;; Estamos passando do limite direito da tela?
	jne DISPLAY_vram_exibir_string_loop	;; N�o, exibindo pr�ximo caractere
	
	mov bl, 0				;; Sim, movendo para o in�cio da linha
	inc bh					;; E movendo para a pr�xima linha

;;*****************************************************************************
	
DISPLAY_vram_exibir_string_loop_checar_rolagem:

	cmp bh, NUM_LINHAS		;; Estamos passando da linha mais abaixo?
	jne DISPLAY_vram_exibir_string_loop	;; N�o, exibindo pr�ximo caractere
									;; Sim, ent�o rolar a tela
	
	push di							;; Salvar DI atual
	mov di, 0						;; Mover DI para o in�cio do buffer
	
	call BufferRolagemDisplay
	
	pop di							;; Restaurar DI atual
	dec bh							;; E colocar o cursor na �ltima linha
	
	sub di, NUM_COLUNAS*2			;; Mover ponteiro de cursor uma linha acima
									;; (2 bytes por caractere)
	
	jmp DISPLAY_vram_exibir_string_loop	;; Exibir pr�ximo caractere
	
;;*****************************************************************************
	
DISPLAY_vram_exibir_string_pronto:

	;; Aqui, BH = linha do cursor ap�s a exibi��o da string
	;;       BL = coluna do cursor ap�s a exibi��o da string
	
	call DISPLAY_mover_cursor_de_hardware	;; Mover cursor de hardware
	
	pop es
	popa
	
	ret

;;*****************************************************************************

;; Mover todas as linhas do display virtual uma linha acima
;;
;; Entrada:
;;
;;		ES:DI - ponteiro para o buffer a ser rolado

BufferRolagemDisplay:

	pusha
	push ds

	push cs
	pop ds
	
	mov cx, (NUM_LINHAS-1)*NUM_COLUNAS	;; Copiando NUM_LINHAS-1 linhas acima
	
;;*****************************************************************************
	
DISPLAY_rolar_buffer_loop:

	mov ax, word [es:di+NUM_COLUNAS*2]	;; Substituir todos os caracteres/atributos 
	mov word [es:di], ax				
	add di, 2							;; Pr�ximo atributo
	
	loop DISPLAY_rolar_buffer_loop
	
	;; DI agora aponta para o come�o da �ltima linha
	
	mov cx, NUM_COLUNAS
	
;;*****************************************************************************
	
DISPLAY_rolar_buffer_ate_ultima_linha:

	mov byte [es:di], ASCII_ESPACO_VAZIO	;; Caractere
	mov byte [es:di+1], CINZA_NO_PRETO	;; Atributo
	add di, 2
	
	loop DISPLAY_rolar_buffer_ate_ultima_linha
	
	pop ds
	popa
	ret

;;*****************************************************************************
	
;; Escrever um caractere ASCII para a mem�ria de v�deo
;;
;; Entrada:
;;
;;		AL - caractere ASCII para imprimir

DISPLAY_vram_imprimir_caractere:

	pusha
	push ds
	
	push cs
	pop ds
	
	mov si, vramBufferSaidaCaractere
	mov byte [ds:si], al					;; Nossa string de um caractere
	
	call DISPLAY_vram_exibir_string
	
	pop ds
	popa
	ret
	
;;*****************************************************************************

;; Entrada:
;;
;;		AL - byte para imprimir

DISPLAY_vram_imprimir_byte:

	pusha
	
	mov ah, 0
	mov bl, 16
	div bl			;; Quosciente em AL, resto em AH
	
	call DEBUG_hex_para_char
	
	call DISPLAY_vram_imprimir_caractere	;; Exibir dez d�gitos
	
	mov al, ah
	
	call DEBUG_hex_para_char
	
	call DISPLAY_vram_imprimir_caractere	;; Imprimir d�gito
	
	popa
	ret
	
;;*****************************************************************************

;; Imprimir n�mero espec�fico de caracteres da string
;;
;; Entrada::
;;
;;		DS:SI -  ponteiro para a string
;;		CX - n�mero de caracteres para imprimir

DISPLAY_vram_imprimir_dump:

	pusha
	
DISPLAY_vram_imprimir_dump_loop:

	lodsb			;; AL = byte em DS:SI
	
	call DISPLAY_vram_imprimir_caractere
	
	dec cx
	
	jne DISPLAY_vram_imprimir_dump_loop
	
	popa
	
	ret
