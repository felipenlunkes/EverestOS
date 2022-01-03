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

;;*****************************************************************************
;;
;;                            Ponto de entrada do Kernel
;; 
;;	> Número do drive em AL
;;	> Pilha válida (SS e SP)
;;
;;*****************************************************************************

[BITS 16]

org 0

jmp EntradaKernel

cabecalhoEVO:

.assinatura db "EVO", 0

;;*****************************************************************************

;;*****************************************************************************
;;
;;    Variáveis, macros e definições importantes para a execução do Kernel
;;
;;*****************************************************************************
	
TABELA_DE_INTERRUPCOES equ 0000h ;; Localização da tabela de interrupções

ESPERA_PROMPT_USUARIO  equ 0 ;; Segundos para esperar comando do usuário

Nome_Arquivo_SHELL: db "SH      EVO", 0 ;; Shell padrão do sistema
												
		  
STRING_INICIALIZACAO: db 10,13
        db "                    Sistema Operacional Everest(R) 16 Bits",10,13,10,13
        db "                                 Versao 0.5.2",10,13,10,13
		db "                 Copyright (C) 2016 Felipe Miguel Nery Lunkes",10,13
		db "                         Todos os direitos reservados",10,13,0
                  
STRING_INTERRUPCAO: db "", 0 ;; Por enquanto, em branco
STRING_CONFIGURACAO: db "> Arquivo de configuracoes lido", 0
STRING_APP_INICIALIZACAO: db "", 0 ;; Por enquanto, em branco
STRING_TIMER: db "", 0 ;; Por enquanto, em branco
STRING_ALEATORIOS: db "", 0 ;; Por enquanto, em branco
STRING_ARENA: db "", 0 ;; Por enquanto, em branco
STRING_ESCALONADOR: db "", 0 ;; Por enquanto, em branco
STRING_DISPLAY:	db "", 0 ;; Por enquanto, em branco
STRING_MOUSE: db "", 0

;; STRING_CARREGANDO_MOUSE: db 13, "> Driver de Mouse PS/2 carregado: (IRQ12)  ", 0		
   STRING_CARREGANDO_MOUSE: db 13, "", 0 ;; Por enquanto, em branco	

STRING_CARREGANDO_MOUSE_PULAR:		db 13, "> Driver de Mouse PS/2 - [FALHA]         ", 0
					

STRING_FALHA_INICIALIZACAO: db 10,13,10,13
    db "> Falha ao iniciar o Sistema Operacional Everest(R)",10,13
	db "  Nao foi possivel localizar um Shell valido para o sistema.",10,13,10,13
    db "> Certifique-se que um Shell valido do Everest(R) esta presente neste disco",10,13
	db "  do sistema e tente novamente.",10,13
	db "> Verifique tambem se o arquivo 'EVEREST.CFG', no disco do sistema declara um",10,13
	db "  Shell valido para o Everest(R).",10,13,10,13
	db "> Nome do arquivo encontrado no arquivo de configuracoes: ",0
	
STRING_FALHA_INICIALIZACAO_2: db 10,13,10,13
    db "Pressione a combinacao CTRL+ALT+DEL para reiniciar o computador...",0

BoasVindas:	db 10,13,10,13,0	

EstadoDebug times 1 db 0

VERSAO equ 0
SUBVERSAO equ 5
REVISAO equ 2		

;;*****************************************************************************
			
EntradaKernel:

push cs
pop ds
	
	;; Configurar qual drive será utilizado
	
	call DISQUETE_definir_drive			;; Passa o código do drive presente em AL

	;; Definir os valores para o agendador, quando se inicia uma tarefa
	
	sti								
	cld									
	pushf								
	pop ax								

	call ESCALONADOR_definir_flags_iniciais	
	
	;; Calcula os segmentos de memória necessários para o Kernel
	
	mov ax, cs							;; AX = este segmento de memória
	add ax, 1000h
	
	call DISQUETE_definir_buffer_segmento ;; Este segmento + 1000h serão usados como
	                                      ;; buffer para operações de disco
	add ax, 1000h						  ;; Este segmento + 2000h serão
                                          ;; usados como alocação primária
										  
	call MEMORIA_definir_segmento_alocacao_primaria 
	
	call DEBUG_imprimir_linha
	
;;*****************************************************************************

