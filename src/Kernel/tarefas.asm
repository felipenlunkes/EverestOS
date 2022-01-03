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

;; Formato de controle de tarefas (64 bytes por tarefa)
;;
;; Bytes:
;;	  0-1 CS 
;;	  2-3 IP 
;;	  4-5 FLAGS 
;;	  6-7 BP
;;	  8-9 GS
;;	10-11 FS
;;	12-13 ES
;;	14-15 DS
;;	16-17 DI
;;	18-19 SI
;;	20-21 DX
;;	22-23 CX
;;	24-25 BX
;;	26-27 AX
;;	28-29 SP
;;	30-31 SS
;;	32-33 ID do display virtual
;;	34-35 ID de tarefa filha
;;	36-63 não usado

TAREFA_tamanho_entrada_de_estado equ 64	;; Em bytes

MaximodeTarefas equ 10

TAREFAS_TAMANHO_TABELA equ MaximodeTarefas*TAREFA_tamanho_entrada_de_estado	;; Em bytes

SEM_TAREFA equ 0FFFFh				;; Usado para marcar tarefa não usada

TAREFA_SP_INICIAL equ 0FFFFh ;; Valor de SP inicial para a tarefa

TAREFA_IP_INICIAL equ 0000h	 ;; Valor do registrador IP inicial para a tarefa

TAREFA_FLAGS_INICIAL: dw 0FFh   ;; Valor de Flags inicial para a tarefa

FlagsAtuais: dw 0				;; Usado para salvar Flags

tabelaEstadoTarefas: times TAREFAS_TAMANHO_TABELA db 0

OffsetTarefaAtual: dw 0			;; Offset dentro da tabela

MododeVideoInicial: db 99

STRING_Sem_Tarefa: db 13, 10, "O Escalonador nao pode executar esta tarefa.", 0

STRING_Impossivel_Adicionar_Tarefa: db 13, 10, "Impossivel adicionar tarefa...", 0

;;*****************************************************************************

;; Iniciar o Escalonador

ESCALONADOR_inicializar:
	
	pushf
	pusha
	push ds
	push es
	
	push cs
	pop es
	push cs
	pop ds
	
	;; Salvar modo de vídeo atual
	
	mov ah, 0Fh						;; Retorna o modo de vídeo atual
	int 10h							;; Está em AL
	mov byte [MododeVideoInicial], al	;; Salva isto
	
	;; Limpa toda a tabela de tarefas
	
	mov cx, TAREFAS_TAMANHO_TABELA / 2 ;; Salva duas words por vez
	mov di, tabelaEstadoTarefas
	mov ax, SEM_TAREFA				
	cld
	rep stosw
	
	pop es
	pop ds
	popa
	popf
	ret

;;*****************************************************************************

;; Entrada:
;;
;;		AX - Valor inicial para o registrador FLAGS para a nova tarefa

ESCALONADOR_definir_flags_iniciais:

	pusha
	push ds
	
	push cs
	pop ds
	
	mov word [TAREFA_IP_INICIAL], ax
	
	pop ds
	popa
	ret
	
;;*****************************************************************************

;; Iniciar o escalonador

ESCALONADOR_iniciar:

	push cs
	pop ds
	
	call ESCALONADOR_encontrar_proxima_tarefa		;; AX = Offset da primeira tarefa
	jc ESCALONADOR_inicia_esfomeado			;; Se carry definido, não existem tarefas
	
	mov word [OffsetTarefaAtual], ax
	jmp ESCALONADOR_executar_tarefa_atual

;;*****************************************************************************

ESCALONADOR_inicia_esfomeado:

	push cs
	pop ds
	
	mov ah, 0Fh				
	int 10h					
	
	cmp al, byte [MododeVideoInicial]
	je ESCALONADOR_inicia_esfomeado_imprimir ;; O modo de vídeo não foi alterado
	
	mov ah, 0						 ;; Reverter modo de vídeo para o inicial
	mov al, byte [MododeVideoInicial]
	int 10h
	
ESCALONADOR_inicia_esfomeado_imprimir:	

	mov si, STRING_Sem_Tarefa
	int 80h
	
	cli
	hlt							;; Suspender CPU

