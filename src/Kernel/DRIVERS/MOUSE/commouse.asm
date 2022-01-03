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

DriverdeMouseCarregado:	db 0
UltimoDadoMouse db 0, 0, 0		

DadoMouseAtual db 0, 0, 0		
DadoMouseAtualOffset dw 0		;; Requerimentos de interrupção

;;*****************************************************************************

;; Inicializar mouse

MOUSE_inicializar:

	pusha
	
	mov al, 0ADh						    ;; Desativar teclado agora
	call CONTROLADOR_PS2_enviar_comando		;; Desativar primeiro dispositivo PS/2
	
	mov al, 0A8h
	call CONTROLADOR_PS2_enviar_comando		;; Habilitar mouse
	
	call MOUSE_reinicio
	
	mov al, 20h
	
	call CONTROLADOR_PS2_enviar_comando		;; Enviar bye de status para mouse PS/2
	
	call CONTROLADOR_PS2_ler_dados		    ;; AL = Byte de status
	
	or al, 00000010b					    ;; Habilitar IRQ12
	and al, 11011111b				     	;; Zerar bit de desativar relógio do mouse
	push ax							    	;; salvar byte de estado modificado
	
	mov al, 60h
	
	call CONTROLADOR_PS2_enviar_comando		;; Guardar primeiro byte enviado
	
	pop ax							    	;; Restaurar estado modificado
	
	call CONTROLADOR_PS2_dados_enviados		;; Enviar estado modificado
	
	mov al, 0F4h
	
	call enviar_mouse						;; Iniciar geração de pacotes
	
	call CONTROLADOR_PS2_ler_dados		    ;; Ler ACK
	
	mov al, 0AEh						    ;; A inicialização do mouse está pronta
	
	call CONTROLADOR_PS2_enviar_comando		;; Habilitar teclado
	
	mov cx, 10
	
;;*****************************************************************************
	
MOUSE_inicializar_buffer_limpo:

	call CONTROLADOR_PS2_ler_dados
	
	dec cx
	
	jnz MOUSE_inicializar_buffer_limpo
	
	mov byte [DriverdeMouseCarregado], 1
	
	popa
	ret

;;*****************************************************************************

;; Esta interrupção responde a IRQ12, o número de IRQ de mouse PS/2.

;
MOUSE_manipulador_interrupcao:
	pushf
	pusha
	push ds							;; Salvar DS
	push es							;; salvar ES
	
	push cs
	pop ds							;; DS = CS
	push cs
	pop es							;; ES = CS
	
	call CONTROLADOR_PS2_ler_dados	;; AL = byte lido
	
	;; Armazenar o novo valor lido do Mouse
	
	mov word bx, [DadoMouseAtualOffset]
	
	mov byte [DadoMouseAtual + bx], al	; DadoMouseAtual[offset] = AL
	
	inc bx									;; offset++
	
	cmp bx, 3									
	jne MOUSE_manipulacao_interrupcao_computada	;; Se BX diferente de 3, não fazer nada
	
	
	
	mov si, DadoMouseAtual
	mov di, UltimoDadoMouse
	
	mov cx, 3			;; for i := 0 to 2

	cld
	rep movsb			;; 	UltimoDadoMouse[i] = DadoMouseAtual[i]
	
	;; Notificar quando houver mudança de estado
	
	mov byte bh, [UltimoDadoMouse + 0]	;; Preparar argumentos
	mov byte dh, [UltimoDadoMouse + 1]
	mov byte dl, [UltimoDadoMouse + 2]	
	
	int 8Bh								;; Invocar manipulador de alteração de estado
	
	mov bx, 0								;; Zerar o offset
	
;;*****************************************************************************
	
MOUSE_manipulacao_interrupcao_computada:

	;; BX contêm o novo Offset
	
	mov word [DadoMouseAtualOffset], bx	;; Armazenar o novo Offset

	;; Enviar EOI (End Of Interrupt) ao PIC
	;;
	;; Quando em modo real, os IRQs são:
	;; MASTER: IRQs 0 a 7, números de interrupção 08h a 0Fh
	;; SLAVE: IRQs 8 a 15, números de interrupção  70h a 77h
	;;
	;; Desde que PS/2 é IRQ 12, devemos enviar EOI para o PIC Slave
	
	mov al, 20h
	out 0A0h, al					;; Enviar EOI PIC Slave
	out 20h, al						;; Enviar EOI PIC Master
	
	pop es							;; Restaurar antigo ES
	pop ds							;; Restaurar antigo DS
	
	popa
	popf
	
	ret

;;*****************************************************************************
	
;; Restaurar os dados do último evento de mouse
;;
;; Saída:
;;
;;		BH - bit 7 - Y estouro
;;			 bit 6 - X estouro
;;			 bit 5 - Y bit de sinal
;;			 bit 4 - X bit de sinal
;;			 bit 3 - não usado
;;			 bit 2 - botão do mouse
;;			 bit 1 - botão direito
;;			 bit 0 - botão esquerdo
;;		DH - X movimento (delta X)
;;		DL - Y movimento (delta Y)

