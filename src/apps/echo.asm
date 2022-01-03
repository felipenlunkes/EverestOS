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
;; #$@$%&*%$#@#!$@@#@#$%!$#!$!#%#      |        Aplicativos do Sistema
;; !#@$EVEREST#%@#!$%#!�%#!$#!�#$      | 
;; $#%@$#!@#$#!$%#EVEREST#$@�!@$�      |
;; #@%�$@$#!@&%#$@�#@&%$@%�$@&�$@      |  
;;
;;*****************************************************************************

[BITS 16]

org 0

jmp inicio

;;*****************************************************************************

cabecalhoEVO:                ;; Cabe�alho utilizado para identifica��o do processo com para o sistema

.assinatura: db "EVO",0      ;; Assinatura do aplicativo EVO
.autor: db "Felipe Luneks",0 ;; Autoria resumida

;;*****************************************************************************

;; Vari�veis para uso com o aplicativo e intera��o com o sistema

entrada times 64 db 0 ;; �rea de despejo para o conte�do do usu�rio
espacador: db 10,13,0 ;; Nova linha
prompt: db "> ",0

;;*****************************************************************************

inicio:

	mov ax, cs
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov si, espacador ;; Criamos um espa�o para com as informa��es do sistema e do aplicativo
	int 80h
	
	mov si, prompt    ;; Exibir um prompt na tela
	int 80h           ;; Pedir ao sistema para exibir o prompt
	
	mov ax, 01        ;; C�digo para receber dados no teclado
	int 26h           ;; Pedimos ao Sistema para verificar a entrada de dados pelo teclado
	
	mov [entrada], si ;; O sistema retorna os valores em uma estrutura apontada por DS:SI
	                  ;; Devemos mover o conte�do para um ponteiro por seguran�a (algo pode dar errado, n�o � mesmo?)
	                  ;; Essa estrutura � "zero terminated", j� editada para trabalhos de impress�o (tela, impressora) e envio serial.
					  
	mov si, espacador ;; Criamos um espa�o para com as informa��es do sistema e do aplicativo
	int 80h	

    mov si, espacador ;; Criamos um espa�o para com as informa��es do sistema e do aplicativo
	int 80h		

	mov si, [entrada] ;; Agora movemos o que est� dentro da �rea de mem�ria de "entrada" para SI
	int 80h           ;; Chamamos o Sistema o pedindo para exibir na tela o conte�do do que foi
                      ;; inserido pelo usu�rio

	mov ax, 00h       ;; Sem c�digo de erro, sa�da limpa
	int 20h           ;; Pedimos o sistema para matar o processo e devolvemos o controle do PC a ele

;;*****************************************************************************
