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

jmp Inicio

;;*****************************************************************************

cabecalho:

.assinatura db "EVO",0

;;*****************************************************************************

stringNovaLinha:	db 13, 10, 0
tabString: db "    ", 0
MensagemIntroducao:	db 13,10,10,13, "Os seguintes aplicativos estao disponiveis (*.EVO):",10,13,10,13, 0
contadorEntradasDiretorioRaiz: dw 0	;; Número de entradas de 32 bytes no diretório raiz
esperarmsg: db 10,13,10,13,"Pressione [ENTER] para ver mais arquivos...",10,13,0

;;*****************************************************************************
							
Inicio:

	mov di, DiretorioRaiz			;; Diretório raiz em ES:DI
	int 87h
	
	;; AX contêm o número de entradas
	
	mov word [contadorEntradasDiretorioRaiz], ax
	

	mov si, MensagemIntroducao
	int 80h					
	
	mov di, DiretorioRaiz
	sub di, 32		;; Inicia após a entrada de 32 bytes
	
	mov dx, 0

;;*****************************************************************************
	
proxima_entrada_diretorio:

	add di, 32
	mov bx, di
	shr bx, 5
	
	cmp bx, word [contadorEntradasDiretorioRaiz]
	jae tudo_pronto	;; Se DI div 32 >= contadorEntradasDiretorioRaiz, pronto
	
	;; ES:DI aponta para os 11 caracteres 
	
	mov al, byte [es:di]
	
	cmp al, 0E5h			;; Se a entrada for 0E5h, é considerada livre
	je proxima_entrada_diretorio ;; Então se deve mover para a próxima entrada do diretório
	
	push di
	
	;; Mover DI para o primeiro caractere da extensão
	
	add di, 8		;; Pular e ir pro nome
	
	cmp byte [es:di], 'E'
	jne procurar_proxima_entrada
	
	cmp byte [es:di+1], 'V'
	jne procurar_proxima_entrada
	
	cmp byte [es:di+2], 'O'
	jne procurar_proxima_entrada
	
	
	pop di			;; Restaurar DI para o início do nome do arquivo
	
	;; O arquivo rem nome de aplicativo
	
	mov si, stringNovaLinha
	int 80h					
	
	mov si, tabString ;; Dar um tab
	int 80h					
	
	mov si, di
	mov cx, 8	;; Imprimir o nome do arquivo sem extensão
	
	int 88h		
	
	add dx, 1
	
	cmp dx, 19 ;; Caso tenham se passado 19 entradas no diretório, aguardar comando
	           ;; do usuário para exibir mais arquivos
	je esperar
	
	
	jmp proxima_entrada_diretorio

;;*****************************************************************************
	
procurar_proxima_entrada:

	pop di
	
	jmp proxima_entrada_diretorio

;;*****************************************************************************

esperar:

 xor dx, dx ;; Importante! Zera DX para recomeçar a contagem
 
 mov si, esperarmsg
 int 80h
 
 mov ax, 0
 int 16h
 
 jmp proxima_entrada_diretorio
 
;;*****************************************************************************
 
tudo_pronto:

	mov si, stringNovaLinha
	int 80h

	int 20h						;; Sair

;;*****************************************************************************
	
DiretorioRaiz:					;; Aqui ele será carregado
