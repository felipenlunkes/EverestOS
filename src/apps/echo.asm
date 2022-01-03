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

org 0

jmp inicio

;;*****************************************************************************

cabecalhoEVO:                ;; Cabeçalho utilizado para identificação do processo com para o sistema

.assinatura: db "EVO",0      ;; Assinatura do aplicativo EVO
.autor: db "Felipe Luneks",0 ;; Autoria resumida

;;*****************************************************************************

;; Variáveis para uso com o aplicativo e interação com o sistema

entrada times 64 db 0 ;; Área de despejo para o conteúdo do usuário
espacador: db 10,13,0 ;; Nova linha
prompt: db "> ",0

;;*****************************************************************************

inicio:

	mov ax, cs
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov si, espacador ;; Criamos um espaço para com as informações do sistema e do aplicativo
	int 80h
	
	mov si, prompt    ;; Exibir um prompt na tela
	int 80h           ;; Pedir ao sistema para exibir o prompt
	
	mov ax, 01        ;; Código para receber dados no teclado
	int 26h           ;; Pedimos ao Sistema para verificar a entrada de dados pelo teclado
	
	mov [entrada], si ;; O sistema retorna os valores em uma estrutura apontada por DS:SI
	                  ;; Devemos mover o conteúdo para um ponteiro por segurança (algo pode dar errado, não é mesmo?)
	                  ;; Essa estrutura é "zero terminated", já editada para trabalhos de impressão (tela, impressora) e envio serial.
					  
	mov si, espacador ;; Criamos um espaço para com as informações do sistema e do aplicativo
	int 80h	

    mov si, espacador ;; Criamos um espaço para com as informações do sistema e do aplicativo
	int 80h		

	mov si, [entrada] ;; Agora movemos o que está dentro da área de memória de "entrada" para SI
	int 80h           ;; Chamamos o Sistema o pedindo para exibir na tela o conteúdo do que foi
                      ;; inserido pelo usuário

	mov ax, 00h       ;; Sem código de erro, saída limpa
	int 20h           ;; Pedimos o sistema para matar o processo e devolvemos o controle do PC a ele

;;*****************************************************************************
