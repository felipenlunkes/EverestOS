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

ManipuladordeMouseestaHabilitado: db 0
LarguraCaixaDelimitadora: dw 0
AlturaCaixaDelimitadora: dw 0

mouseX:	dw 0
mouseY:	dw 0
ButoesMouse: db 0	;; bits 3 a 7 - sem uso
					;; bit 2 - estado atual do botão central
					;; bit 1 - estado atual do botão direito
					;; bit 0 - estado atual do botão esquerdo
					
UltimosBotoesdoMouse: db 0	;; Como acima

FatorMouseCaixa: dd 0	;; Multiplicar o delta do mouse por isto

FatorMouseCaixaAcelerado: dd 0	;; Como acima, para valores acelerados

DimensaoMaisLongaCaixaDelimitadora: dd 0 ;; Usado para calcular mouse para caixa

DenominadordeTaxa: dw 1000 ; Deltas do mouse de hardware serão divididos
                           ;; por este número para retardar ponteiro para baixo
						   
DenominadordeTaxaAcelerado: dw 400	;; Como acima, para valores acelerados
								
deltaX: dw 0			;; Sem sinal, 0-255

deltaXCoordenadasdoUsuario: dd 0	;; Sem sinal

deltaY: dw 0			;; Sem sinal, 0-255

deltaYCoordenadasdoUsuario: dd 0	;; Sem sinal

LimiteAceleracao equ 32	;; Valores para aceleração

;;*****************************************************************************

;; Este manipulador de interrupção calcula e atualiza a posição do mouse dentro do
;; sistema de coordenadas especificadas pelo utilizador, de modo que o utilizador pode, em última
;; análise verificar e obter a nova localização do mouse.
;; Programas de usuário que desejam utilizar o mouse de forma mais avançada podem escolher
;; para registrar seu próprio manipulador de interrupção.
;; Nota: recebe dados mouse PS/2 - padrão como entrada
;; Nota: se este for substituído, o comportamento da interrupção de"poll gerido" torna-se
;; indefinido.
;;
;; Entrada:
;;
; BH - bit 7 - Y estouro
; bit 6 - X estouro
; bit 5 - bit de sinal de Y
; bit 4 - bit de sinal de X
; bit 3 - não utilizado e indeterminado
; bit 2 - botão do meio
; bit 1 - botão direito
; bit 0- botão esquerdo
; DH - Movimento X (delta X)
; DL - movimento Y (delta Y)

MOUSE_estado_alterado_manipulador_raw:

	pusha
	push ds
	
	push cs
	pop ds							;; DS = CS
	
	mov al, byte [ManipuladordeMouseestaHabilitado]
	cmp al, 0
	je MOUSE_estado_alterado_manipulador_nativo_pronto	;; Se não inicializado, não fazer nada
	
	call MOUSE_computar_novo_X
	call MOUSE_computar_novo_Y
		
	and bh, 00000111b				;; BH = apenas estado atual dos botões
	mov byte [ButoesMouse], bh		;; Armazenar novo valor

;;*****************************************************************************
	
MOUSE_estado_alterado_manipulador_nativo_pronto:

	pop ds
	popa
	ret
	
;;*****************************************************************************

;; Computar e armazenar valor de X em coordenadas de usuário.
;;
;; Entrada:
;;
;;		BH - bit 4 - bit de sinal de X 
;;		DH - movimento de X (delta X)

MOUSE_computar_novo_X:

	pusha
	
	cmp dh, 0
	je MOUSE_computar_novo_X_pronto	;; Se não ocorrer movimento horizontal, pronto
	
	mov cl, bh				;; Salvar bit de sinal em CL
	
	test cl, 00010000b		;; Quando o bit 4 está limpo, o delta é positivo
	jz MOUSE_computar_novo_X_positivo
	
	neg dh					;; delta = |delta|

;;*****************************************************************************
	
MOUSE_computar_novo_X_positivo:	

	mov ah, 0
	mov al, dh				;; AX = DH
	mov word [deltaX], ax	;; Armazenar em memória em preparação a chamadas FPU
	
	fild word [deltaX]				;; st0 = deltaX
	
	cmp ax, LimiteAceleracao
	jb MOUSE_computar_novo_X_sobre_limite	;; Está sobre o limite?
	
	fld dword [FatorMouseCaixaAcelerado]	;; st1 = deltaX
											;; st0 =FatorMouseCaixaAcelerado
	jmp MOUSE_computar_novo_X_multiplicar
	
;;*****************************************************************************
	
MOUSE_computar_novo_X_sobre_limite:

	fld dword [FatorMouseCaixa]	;; st1 = deltaX
									;; st0 = FatorMouseCaixa

;;*****************************************************************************									
MOUSE_computar_novo_X_multiplicar:

	fmulp st1, st0					;; st0 = st1 * st0
	fistp dword [deltaXCoordenadasdoUsuario]	;; deltaXCoordenadasdoUsuario = st0
	
	
