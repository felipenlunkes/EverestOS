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

;; Formato de entrada de display (cada entrada armazena o estado de um display virtual):
;;
;; Bytes:
;;
;; 0-1 status (0xFFFF significa vazio)
;; 2 linhas do cursor (de 0 a 24, porque existem 25 linhas)
;; 3 coluna do cursor (de 0 a 79, porque existem 80 colunas)
;; 4-99 n�o utilizados
;; 100-4099 car�ter e atributos de dados (buffer adequado)


TAMANHO_ENTRADA_DISPLAY equ 4100		;; Em bytes
MAX_DISPLAYS equ 10
TAMANHO_TABELA_DISPLAY equ MAX_DISPLAYS*TAMANHO_ENTRADA_DISPLAY	;; Em bytes
STATUS_DISPLAY_VAZIO equ 0FFFFh		;; Usado para marcar slot vazio
STATUS_DISPLAY_CHEIO equ 0h			;; Usado para marcar slot utilizado

TabelaDisplay: times TAMANHO_TABELA_DISPLAY db 0
offsetDisplayativo: dw 0			;; Offset dentro da tabela
								
NUM_LINHAS equ 25
NUM_COLUNAS equ 80

ASCII_ESPACO_VAZIO equ ' '
ASCII_CARRIAGE_RETURN equ 13
ASCII_LINE_FEED equ 10
ASCII_BACKSPACE equ 8
CINZA_NO_PRETO equ 7
									
STRING_impossivelAdcionarDisplay: db 13, 10, "Impossivel alocar display virtual. PANICO", 0
Buffersaida_caractere: db ' ', 0 

;;*****************************************************************************

;; Inicializar o manipulador de display virtual

DISPLAY_inicializar:

	pusha
	pushf
	push es
	
	push cs
	pop es
	
	mov cx, TAMANHO_TABELA_DISPLAY / 2	;; Armazenar uma word neste momento
	mov di, TabelaDisplay
	mov ax, STATUS_DISPLAY_VAZIO	;; Preencher com estado de exibi��o vazio
                                    
	cld
	rep stosw
	
	pop es
	popf
	popa
	ret

;;*****************************************************************************	

;; Aloca um novo display virtual
;;
;; Sa�da:
;;
;; AX - ID de v�deo virtual que acabou de ser alocado

DISPLAY_alocar:

	pushf
	push cx
	push di
	push ds
	push es
	
	push cs
	pop ds
	push cs
	pop es
	
	call DISPLAY_encontrar_slot_livre	;; AX = offset do slot
	
	push ax							;; Salvar offset para que possamos voltar a ele
	mov di, TabelaDisplay
	add di, ax						;; SI agora aponta para o in�cio do slot
	
	mov word [es:di], STATUS_DISPLAY_CHEIO	;; Marcar slot como cheio
	mov byte [es:di+2], 0					;; O cursor inicia na linha 0
	mov byte [es:di+3], 0					;; O cursor inicia na coluna 0
	
	;; Agora definir as propriedades de v�deo
	
	add di, 100						;; SI agora aponta para o in�cio do buffer
	mov cx, 2000					;; Armazenar 2000 words (4000 bytes no total)
	mov al, ASCII_ESPACO_VAZIO		;; Caractere
	mov ah, CINZA_NO_PRETO			;; Atributos
	cld
	rep stosw						;; Armazenar 2000 words em ES:DI

	pop ax							;; Restaurar offset ("ID"), ent�o podemos retornar em AX
	
	pop es
	pop ds
	pop di
	pop cx
	popf
	
	ret
	
;;*****************************************************************************

;; Sa�da:
;;
;;		AX - Offset na tabela para o primeiro slot livre

DISPLAY_encontrar_slot_livre:

	push bx
	push si
	push ds
	
	push cs
	pop ds
	
	;; Encontrar primeiro slot marcado como livre
	
	mov si, TabelaDisplay
	mov bx, 0				;; Offset na tabela de slot checado
	
;;*****************************************************************************
	
DISPLAY_encontrar_slot_livre_loop:

	cmp word [ds:si+bx], STATUS_DISPLAY_VAZIO ;; Este slot est� livre?
											  ;; Os primeiros dois bytes sinalizam
											  ;;	STATUS_DISPLAY_VAZIO?)
	je DISPLAY_encontrar_slot_livre_encontrado		  ;; Sim
	
	add bx, TAMANHO_ENTRADA_DISPLAY			  ;; Pr�ximo slot
	
	cmp bx, TAMANHO_TABELA_DISPLAY			
	jb DISPLAY_encontrar_slot_livre_loop		
	
;;*****************************************************************************
	
DISPLAY_encontrar_slot_cheio:			;; Sim

	mov si, STRING_impossivelAdcionarDisplay
	int 80h
	
	cli
	hlt									;; Suspender processador

;;*****************************************************************************
	
DISPLAY_encontrar_slot_livre_encontrado:

	mov ax, bx							;; Retornar resultado em AX

;;*****************************************************************************
	
DISPLAY_encontrar_slot_livre_pronto:

	pop ds
	pop si
	pop bx
	ret

;;*****************************************************************************

;; Salva o estado da RAM de v�deo (VRA ) para a exibi��o virtual especificada
;;
;; Entrada:
;;
;; AX - ID (offset) da tela virtual

