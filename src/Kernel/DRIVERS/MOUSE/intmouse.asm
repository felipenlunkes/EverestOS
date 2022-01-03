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

ManipuladordeMouseestaHabilitado: db 0
LarguraCaixaDelimitadora: dw 0
AlturaCaixaDelimitadora: dw 0

mouseX:	dw 0
mouseY:	dw 0
ButoesMouse: db 0	;; bits 3 a 7 - sem uso
					;; bit 2 - estado atual do bot�o central
					;; bit 1 - estado atual do bot�o direito
					;; bit 0 - estado atual do bot�o esquerdo
					
UltimosBotoesdoMouse: db 0	;; Como acima

FatorMouseCaixa: dd 0	;; Multiplicar o delta do mouse por isto

FatorMouseCaixaAcelerado: dd 0	;; Como acima, para valores acelerados

DimensaoMaisLongaCaixaDelimitadora: dd 0 ;; Usado para calcular mouse para caixa

DenominadordeTaxa: dw 1000 ; Deltas do mouse de hardware ser�o divididos
                           ;; por este n�mero para retardar ponteiro para baixo
						   
DenominadordeTaxaAcelerado: dw 400	;; Como acima, para valores acelerados
								
deltaX: dw 0			;; Sem sinal, 0-255

deltaXCoordenadasdoUsuario: dd 0	;; Sem sinal

deltaY: dw 0			;; Sem sinal, 0-255

deltaYCoordenadasdoUsuario: dd 0	;; Sem sinal

LimiteAceleracao equ 32	;; Valores para acelera��o

;;*****************************************************************************

;; Este manipulador de interrup��o calcula e atualiza a posi��o do mouse dentro do
;; sistema de coordenadas especificadas pelo utilizador, de modo que o utilizador pode, em �ltima
;; an�lise verificar e obter a nova localiza��o do mouse.
;; Programas de usu�rio que desejam utilizar o mouse de forma mais avan�ada podem escolher
;; para registrar seu pr�prio manipulador de interrup��o.
;; Nota: recebe dados mouse PS/2 - padr�o como entrada
;; Nota: se este for substitu�do, o comportamento da interrup��o de"poll gerido" torna-se
;; indefinido.
;;
;; Entrada:
;;
; BH - bit 7 - Y estouro
; bit 6 - X estouro
; bit 5 - bit de sinal de Y
; bit 4 - bit de sinal de X
; bit 3 - n�o utilizado e indeterminado
; bit 2 - bot�o do meio
; bit 1 - bot�o direito
; bit 0- bot�o esquerdo
; DH - Movimento X (delta X)
; DL - movimento Y (delta Y)

MOUSE_estado_alterado_manipulador_raw:

	pusha
	push ds
	
	push cs
	pop ds							;; DS = CS
	
	mov al, byte [ManipuladordeMouseestaHabilitado]
	cmp al, 0
	je MOUSE_estado_alterado_manipulador_nativo_pronto	;; Se n�o inicializado, n�o fazer nada
	
	call MOUSE_computar_novo_X
	call MOUSE_computar_novo_Y
		
	and bh, 00000111b				;; BH = apenas estado atual dos bot�es
	mov byte [ButoesMouse], bh		;; Armazenar novo valor

;;*****************************************************************************
	
MOUSE_estado_alterado_manipulador_nativo_pronto:

	pop ds
	popa
	ret
	
;;*****************************************************************************

;; Computar e armazenar valor de X em coordenadas de usu�rio.
;;
;; Entrada:
;;
;;		BH - bit 4 - bit de sinal de X 
;;		DH - movimento de X (delta X)

MOUSE_computar_novo_X:

	pusha
	
	cmp dh, 0
	je MOUSE_computar_novo_X_pronto	;; Se n�o ocorrer movimento horizontal, pronto
	
	mov cl, bh				;; Salvar bit de sinal em CL
	
	test cl, 00010000b		;; Quando o bit 4 est� limpo, o delta � positivo
	jz MOUSE_computar_novo_X_positivo
	
	neg dh					;; delta = |delta|

;;*****************************************************************************
	
MOUSE_computar_novo_X_positivo:	

	mov ah, 0
	mov al, dh				;; AX = DH
	mov word [deltaX], ax	;; Armazenar em mem�ria em prepara��o a chamadas FPU
	
	fild word [deltaX]				;; st0 = deltaX
	
	cmp ax, LimiteAceleracao
	jb MOUSE_computar_novo_X_sobre_limite	;; Est� sobre o limite?
	
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
	
	
;; Enquanto deltaXCoordenadasdoUsuario � um dword  o seu valor nunca dever�
;; estar acima de 65535, o que significa que ele pode ser moldado de forma segura para uma palavra.
	
	mov ax, word [deltaXCoordenadasdoUsuario]
	
	cmp ax, 0
	jne MOUSE_computar_novo_X_nao_zero		
						;; if deltaXCoordenadasdoUsuario = 0, then deltaXCoordenadasdoUsuario = 1
	mov ax, 1			;; Ent�o o movimento do mouse terminado no delta

