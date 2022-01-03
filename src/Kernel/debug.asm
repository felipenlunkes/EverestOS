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

StringNovaLinha:			db 13, 10, 0

;;*****************************************************************************

DEBUG_imprimir_linha:

	pusha
	
	mov si, StringNovaLinha
	
	call DEBUG_imprimir_string
	
	popa
	ret

;;*****************************************************************************

;; Entrada:
;;
;;		DS:SI apontando para string

DEBUG_imprimir:

	pusha
	
	call DEBUG_imprimir_string
	
	mov si, StringNovaLinha
	
	call DEBUG_imprimir_string
	
	popa

	ret

;;*****************************************************************************
	
;; Entrada:
;;
;;		DS:SI apontando para string

DEBUG_imprimir_string:

	pusha
	
	mov ah, 0x0E
	mov bx, 0x0007	;; Cinza no fundo preto
	
DEBUG_imprimir_string_loop:

	lodsb
	
	cmp al, 0		;; Strings terminam em 0
	je DEBUG_imprimir_string_fim
	
	int 10h
	
	jmp DEBUG_imprimir_string_loop
	
DEBUG_imprimir_string_fim:	

	popa

	ret

;;*****************************************************************************

;; Entrada:
;;
;; Word em AX

DEBUG_imprimir_word:

	pusha
	xchg al, ah
	
	call DEBUG_imprimir_byte
	
	xchg al, ah
	
	call DEBUG_imprimir_byte
	
	popa

	ret

;;*****************************************************************************
	
;; Entrada:
;;
;; Byte em AL

DEBUG_imprimir_byte:

	pusha
	
	mov ah, 0
	mov bl, 16
	div bl			;; Quociente em AL, resto em AH
	
	call DEBUG_hex_para_char
	
	call DEBUG_imprimir_char	;; Imprimir
	
	mov al, ah
	
	call DEBUG_hex_para_char
	
	call DEBUG_imprimir_char	;; Imprimir unidade
	
	popa

	ret

;;*****************************************************************************
	
;; Entrada:
;;
;;			hex digit in AL
;;
;; Saída:
;;
;;			Caractere hexadecimal imprimível em AL

DEBUG_hex_para_char:

	cmp al, 9
	jbe DEBUG_hex_para_char_abaixo_de_9
	
	add al, 7		;; Offset da tabela ASCII de '0' a 'A'
					;; Menos 9 (10 retorna a 'A')

;;*****************************************************************************
					
DEBUG_hex_para_char_abaixo_de_9:

	add al, '0'

	ret

;;*****************************************************************************
	
;; Entrada:
;;
;;		DS:SI apontando para string
;;		contagem de caracteres em CX

DEBUG_imprimir_dump:

	pusha
	
DEBUG_imprimir_dump_loop:

	lodsb			;; AL = byte em DS:SI
	
	call DEBUG_imprimir_char
	
	dec cx
	jne DEBUG_imprimir_dump_loop
	
	popa

	ret

;;*****************************************************************************
	
;; Entrada:
;;
;;		ASCII em AL

DEBUG_imprimir_char:

	pusha

	mov ah, 0x0E
	mov bx, 0x0007	;; cinza no fundo preto

	int 10h

	popa

	ret
