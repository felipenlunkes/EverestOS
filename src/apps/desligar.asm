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

;;*****************************************************************************

cabecalho:

.assinatura db "EVO",0

;;*****************************************************************************

StringFalha: 	db "O comando de desligamento APM falhou.", 0
StringConexao: 	 db "Impossivel conectar a interface APM.", 0
StringSelecionarVersao: db "Impossivel utilizar Driver APM 1.2.", 0
StringChecarInst: db "APM nao disponivel.", 0

Boasvindas db 10,13,10,13,"Assistente de desligamento do Sistema Operacional Everest(R)",10,13
           db 10,13,"Este assistente requer APM 1.2+",10,13,10,13
           db "> Preparando para desligar seu computador...",10,13,10,13,0

Parando db "> Parando os discos...",10,13,10,13,0

Desligando db "> Desligando o computador...",10,13,0

parametros_disco times 4 db 0  

;;*****************************************************************************

inicio:
     
	mov si, Boasvindas
    int 80h
	
	mov ax, 5
	int 27h
	
	mov si, Parando
	int 80h
    
    call parardiscos

    mov ax, 50
    int 27h
   	
	mov si, Desligando
	int 80h
	
	mov ax, 5
	int 27h
	
    int 9Bh	;; Interrupção de desligamento do sistema
	
	
	cmp ax, 0
	je falha_instalacao
	
	cmp ax, 1
	je impossivel_conectar_interface
	
	cmp ax, 2
	je impossivel_selecionar_driver
	
;;*****************************************************************************
	
erro_comando_desligar:

	mov si, StringFalha
	
	int 80h	
	
	int 20h						

;;*****************************************************************************
	
falha_instalacao:

	mov si, StringChecarInst
	
	int 80h
	
	int 20h					

;;*****************************************************************************
	
impossivel_conectar_interface:

	mov si, StringConexao
	
	int 80h
	
	int 20h						;; Sair
	
;;*****************************************************************************
	
impossivel_selecionar_driver:

	mov si, StringSelecionarVersao
	int 80h
	
	int 20h						;; Sair

;;*****************************************************************************
	
parardiscos:

;; Obter parâmetros dos discos

mov ah, 08h
mov dl, 80h
mov ax, 0000h
mov di, ax
mov es, ax

int 13h

mov [parametros_disco], dl



    mov ah, 00h
	mov dl, 80h
	
	int 13h
	
	mov ah, 09h ;; Inicia o controlador
	mov dl, 80h
	
	int 13h
	
	
	
	mov ah, 48h ;; Obtêm parâmetros do disco
	mov dl, 80h
	
	int 13h
	
	
	mov ah, 00h
	mov dl, 00h
	
	int 13h
	
	mov ah, 00h
	mov dl, 80h
	
	int 13h
	
	int 13h
	
	mov ah, 10h
	mov dl, 80h
	
	int 13h
	
	mov ah, 11h
	mov dl, 80h
	
	int 13h
	
	mov ah, 01h
	
	int 13h
	
    ret	
	
;;*****************************************************************************	