;;*****************************************************************************
	
MOUSE_computar_novo_X_nao_zero:

	;; AX = delta do movimento em coordenadas de usu�rio
	
	test cl, 00010000b	;; Quando o bit 4 est� limpo, � positivo
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
	
	;; Estourou, ent�o vamos reduzir o valor para o limite
	
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
	
;; Computar e armazenar valor de Y em coordenadas de usu�rio
;;
;; Entrada:
;;
;;		BH - bit 5 - bit de sinal de Y
;;		DL - movimento de Y (delta Y)

MOUSE_computar_novo_Y:

	pusha
	
	cmp dl, 0
	je MOUSE_computar_novo_Y_pronto	;; Se sem movimento horizontal, est� pronto
	
	mov cl, bh				;; Salvar bit de sinal em CL
	
	test cl, 00100000b		;; Quando bit 5 limpo, delta positivo
	jz MOUSE_computar_novo_Y_positivo
	
	neg dl					;; delta = |delta|

;;*****************************************************************************	
	
MOUSE_computar_novo_Y_positivo:	

	mov ah, 0
	mov al, dl				;; AX = DL
	mov word [deltaY], ax	;; Armazenar em mem�ria em prepara��o a chamadas FPU
	
	fild word [deltaY]				;; st0 = deltaY
	
	cmp ax, LimiteAceleracao
	jb MOUSE_computar_novo_Y_sobre_limite	;; Est� dentro do limite?
	
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
	
						;; Se deltaYCoordenadasdoUsuario = 0, ent�o deltaYCoordenadasdoUsuario = 1
	mov ax, 1			;; O movimento do mouse termina em delta
	
;;*****************************************************************************
	
MOUSE_computar_novo_Y_nao_zero:

	;; AX = delta de movimento em coordenadas de usu�rio
	
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
	
	jmp MOUSE_computar_novo_Y_pronto	;; Est� pronto

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
	
;; Retornar a localiza��o atual do mouse, assim como o estado dos bot�es.
;;
;; Entrada:
;;
;;		AL - bits 3 a 7 - sem uso e indeterminado
;;			 bit 2 - estado do bot�o central
;;			 bit 1 - estado do bot�o direito
;;			 bit 0 - estado do bot�o esquerdo
;;		BX - posi��o de X em coordenadas de usu�rio
;;		DX - posi��o de Y em coordenadas de usu�rio

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
	
	mov byte [ButoesMouse], 0			;; Limpar estado dos bot�es
	
	mov ax, bx							;; Assumir largura t�o grande quanto altura
	
	cmp bx, dx
	jae MOUSE_manipulador_inicializar_obter_dimensao	;; Largura � maior - n�o fazer nada
	
	mov ax, dx							;; Altura � maior que largura

;;*****************************************************************************	
	
MOUSE_manipulador_inicializar_obter_dimensao:

	;; Aqui, AX = maior dimens�o
	;; Armazenar maior dimens�o como dword
	
	mov byte [DimensaoMaisLongaCaixaDelimitadora], bl	 ;; low endian word->dwor
	mov byte [DimensaoMaisLongaCaixaDelimitadora+1], bh  ;; FPU n�o consegue
	mov byte [DimensaoMaisLongaCaixaDelimitadora+2], 0	 ;; interpretar palavras grandes
	mov byte [DimensaoMaisLongaCaixaDelimitadora+3], 0	 ;; Valores s�o negativos
	
	mov word [LarguraCaixaDelimitadora], bx		;; Armazenar largura como dword
	shr bx, 1
	mov word [mouseX], bx				;; Inicialmente, mouseX = Largura da caixa / 2
	
	mov word [AlturaCaixaDelimitadora], dx	;; Armazenar altura
	shr dx, 1
	mov word [mouseY], dx				;; Inicialmente, mouseY = Altura da caiza / 2
	
	fninit								;; Inicializar FPU
	
	; calculate mouse-to-box factor
	fild dword [DimensaoMaisLongaCaixaDelimitadora] ;; st0 = maior dimens�o da caixa
	fild word [DenominadordeTaxa]			        ;; st1 = maior dimens�o da caixa
											        ;; st0 = DenominadordeTaxa
	fdivp st1, st0							        ;; st0 = st1 / st0
	fstp dword [FatorMouseCaixa]	 		        ;; FatorMouseCaixa = st0
	
	;; Calcular mouse para caixa com valores acelerados
	
	fild dword [DimensaoMaisLongaCaixaDelimitadora] ;; st0 = maior dimens�o da caixa
	fild word [DenominadordeTaxaAcelerado]	        ;; st1 = maior dimens�o da caixa
											        ;; st0 = DenominadordeTaxa
	fdivp st1, st0							        ;; st0 = st1 / st0
	fstp dword [FatorMouseCaixaAcelerado]           ;; FatorMouseCaixa = st0
	
	pop ds
	popa
	
	ret