KERNEL_iniciar_componentes:

	;; Agora os módulos do Kernel serão inicializados
	
	mov si, STRING_INICIALIZACAO
	call DEBUG_imprimir
	
	call KERNEL_iniciar_TIMER	
	call KERNEL_iniciar_ALEATORIOS
	call KERNEL_iniciar_INTERRUPCOES
	call KERNEL_iniciar_MEMORIA
	call KERNEL_iniciar_ESCALONADOR
	call KERNEL_iniciar_MOUSE
	call KERNEL_iniciar_DISPLAY
	call KERNEL_iniciar_HAL ;; Iniciar Camada de Abstração de Hardware (HAL)
	call KERNEL_ler_configuracao
	
	;; Agora o Shell será carregado e executado

;;*****************************************************************************
	
KERNEL_carregar_SHELL:

	;; mov si, STRING_APP_INICIALIZACAO
	;; call DEBUG_imprimir
	
	mov si, Nome_Arquivo_SHELL	;; Converter o nome para letra maiúscula,
	                                    ;; como manda o formato FAT12
	int 82h
	;; Pedir um segmento para o alocador de memória
	;; O aplicativo será alocado neste segmento
	
	int 91h				;; BX = segmento alocado
	
	push bx
	
	pop es				;; ES = segmento alocado
	mov di, 0			; ES:DI aponta para o segmento
	
	mov si, Nome_Arquivo_SHELL
	int 81h				;; Carregar arquivo para a memória
	
	cmp al, 0
	jne KERNEL_carregar_app_inicializacao_falha ;; Falha ao carregar e executar
	
;;*****************************************************************************
;;
;; Caso tudo tenha sido carregado da maneira apropriada...
;;
;;*****************************************************************************

	mov si, BoasVindas
	call DEBUG_imprimir_string				;; Exibe a mensagem de boas vindas

	;; Aqui, BX é o segmento alocado
	
	int 93h								;; Adicionar o aplicativo as tarefas
										;; AX = ID da aplicação (offset)
										
	call ESCALONADOR_exibir_id_para_tarefa ;; AX = exibe ID para tarefa específica
	call DISPLAY_inicializar_display_ativo
	jmp ESCALONADOR_iniciar				 ;; Inicia o agendador de tarefas
	

;;*****************************************************************************
;;
;; Agora o controle retornou ao Agendador
;;
;;*****************************************************************************	

KERNEL_carregar_app_inicializacao_falha:

	mov si, STRING_FALHA_INICIALIZACAO		;; Imprime primeira parte da mensagem
	call DEBUG_imprimir_string
	
	mov si, Nome_Arquivo_SHELL		;; Imprime o nome do arquivo
	mov cx, 8
	call DEBUG_imprimir_dump
	
	call DEBUG_imprimir_linha
	mov si, STRING_FALHA_INICIALIZACAO_2	;; Imprime a segunda parte da mensagem
	
	call DEBUG_imprimir_string
	
	cli		;; Halt
	hlt

;;*****************************************************************************
					
;;*****************************************************************************
;;
;; Subrotinas do Kernel
;;
;;*****************************************************************************

KERNEL_ler_configuracao:

	pusha
	
	;; mov si, STRING_CONFIGURACAO
	;; call DEBUG_imprimir
	
	call CONFIG_encontrar_nome_app_inicializacao ;; Carregar nome do arquivo
	
	popa
	ret

;;*****************************************************************************
	
KERNEL_iniciar_TIMER:

	pusha
	
	;; mov si, STRING_TIMER
	;; call DEBUG_imprimir
	
	mov al, 1Ch
	mov bx, KERNEL_interrupcao_timer_usuario
	call KERNEL_definir_interrupcao

	popa
	ret

;;*****************************************************************************
	
KERNEL_iniciar_DISPLAY:

	pusha
	
	;; mov si, STRING_DISPLAY
	;; call DEBUG_imprimir
	
	call DISPLAY_inicializar
	
	popa
	ret

;;*****************************************************************************
	
KERNEL_iniciar_HAL:

	pusha
	
	call HAL_INICIALIZAR
	
	popa
	ret

;;*****************************************************************************
	
KERNEL_iniciar_MEMORIA:

	pusha
	
	;; mov si, STRING_ARENA
	;; call DEBUG_imprimir
	
	call MEMORIA_inicializar
	
	popa
	ret

;;*****************************************************************************
	
KERNEL_iniciar_ESCALONADOR:

	pusha
	
	;; mov si, STRING_ESCALONADOR
	;; call DEBUG_imprimir
	
	call ESCALONADOR_inicializar
	
	popa
	ret

;;*****************************************************************************
	
KERNEL_iniciar_ALEATORIOS:
	
	pusha
	
	;; mov si, STRING_ALEATORIOS
	;; call DEBUG_imprimir
	
	call ALEATORIOS_inicializar
	
	popa
	ret
	
;;*****************************************************************************

