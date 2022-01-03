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

mov ax, cs
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax

jmp inicio

;;*****************************************************************************

%macro print 1+

     section .data  
	 
 %%string:
 
     db %1,0
     section .text    
 
     mov si,%%string
     int 97h
	 
 %endmacro
 
;;*****************************************************************************
 
Aviso_Display db 10,13,"O aplicativo foi aberto em uma nova area de trabalho virtual.",10,13
              db 10,13,"Utilize a combinacao fornecida acima para acessa-lo.",0

			  
;;*****************************************************************************

inicio:

mov si, Aviso_Display
int 80h

print 10,13,"Sobre o Everest(R)",10,13,0

print 10,13,"Nome do Sistema Operacional: Sistema Operacional Everest(R)",10,13,10,13,0
print "Copyright (C) 2016 Felipe Miguel Nery Lunkes",10,13,0
print "Todos os direitos reservados.",10,13,0

print 10,13,"Tipo de Sistema Operacional: 16 Bits",10,13,0

print "Versao do Sistema em execucao: ",0

int 0xA3

int 0xA4

mov si, ax

int 97h

print ".",0

int 0xA3

mov ax, bx

int 0xA4

mov si, ax

int 97h

print ".",0

int 0xA3

mov ax, cx

int 0xA4

mov si, ax

int 97h

print 10,13,0

print "Modo de operacao: Multitarefa cooperativa",10,13,0

call verificarProcessador

print 10,13,10,13,0

print "Este aplicativo estara aberto na multitarefa, caso queira voltar.",10,13,0

print "Nao se preocupe, o sistema o fechara automaticamente caso precise de",10,13,0

print "mais memoria disponivel para executar aplicativos.",10,13,0

print 10,13,"Pressione [ALT+F1] para retornar a tela inicial.",10,13,10,13,0
    
mov dx, 100

;;*****************************************************************************
	
loop_Principal:

	dec dx
	jz pronto
	
	mov cx, 1					;; Delay em um intervalo de tempo
	
	int 85h						
	int 37h						
	
	int 85h						
	int 37h						
	
	int 85h						
	int 37h						
	
	int 85h						
	int 37h						
	
	
	jmp loop_Principal				

;;*****************************************************************************
	
pronto:

	int 20h						;; Sair

;;*****************************************************************************

verificarProcessador:

    mov eax,80000002h	
	cpuid
	
	mov di,produto		
	stosd
	mov eax,ebx
	stosd
	mov eax,ecx
	stosd
	mov eax,edx
	stosd
	
	mov eax,80000003h	
	cpuid
	
	stosd
	mov eax,ebx
	stosd
	mov eax,ecx
	stosd
	mov eax,edx
	stosd
	
	mov eax,80000004h	
	cpuid
	
	stosd
	mov eax,ebx
	stosd
	mov eax,ecx
	stosd
	mov eax,edx
	stosd
	mov si,produto		
	mov cx,48
	
loop_CPU:	

    lodsb
	cmp al,' '
	jae imprimir_CPU
	mov al,'_'
	
imprimir_CPU:	

    mov [si-1],al
	loop loop_CPU

	mov si, prodmsg		
	int 97h

	ret

;;*****************************************************************************
		
prodmsg	db "Nome do Processador: ["

produto	db "abcdabcdabcdabcdABCDABCDABCDABCDabcdabcdabcdabcd]",13,10,0