MOUSE_raw:

	push ds
	
	push cs
	pop ds							;; DS = CS
	
	mov byte bh, [UltimoDadoMouse + 0]	;; Preparar argumentos
	mov byte dh, [UltimoDadoMouse + 1]
	mov byte dl, [UltimoDadoMouse + 2]
	
	pop ds
	
	ret

;;*****************************************************************************	


CONTROLADOR_PS2_esperar_apos_dados:

	pusha
	mov cx, 1000							;; Tentará várias vezes
	
CONTROLADOR_PS2_esperar_apos_ler_loop:

	dec cx
	jz CONTROLADOR_PS2_esperar_apos_ler_pronto	;; Quando o tempo expirar, está pronto
	
	in al, 64h
	
	test al, 00000001b						;; Bit 0 se saiu do buffer
	
	jz CONTROLADOR_PS2_esperar_apos_ler_loop	;; Está cheio (dados presentes)
	
CONTROLADOR_PS2_esperar_apos_ler_pronto:

	popa
	
	ret

;;*****************************************************************************	


CONTROLADOR_PS2_esperar_apos_escrever:

	pusha
	mov cx, 1000							;; Tentará várias vezes
	
CONTROLADOR_PS2_esperar_apos_escrever_loop:

	dec cx
	jz CONTROLADOR_PS2_esperar_apos_escrever_pronto	;; Quando o tempo acabar, está pronto
	
	in al, 64h
	
	test al, 00000010b						       ;; Bit 0 está limpo se entrou no buffer
	
	jnz CONTROLADOR_PS2_esperar_apos_escrever_loop ;; Está limpo (pode ser gravado)
	
CONTROLADOR_PS2_esperar_apos_escrever_pronto:

	popa
	ret
	
;;*****************************************************************************

;; Enviar valor para o hardware do mouse
;;
;; Entrada:
;;
;;		AL - byte para enviar

enviar_mouse:

	pusha
	push ax				;; Salvar byte para a saída

	;; Dizer ao controlador PS/2 que os dados são do Mouse
	
	mov al, 0D4h					;; Devemos mandar D4 para selecionar o segundo
	
	call CONTROLADOR_PS2_enviar_comando	;; Dispositivo PS/2						
	
	pop ax					;; AL = byte para enviar
	
	call CONTROLADOR_PS2_dados_enviados
	
	popa
	
	ret
	
;;*****************************************************************************

;; Enviar comando ou byte de estado para o controlados
;;
;; Entrada:
;;
;;		AL - byte para enviar

CONTROLADOR_PS2_enviar_comando:

	pusha
	push ax				;; Salvar byte para enviar
	
	call CONTROLADOR_PS2_esperar_apos_escrever
	
	pop ax				;; AL = byte para enviar
	out 64h, al	    	;; Byte
	
	popa
	ret
	
;;*****************************************************************************

;; Enviar dado para o controlador PS/2
;;
;; Entrada:
;;
;;		AL - byte para enviar

CONTROLADOR_PS2_dados_enviados:

	pusha
	push ax				;; Salvar byte para enviar
	
	call CONTROLADOR_PS2_esperar_apos_escrever
	
	pop ax				;; AL = byte para enviar
	out 60h, al			;; Byte
	
	popa
	ret
	
;;*****************************************************************************

;; Receber valor do controlador PS/2
;;
;; Entrada:
;;
;;		AL - byte lido

CONTROLADOR_PS2_ler_dados:

	call CONTROLADOR_PS2_esperar_apos_dados		;; Byte de estado
	
	in al, 60h
	ret
	

;; Colocar o mouse em modo RESET, inicializando um teste automático, que
;; retorna 0xAA quando sucesso.	
;; Após o término, o mouse entra em estado STREAM.
;;

;;*****************************************************************************

MOUSE_reinicio:

	pusha
	
	mov al, 0FFh
	
	call enviar_mouse						;; Enviar comando de reinício
	
	call CONTROLADOR_PS2_ler_dados		    ;; ler ACK
	
	mov cx, 4*18		;; Tempo (aproximadamente 4 seconds)
						;; PCs antigos demoram 2 segundos para reiniciar o mouse
						
MOUSE_reiniciar_esperar_reset_ou_resposta:

	dec cx
	
	jz MOUSE_reiniciar_esperar_reset_leitura_teste_ok	;; Tempo vencido
	
	push cx
	mov cx, 1			;; 1 tick (18.2 ticks/segundo)
	
	int 85h				;; Causa Delay
	pop cx
	
	call CONTROLADOR_PS2_ler_dados
	
	cmp al, 0AAh		;; O mouse responde com isto após reinício
						
	jne MOUSE_reiniciar_esperar_reset_ou_resposta

;;*****************************************************************************
	
MOUSE_reiniciar_esperar_reset_leitura_teste_ok:
	
	call CONTROLADOR_PS2_ler_dados

;;*****************************************************************************
	
MOUSE_reiniciar_pronto:

	popa
	ret

;;*****************************************************************************

;; Saída:
;;
;;			AL = 1 se Driver carregado, 0 se não

MOUSE_obter_status_driver:
	push ds
	
	push cs
	pop ds			;; DS = CS
	
	mov al, byte [DriverdeMouseCarregado]
	
	pop ds
	ret
