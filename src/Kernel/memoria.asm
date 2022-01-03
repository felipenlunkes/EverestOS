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

PrimeiroSegmentoAlocavel:	dw 0
UltimoSegmentoAlocavel:	equ 7000h ;; 7FFFF (7000:FFFF) é o último endereço
                                  ;; na memória convencional

NumeroMaximodeSegmentosAlocaveis equ 15
NumerodeSegmentosAlocaveis:	dw 0
TabeladeAlocacaodeSegmentos:	   times NumeroMaximodeSegmentosAlocaveis db 0

;;*****************************************************************************

;; Iniciar gerenciamento de memória

MEMORIA_inicializar:

	pusha
	push ds
	
	push cs
	pop ds
	
	mov ax, UltimoSegmentoAlocavel
	sub ax, word [PrimeiroSegmentoAlocavel]
	shr ax, 12							 ;; AX = Zh (assumindo o máximo como < 16)
	inc ax								 ;; O primeiro é usável
	mov word [NumerodeSegmentosAlocaveis], ax	;; Salvar isso
	
	pop ds
	popa
	ret

;;*****************************************************************************

;; Entrada:
;;
;;		AX - Valor inicial para uma tarefa

MEMORIA_definir_segmento_alocacao_primaria:

	pusha
	push ds
	
	push cs
	pop ds
	
	mov word [PrimeiroSegmentoAlocavel], ax
	
	pop ds
	popa
	ret
	
;;*****************************************************************************
	
;; Alocar 64 Kbytes para o uso
;;
;; Saída:
;;
;;		AX - 0 quando sucesso
;;		BX - número do segmento alocado, quando sucesso

MEMORIA_alocar_segmento:

	push si
	push ds
	
	push cs
	pop ds
	
	;; Primeiro encontrar segmentos não alocados
	
	mov si, TabeladeAlocacaodeSegmentos
	mov bx, 0				;; Índice do segmento atual

;;*****************************************************************************
	
MEMORIA_encontrar_segmento:

	cmp byte [ds:si+bx], 0					;; Este segmento está limpo?
	je MEMORIA_encontrar_segmento_encontrado		;; Sim
	
	inc bx					;; Próximo segmento
	
	cmp bx, word [NumerodeSegmentosAlocaveis]	;; Quase no final?
	jne MEMORIA_encontrar_segmento		;; Não
	
MEMORIA_encontrar_segmento_cheio:				;; Sim

	mov ax, 1								;; Indica falha
	
	jmp MEMORIA_encontrar_segmento_pronto		;; Tudo pronto
	
MEMORIA_encontrar_segmento_encontrado:

	;; Aqui, BX = índice do segmento disponível
	
	mov byte [ds:si+bx], 1					;; Marca o segmento como alocado
	
	shl bx, 12								; BX = Z000h (assumindo como máximo < 16)
	add bx, word [PrimeiroSegmentoAlocavel]	;; Offset para o primeiro alocável
											;; Segmento
	mov ax, 0		;; Indicando sucesso
	
MEMORIA_encontrar_segmento_pronto:

	pop ds
	
	pop si
	
	ret

;;*****************************************************************************

;; Desalocar um segmento
;;
;; Entrada:
;;
;;		BX - segmento para desalocar

MEMORIA_limpar_segmento:

	pusha
	push ds
	
	push cs
	pop ds
	
	sub bx, word [PrimeiroSegmentoAlocavel]
	shr bx, 12
	
	mov si, TabeladeAlocacaodeSegmentos
	mov byte [ds:si+bx], 0
	
	pop ds
	
	popa 
	
	ret
