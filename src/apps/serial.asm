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

;;************************************************************************

cabecalho:

.assinatura db "EVO",0

;;************************************************************************

buffer times 64 db 0

;;************************************************************************

boasvindas: db "Assistente de comunicacao serial do Sistema Operacional Everest(R)",10,13,10,13
            db "Versao: ",0
		   
mensagemInserir: db	10,13,10,13,"Insira a mensagem a ser enviada.",10,13
                 db "Ela deve ter no maximo 64 caracteres.",10,13,10,13
				 db "> ",0
				 
msgTransferir db 10,13,10,13,"Enviando via porta serial...",10,13,0

msgFim db "Pronto!",10,13,0

;;************************************************************************

%macro print 1+

     section .data  
	 
 %%string:
 
     db %1,0
     section .text    
 
     mov si,%%string
     int 80h
	 
 %endmacro 

;;************************************************************************

inicio:

int 9Dh ;; Inicializar via Kernel a comunicação via portas seriais...

mov si, boasvindas
int 80h

;;************************************************************************

;; Aqui serão mostradas as informações do sistema

int 0xA3

int 0xA4

mov si, ax

int 80h

print ".",0

int 0xA3

mov ax, bx

int 0xA4

mov si, ax

int 80h

print ".",0

int 0xA3

mov ax, cx

int 0xA4

mov si, ax

int 80h

;;************************************************************************

;; Continuação da execução do software

mov si, mensagemInserir
int 80h

int 26h

mov [buffer], si

mov si, msgTransferir
int 80h

int 9Dh

mov si, [buffer]
int 9Eh

mov si, msgFim
int 80h

int 20h