;;*****************************************************************************

;; Invocado quando se quer permitir que o Agendador passe o controle para outra
;; tarefa	

ESCALONADOR_rendimento_tarefa:
	
	;; Primeiro salvando os detalhes da tarefa
	
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push ds
	push es
	push fs
	push gs
	push bp
	
	push cs
	pop ds
	
	mov si, tabelaEstadoTarefas
	add si, word [OffsetTarefaAtual]	;; SI agora aponta para o início
	
	pop word [ds:si+6]				;; BP
	pop word [ds:si+8]				;; GS
	pop word [ds:si+10]				;; FS
	pop word [ds:si+12]				;; ES
	pop word [ds:si+14]				;; DS
	pop word [ds:si+16]				;; DI
	pop word [ds:si+18]				;; SI
	pop word [ds:si+20]				;; DX
	pop word [ds:si+22]				;; CX
	pop word [ds:si+24]				;; BX
	pop word [ds:si+26]				;; AX
	
	pop word [ds:si+2]				;; IP
	pop word [ds:si+0]				;; CS
	pop word [ds:si+4]				;; FLAGS
	
	mov word [ds:si+28], sp				;; SP
	mov word [ds:si+30], ss				;; SS
	

	call ESCALONADOR_encontrar_proxima_tarefa ;; AX = offset da primeira tarefa
	jc ESCALONADOR_inicia_esfomeado			;; Se carry definido, não existem tarefas
	
	mov word [OffsetTarefaAtual], ax	;; Salvar nova tarefa atual
	
	jmp ESCALONADOR_executar_tarefa_atual		;; Executar tarefa atual
	
;;*****************************************************************************

;; Adiciona uma tarefa a um segmento de memória. Este já está pronto para
;; ser executado pelo Escalonador

;; Entrada:
;;
;;		BX - segmento contendo o app carregado para ser executado
;;		DX - ID do display virtual para o app
;;
;; Saída:
;;
;;		AX - ID da tarefa (offset)

ESCALONADOR_adicionar_tarefa:

	push si
	push ds
	
	push cs
	pop ds
	
	call ESCALONADOR_encontrar_slot_vazio	;; AX = Byte de offset da tabela
	push ax							;; Salvar ID da tarefa
	mov si, tabelaEstadoTarefas
	add si, ax						;; SI aponta para o início da tarefa
	
	mov word [ds:si+0], bx			;; CS (em BX)
	mov word [ds:si+2], TAREFA_IP_INICIAL		;; IP
	
	mov ax, word [TAREFA_FLAGS_INICIAL]
	mov word [ds:si+4], ax			;; FLAGS
		
	mov word [ds:si+6], TAREFA_SP_INICIAL		;; BP
	mov word [ds:si+8], bx			;; GS
	mov word [ds:si+10], bx			;; FS
	mov word [ds:si+12], bx			;; ES
	mov word [ds:si+14], bx			;; DS
	mov word [ds:si+16], 0			;; DI
	mov word [ds:si+18], 0			;; SI
	mov word [ds:si+20], 0			;; DX
	mov word [ds:si+22], 0			;; CX
	mov word [ds:si+24], 0			;; BX
	mov word [ds:si+26], 0			;; AX
	
	mov word [ds:si+28], TAREFA_SP_INICIAL	;; SP
	mov word [ds:si+30], bx			;; SS
	
	mov word [ds:si+32], dx			;; ID do display virtual
	
	mov ax, word [OffsetTarefaAtual]
	mov word [ds:si+34], ax			;; ID da tarefa filha (atual é a mãe)
	
	pop ax							;; Restaurar o ID para retornar
	pop ds
	pop si
	ret

;;*****************************************************************************
	
