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
;;
;;
;;                     Arquivo de Controle de Portas Seriais
;;
;;          Este arquivo contém funções importantes de Debug para a HAL
;;                                 
;;
;;
;;**************************************************************************************

interrupcaoHAL equ 69h ;; Chama a HAL para abertura da Porta Serial
SEGMENTO equ 32768

HAL_Serial: ;; Função inicio


    ;; call chamar_HAL ;; Chama a camada de Abstração de Hardware do PX-DOS, a solicitando
	                   ;; a abertura da porta serial. Posso fazer isso aqui, mas já fiz
					   ;; a HAL, deu trabalho, é mais seguro, mais fácil e a... é isso aí.


					   
    call SERIAL_iniciar_serial ;; Inicia a Porta Serial COM1
   
   
    mov si, msgInicio ;; Move para si o conteúdo da variável msgInicio, criada lá no final.
    

    call SERIAL_transferir ;; Chama o método para SERIAL_transferir a mensagem
	
	
	mov si, msgEspaco ;; A mesma coisa..
	
	
	call SERIAL_transferir

;;****************Separando as mensagens***********
	
	mov si, msgServicos
	
	call SERIAL_transferir
	
	mov si, msgEspaco ;; A mesma coisa..
	
	
	call SERIAL_transferir

;;****************Separando as mensagens***********

	
	mov si, msgPorta
	
	call SERIAL_transferir
	
	mov si, msgEspaco ;; A mesma coisa..
	
;;****************Separando as mensagens***********

	
	call SERIAL_transferir
	
	mov si, msgSobre
	
	
	call SERIAL_transferir
	
	mov si, msgEspaco
	
	
	call SERIAL_transferir

;;****************Separando as mensagens***********

	
	mov si, msgDebug
	
	call SERIAL_transferir
	
	mov si, msgEspaco
	
	
	call SERIAL_transferir
	
;;****************Separando as mensagens***********

	
	call obterProcessador ;; Chama um método que identifica o processador

	
	mov si, msgEspaco
	
	
	call SERIAL_transferir
	

;;****************Separando as mensagens***********
	
	call memoria ;; Chama um método para identificar quantos kbytes de RAM estão disponíveis
	             ;; Isso mesmo, Kbytes, visto que é um sistema DOS 16 Bits e só suporta,
				 ;; no máximo, 1 MB de RAM... É culpa do procesador...
	
	mov si, msgEspaco

;;****************Separando as mensagens***********
	
ret
			
;;************************************************************************
		

obterProcessador:

call BANDEIRA_Serial ;; Realiza a verificação e formatação do resultado 
                     ;; para o padrão serial
					 
call SERIAL_iniciar_serial

    mov si, .msgProcessador
	call SERIAL_transferir
	
call SERIAL_iniciar_serial
	
	mov si, produtoSerial
	call SERIAL_transferir

call SERIAL_iniciar_serial

	
	ret ;; Retorna ao método que o chamou

section .data
	
	.msgProcessador: db "Processador principal instalado atualmente: [",0
	
;;************************************************************************	

section .text

memoria:


call SERIAL_iniciar_serial

mov si, .msgMemoria

call SERIAL_transferir

;;****************Separando as mensagens***********

call SERIAL_iniciar_serial

mov ax, 0
int 12h  ;; Chama o BIOS para descobrir quanta memória está disponível

call paraString

mov [memoria], ax
mov si, [memoria]

call SERIAL_transferir

;;****************Separando as mensagens***********


call SERIAL_iniciar_serial

mov si, .msgKbytes
call SERIAL_transferir

;;****************Separando as mensagens***********

call SERIAL_iniciar_serial

mov si, msgEspaco
call SERIAL_transferir

;;****************Separando as mensagens***********

call SERIAL_iniciar_serial

mov si, msgEspaco
call SERIAL_transferir

ret ;; Retorna ao método que o chamou

;; Criando variáveis 
;; Variáveis com . são variáveis locais, com acesso apenas ao método em que foram
;; criadas.

section .data

.msgMemoria db 'Memoria RAM total instalada: ',0 
.tamanhoMemoria dw 29
.tamanhoTotal dw 3
.msgKbytes db ' Kbytes. ',0
.tamanhoKbytes dw 8
.memoria db 0

;;************************************************************************

section .text

chamar_HAL:

mov ah, 5h ;; Função de Portas Seriais
mov bh, 1 ;; COM1

int interrupcaoHAL

ret

;;************************************************************************	

section .data


    msgInicio db 'Camada de Abstracao do Everest(R) (HAL) versao 0.5.2. Copyright (C) 2016 Felipe Miguel Nery Lunkes. Todos os direitos reservados.',0
	
	msgServicos db 'Iniciando servicos de Debug via Porta Serial para o Everest(R)...',0
	
	msgPorta db 'Estabelecendo comunicacao com a Porta Serial COM1...',0
	
	msgSobre db 'Sucesso. A Porta Serial pode ser utilizada pelo sistema.',0
	
	msgDebug db 'Iniciando Debug da HAL pela Porta Serial COM1 aberta...',0
	
	msgEspaco db '                                                                                                                                      ',0


dispositivo: dw "COM1    ",0 ;; Especifica ao sistema que o driver usará a porta "COM1"
tipo: dw 7h

