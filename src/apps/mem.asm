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

%define .texto [SECTION .TEXT]
%define .dados [SECTION .DATA ALIGN=8]
%define .info [SECTION .INFO]
%define .comm [SECTION .COMMENT]
%define .bss [SECTION .BSS]

[BITS 16]

org 0h

mov ax, cs
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax

xor ax, ax
xor bx, bx
xor cx, cx

jmp inicio

;;*****************************************************************************

%macro print 1+

     section .data  
	 
 %%string:
 
     db %1,0
     section .text    
 
     mov si,%%string
     int 80h
	 
 %endmacro

;;*****************************************************************************
 
inicio:

print 10,13,"Sistema de Gerenciamento de Hardware do Everest(R)",10,13,0


print 10,13,10,13,"# Memoria RAM total disponivel encontrada: ",0

    pusha
	mov al,18h
	out 70h,al
	in al,71h
	mov ah,al
	mov al,17h
	out 70h,al
	in al,71h
	
	add ax,1024
	
	int 0xA4

mov si, ax

int 80h

print " Kbytes.",10,13,0
	
int 20h

;;*****************************************************************************

nomeoriginal: db "MEM.EVO",0
nomeapp: db "Gerencimento de Memoria do Everest(R)",0
autor: db "Felipe Miguel Nery Lunkes",0
copyright: db "Copyright 2013-2016 Felipe Miguel Nery Lunkes. Todos os direitos reservados.",0