KERNEL_iniciar_MOUSE:
	
	pusha
	
	mov si, STRING_MOUSE
	mov bh, 'n'							;; Minúsculo
	mov bl, 'N'							;; Maiúsculo
	
	mov dl, ESPERA_PROMPT_USUARIO	    ;; Segundos para aguardar
	
	;call UTILIDADE_contar_prompt_usuario	; AL = 1 se N pressionado
	;cmp al, 1
	
	;je KERNEL_mouse_pular			;; Não carregar Driver de Mouse PS/2
	
	
	;; mov si, STRING_CARREGANDO_MOUSE
	;; call DEBUG_imprimir
	
	call MOUSE_inicializar
	
	;; Esta interrupção recebe dados do mouse PS/2 vindos do manipulador IRQ12
	
	mov al, 8Bh										
	mov bx, KERNEL_mouse_interrupcao_alterar_status 
	call KERNEL_definir_interrupcao						
	
	;; Esta interrupção retorna dados do mouse PS/2 quando chamado explicitamente
	
	mov al, 8Ch								
	mov bx, KERNEL_mouse_interrupcao_manipulador_raw	
	call KERNEL_definir_interrupcao				
	
	;; Esta interrupção retorna coordenadas do mouse quando chamada
	
	mov al, 8Fh								
	mov bx, KERNEL_mouse_interrupcao_manipulador_coordenadas
	call KERNEL_definir_interrupcao				
	
	;; Esta interrupção inicializa o manipulador de Mouse
	
	mov al, 90h
	mov bx, KERNEL_mouse_interrupcao_manipulador_inicializar
	call KERNEL_definir_interrupcao
	
	;; Interrupção de Hardware do Kernel, via IRQ12, chamada pelo PIC
	
	mov al, 74h							
	mov bx, KERNEL_interrupcao_mouse	
	call KERNEL_definir_interrupcao
	
	popa
	ret

;;*****************************************************************************
	
KERNEL_mouse_pular:	

	;; mov si, STRING_CARREGANDO_MOUSE_PULAR
	;; call DEBUG_imprimir
	
	popa
	ret

;;*****************************************************************************
	
