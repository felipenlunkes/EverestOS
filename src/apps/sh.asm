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
;; $#%@$#!@#$#!$%#EVEREST#$@¨!@$¨      | Shell do Sistema Operacional Everest®
;; #@%¨$@$#!@&%#$@¨#@&%$@%¨$@&¨$@      |  
;;
;;*****************************************************************************

[BITS 16]

org 0

jmp Inicio_Console
	
;;*****************************************************************************

PROCURAR_ALT_F1 equ 68h
PROCURAR_ALT_F9 equ 70h

NovaLinha:		db 13, 10, 0

MENSAGEM_BoasVindas:	db 13, 10
					    db "Sistema Operacional Everest(R)"
					    db 13, 10
						db "Versao 0.5.2", 10,13
AjudaConsole:           db 13, 10
					    db "Para ver os apps disponiveis, utilize 'dir'"
					    db 13, 10,0

MENSAGEM_PROMPT:	db 13, 10, 10, 13, "[root@everest:/]: ", 0

MENSAGEM_STRING_MUITO_LONGA: db 13, 10,10,13,
						     db "O nome de arquivo nao pode exceder 8 caracteres!", 10,13,10,13,0
						
MENSAGEM_FALHA_APP1: db 13, 10, 10, 13,"Nao e possivel encontrar ou executar o arquivo: ", 0
MENSAGEM_FALHA_APP2: db ".EVO", 10,13,0
MENSAGEM_FALHA_APP3: db "Verifique se o mesmo e um aplicativo e se e compativel com o sistema.", 10,13,0

MENSAGEM_SEMMEMORIA:		db 13, 10, "Impossivel alocar memoria para este aplicativo!", 0

MENSAGEM_JA_EXECUTANDO:	db 13,10,13,10,"Impossivel abrir outra instancia para o Shell.", 0

MENSAGEM_NAO_EXISTE_TAREFA:		db 10,13,13,10,"Impossivel alterar para tarefa solicitada.", 10,13
                                db "A mesma ja pode ter sido finalizada pelo sistema.",0

MENSAGEM_TROCAR_DISPLAY1:	db 13,10,13,10, "Utilize [ALT+F", 0
MENSAGEM_TROCAR_DISPLAY2:	db "] para ir ao app aberto agora. Use [ALT+F1] para retornar.", 10,13, 0

TAMANHO_Maximo_Linha 		equ 100
Buffer_Entrada_Atual: 		times ( TAMANHO_Maximo_Linha + 1 ) db 0 

Buffer_Nome_Arquivo:		db "        EVO", 0
INSTANCIA_SHELL:	db "SH      EVO", 0

SEM_TAREFAS equ 0FFFFh
NUMERO_MAXIMO_TAREFAS_FILHAS 	equ 9
ListaIDTarefas:		times ( NUMERO_MAXIMO_TAREFAS_FILHAS + 1 ) dw 0 ;; +1 para a tarefa
ListaIDTarefas_FIM:

;;*****************************************************************************

Inicio_Console:

	int 9Ah						;; AX = ID de tarefa atual
	
	mov di, ListaIDTarefas 
	
	mov word [es:di+0], ax		;; ListaIDTarefas[0] = O ID desta tarefa
	
	mov ax, SEM_TAREFAS
	mov cx, NUMERO_MAXIMO_TAREFAS_FILHAS
	mov di, ListaIDTarefas
	add di, 2					;; Mover 1 para o índice
	
	rep stosw					;; Marcar os Slotes de tarefas filhas como livres
	
	mov si, MENSAGEM_BoasVindas	
	int 97h

;;*****************************************************************************
	
;; Iniciar lendo caracteres em nova linha
	
CONSOLE_ler_nova_linha:

	mov si, MENSAGEM_PROMPT
	int 97h						;; Exibir Prompt

	int 83h						;; Limpar Buffer de teclado
	
	call CONSOLE_limpar_linha_buffer_atual
	
	mov di, Buffer_Entrada_Atual	;; DI aponta para o início do buffer