ESCALONADOR_executar_tarefa_atual:
	push cs
	pop ds
	
	mov si, tabelaEstadoTarefas
	add si, word [OffsetTarefaAtual]	;; SI apontando para o início do Slot

	;; Alterando a pilha para a tarefa a que se quer ir
	
	pushf
	pop ax
	mov word [FlagsAtuais], ax	;; Salvar registradores antigos
	
	cli						
	mov ax, word [ds:si+28]
	mov sp, ax
	mov ax, word [ds:si+30]
	mov ss, ax				

	mov ax, word [FlagsAtuais]
	push ax
	popf					;; Restaurar registradores
	
	;; Isto se restaurado automaticamente pelo iret
	
	push word [ds:si+4]		;; FLAGS
	push word [ds:si+0]		;; CS
	push word [ds:si+2]		;; IP
	
	;; Isto será um a um. DS e SI podem ser destruídos
	
	push word [ds:si+26]
	push word [ds:si+24]
	push word [ds:si+22]
	push word [ds:si+20]
	push word [ds:si+18]
	push word [ds:si+16]
	push word [ds:si+14]
	push word [ds:si+12]
	push word [ds:si+10]
	push word [ds:si+8]
	push word [ds:si+6]
	
	;; Restaurar registradores e preparar para iniciar tarefa
	
	pop bp					;; BP
	pop gs					;; GS
	pop fs					;; FS
	pop es					;; ES
	pop ds					;; DS
	pop di					;; DI
	pop si					;; SI
	pop dx					;; DX
	pop cx					;; CX
	pop bx					;; BX
	pop ax					;; AX

	iret					;; Pop FLAGS, IP, CS, imitando um retorno de interrupção
	
;;*****************************************************************************

;; Finalizar uma tarefa
;;
;;			pushf
;;			push cs
;;			push ip
ESCALONADOR_matar_tarefa:

;; Primeiro, limpar a pilha ou que foi jogado nela.

	
	pop ax				;; IP
	pop bx				;; CS
	pop ax				;; FLAGS
	
	push cs
	pop ds
	
	mov si, tabelaEstadoTarefas
	add si, word [OffsetTarefaAtual]	;; SI aponta para o início so Slot
	
	mov word [ds:si], SEM_TAREFA		;; Marque o Slot usado como livre
	
	;; Aqui, BX contêm o segmento onde a tarefa está carregada
	
	call MEMORIA_limpar_segmento			;; Limpar a memória usada
	
	mov ax, word [ds:si+32]
	call DISPLAY_liberar					;; Limpar a área de trabalho virtual (display virtual)
	
	call ESCALONADOR_encontrar_proxima_tarefa		;; AX = offset da próxima tarefa
	
	jc ESCALONADOR_inicia_esfomeado			;; Se carry definido, nenhuma tarefa
	
	mov word [OffsetTarefaAtual], ax	;; Definir tarefa como atual
	
	jmp ESCALONADOR_executar_tarefa_atual		;; Passar o controle para ela
	
;;*****************************************************************************

;; Saída:
;;
;; AX - offset do primeiro Slot livre da da tabela de tarefas

ESCALONADOR_encontrar_slot_vazio:

	push bx
	push si
	push ds
	
	push cs
	pop ds
	
	;; Encontrar primeiro Slot livre
	
	mov si, tabelaEstadoTarefas
	mov bx, 0				;; Offset da tabela que está sendo testado
	
ESCALONADOR_encontrar_slot_vazio_loop:

	cmp word [ds:si+bx], SEM_TAREFA			;; Este está limpo?
											;; Os primeiros bytes são SEM_TAREFA?
	je ESCALONADOR_encontrar_slot_vazio_encontrado		;; Sim
	
	add bx, TAREFA_tamanho_entrada_de_estado			;; Próximo Slot
	cmp bx, TAREFAS_TAMANHO_TABELA			;; Perto do fim?
	
	jb ESCALONADOR_encontrar_slot_vazio_loop		;; Não
	
ESCALONADOR_encontrar_slot_vazio_cheio:				;; Sim

	mov si, STRING_Impossivel_Adicionar_Tarefa
	int 80h
	
	cli
	hlt		
	;; halt CPU
	
ESCALONADOR_encontrar_slot_vazio_encontrado:

	mov ax, bx								;; Retornar resultados em AX
	
ESCALONADOR_encontrar_slot_vazio_pronto:

	pop ds
	pop si
	pop bx
	ret

;;*****************************************************************************

;; Retornar o offset da próxima tarefa, assumindo que uma exista
;;
;; Saída:
;;		AX - offset na tabela para a próxima tarefa
;;		Carry - definido quando não existem outras tarefas.