KERNEL_iniciar_INTERRUPCOES:
	
	pusha
	
	;; mov si, STRING_INTERRUPCAO
	;; call DEBUG_imprimir
	
	;; Interrupções de 60h a 71h: Interface Gráfica
	;; Interrupção 72h: Limpar tela, gerenciado pelo sistema
	
	mov al, 20h
	mov bx, KERNEL_interrupcao_agendador_sair_tarefa
	call KERNEL_definir_interrupcao
	
	mov al, 21h
	mov bx, KERNEL_interrupcao_habilitar_debug
	call KERNEL_definir_interrupcao
	
	mov al, 22h
	mov bx, KERNEL_interrupcao_desativar_debug
	call KERNEL_definir_interrupcao
	
	mov al, 23h
	mov bx, KERNEL_interrupcao_verificar_debug
	call KERNEL_definir_interrupcao
	
	mov al, 24h
	mov bx, KERNEL_interrupcao_iniciar_impressora
	call KERNEL_definir_interrupcao
	
	mov al, 25h
	mov bx, KERNEL_interrupcao_impressora_imprimir
	call KERNEL_definir_interrupcao
	
	mov al, 26h
	mov bx, KERNEL_interrupcao_teclado_ler
	call KERNEL_definir_interrupcao
	
	mov al, 27h
	mov bx, KERNEL_interrupcao_delay_seguro ;; Método mais eficiente
	call KERNEL_definir_interrupcao
	
	mov al, 37h
	mov bx, KERNEL_interrupcao_agendador_rendimento_tarefa
	call KERNEL_definir_interrupcao
	
	mov al, 60h
	mov bx, KERNEL_ativar_GUI
	call KERNEL_definir_interrupcao
	
	mov al, 61h
	mov bx, KERNEL_criar_GUI
	call KERNEL_definir_interrupcao
	
	mov al, 62h
	mov bx, KERNEL_adaptar_GUI
	call KERNEL_definir_interrupcao
	
	mov al, 63h
	mov bx, KERNEL_adaptar_pagina
	call KERNEL_definir_interrupcao
	
	mov al, 64h
	mov bx, KERNEL_atualizar_GUI
	call KERNEL_definir_interrupcao
	
	mov al, 65h
	mov bx, KERNEL_matar_GUI
	call KERNEL_definir_interrupcao
	
	mov al, 66h
	mov bx, KERNEL_dialogo_GUI
	call KERNEL_definir_interrupcao
	
	mov al, 67h
	mov bx, KERNEL_mostrar_cursor
	call KERNEL_definir_interrupcao
	
	mov al, 68h
	mov bx, KERNEL_esconder_cursor
	call KERNEL_definir_interrupcao
	
	mov al, 69h
	mov bx, KERNEL_limpar_linha
	call KERNEL_definir_interrupcao
	
	mov al, 70h
	mov bx, KERNEL_marcar_linha
	call KERNEL_definir_interrupcao
	
	mov al, 71h
	mov bx, KERNEL_colorir_linha
	call KERNEL_definir_interrupcao
	
	mov al, 72h
	mov bx, KERNEL_limpar_tela
	call KERNEL_definir_interrupcao
	
	mov al, 80h
	mov bx, KERNEL_interrupcao_imprimir_string
	call KERNEL_definir_interrupcao
	
	mov al, 81h
	mov bx, KERNEL_interrupcao_carregar_arquivo
	call KERNEL_definir_interrupcao

	mov al, 82h
	mov bx, KERNEL_interrupcao_string_para_maiusculo
	call KERNEL_definir_interrupcao

	mov al, 83h
	mov bx, KERNEL_interrupcao_limpar_buffer_teclado
	call KERNEL_definir_interrupcao

	mov al, 84h
	mov bx, KERNEL_interrupcao_obter_ticks
	call KERNEL_definir_interrupcao
	
	mov al, 85h
	mov bx, KERNEL_interrupcao_delay
	call KERNEL_definir_interrupcao
	
	mov al, 86h
	mov bx, KERNEL_obter_proximo_numero_aleatorio
	call KERNEL_definir_interrupcao

	mov al, 87h
	mov bx, KERNEL_interrupcao_carregar_diretorio
	call KERNEL_definir_interrupcao

	mov al, 88h
	mov bx, KERNEL_interrupcao_imprimir_dump
	call KERNEL_definir_interrupcao

	mov al, 89h
	mov bx, KERNEL_interrupcao_altofalante_tocar
	call KERNEL_definir_interrupcao
	
	mov al, 8Ah
	mov bx, KERNEL_interrupcao_altofalante_parar
	call KERNEL_definir_interrupcao
	
	mov al, 8Dh		;; Definida para estar sempre presente (mesmo quando Driver não carregado)
	mov bx, KERNEL_interrupcao_mouse_status_driver
	call KERNEL_definir_interrupcao
	
	mov al, 8Eh
	mov bx, KERNEL_interrupcao_imprimir_byte
	call KERNEL_definir_interrupcao

	mov al, 91h
	mov bx, KERNEL_interrupcao_alocar_memoria
	call KERNEL_definir_interrupcao
	
	mov al, 92h
	mov bx, KERNEL_interrupcao_limpar_memoria
	call KERNEL_definir_interrupcao

	mov al, 93h
	mov bx, KERNEL_interrupcao_agendador_adicionar_tarefa
	call KERNEL_definir_interrupcao
	
	mov al, 96h
	mov bx, KERNEL_interrupcao_ativar_display_virtual_tarefa
	call KERNEL_definir_interrupcao
	
	mov al, 97h
	mov bx, KERNEL_interrupcao_DISPLAY_imprimir_string
	call KERNEL_definir_interrupcao
	
	mov al, 98h
	mov bx, KERNEL_interrupcao_DISPLAY_imprimir_caractere
	call KERNEL_definir_interrupcao
	
	mov al, 99h
	mov bx, KERNEL_interrupcao_agendador_obter_status_tarefa
	call KERNEL_definir_interrupcao
	
	mov al, 9Ah
	mov bx, KERNEL_interrupcao_agendador_obter_id_tarefa
	call KERNEL_definir_interrupcao
	
	mov al, 9Bh
	mov bx, KERNEL_interrupcao_desligamento
	call KERNEL_definir_interrupcao
	
	mov al, 9Ch
	mov bx, KERNEL_interrupcao_imprimir_string_sem_display_virtual
	call KERNEL_definir_interrupcao
	
	mov al, 9Dh
	mov bx, KERNEL_interrupcao_serial_iniciar
	call KERNEL_definir_interrupcao
	
	mov al, 9Eh
	mov bx, KERNEL_interrupcao_serial_transferir
	call KERNEL_definir_interrupcao
	
	mov al, 9Fh
	mov bx, KERNEL_interrupcao_serial_receber
	call KERNEL_definir_interrupcao
	
	mov al, 0xA2
	mov bx, KERNEL_interrupcao_obter_processador
	call KERNEL_definir_interrupcao
	
	mov al, 0xA3
	mov bx, KERNEL_interrupcao_retornar_versao
	call KERNEL_definir_interrupcao
	
	mov al, 0xA4
	mov bx, KERNEL_interrupcao_para_string
	call KERNEL_definir_interrupcao
	
	popa
	ret
	