DISPLAY_salvar:

	pusha
	pushf
	push ds
	push es
	
	push cs
	pop es
	
	mov di, TabelaDisplay
	add di, ax						;; DI aponta para o in�cio do slot
	
	call DISPLAY_obter_hardware_posicao_cursor
	
	mov byte [es:di+2], bh			;; Salvar linha do cursor
	mov byte [es:di+3], bl			;; Salvar coluna do cursor
	
	add di, 100						;; DI agora aponta para o in�cio do buffer
	
	;; ES:DI aponta para o local de salvamento
	
	push word 0B800h
	pop ds
	
	mov si, 0				;; DS:SI agora aponta para o in�cio da mem�ria de v�deo
	
	mov cx, 2000					;; Ser�o transferidas words (4000 bytes no total)
	cld
	rep movsw						;; Realizar a c�pia de string
	
	pop es
	pop ds
	popf
	popa
	ret

;;*****************************************************************************

;; Restaura uma exibi��o virtual para a mem�ria RAM de v�deo, de forma eficaz
;; tornando-a a tela.
;;
;; Entrada :
;;
;; AX - ID (offset) do display virtual cujo buffer � restaurado

DISPLAY_restaurar:

	pusha
	pushf
	push ds
	push es
	
	push cs
	pop ds
	
	mov si, TabelaDisplay
	add si, ax						;; SI aponta para o in�cio do slot
	
	;; Iremos recuperar o cursor
	
	mov bh, byte [ds:si+2]				;; Linha do cursor
	mov bl, byte [ds:si+3]				;; Coluna do cursor
	
	call DISPLAY_mover_cursor_de_hardware	;; Mover o cursor de hardware
	
	;; Chamaremos o Buffer restaurado
	
	add si, 100						;; SI aponta para o in�cio do Buffer
	
	push word 0B800h
	pop es
	mov di, 0						;; Apontar ES:DI para B800:0000
	
	mov cx, 2000					;; Transferir 2000 words (4000 bytes no total)
	cld
	rep movsw						;; Realizar a c�pia de string
	
	pop es
	pop ds
	popf
	popa
	ret
	
;;*****************************************************************************
	
;; Desaloca um display virtual
;;
;; Entrada:
;;
;; AX - ID (offset) do display virtual cujo buffer ser� copiado

DISPLAY_liberar:

	pusha
	push ds
	
	push cs
	pop ds
	
	mov si, TabelaDisplay
	add si, ax
	mov word [ds:si+0], STATUS_DISPLAY_VAZIO
	
	pop ds
	popa
	ret

;;*****************************************************************************	

; Faz um display virtual ativo, significando que o que � escrito nele tamb�m ser�
;; enviado para a RAM de v�deo, efetivamente exibido na tela f�sica
;;
;; Entrada:
;;
;; AX - ID (offset) do display virtual que ficar� ativo

DISPLAY_ativar:

	pusha
	push ds
	
	push cs
	pop ds

	push ax								;; Salvar display que est� sendo ativado
	mov ax, word [offsetDisplayativo]
	
	call DISPLAY_salvar					;; Salvar vram do display
	
	pop ax								;; Restaurar display que est� sendo ativado
	mov word [offsetDisplayativo], ax	;; Salvar o offset
	
	call DISPLAY_restaurar				;; Copiar display para a mem�ria de v�deo
	
	pop ds
	popa
	
	ret

;;*****************************************************************************

;; Necess�rios durante a inicializa��o, para ajustar o valor inicial
;; de offsetDisplayativo

DISPLAY_inicializar_display_ativo:

	pusha
	push ds
	
	push cs
	pop ds

	mov word [offsetDisplayativo], ax
	
	pop ds
	popa
	ret
	
;;*****************************************************************************

;; Grava um caractere ASCII no display virtual especificado.
;; Tamb�m escreve para a mem�ria RAM de v�deo se a tela virtual especificada � o
;; monitor virtual ativo.
;;
;; Entrada:
;;
;; Caracteres ASCII para impress�o - DL
;; AX - ID do display virtual onde estamos escrevendo o caractere

DISPLAY_embrulhar_saida_caractere:

	pusha
	push ds
	
	push cs
	pop ds
	
	mov si, Buffersaida_caractere
	mov byte [ds:si], dl					
	
	call DISPLAY_embrulhar_saida_string
	
	pop ds
	popa
	ret
	
;;*****************************************************************************
	
;; Grava uma string terminada em zero para o display virtual especificado.
;; Tamb�m escreve para a mem�ria RAM de v�deo se o display virtual especificado � o
;; monitor virtual ativo.
;;
;; Entrada:
;;
;; DS: SI - ponteiro para o primeiro caractere da cadeia
;; AX - ID tela virtual onde estamos escrevendo a string

DISPLAY_embrulhar_saida_string:

	pusha
	push ds
	
	push cs								;; Alterar DS para o segmento da
	pop ds								;; derrefer�ncia abaixo
	
	cmp ax, word [offsetDisplayativo]	;; � o display especificado?
	jne DISPLAY_embrulhar_saida_string_virtual_apenas	;; N�o

;;*****************************************************************************
	
;; Caso 1: quando o diplay est� ativado, ser� enviado para a vram apenas

DISPLAY_embrulhar_saida_string_vram_apenas:

	pop ds								;; Restaurar DS ao passo que
	                                    ;; � necess�rio BH e BL a seguir
	call DISPLAY_vram_exibir_string		
	
	popa
	ret									;; Impresso na vram e pronto

;;*****************************************************************************
	
;; Caso 2: quando a exibi��o n�o est� ativa, a sa�da vai para a tela virtual apenas

DISPLAY_embrulhar_saida_string_virtual_apenas:

	pop ds								;; Restaurar DS passado
	
	call DISPLAY_saida_string			;; Escrever no display virtual
	
	popa
	ret

;;*****************************************************************************

;; Devolver o ID (offset) do display virtual ativo
;;
;; Sa�da:
;;
;; AX - ID (offset) do display virtual ativo

DISPLAY_obter_id_display_ativo:

	push ds
	
	push cs
	pop ds
	
	mov ax, word [offsetDisplayativo]
	
	pop ds
	ret