;;*****************************************************************************
	
CONSOLE_ler_caractere:

	int 37h						
	
	mov ah, 1
	int 16h 									;; Alguma tecla pressionada?
	
	jnz CONSOLE_ler_caractere_foi_pressionado  ;; Sim
	
	;; Não
	
	jmp CONSOLE_ler_caractere	;; Ler próximo caratere
	
CONSOLE_ler_caractere_foi_pressionado:

	mov ah, 0
	int 16h			;; Bloquear e esperar tecla: AL = ASCII
					;; AH = código
	
	;; Primeiro, tentar ver se está tentando trocar de área de trabalho
	
	cmp ah, PROCURAR_ALT_F9	;; apenas F1 a F9
	ja CONSOLE_ler_caractere_nao_trocando_display
	
	cmp ah, PROCURAR_ALT_F1
	jb CONSOLE_ler_caractere_nao_trocando_display
	
	call CONSOLE_alterar_display_ativo	;; Alterar display
	
	cmp al, 0							;; Alterou:
	jne CONSOLE_ler_nova_linha			;; Não, exibir prompt e tentar de novo
	
	jmp CONSOLE_ler_caractere			;; Sim, ler próximo caractere
	
;;*****************************************************************************

;; Agora, trocando para próximo display

CONSOLE_ler_caractere_nao_trocando_display:

	cmp al, 13				;; ASCII para ENTER
	je CONSOLE_processar_linha	;; Processar linha
	
	cmp al, 8				;; ASCII para tecla de apagar (Backspace)
	jne CONSOLE_ler_nao_enter_ou_backspace
	
	;; Processar Backspace
	
	cmp di, Buffer_Entrada_Atual
	je CONSOLE_ler_caractere	;; Se buffer limpo, Backspace não faz nada
	
	;; Manipular a limpeza de caractere. Se buffer limpo, Backspace não faz nada
	
	dec di					;; Mover buffer uma posição atrás
	mov byte [es:di], 0		;; E limpar a última localização
	
	call CONSOLE_imprimir_caractere	;; Exibir o efeito na tela
	
	jmp CONSOLE_ler_caractere		;; Ler próximo caractere
	
;;*****************************************************************************	
	
CONSOLE_ler_nao_enter_ou_backspace:

	
	cmp al, 0
	je CONSOLE_ler_caractere	;; Caracteres não imprimíveis são ignorados
								;; Setas, teclas de função, etc
								
	
	mov bx, di
	
	sub bx, Buffer_Entrada_Atual	;; BX = atual - começo
	
	cmp bx, TAMANHO_Maximo_Linha
	jae CONSOLE_ler_caractere	;; Se buffer cheio, não fazer nada
	
	
	stosb
	
	call CONSOLE_imprimir_caractere
	
	jmp CONSOLE_ler_caractere
	
;;*****************************************************************************
	
CONSOLE_processar_linha:	

	mov bx, di
	sub bx, Buffer_Entrada_Atual				;; BX = atual - inicial
	
	cmp bx, 8
	jbe CONSOLE_processar_linha_curta_suficiente ;; Se não exceder 8 carateres, tudo bem

	;; Se não, linha muito grande!
	
	mov si, MENSAGEM_STRING_MUITO_LONGA
	
	int 97h							;; Exibir erro
	
	jmp CONSOLE_ler_nova_linha		;; Tudo pronto

;;*****************************************************************************
	
CONSOLE_processar_linha_curta_suficiente:	

	
	cmp bx, 0
	je CONSOLE_ler_nova_linha		;; Se linha limpa, iniciar nova linha

;;*****************************************************************************
	
CONSOLE_processar_linha_realizar:

	
	mov cx, bx
	
	call CONSOLE_executar_app
	
	jmp CONSOLE_ler_nova_linha		;; Iniciar nova linha

;;*****************************************************************************
	
;; Entrada:
;;
;; Caractere em AL