;;*****************************************************************************	

;; Entrada:
;;			Offset do manipulador de interrupção em BX
;;			Número da interrupção em AL

KERNEL_definir_interrupcao:

	pusha
	push ds
	
	mov ah, 0	
	shl ax, 2	;; AX = AL * 4  pata encontrar o valor
	mov si, ax	;; SI aponta para o início dos 4-byte na entrada da IVT
	
	mov ax, TABELA_DE_INTERRUPCOES
	mov ds, ax
	
	cli						;; Desabilita as interrupções
	
	mov word [ds:si], bx	;; Offset do manipulador
	mov word [ds:si+2], cs	;; Segmento do manipulador
	
	sti						;; Habilitar interrupções novamente
	
	pop ds
	popa
	
	ret

;;*****************************************************************************
	
;; Entrada:
;;		AL - Byte para imprimir

KERNEL_interrupcao_imprimir_byte:

	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call DISPLAY_vram_imprimir_byte
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************
	
;; Entrada:
;;
;;		DS:SI ponteiro para a String

KERNEL_interrupcao_imprimir_string:

	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	;; Escrever diretamente na memória de vídeo
	
	call DISPLAY_vram_exibir_string
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************
	
;; Entrada:
;;
;;		DS:SI ponteiro para a String
;;		Número de caracteres em CX

KERNEL_interrupcao_imprimir_dump:

	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call DISPLAY_vram_imprimir_dump
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************
	
;; Entrada:
;;
;;		DS:SI ponteiro para a String

KERNEL_interrupcao_string_para_maiusculo:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call STRING_para_maiusculo
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************

KERNEL_interrupcao_limpar_buffer_teclado:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call TECLADO_limpar_buffer
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************
	
;; ENTRADA
;;
;;		DS:SI - ponteiro para primeiro caractere na String

KERNEL_interrupcao_DISPLAY_imprimir_string:

	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call ESCALONADOR_obter_id_tarefa_atual	;; AX = ID da tarefa atual
	call ESCALONADOR_exibir_id_para_tarefa	;; AX = Exibir ID da tarefa atual
	call DISPLAY_embrulhar_saida_string
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
	
;;*****************************************************************************

;; Entrada:
;;
;;		DL - Caractere ASCII para imprimir

KERNEL_interrupcao_DISPLAY_imprimir_caractere:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call ESCALONADOR_obter_id_tarefa_atual	;; AX = ID da tarefa atual
	call ESCALONADOR_exibir_id_para_tarefa	;; AX = Exibir ID da tarefa atual
	call DISPLAY_embrulhar_saida_caractere
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
	
;;*****************************************************************************
	
;; Isto a seguir é registrado como interrupção de hardware, para permitir o
;; recebimento de eventos do Mouse PS/2 (IRQ12)

KERNEL_interrupcao_mouse:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call MOUSE_manipulador_interrupcao
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret	

;;*****************************************************************************

;; Este manipulador é chamado pela interrupção de hardware quando acumula muitos
;; bytes de status.	
;; Destina-se a ser substituído por um manipulador de interrupção do usuário sempre
;; que um usuário precisa de interagir com o mouse de um modo mais avançado, para
;; ter acesso aos dados brutos.

;; Entrada:
;;
;;		BH - bit 7 - Y estouro
;;			 bit 6 - X estouro
;;			 bit 5 - Y bit de sinal
;;			 bit 4 - X bit de sinal
;;			 bit 3 - sem uso e indeterminado
;;			 bit 2 - botão do meio
;;			 bit 1 - botão direito
;;			 bit 0 - botão esquerdo
;;		DH - X movimento (delta X)
;;		DL - Y movimento (delta Y)

KERNEL_mouse_interrupcao_alterar_status:

	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call MOUSE_estado_alterado_manipulador_raw
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
	
;;*****************************************************************************

;; Inicializa o manipulador de mouse, habilitando seu uso por programas.
	

;; Entrada:
;;
;;		BX - Largura da caixa delimitadora em que o cursor do mouse se moverá
;;		DX - Altura da caixa delimitadora em que o cursor do mouse se moverá

KERNEL_mouse_interrupcao_manipulador_inicializar:

	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call MOUSE_manipulador_inicializar
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
	
;;*****************************************************************************
	
KERNEL_interrupcao_timer_usuario:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call TIMER_chamar_de_volta
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
	
;;*****************************************************************************
	
KERNEL_interrupcao_serial_iniciar:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call SERIAL_iniciar_serial
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************

