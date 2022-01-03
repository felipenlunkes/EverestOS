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
;; #$@$%&*%$#@#!$@@#@#$%!$#!$!#%#      | 
;; !#@$EVEREST#%@#!$%#!¨%#!$#!¨#$      | 
;; $#%@$#!@#$#!$%#EVEREST#$@¨!@$¨      |
;; #@%¨$@$#!@&%#$@¨#@&%$@%¨$@&¨$@      |  
;;
;;*****************************************************************************

CONFIG_arquivo_nao_encontrado:		db "Arquivo EVEREST.SIS nao encontrado! ", 0

CONFIG_nome_de_arquivo_muito_grande: db "O nome do arquivo nao pode ser maior que 8 caracteres! ", 0

CONFIG_delimitador_nao_encontrado: db "Nome de arquivo nao encontrado nos primeiros 4kb do arquivo!", 0

CONFIG_nome_de_arquivo: db "EVEREST CFG", 0

;;*****************************************************************************

CONFIG_encontrar_nome_app_inicializacao:

	pusha
	push es

	push cs
	pop es
	mov di, KERNEL_buffer_de_dados	;; ES:DI aponta para o local de carregamento
								
	mov si, CONFIG_nome_de_arquivo		;; DS:SI aponta para o nome do arquivo
	int 81h						        ;; Carregar arquivo
	
	cmp al, 0
	jne CONFIG_falha_encontrar ;; Falha ao carregar?
	
	push ds
	
	push cs
	pop ds
	
	mov si, KERNEL_buffer_de_dados	;; DS:SI agora aponta para o conteúdo
	mov bx, 0xFFFF				    ;; Iniciando em -1
	
CONFIG_encontrar_nome_arquivo_entre_delimitadores:

	inc bx
	
	cmp bx, 0x1000
	je CONFIG_encontrar_nome_arquivo_nao_encontrado	;; Parar depois de 4 Kb
	
	mov al, [ds:si+bx]
	
	cmp al, '['
	jne CONFIG_encontrar_nome_arquivo_entre_delimitadores ;; Próximo
	
	;; BX aponta para o primeiro caractere
	
	push cs
	pop es
	mov di, Nome_Arquivo_SHELL ;; Copiar o nome para ES:DI 
	
	mov si, KERNEL_buffer_de_dados
	
	add si, bx				;; Mover SI para onde BX aponta
	mov bx, 0				;; Iniciar em 0
	
CONFIG_encontrar_nome_copiar_nome:

	inc bx
	cmp bx, 10				;; BX começa como 1
							;; E termina em ']', 9
							
	je CONFIG_encontrar_nome_correr	;; Parar depois de 8 caracteres
	
	mov al, [ds:si+bx]
	
	cmp al, ']'						;; Pronto
	je CONFIG_encontrar_nome_pronto	;; Sim
	
	;; Ainda não, então reservando o caractere
	
	stosb
	
	jmp CONFIG_encontrar_nome_copiar_nome

;;*****************************************************************************
	
CONFIG_encontrar_nome_pronto:

	pop ds
	pop es
	popa
	
	ret

;;*****************************************************************************
	
CONFIG_encontrar_nome_correr:

	pop ds
	pop es
	
	mov si, CONFIG_nome_de_arquivo_muito_grande
	
	call DEBUG_imprimir
	
	popa
	
	cli
	hlt

;;*****************************************************************************
	
CONFIG_encontrar_nome_arquivo_nao_encontrado:

	pop ds
	pop es
	
	mov si, CONFIG_delimitador_nao_encontrado
	
	call DEBUG_imprimir
	
	popa
	
	cli							;; Sem interrupções
	hlt							;; Suspender CPU

;;*****************************************************************************
	
CONFIG_falha_encontrar:

	pop es
	
	mov si, CONFIG_arquivo_nao_encontrado
	
	call DEBUG_imprimir
	
	popa
	
	cli							;; Sem interrupções
	hlt							;; Suspender CPU