CONSOLE_imprimir_caractere:

	pusha
	
	cmp al, 8
	je CONSOLE_imprimir_caractere_backspace

	cmp al, 9
	je CONSOLE_imprimir_caractere_tab
	
	cmp al, 126		;; Último caractere imprimível ASCII
	ja CONSOLE_imprimir_caractere_pronto
	
	cmp al, 32	    ;; Primeiro caractere imprimível ASCII	
	jb CONSOLE_imprimir_caractere_pronto
	
	mov dl, al
	
	int 98h			;; Imprimir
	
	jmp CONSOLE_imprimir_caractere_pronto

;;*****************************************************************************
	
CONSOLE_imprimir_caractere_backspace:

	mov dl, al
	
	int 98h			
	
	jmp CONSOLE_imprimir_caractere_pronto

;;*****************************************************************************
	
CONSOLE_imprimir_caractere_tab:

	mov dl, ' '		;; Imprimir como conjunto de espaços
	
	int 98h
	
	jmp CONSOLE_imprimir_caractere_pronto

;;*****************************************************************************
	
CONSOLE_imprimir_caractere_pronto:

	popa
	
	ret

;;*****************************************************************************

CONSOLE_limpar_linha_buffer_atual:

	pusha
	
	mov di, Buffer_Entrada_Atual
	mov cx, TAMANHO_Maximo_Linha
	mov al, 0
	
	rep stosb					;; Encher o Buffer de 0
	
	popa
	
	ret

;;*****************************************************************************

CONSOLE_limpar_buffer_nome_arquivo:

	pusha
	
	mov di, Buffer_Nome_Arquivo
	mov cx, 8 ;; 8 devido ao formato FAT
	mov al, ' '
	
	rep stosb					
	
	popa
	ret
	
;;*****************************************************************************
	
;; Entrada:
;;	CX = tamanho do nome inserido

CONSOLE_executar_app:

	pusha
	
	call CONSOLE_limpar_buffer_nome_arquivo
	
	mov si, Buffer_Entrada_Atual
	mov di, Buffer_Nome_Arquivo
	
	rep movsb
	
	mov si, Buffer_Nome_Arquivo
	int 82h						;; Converter para maiúsculo
	
	mov di, INSTANCIA_SHELL
	mov cx, 11
	repe cmpsb					;; Comparar 11 bytes seguidos
	
	jnz CONSOLE_executar_app_realizar_carregamento 
	
	mov si, MENSAGEM_JA_EXECUTANDO
	int 97h							
	
	jmp CONSOLE_executar_app_pronto

;;*****************************************************************************
	
CONSOLE_executar_app_realizar_carregamento:

	int 91h						;; Perguntar Kernel segmento em BX
	
	cmp ax, 0					;; Temos algum?
	je CONSOLE_executar_app__carregar_segmento_presente	;; Sim
	
	mov si, MENSAGEM_SEMMEMORIA
	int 97h
	
	jmp CONSOLE_executar_app_pronto	;; Pronto, mas não foi executado
	
CONSOLE_executar_app__carregar_segmento_presente:

	push es
	mov es, bx					;; ES novo segmento alocado
	
	mov di, 0
	mov si, Buffer_Nome_Arquivo
	
	int 81h						;; Carregar aplicativo em ES:DI
	pop es

	cmp al, 0
	je CONSOLE_executar_app_sucesso

	;; Falha
	
	int 92h							;; Limpar segmento em BX
	
	mov si, MENSAGEM_FALHA_APP1 ;; Imprimir mensagem de falha
	int 97h				
	
	mov si, Buffer_Entrada_Atual
	int 82h							;; Converter para maiúsculo
	
	int 97h
	
	mov si, MENSAGEM_FALHA_APP2
	int 97h
	
	mov si, MENSAGEM_FALHA_APP3
	int 97h
	
	jmp CONSOLE_executar_app_pronto	;; Pronto
	
;;*****************************************************************************
	