KERNEL_interrupcao_delay_seguro:

    pushf
	
	push ds
	push es
	push fs
	push gs
	
	call TIMER_delay_seguro
	
	pop gs
	pop fs
	pop es
	pop ds
	
	popf
	
	iret

;;*****************************************************************************
	
KERNEL_interrupcao_serial_transferir:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call SERIAL_transferir
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
	
;;*****************************************************************************
	
KERNEL_interrupcao_serial_receber:

;; Conteúdo armazenado em [recebido]
	
	pushf
	
	push ds
	push es
	push fs
	push gs
	
	call SERIAL_receber
	
	mov si, [recebido]
	
	pop gs
	pop fs
	pop es
	pop ds
	
	popf
	
	iret

;;*****************************************************************************
	
KERNEL_interrupcao_obter_processador:

pushf

push ds
push es
push fs
push gs

call BANDEIRA

mov si, prodmsg

pop gs
pop fs
pop es
pop ds

popf

iret

;;*****************************************************************************

;; Entrada:
;;
;;		AX - ID (offset) da tarefa a ter o display virtual ativado

KERNEL_interrupcao_ativar_display_virtual_tarefa:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs

	call ESCALONADOR_exibir_id_para_tarefa ;; AX = Exibir o ID da tarefa atual
	call DISPLAY_ativar				     ;; Tornar display ativo

	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

	
;;*****************************************************************************

;; Entrada:
;;
;;			DS:SI aponta para o buffer de 11-byte contendo o nome de arquivo no
;;          formato FAT12
;;			ES:DI aponta para o local aonde o arquivo será carregado
;;
;; Saída:
;;
;;			Status da operação em AL (0 = sucesso, 1 = não encontrado)
;;
;; Interrupção não reentrante

KERNEL_interrupcao_carregar_arquivo:

	pushf
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
	
	call DISQUETE_carregar_arquivo_em_ponto_de_entrada
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	
	iret

;;*****************************************************************************
	
;; Saída:
;;
;;		BH - bit 7 - Y estouro
;;			 bit 6 - X estouro
;;			 bit 5 - Y bit de sinal
;;			 bit 4 - X bit de sinal
;;			 bit 3 - sempre 1
;;			 bit 2 - botão do meio
;;			 bit 1 - botão direito
;;			 bit 0 - botão esquerdo
;;		DH - X movimento (delta X)
;;		DL - Y movimento (delta Y)

KERNEL_mouse_interrupcao_manipulador_raw:
	
	pushf
	push ax
	push cx
	push si
	push di
	
	push ds
	push es
	push fs
	push gs
	push bp
	
	call MOUSE_raw
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop cx
	pop ax
	popf
	
	iret

;;*****************************************************************************
	
;; Retorna a localização atual do mouse (em coordenadas) e o estado dos botões
;;
;; Saída:
;;
;;		AL - bits 3 a 7 - sem uso
;;			 bit 2 - estado do botão do meio
;;			 bit 1 - estado do botão direito
;;			 bit 0 - estado do botão esquerdo
;;		BX - X posição em coordenadas
;;		DX - Y posição em coordenadas

KERNEL_mouse_interrupcao_manipulador_coordenadas:

	pushf
	push cx
	push si
	push di
	
	push ds
	push es
	push fs
	push gs
	push bp
	
	call MOUSE_manipulador
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop cx
	popf
	
	iret

;;*****************************************************************************
	
KERNEL_interrupcao_retornar_versao:

	pushf
	
	push si
	push di
	
	push ds
	push es
	push fs
	push gs
	push bp
	
	mov ax, VERSAO
	mov bx, SUBVERSAO
	mov cx, REVISAO
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	
	popf
	
	iret
		
;;*****************************************************************************

;; Invocado quando a tarefa atual deseja enviar o controle a outra	


KERNEL_interrupcao_agendador_rendimento_tarefa:

	jmp ESCALONADOR_rendimento_tarefa
	
;;*****************************************************************************

KERNEL_interrupcao_agendador_sair_tarefa:

	push ax
	push bx
	
	;; Primeiro, devemos ir ao display virtual da tarefa atual
	
	call ESCALONADOR_obter_id_tarefa_atual	;; AX = ID da tarefa corrente (saindo)
	call ESCALONADOR_exibir_id_para_tarefa	;; AX = Exibe ID da tarefa existente
	
	mov bx, ax								;; BX = Exibe ID d tarefa existente
	
	call DISPLAY_obter_id_display_ativo		;; AX = ID do display ativo
	
	cmp bx, ax								;; Existe ID de display ativo?
	
	jne KERNEL_agendar_saida_tarefa	        ;; não
											;; sim, alterando para display de tarefa filha
	call ESCALONADOR_obter_id_tarefa_atual	;; AX = ID da tarefa atual
	call ESCALONADOR_obter_id_tarefa_filha		;; AX = ID da tarefa filha
	call ESCALONADOR_exibir_id_para_tarefa	;; AX = Exibe ID da tarefa filha
	call DISPLAY_ativar					    ;; Alterar para display com ID presente em AX
	
	;; Realizar a saída

