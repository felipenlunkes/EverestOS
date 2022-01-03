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
;;          Este arquivo contém funções complementares de acesso a Portas Seriais
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

SERIAL_iniciar_serial:  ;; Esse método é usado para inicializar uma Porta Serial


    mov ah, 0               ; Move o valor 0 para o registrador ah 
	                        ; A função 0 é usada para inicializar a Porta Serial COM1
    mov al, 0xe3            ; Parâmetros da porta serial
    mov dx, 0               ; Número da porta (COM 1) - Porta Serial 1
    int 0x14                ; Inicializar porta - Ativa a porta para receber e enviar dados
	
	ret
	
;;************************************************************************
	
SERIAL_transferir:  ;; Esse método é usado para transferir dados pela Porta Serial aberta

lodsb         ;; Carrega o próximo caractere à ser enviado

or al, al     ;; Compara o caractere com o fim da mensagem
jz .pronto    ;; Se igual ao fim, pula para .pronto

mov ah, 0x1   ;; Função de envio de caractere do BIOS por Porta Serial
int 0x14      ;; Chama o BIOS e executa a ação 

jc near .erro

jmp SERIAL_transferir ;; Se não tiver acabado, volta à função e carrega o próximo caractere


.pronto: ;; Se tiver acabado...

ret      ;; Retorna a função que o chamou

.erro:

print 10,13,"Impossivel estabelecer conexao com porta serial... [Pulando]",10,13,0

ret
	
;;************************************************************************

SERIAL_receber: ;; Recebe os dados enviados pela Porta Serial, em resposta

	mov ah, 2 ;; Define função 2 - Obter cracteres
	mov dx, 0 ;; Define Porta Serial 0 (COM1)
	
	int 0x14  ;; Chama o BIOS
	
	jc near .erro
	
	cmp al, '$' ;; Compara a resposta com '$'
	            ;; Se for igual, significa o fim da mensagem
	je .pronto  ;; Se for igual, vai até .pronto, para terminar
	
	mov [recebido + 1] , al ;; Se não, joga o valor para dentro da variável
	
	jmp SERIAL_receber ;; Volta a executar para receber o próximo caractere


	.pronto:
	
	ret ;; Retorna a função que o chamou
	
	.erro:
	
	print 10,13,"Impossivel estabelecer conexao com porta serial... [Pulando]",10,13,0

    ret

;;************************************************************************

section .data
	
recebido times 64 db 0 ;; Variável em memória de tamanho 64