;; Enquanto deltaXCoordenadasdoUsuario é um dword  o seu valor nunca deverá
;; estar acima de 65535, o que significa que ele pode ser moldado de forma segura para uma palavra.
	
	mov ax, word [deltaXCoordenadasdoUsuario]
	
	cmp ax, 0
	jne MOUSE_computar_novo_X_nao_zero		
						;; if deltaXCoordenadasdoUsuario = 0, then deltaXCoordenadasdoUsuario = 1
	mov ax, 1			;; Então o movimento do mouse terminado no delta

;;*****************************************************************************
	
MOUSE_computar_novo_X_nao_zero:

	;; AX = delta do movimento em coordenadas de usuário
	
	test cl, 00010000b	;; Quando o bit 4 está limpo, é positivo
	jz MOUSE_computar_novo_X_mover_direita

;;*****************************************************************************
	
MOUSE_computar_novo_X_mover_esquerda:

	clc				
	mov bx, [mouseX]
	
	sub bx, ax			;; BX = mouseX - deltaXCoordenadasdoUsuario
	jnc MOUSE_computar_novo_X_mover_esquerda_sem_estouro
	
	;; Estouro
	
	mov bx, 0
	
;;*****************************************************************************
	
MOUSE_computar_novo_X_mover_esquerda_sem_estouro:

	mov word [mouseX], bx
	
	jmp MOUSE_computar_novo_X_pronto	;; E estamos prontos

;;*****************************************************************************
	
MOUSE_computar_novo_X_mover_direita:

	clc					
	mov bx, [mouseX]
	
	add bx, ax			;; BX = mouseX + deltaXCoordenadasdoUsuario
	jnc MOUSE_computar_novo_X_mover_direita_sem_estouro
	
	;; Estourou, então vamos reduzir o valor para o limite
	
	mov bx, 0FFh
	
;;*****************************************************************************
	
MOUSE_computar_novo_X_mover_direita_sem_estouro:

	cmp bx, word [LarguraCaixaDelimitadora]
	jb MOUSE_computar_novo_X_mover_direita_sem_limite
	
	mov bx, word [LarguraCaixaDelimitadora]	;; if BX >= LarguraCaixaDelimitadora
	dec bx							        ;; then BX = LarguraCaixaDelimitadora - 1
	
;;*****************************************************************************
	
MOUSE_computar_novo_X_mover_direita_sem_limite:

	mov word [mouseX], bx			;; Armazenar valor final

;;*****************************************************************************
	
MOUSE_computar_novo_X_pronto:

	popa
	ret
	
;;*****************************************************************************
	
;; Computar e armazenar valor de Y em coordenadas de usuário
;;
;; Entrada:
;;
;;		BH - bit 5 - bit de sinal de Y
;;		DL - movimento de Y (delta Y)

MOUSE_computar_novo_Y:

	pusha
	
	cmp dl, 0
	je MOUSE_computar_novo_Y_pronto	;; Se sem movimento horizontal, está pronto
	
	mov cl, bh				;; Salvar bit de sinal em CL
	
	test cl, 00100000b		;; Quando bit 5 limpo, delta positivo
	jz MOUSE_computar_novo_Y_positivo
	
	neg dl					;; delta = |delta|

;;*****************************************************************************	
	
MOUSE_computar_novo_Y_positivo:	

	mov ah, 0
	mov al, dl				;; AX = DL
	mov word [deltaY], ax	;; Armazenar em memória em preparação a chamadas FPU
	
	fild word [deltaY]				;; st0 = deltaY
	
	cmp ax, LimiteAceleracao
	jb MOUSE_computar_novo_Y_sobre_limite	;; Está dentro do limite?
	
	fld dword [FatorMouseCaixaAcelerado]	;; st1 = deltaY
											;; st0 =FatorMouseCaixaAcelerado
	jmp MOUSE_computar_novo_Y_multiplicar
	
;;*****************************************************************************
	
MOUSE_computar_novo_Y_sobre_limite:

	fld dword [FatorMouseCaixa]	;; st1 = deltaY
								;; st0 = FatorMouseCaixa

;;*****************************************************************************
									
MOUSE_computar_novo_Y_multiplicar:

	fmulp st1, st0					;; st0 = st1 * st0
	fistp dword [deltaYCoordenadasdoUsuario]	;; deltaYCoordenadasdoUsuario = st0
	
	mov ax, word [deltaYCoordenadasdoUsuario]
	
	cmp ax, 0
	jne MOUSE_computar_novo_Y_nao_zero		
	
						;; Se deltaYCoordenadasdoUsuario = 0, então deltaYCoordenadasdoUsuario = 1
	mov ax, 1			;; O movimento do mouse termina em delta
	
;;*****************************************************************************
	
MOUSE_computar_novo_Y_nao_zero:

	;; AX = delta de movimento em coordenadas de usuário
	
	test cl, 00100000b	;; Se bit 5 limpo, o mouse moveu para cima
	jnz MOUSE_computar_novo_Y_mover_para_baixo	
	
;;*****************************************************************************
	
MOUSE_computar_novo_Y_mover_para_cima:

	clc					
	mov bx, [mouseY]
	
	sub bx, ax			;; BX = mouseY - deltaYCoordenadasdoUsuario
	jnc MOUSE_computar_novo_Y_mover_para_cima_sem_estouro
	
	;; Estourou
	
	mov bx, 0
	