;;*****************************************************************************
	
KERNEL_agendar_saida_tarefa:

	pop bx
	pop ax
	
	jmp ESCALONADOR_matar_tarefa

;;*****************************************************************************

;; Saída:
;;
;;			AL = 1 quando Driver carregado, 0 caso não

KERNEL_interrupcao_mouse_status_driver:
	
	pushf
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
	
	call MOUSE_obter_status_driver
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	
	iret

;;*****************************************************************************
;;
;; Tem por função imprimir dados na tela sem utilizar o driver de display virtual
;;
	
KERNEL_interrupcao_imprimir_string_sem_display_virtual:

    pushf
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
	
	call DISPLAY_imprimir_sem_display_virtual
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	
	iret

	
;;*****************************************************************************
	
;; Saída:
;;
;;			Contagem atual em AX

KERNEL_interrupcao_obter_ticks:

	pushf
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
	
	call TIMER_obter_contagem_atual
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	
	iret

;;*****************************************************************************
	
KERNEL_interrupcao_teclado_ler:

    pushf
	push bx
	push cx
	push dx
	
	
	push ds
	push es
	push fs
	push gs
	push bp
	
	call TECLADO_ler
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	
	pop dx
	pop cx
	pop bx
	popf
	
	iret

;;*****************************************************************************

;; Entrada:
;;
;;		Número de contagem do sistema para esperar em CX

KERNEL_interrupcao_delay:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call TIMER_delay
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
	
;;*****************************************************************************

;; Entrada:
;;
;;		Nada

KERNEL_ativar_GUI:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call ativar_interface
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************
	
KERNEL_interrupcao_impressora_imprimir:

    pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call IMPRESSORA_imprimir
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
	
;;*****************************************************************************
	
KERNEL_interrupcao_iniciar_impressora:

    pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call IMPRESSORA_iniciar
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
	
;;*****************************************************************************

KERNEL_criar_GUI:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call criar_interface
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************

KERNEL_adaptar_GUI:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call adaptar_interface
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
		
;;*****************************************************************************

KERNEL_adaptar_pagina:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call adaptar_pagina
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************

KERNEL_atualizar_GUI:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call atualizar_interface
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************

KERNEL_matar_GUI:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call matar_interface
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************

KERNEL_dialogo_GUI:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call criar_dialogo
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************

KERNEL_mostrar_cursor:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call mostrar_cursor
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************

KERNEL_esconder_cursor:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call esconder_cursor
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
		
;;*****************************************************************************

KERNEL_limpar_linha:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call limpar_linha
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
	
;;*****************************************************************************

KERNEL_marcar_linha:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call marcar_linha
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************

KERNEL_limpar_tela:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call clrscr
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************

KERNEL_colorir_linha:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call colorir_linha
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret
	
	
;;*****************************************************************************

;; Desalocar um segmento
;;
;; Entrada:
;;
;;		BX - segmento para desalocar

KERNEL_interrupcao_limpar_memoria:

	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call MEMORIA_limpar_segmento
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret	
	
;;*****************************************************************************

;; Tocar um som
;;
;; Entrada:
;;
;;			Número da frequência, em AX

KERNEL_interrupcao_altofalante_tocar:

	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call SOM_tocar_nota
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************
	
;; Parar som após execução

KERNEL_interrupcao_altofalante_parar:
	
	pushf
	pusha
	push ds
	push es
	push fs
	push gs
	
	call SOM_parar
	
	pop gs
	pop fs
	pop es
	pop ds
	popa
	popf
	iret

;;*****************************************************************************

;; Especificar segmento a ser executado pelo agendador
;;
;; Entrada:
;;			BX - segmento contendo o arquivo a ser executado como tarefa
;;
;; Saída:
;;
;;			AX - ID (offset) para a recém criada tarefa

KERNEL_interrupcao_agendador_adicionar_tarefa:

	pushf
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
	
	call DISPLAY_alocar	;; Alocar display virtual para a nova tarefa
					    ;; AX = ID do display virtual					
	mov dx, ax			;; ESCALONADOR_adicionar_tarefa espera o ID do display em DX

	call ESCALONADOR_adicionar_tarefa
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	
	iret
	
;;*****************************************************************************
	
