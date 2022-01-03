;;*****************************************************************************
;;
;; #$@$%&*%$#@#!$@@#@#$%!$#!$!#%#
;; !#@$@$EVEREST@#!$%#!�%#!$#!�#$
;; $#%@$#!@#$#!$%#W@�#!!@#$@�!@$�          Sistema Operacional Everest�
;; #@%�$@$#!@&%#$@�#@&%$@%�$@&�$@
;; #@$@%�#!$#                        Copyright � 2016 Felipe Miguel Nery Lunkes
;; #EVEREST#$                               Todos os direitos reservados
;; #@#$!@$@#!
;; #@$@!#!@#@
;; #!@$@!$@!#
;; @$!@!@#$$$
;; @!@$%@#$@$@#@@$#!@#!#!#!!@#
;; @!#@!$#$@#@$@##%#%#%%%#!@#!
;; #$@$@$@EVEREST$%#!#$!@#!!##         |    Sistema Operacional Everest� 
;; #@$%!$@%!#e@$%#!@�#@$%%�!#!         | 
;; !$@#$%�@#@#@$@$%%#$%#%$@$!@         | Sistema desenvolvido em linguagem 
;; �@!#$@$@#@                          |   Assembly x86 para uso em PCs
;; @!@$%@#$@$                          |          Intel/AMD 386+
;; @!#@!$#$@$                          | 
;; #EVEREST@%                          |
;; #@$%!$@%!%                          |  
;; !$@#$%�@#$                          |
;; �@!#$@$@##                          |
;; #$@$%&*%$#@#!$@@#@#$%!$#!$!#%#      | 
;; !#@$EVEREST#%@#!$%#!�%#!$#!�#$      | 
;; $#%@$#!@#$#!$%#EVEREST#$@�!@$�      |
;; #@%�$@$#!@&%#$@�#@&%$@%�$@&�$@      |  
;;
;;*****************************************************************************
;;
;;
;;                     Arquivo de Controle de Portas Seriais
;;
;;          Este arquivo cont�m fun��es complementares de acesso a Portas Seriais
;;                                 
;;
;;
;;**************************************************************************************

[BITS 16]

%macro paraSerial 1+

     section .data
	 
 %%mensagem:
 
     db %1,0
	 
     section .text 
	 
     mov si,%%mensagem
	 
     call transferir
	 
 %endmacro

section .text

;;************************************************************************

SERIAL_iniciar_serial:  ;; Esse m�todo � usado para inicializar uma Porta Serial


    mov ah, 0               ; Move o valor 0 para o registrador ah 
	                        ; A fun��o 0 � usada para inicializar a Porta Serial COM1
    mov al, 0xe3            ; Par�metros da porta serial
    mov dx, 0               ; N�mero da porta (COM 1) - Porta Serial 1
    int 0x14                ; Inicializar porta - Ativa a porta para receber e enviar dados
	
	ret
	
;;************************************************************************
	
SERIAL_transferir:  ;; Esse m�todo � usado para transferir dados pela Porta Serial aberta

lodsb         ;; Carrega o pr�ximo caractere � ser enviado

or al, al     ;; Compara o caractere com o fim da mensagem
jz .pronto    ;; Se igual ao fim, pula para .pronto

mov ah, 0x1   ;; Fun��o de envio de caractere do BIOS por Porta Serial
int 0x14      ;; Chama o BIOS e executa a a��o 

jc near .erro

jmp SERIAL_transferir ;; Se n�o tiver acabado, volta � fun��o e carrega o pr�ximo caractere


.pronto: ;; Se tiver acabado...

ret      ;; Retorna a fun��o que o chamou

.erro:

print 10,13,"Impossivel estabelecer conexao com porta serial... [Pulando]",10,13,0

ret
	
;;************************************************************************

SERIAL_receber: ;; Recebe os dados enviados pela Porta Serial, em resposta

	mov ah, 2 ;; Define fun��o 2 - Obter cracteres
	mov dx, 0 ;; Define Porta Serial 0 (COM1)
	
	int 0x14  ;; Chama o BIOS
	
	jc near .erro
	
	cmp al, '$' ;; Compara a resposta com '$'
	            ;; Se for igual, significa o fim da mensagem
	je .pronto  ;; Se for igual, vai at� .pronto, para terminar
	
	mov [recebido + 1] , al ;; Se n�o, joga o valor para dentro da vari�vel
	
	jmp SERIAL_receber ;; Volta a executar para receber o pr�ximo caractere


	.pronto:
	
	ret ;; Retorna a fun��o que o chamou
	
	.erro:
	
	print 10,13,"Impossivel estabelecer conexao com porta serial... [Pulando]",10,13,0

    ret

;;************************************************************************

section .data
	
recebido times 64 db 0 ;; Vari�vel em mem�ria de tamanho 64

