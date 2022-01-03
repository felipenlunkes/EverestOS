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

MensagemSemDriver: 	db "Sem driver de mouse presente... Saindo.", 0
BoasVindas:			db "[]", 13, 10, 13, 10, 0
TamanhoMensagem:			db "                          Tamanho da caixa:  ", 0
UltimaMensagem:		db 13, "(PRESSIONE [Q] PARA SAIR) Botoes: [", 0
	
UltimaMensagem2:		db "] Localizacao: (", 0
Virgula:			db ", ", 0
UltimaMensagem3:		db ")", 0 ;
MensagemMarcada:				db "o", 0
MensagemEspaco:		db " ", 0
MensagemNovaLinha:			db 13, 10

LARGURA_CAIXA 				equ 320
ALTURA_CAIXA 				equ 200

;;*****************************************************************************
	
inicio:
 
	int 83h						;; Limpar buffer de teclado
	
	int 8Dh						;; AL = status do driver de mouse
	cmp al, 0					;; 0 significa driver não carregado
	je semDriver					;; Exibir mensagem e sair
	
	mov bx, LARGURA_CAIXA			
	mov dx, ALTURA_CAIXA		
	int 90h						;; Iniciar manipulador de mouse
	
	mov si, BoasVindas
	int 9Ch
	
	mov si, TamanhoMensagem
	int 9Ch
	
	mov ax, LARGURA_CAIXA
	
	call exibir_mundo
	
	mov si, Virgula
	int 9Ch
	
	mov ax, ALTURA_CAIXA
	
	call exibir_mundo
	
	mov si, MensagemNovaLinha
	
	int 9Ch

;;*****************************************************************************
	
de_novo:

	mov si, UltimaMensagem
	int 9Ch						;; Exibir mensagem
	
	int 8Fh		
	
	;;		AL - bits 3 a 7 - não usado
	;;			 bit 2 - estado do botão central
	;;			 bit 1 - estado do botão direito
	;;			 bit 0 - estado do botão esquerdo
	;;		BX - posição de X
	;;		DX - posição de Y

	test al, 00000001b
	jnz apertado_esquerdo
	
	mov si, MensagemEspaco
	int 9Ch
	
	jmp apos_apertado_esquerdo

;;*****************************************************************************
	
apertado_esquerdo:

	mov si, MensagemMarcada
	
	int 9Ch

;;*****************************************************************************
	
apos_apertado_esquerdo:

	test al, 00000100b
	jnz apertado_central
	
	mov si, MensagemEspaco
	
	int 9Ch
	
	jmp apos_apertado_central

;;*****************************************************************************
	
apertado_central:

	mov si, MensagemMarcada
	
	int 9Ch

;;*****************************************************************************
	
apos_apertado_central:

	test al, 00000010b
	jnz apertado_direito
	
	mov si, MensagemEspaco
	
	int 9Ch
	
	jmp apos_apertado_direito

;;*****************************************************************************
	
apertado_direito:

	mov si, MensagemMarcada
	
	int 9Ch

;;*****************************************************************************
	
apos_apertado_direito:
	
	mov si, UltimaMensagem2
	
	int 9Ch
	
	mov ax, bx
	call exibir_mundo				;; Exibir posição de X
	
	mov si, Virgula
	
	int 9Ch
	
	mov ax, dx
	call exibir_mundo				;; Exibir posição de Y
	
	mov si, UltimaMensagem3
	
	int 9Ch
	
	mov cx, 1					
	int 85h						
	
	mov ah, 1
	int 16h 					
	
	jz de_novo 					
	
	mov ah, 0
	int 16h						
	
	cmp al, 'q'
	je finalizar 					
	
	cmp al, 'Q'
	je finalizar 				
	
	jmp de_novo					

;;*****************************************************************************
	
semDriver:

	mov si, MensagemSemDriver
	
	int 9Ch						

;;*****************************************************************************
	
finalizar:

	int 20h						

;;*****************************************************************************

exibir_mundo:

	xchg ah, al
	int 8Eh		
	
	xchg ah, al
	int 8Eh		
	
	ret

;;*****************************************************************************

clrscr:                      ;; Processo para limpar a tela

push ax
push bx
push cx
push dx


mov dx, 0
mov bh, 0
mov ah, 2
int 10h

mov ah, 6
mov al, 0
mov cx, 0
mov dh, 24
mov dl, 79
int 10h


pop dx
pop cx
pop bx
pop ax

ret