CONSOLE_executar_app_sucesso:	
	
	;; BX no segmento onde foi carregado o aplicativo
	
	call CONSOLE_encontrar_slot_para_tarefa	;; CX = offset na tabela para a tarefa
	
	int 93h						;; Escalonar nova tarefa em BX:0000
								;; AX = ID da tarefa
	
	;; Armazenar o ID da nova tarefa (aqui, CX = offset na lista de tarefas)
	
	mov si, ListaIDTarefas
	add si, cx					;; SI aponta para o slot
	mov word [ds:si], ax		;; Armazena o ID (a seguir, DS:SI aponta para o ID na tabela
	
	;; Informar o usuáro sobre a combinação para acessar a tarefa
	
	mov si, MENSAGEM_TROCAR_DISPLAY1
	int 97h
	
	shr cx, 1					;; CX = index na matriz
	inc cx						;; Função do tipo -1
	add cl, '0'					;; itoa 
	
	mov dl, cl
	int 98h						;; Imprimir caractere em DL
	
	mov si, MENSAGEM_TROCAR_DISPLAY2
	int 97h
		
	mov si, NovaLinha
	int 97h
	
	int 37h

;;*****************************************************************************
	
CONSOLE_executar_app_pronto:

	popa
	ret

;;*****************************************************************************

;; Alterar para display virtual
;; 
;; Entrada:
;;
;		AH - tecla
;;
;; Saída:
;;
;;		AL - 0 caso não alterado o display

CONSOLE_alterar_display_ativo:

	push si
	push bx
	
	sub ah, PROCURAR_ALT_F1		;; Converter o índice para F1
	shl ah, 1					;; Converter para offset (cada entrada tem 2 bytes)
	
	mov al, ah
	mov ah, 0					;; AX = offset da tarefa
	mov si, ListaIDTarefas
	add si, ax					;; SI aponta para a entrada e ID apropriados
	
	mov ax, word [ds:si]		;; AX = ID da tabela para alterar
	cmp ax, SEM_TAREFAS		    ;; Sem tarefa, não trocar
	
	je CONSOLE_alterar_display_ativo_sem_tarefa ;; Sem tarefa
	
	mov bx, ax					;; salvar o ID da tarefa em BX
	int 99h						;; AX = status da tarefa
	cmp ax, 0FFFFh				;; A tarefa está presente no escalonador?
	
	je CONSOLE_alterar_display_ativo_sem_tarefa	;; Não, então não fazer anda
	
	mov ax, bx					;; Restaurar o ID em AX
	int 96h						;; Display a ser utilizado
	
	mov al, 0					;; Foi trocado
	
	jmp CONSOLE_alterar_display_ativo_pronto

;;*****************************************************************************
	
CONSOLE_alterar_display_ativo_sem_tarefa:

	mov si, MENSAGEM_NAO_EXISTE_TAREFA
	int 97h
	
	mov al, 1					;; Não foi trocado
	
;;*****************************************************************************
	
CONSOLE_alterar_display_ativo_pronto:

	pop bx
	pop si
	
	ret
	
;;*****************************************************************************

;; Encontrar um slot para a criação de uma nova tarefa
;;
;;		CX - offset oda lista com o slot encontrado

CONSOLE_encontrar_slot_para_tarefa:

	push ax
	push bx
	push si
	
	mov si, ListaIDTarefas
	mov bx, 0					;; Armazenar offset
	
;;*****************************************************************************
	
CONSOLE_encontrar_slot_loop:

	mov ax, word [ds:si+bx]		;; AX = ID da tarefa
	
	cmp ax, SEM_TAREFAS				;; Se sem tarefas, o slot foi encontrado
	je CONSOLE_encontrar_slot_pronto

	int 99h						;; AX = status da tarefa
	
	cmp ax, 0FFFFh				;; A tarefa está presente no escalonador?
	je CONSOLE_encontrar_slot_pronto	;; Econtrado
	
	add bx, 2					;; Próximo slot na tabela
	
	jmp CONSOLE_encontrar_slot_loop

;;*****************************************************************************
	
CONSOLE_encontrar_slot_pronto:

	mov cx, bx					;; Offset na lista retornado em CX
	
	pop si
	pop bx
	pop ax
	
	ret
