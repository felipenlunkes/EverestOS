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

inicio:

push es
mov ax, 040h
mov es, ax
mov bx, 0xB2
mov cx, 01234h
mov [bx], cx
        
mov ax, 0ffffh
push ax
mov ax, 0
push ax
		
retf

ret

;;*****************************************************************************
		