;;*****************************************************************************
	
MOUSE_computar_novo_Y_mover_para_cima_sem_estouro:

	mov word [mouseY], bx
	
	jmp MOUSE_computar_novo_Y_pronto	;; Está pronto

;;*****************************************************************************
	
MOUSE_computar_novo_Y_mover_para_baixo:

	clc					
	mov bx, [mouseY]
	
	add bx, ax			; BX := mouseY + deltaYCoordenadasdoUsuario
	jnc MOUSE_computar_novo_Y_mover_para_baixo_sem_estouro
	
	;; Estourou, retornando aos valores limite
	
	mov bx, 0FFh
	
;;*****************************************************************************
	
MOUSE_computar_novo_Y_mover_para_baixo_sem_estouro:

	cmp bx, word [AlturaCaixaDelimitadora]
	jb MOUSE_computar_novo_Y_mover_para_baixo_sem_limite
	
	mov bx, word [AlturaCaixaDelimitadora]	;; if BX >= AlturaCaixaDelimitadora
	dec bx							        ;; then BX = AlturaCaixaDelimitadora - 1
	
;;*****************************************************************************
	
MOUSE_computar_novo_Y_mover_para_baixo_sem_limite:

	mov word [mouseY], bx			;; Armazenar valor final

;;*****************************************************************************
	
MOUSE_computar_novo_Y_pronto:

	popa
	ret

;;*****************************************************************************	
	
;; Retornar a localização atual do mouse, assim como o estado dos botões.
;;
;; Entrada:
;;
;;		AL - bits 3 a 7 - sem uso e indeterminado
;;			 bit 2 - estado do botão central
;;			 bit 1 - estado do botão direito
;;			 bit 0 - estado do botão esquerdo
;;		BX - posição de X em coordenadas de usuário
;;		DX - posição de Y em coordenadas de usuário

MOUSE_manipulador:

	push ds
	
	push cs
	pop ds							;; DS :== CS
	
	mov al, byte [ButoesMouse]
	mov bx, word [mouseX]
	mov dx, word [mouseY]
	
	pop ds
	
	ret

;;*****************************************************************************	
	
;; Inicializar o manipulador do mouse para uso com aplicativos.
;; Normalmente, leva o ponteiro para o centro da caixa.
;;
;; Entrada:
;;
;;		BX - largura da caixa limitadora para mover o mouse
;;		DX - altura da caixa limitadora para mover o mouse

MOUSE_manipulador_inicializar:

	pusha
	push ds
	
	push cs
	pop ds
	
	mov byte [ManipuladordeMouseestaHabilitado], 1	;; Foi inicializado
	
	mov byte [ButoesMouse], 0			;; Limpar estado dos botões
	
	mov ax, bx							;; Assumir largura tão grande quanto altura
	
	cmp bx, dx
	jae MOUSE_manipulador_inicializar_obter_dimensao	;; Largura é maior - não fazer nada
	
	mov ax, dx							;; Altura é maior que largura

;;*****************************************************************************	
	
MOUSE_manipulador_inicializar_obter_dimensao:

	;; Aqui, AX = maior dimensão
	;; Armazenar maior dimensão como dword
	
	mov byte [DimensaoMaisLongaCaixaDelimitadora], bl	 ;; low endian word->dwor
	mov byte [DimensaoMaisLongaCaixaDelimitadora+1], bh  ;; FPU não consegue
	mov byte [DimensaoMaisLongaCaixaDelimitadora+2], 0	 ;; interpretar palavras grandes
	mov byte [DimensaoMaisLongaCaixaDelimitadora+3], 0	 ;; Valores são negativos
	
	mov word [LarguraCaixaDelimitadora], bx		;; Armazenar largura como dword
	shr bx, 1
	mov word [mouseX], bx				;; Inicialmente, mouseX = Largura da caixa / 2
	
	mov word [AlturaCaixaDelimitadora], dx	;; Armazenar altura
	shr dx, 1
	mov word [mouseY], dx				;; Inicialmente, mouseY = Altura da caiza / 2
	
	fninit								;; Inicializar FPU
	
	; calculate mouse-to-box factor
	fild dword [DimensaoMaisLongaCaixaDelimitadora] ;; st0 = maior dimensão da caixa
	fild word [DenominadordeTaxa]			        ;; st1 = maior dimensão da caixa
											        ;; st0 = DenominadordeTaxa
	fdivp st1, st0							        ;; st0 = st1 / st0
	fstp dword [FatorMouseCaixa]	 		        ;; FatorMouseCaixa = st0
	
	;; Calcular mouse para caixa com valores acelerados
	
	fild dword [DimensaoMaisLongaCaixaDelimitadora] ;; st0 = maior dimensão da caixa
	fild word [DenominadordeTaxaAcelerado]	        ;; st1 = maior dimensão da caixa
											        ;; st0 = DenominadordeTaxa
	fdivp st1, st0							        ;; st0 = st1 / st0
	fstp dword [FatorMouseCaixaAcelerado]           ;; FatorMouseCaixa = st0
	
	pop ds
	popa
	
	ret
