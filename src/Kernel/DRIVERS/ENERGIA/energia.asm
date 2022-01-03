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

ERRO_INSTALACAO equ 0
ERRO_CONEXAO_MODO_REAL equ 1
ERRO_DRIVER_NAO_SUPORTADO equ 2
ERRO_ALTERANDO_STATUS equ 3

;; Sa�da:
;;
;;			AX - c�digos de erro:
;;				0 = falha de instala��o
;;				1 = falha na conex�o de modo real
;;				2 = Driver APM vers�o 1.2 n�o suportado
;;				3 = falha ao mudar status para "off"


KERNEL_APM_desligar:

	push bx
	push cx

	mov ax, 5300h		;; Fun��o de checagem de instala��o
	mov bx, 0			;; ID do dispositivo
	int 15h				;; Invocar interrup��o APM
	
	jc checar_falha_instalacao

	mov ax, 5301h		;; Fun��o APM para conex�o com interface de modo real
	mov bx, 0			;; ID do dispositivo
	int 15h				;; Invocar interrup��o APM
	
	jc erro_conexao_com_interface

	mov ax, 530Eh		;; Fun��o de sele��o de vers�o do Driver
	mov bx, 0			;; ID do dispositivo
	mov cx, 0102h		;; Vers�o 1.2 (desligamento)
	int 15h				;; Invocar interrup��o APM
	
	jc impossivel_selecionar_versao_driver

	mov ax, 5307h		;; Fun��o de definir estado
	mov cx, 0003h		;; Estado de desligar sistema
	mov bx, 0001h		;; Todos os dispositivos gerenciados - ID 1
	int 15h				;; Invocar interrup��o APM
	
	;; Se o sistema n�o desligar, manipular os erros abaixo

;;*****************************************************************************
	
falha_desligamento:

	mov ax, ERRO_ALTERANDO_STATUS
	
	jmp desligamento_concluido

;;*****************************************************************************
	
checar_falha_instalacao:

	mov ax, ERRO_INSTALACAO
	
	jmp desligamento_concluido

;;*****************************************************************************
	
erro_conexao_com_interface:

	mov ax, ERRO_CONEXAO_MODO_REAL
	
	jmp desligamento_concluido

;;*****************************************************************************
	
impossivel_selecionar_versao_driver:

	mov ax, ERRO_DRIVER_NAO_SUPORTADO

;;*****************************************************************************
	
desligamento_concluido:

	pop cx
	pop bx
	
	ret
