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

;; Mapeamento de teclado para uso com a interface

DEL equ 1Bh
F8 equ 4200h
CTRLC equ 03h
Espaco equ 20h
ESCAPE equ 1Bh
SHIFT1 equ 21h
SHIFT2 equ 22h
SHIFT3 equ 23h
SHIFT4 equ 24h
SHIFT5 equ 25h
SHIFT6 equ 26h
SHIFT7 equ 27h
SHIFT8 equ 28h
SHIFT9 equ 29h
SHIFT0 equ 2Ah
Mais equ 2Bh
Menos equ 2Dh
Igual equ 3Dh
AMai equ 41h
AMin equ 61h
BMai equ 42h
BMin equ 62h
CMai equ 43h
CMin equ 63h
DMai equ 44h
DMin equ 64h
EMai equ 45h
EMin equ 65h
FMai equ 46h
FMin equ 66h
GMai equ 47h
GMin equ 67h
HMai equ 48h
HMin equ 68h
IMai equ 49h
IMin equ 69h
JMai equ 4Ah
JMin equ 6Ah
KMai equ 4Bh
KMin equ 6Bh
LMai equ 4Ch
LMin equ 6Ch
MMai equ 4Dh
MMin equ 6Dh
NMai equ 4Eh
NMin equ 6Eh
OMai equ 4Fh
Omin equ 6Fh
PMai equ 50h
PMin equ 70h
QMai equ 51h
QMin equ 71h
RMai equ 52h
RMin equ 72h
SMai equ 53h
SMin equ 73h
TMai equ 54h
TMin equ 74h
UMai equ 55h
UMin equ 75h
VMai equ 56h
VMin equ 76h
WMai equ 57h
WMin equ 77h
XMai equ 58h
XMin equ 78h
YMai equ 59h
YMin equ 79h
ZMai equ 5Ah
ZMin equ 7Ah
Del equ 7fh
Backspace equ 08h
Interrogacao equ 3Fh

TAMANHO_Maximo_Linha 		equ 100
Buffer_Entrada_Atual: 		times ( TAMANHO_Maximo_Linha + 1 ) db 0 

MENSAGEM_STRING_MUITO_LONGA: db 13,10,10,13,
						     db "O texto nao pode exceder 64 caracteres!", 10,13,10,13,0

;;*****************************************************************************

TECLADO_limpar_buffer:

	pusha

;;*****************************************************************************
	
TECLADO_limpar_buffer_loop:

	mov ah, 1
	int 16h 		;; Alguma tecla está no buffer?
	
	jz TECLADO_limpar_buffer_pronto ;; Não, ele está limpo
	
	mov ah, 0
	int 16h			;; Ler uma tecla, limpando o buffer
	
	jmp TECLADO_limpar_buffer_loop	;; Ver se existem mais teclas no buffer
									
;;*****************************************************************************
	
TECLADO_limpar_buffer_pronto:

	popa
	
	ret

;;*****************************************************************************

TECLADO_ler:

TECLADO_ler_nova_linha:

	call TECLADO_limpar_buffer	;; Limpar Buffer de teclado
	
	call TECLADO_limpar_linha_buffer_atual
	
	mov di, Buffer_Entrada_Atual	;; DI aponta para o início do buffer

;;*****************************************************************************
	
TECLADO_ler_caractere:					
	
	mov ah, 1
	int 16h 									;; Alguma tecla pressionada?
	
	jnz TECLADO_ler_caractere_foi_pressionado  ;; Sim
	
	;; Não
	
	jmp TECLADO_ler_caractere	;; Ler próximo caratere
	
