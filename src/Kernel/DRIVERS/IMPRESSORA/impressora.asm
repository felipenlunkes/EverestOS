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

;;*****************************************************************************
;;
;;                   Fun��es para manipula��o de impressora
;;
;;*****************************************************************************

;;************************************************************

IMPRESSORA_iniciar:

mov ah, 01h
mov dx, 0h
int 17h

jc near IMPRESSORA_falha
ret

;; Driver para impress�o de relat�rio do Computador

;;************************************************************

IMPRESSORA_imprimir:  ;; Esse m�todo � usado para transferir dados para a impressora

lodsb         ;; Carrega o pr�ximo caractere � ser enviado

or al, al     ;; Compara o caractere com o fim da mensagem
jz .pronto    ;; Se igual ao fim, pula para .pronto

mov dx, 0x0   ;; Porta Paralela a ser utilizada
mov ah, 0x00
int 0x17      ;; Chama o BIOS e executa a a��o 

jc IMPRESSORA_falha

jmp IMPRESSORA_imprimir ;; Se n�o tiver acabado, volta � fun��o e carrega o pr�ximo caractere


.pronto: ;; Se tiver acabado...

ret      ;; Retorna a fun��o que o chamou

;;************************************************************

IMPRESSORA_falha:

stc

ret
