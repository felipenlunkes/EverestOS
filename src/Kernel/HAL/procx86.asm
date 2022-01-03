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
;;                        Módulo de Gerenciamento de Processador
;;
;;  Este arquivo contém funções necessárias para verificar recursos do processador,
;;     ativá-los e torná-los disponíveis aos programas e ao Sistema Operacional
;;
;;
;;**************************************************************************************
 
 [BITS 16]
 
cpu 586
 
;; Este módulo possui todas as instruções de verificação de processador
;; do Driver Auxiliar de arquitetura para o PX-DOS.


;;**************************************************************************************

Ativar_A20: ;; Ativa a linha A20


        cli
 
        call    aguardarA20
        mov     al,0xAD
        out     0x64,al
 
        call    aguardarA20
        mov     al,0xD0
        out     0x64,al
 
        call    aguardarA20_2
        in      al,0x60
        push    eax
 
        call    aguardarA20
        mov     al,0xD1
        out     0x64,al
 
        call    aguardarA20
        pop     eax
        or      al,2
        out     0x60,al
 
        call    aguardarA20
        mov     al,0xAE
        out     0x64,al
 
        call    aguardarA20
        sti
		
		; print 10,13,"## A20 habilitado.",0
		
		jc near .nao
		
        ret
 
 .nao:

print "!! A20 nao habilitado.",0

ret
		
		
aguardarA20:

        in      al,0x64
        test    al,2
        jnz     aguardarA20
        ret
 
 
aguardarA20_2:

        in      al,0x64
        test    al,1
        jz      aguardarA20_2
        ret


;;**************************************************************************************
		
x86_INICIALIZAR:

; print 10,13,"-> Verificando suporte do processador para o sistema...",0

mov ax, 6
call delay

pushfd   
              
pop eax                
mov ebx, eax    
        
xor eax, 00200000h      ; Ativa o bit 21

push eax   
           
popfd                   ; Devolver valores da pilha aos registradores

pushfd 
                
pop eax   
             
cmp eax, ebx
jnz @CPUID_SUPORTADO    ; Suporta esta função
	
print 10,13,"!! Desculpe, mas seu processador nao pode ser identificado.",0
print 10,13,"!! Este processador nao e suportado completamente pelo sistema.",10,13,0

ret
 
;;************************************************************************************** 
 
@CPUID_SUPORTADO:

call Ativar_A20

; print " -> Este processador suporta a instrucao CPUID corretamente.",0

         mov eax,0
         CPUID     
		 
         mov [edi+0],eax 
		 
         add edi,4
		 
         mov [edi+0],ebx
		 
         mov [edi+4],edx
		 
         mov [edi+8],ecx
		 
         mov [edi+12],byte 0       

         add edi,16

 ;; Checagem de MMX

         mov EAX,1
		 
         CPUID
		 
         mov ebx,edx
		 
         and ebx,0x800000
		 
         shr ebx,23
		 
         mov [edi+0],bl            ;; MMX Suportado?
		 
		 
         ; print 10,13,"-> Este processador suporta instrucoes MMX.",0
		 
         add edi,1

 ;; Checar 3DNow!

         mov [edi+0],byte 0
		 
         mov eax, 0x80000001       ;; Nivel Extendido 1
		 
         CPUID
		 
         test edx, 0x80000000
		 
         jz @sem_3DNOW
		 
         mov [edi+0],byte 1        ;; 3DNOW! Suportado
		 

		 ;; print 10,13,"-> O Processador atual possui tecnologia 3DNow!, da AMD.",10,13,0
		 
		 call BANDEIRA
		 
		 ret
		 
         @sem_3DNOW:
		 
		; print 10,13,"-> O Processador atual nao possui tecnologia 3DNow!, da AMD.",10,13,0
		  
         add edi,1

         mov eax, 0x80000000
		 
         CPUID
		 
         mov [edi+0],eax
		
        call BANDEIRA
		
		ret

;;**************************************************************************************	
	
BANDEIRA:

    mov eax,80000002h	
	cpuid
	
	mov di,produto		
	stosd
	mov eax,ebx
	stosd
	mov eax,ecx
	stosd
	mov eax,edx
	stosd
	
	mov eax,80000003h	
	cpuid
	
	stosd
	mov eax,ebx
	stosd
	mov eax,ecx
	stosd
	mov eax,edx
	stosd
	
	mov eax,80000004h	
	cpuid
	
	stosd
	mov eax,ebx
	stosd
	mov eax,ecx
	stosd
	mov eax,edx
	stosd
	mov si,produto		
	mov cx,48
	
loop_CPU:	

    lodsb
	cmp al,' '
	jae imprimir_CPU
	mov al,'_'
	
imprimir_CPU:	

    mov [si-1],al
	loop loop_CPU

	;; mov si, prodmsg		;; Não deverá ser impresso na tela. Entretanto, 
	;; int 80h              ;; as informações ficam salvas

		
mov eax, 0x0
cpuid

mov [ processador_global ], ebx
mov [ processador_global + 4 ], edx
mov [ processador_global + 8 ], ecx

ret

;;***************Separando métodos chamados por várias áreas***********

	
BANDEIRA_Serial:
	
    mov eax,80000002h	
	cpuid
	
	mov di,produtoSerial		
	stosd
	mov eax,ebx
	stosd
	mov eax,ecx
	stosd
	mov eax,edx
	stosd
	
	mov eax,80000003h	
	cpuid
	
	stosd
	mov eax,ebx
	stosd
	mov eax,ecx
	stosd
	mov eax,edx
	stosd
	
	mov eax,80000004h	
	cpuid
	
	stosd
	mov eax,ebx
	stosd
	mov eax,ecx
	stosd
	mov eax,edx
	stosd
	mov si,produtoSerial		
	mov cx,48
	
loop_CPUSerial:	

    lodsb
	cmp al,' '
	jae imprimir_CPUSerial
	mov al,'_'
	
imprimir_CPUSerial:	

    mov [si-1],al
	loop loop_CPUSerial


	ret
	
;;**************************************************************************************



processador_global times 13 db 0

prodmsg	db "# Nome do Processador: ["

produto	db "abcdabcdabcdabcdABCDABCDABCDABCDabcdabcdabcdabcd]",13,10,0

produtoSerial	db "abcdabcdabcdabcdABCDABCDABCDABCDabcdabcdabcdabcd]",13,10,0