TECLADO_ler_caractere_foi_pressionado:

	mov ah, 0
	int 16h			;; Bloquear e esperar tecla: AL = ASCII
					;; AH = código
	

	cmp al, 13				;; ASCII para ENTER
	je TECLADO_processar_linha	;; Processar linha
	
	cmp al, 8				;; ASCII para tecla de apagar (Backspace)
	jne TECLADO_ler_nao_enter_nem_backspace
	
	;; Processar Backspace
	
	cmp di, Buffer_Entrada_Atual
	je TECLADO_ler_caractere	;; Se buffer limpo, Backspace não faz nada
	
	;; Manipular a limpeza de caractere. Se buffer limpo, Backspace não faz nada
	
	dec di					;; Mover buffer uma posição atrás
	mov byte [es:di], 0		;; E limpar a última localização
	
	call TECLADO_imprimir_caractere	;; Exibir o efeito na tela
	
	jmp TECLADO_ler_caractere		;; Ler próximo caractere
	
;;*****************************************************************************	
	
TECLADO_ler_nao_enter_nem_backspace:

	
	cmp al, 0
	je TECLADO_ler_caractere	;; Caracteres não imprimíveis são ignorados
								;; Setas, teclas de função, etc
								
	
	mov bx, di
	
	sub bx, Buffer_Entrada_Atual	;; BX = atual - começo
	
	cmp bx, TAMANHO_Maximo_Linha
	jae TECLADO_ler_caractere	;; Se buffer cheio, não fazer nada
	
	
	stosb
	
	call TECLADO_imprimir_caractere
	
	jmp TECLADO_ler_caractere
	
;;*****************************************************************************
	
TECLADO_processar_linha:	

	mov bx, di
	sub bx, Buffer_Entrada_Atual				;; BX = atual - inicial
	
	cmp bx, 64
	jbe TECLADO_processar_linha_curta_suficiente ;; Se não exceder 64 carateres, tudo bem

	;; Se não, linha muito grande!
	
	mov si, MENSAGEM_STRING_MUITO_LONGA
	
	call DISPLAY_vram_exibir_string							;; Exibir erro
	
	jmp TECLADO_ler_nova_linha		;; Tudo pronto

;;*****************************************************************************
	
TECLADO_processar_linha_curta_suficiente:	

	
	cmp bx, 0
	je TECLADO_ler_nova_linha		;; Se linha limpa, iniciar nova linha

;;*****************************************************************************
	
TECLADO_processar_linha_pronto:

    mov si, Buffer_Entrada_Atual

	ret

;;*****************************************************************************
	
;; Entrada:
;;
;; Caractere em AL

TECLADO_imprimir_caractere:

	pusha
	
	cmp al, 8
	je TECLADO_imprimir_caractere_backspace

	cmp al, 9
	je TECLADO_imprimir_caractere_tab
	
	cmp al, 126		;; Último caractere imprimível ASCII
	ja TECLADO_imprimir_caractere_pronto
	
	cmp al, 32	    ;; Primeiro caractere imprimível ASCII	
	jb TECLADO_imprimir_caractere_pronto
	
	mov dl, al
	
	mov ax, 0
	call DISPLAY_embrulhar_saida_caractere	;; Imprimir
	
	jmp TECLADO_imprimir_caractere_pronto

;;*****************************************************************************
	
TECLADO_imprimir_caractere_backspace:

	mov dl, al
	
	mov ax, 0
	call DISPLAY_embrulhar_saida_caractere		
	
	jmp TECLADO_imprimir_caractere_pronto

;;*****************************************************************************
	
TECLADO_imprimir_caractere_tab:

	mov dl, ' '		;; Imprimir como conjunto de espaços
	
	mov ax, 0
	call DISPLAY_embrulhar_saida_caractere
	
	jmp TECLADO_imprimir_caractere_pronto

;;*****************************************************************************
	
TECLADO_imprimir_caractere_pronto:

	popa
	
	ret

;;*****************************************************************************

TECLADO_limpar_linha_buffer_atual:

	pusha
	
	mov di, Buffer_Entrada_Atual
	mov cx, TAMANHO_Maximo_Linha
	mov al, 0
	
	rep stosb					;; Encher o Buffer de 0
	
	popa
	
	ret

;;*****************************************************************************