;; Entrada:
;;
;			ES:DI apontando para onde o diretório deve ser carregado
;;
;; Saída:
;;
;; Número de entradas no diretório raiz em AX (FAT12, 32 bytes)

KERNEL_interrupcao_carregar_diretorio:
	
	pushf
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
	
	call DISQUETE_carregar_root_em_ponto_de_entrada
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	
	iret

;;*****************************************************************************
	
KERNEL_interrupcao_para_string:

pushf

push cx
push dx
push di
push si

push ds
push es
push fs
push gs
push bp

call UTILIDADE_para_string

pop bp
pop gs
pop fs
pop es
pop ds

pop si
pop di
pop dx
pop cx

popf

iret

;;*****************************************************************************
	
;; Alocar 64 kBytes para o uso
;;
;; Saída:
;;
;;		AX - 0 quando sucesso
;;		BX - número do segmento alocado, em caso de sucesso

KERNEL_interrupcao_alocar_memoria:

	pushf
	push cx
	push dx
	push si
	push di
	
	push ds
	push es
	push fs
	push gs
	push bp
	
	call MEMORIA_alocar_segmento
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	popf
	
	iret
	
;;*****************************************************************************
	
;; Saída:
;;
;; Próximo número aleatório (randômico) em AX

KERNEL_obter_proximo_numero_aleatorio:
	
	pushf
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
	
	call ALEATORIO_obter_proximo
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf	
	iret

;;*****************************************************************************	
	
;; Saída:
;;
;;			AX - ID (offset) da tarefa atual

KERNEL_interrupcao_agendador_obter_id_tarefa:

	pushf
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
	
	call ESCALONADOR_obter_id_tarefa_atual
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	iret

;;*****************************************************************************

;; Saída:
;;
;;			AX - códigos de erro:
;;				0 = falha de instalação
;;				1 = falha na conexão de modo real
;;				2 = Driver APM versão 1.2 não suportado
;;				3 = falha ao mudar status para "off"

KERNEL_interrupcao_desligamento:

	pushf
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
	
	call KERNEL_APM_desligar
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	iret
	
;;*****************************************************************************

;; Entrada:
;;
;;			AX - ID da tarefa (offset)
;;
;; Saída:
;;
;;			AX - status:
;;				0FFFFh - não presente

KERNEL_interrupcao_agendador_obter_status_tarefa:

	pushf
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
	
	call ESCALONADOR_obter_status_tarefa
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	
	iret
	
;;*****************************************************************************	

KERNEL_interrupcao_habilitar_debug:

    pushf
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
	
	mov ax, 1
	mov [EstadoDebug], ax
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	
	iret
	
;;*****************************************************************************	

KERNEL_interrupcao_desativar_debug:

    pushf
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
	
	mov ax, 0
	mov [EstadoDebug], ax
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	
	iret

;;*****************************************************************************	

KERNEL_interrupcao_verificar_debug:

    pushf
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
	
	mov ax, [EstadoDebug]
	
	pop bp
	pop gs
	pop fs
	pop es
	pop ds
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	
	iret
;;*****************************************************************************	

;;*****************************************************************************
;;
;; Drivers, serviços e utilidades
;;
;;*****************************************************************************

%include "INTERFACE\uniao.asm"

%include "DRIVERS\VIDEO\videoh.asm"	;; Driver CRT (baixo nível)
%include "DRIVERS\VIDEO\videov.asm"	;; Driver de Display virtual (baixo nível)
%include "DRIVERS\VIDEO\videom.asm"	;; Interface de Display virtual (alto nível)
%include "DRIVERS\MOUSE\commouse.asm"	;; Rotinas de comunicação PS/2 (baixo nível)
%include "DRIVERS\MOUSE\intmouse.asm"	;; Interface de comunicação (alto nível)
%include "DRIVERS\SERIAL\Arena.asm"     ;; Driver de comunicação serial
%include "DRIVERS\IMPRESSORA\impressora.asm" ;; Driver de impressora
%include "DRIVERS\TECLADO\teclado.asm" ;; Driver e rotinas de teclado
%include "DRIVERS\ENERGIA\energia.asm" ;; Driver de suporte APM

%include "HAL\uniao.asm" ;; Camada de Abstração de Hardware (HAL)

%include "fat.asm" ;; Sistema de Arquivos FAT12 e rotinas para disquete
%include "debug.asm"
%include "string.asm"
%include "config.asm"
%include "timer.asm"
%include "som.asm"
%include "memoria.asm"
%include "tarefas.asm"
%include "util.asm"



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Buffer de dados
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KERNEL_buffer_de_dados:			;; Restante da área de dados utilizada
								;; pelo Kernel