ESCALONADOR_encontrar_proxima_tarefa:
 
	push bx
	push si
	push ds
	
	push cs
	pop ds
	
	mov si, tabelaEstadoTarefas
	mov bx, word [OffsetTarefaAtual]		;; Se inicia logo adiante
	add bx, TAREFA_tamanho_entrada_de_estado			;; A atual
	
	cmp bx, TAREFAS_TAMANHO_TABELA			;; Próximo do fim?
	jb ESCALONADOR_encontrar_proxima_tarefa_loop		;; Não, iniciando agora...
	
	mov bx, 0	;; Loop para começar	
	
ESCALONADOR_encontrar_proxima_tarefa_loop:

	cmp word [ds:si+bx], SEM_TAREFA			;; O Slot contêm uma tarefa?
	jne ESCALONADOR_encontrar_proxima_tarefa_encontrada		;; Sim
	
	cmp bx, word [OffsetTarefaAtual]		;; Se tivermos que voltar a tarefa atual
	je ESCALONADOR_encontrar_proxima_tarefa_faminta		;; significa quem nenhuma está disponível
	
	add bx, TAREFA_tamanho_entrada_de_estado			;; Não, próximo Slot
	cmp bx, TAREFAS_TAMANHO_TABELA			;; próximo do fim?
	jb ESCALONADOR_encontrar_proxima_tarefa_loop		;; Não
	
ESCALONADOR_encontrar_proxima_tarefa_retornar:		;; Sim

	mov bx, 0								;; Voltar ao começo da tabela de tarefas
											
	jmp ESCALONADOR_encontrar_proxima_tarefa_loop		;; Tentar novamente
	
ESCALONADOR_encontrar_proxima_tarefa_faminta:

	stc										;; Definir carry para sinalizar falha
	
	jmp ESCALONADOR_encontrar_proxima_tarefa_pronto
	
ESCALONADOR_encontrar_proxima_tarefa_encontrada:

	mov ax, bx								;; Retornar resultado em AX
	clc										;; Limpar carry para indicar sucesso
	
ESCALONADOR_encontrar_proxima_tarefa_pronto:

	pop ds
	pop si
	pop bx
	ret

;;*****************************************************************************

;; Retornar o ID do display virtual da tarefa
;;
;; Entrada:
;;
;;		AX - ID (offset) da tarefa
;;
;; Saída:
;;
;;		AX - ID do display virtual da tarefa

ESCALONADOR_exibir_id_para_tarefa:

	push ds
	push si
	
	push cs
	pop ds
	
	mov si, tabelaEstadoTarefas
	add si, ax
	mov ax, word [ds:si+32]				;; AX = ID do display virtual da tarefa
	
	pop si
	pop ds
	ret

;;*****************************************************************************

;; Retornar o ID da atrefa atual
;;
;; saída:
;;
;;		AX - ID (offset) da tarefa atual

ESCALONADOR_obter_id_tarefa_atual:

	push ds
	
	push cs
	pop ds
	
	mov ax, word [OffsetTarefaAtual]
	
	pop ds
	ret

;;*****************************************************************************

;; Obter o ID da tarefa mãe
;;
;; Entrada:
;;
;;		AX - ID da tarefa (offset)
;;
;; Saída:
;;
;;		AX - ID da tarefa mãe (offset)

ESCALONADOR_obter_id_tarefa_filha:

	push ds
	push si
	
	push cs
	pop ds
	
	mov si, tabelaEstadoTarefas
	add si, ax
	mov ax, word [ds:si+34]				;; ID da tarefa mãe
	
	pop si
	pop ds
	ret

;;*****************************************************************************

;; Obtêr status de determinada tarefa
;;
;; Entrada:
;;
;;		AX - ID da tarefa
;;
;; Saída:
;;
;;		AX - status:
;;
;;			0FFFFh - não presente


ESCALONADOR_obter_status_tarefa:

	push ds
	push si
	
	push cs
	pop ds
	
	mov si, tabelaEstadoTarefas
	add si, ax
	mov ax, word [ds:si+0]				;; AX = status
	
	pop si
	pop ds
	ret

