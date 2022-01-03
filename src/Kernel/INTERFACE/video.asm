;;*****************************************************************************
;;
;;         ____
;;        / __ \           Ambiente de Desenvolvimento para PX-DOS®
;;       / |__| \       Copyright © 2012-2016 Felipe Miguel Nery Lunkes
;;      /  /  \  \               Todos os direitos reservados
;;     /__/    \__\ssembly 
;;
;;
;;*****************************************************************************
;;
;; Sistema Operacional PX-DOS®. Copyright © 2012-2016 Felipe Miguel Nery Lunkes.
;; O Sistema Operacional PX-DOS® é protegido por direitos autorais.
;;
;;*****************************************************************************

%define VIDEO_INCLUIDO

   
;;*******************************************************************   


%ifndef LIB_PXDOS

escrever: ;; Driver para imprimir caracteres na tela


;; Use este driver para escrever caracteres na tela utilizando o PX-DOS

;; Sintaxe desta função:

;;mov si, mensagem ou registrador
;;call escrever


lodsb

or al, al
jz pronto

mov ah, 0x0E
int 0x10

jmp escrever


pronto:

%ifdef GUI

call esconder_cursor

%endif

ret

%endif

;;*******************************************************************

%ifdef LIB_PXDOS

escrever:

mov dx, si
mov ah, 03h
int 90h

ret

%endif

;;*******************************************************************  

clrscr:                      ;; Processo para limpar a tela


push ax
push bx
push cx
push dx


mov dx, 0
mov bh, 0
mov ah, 2
int 10h

mov ah, 6
mov al, 0
mov cx, 0
mov dh, 24
mov dl, 79
int 10h


pop dx
pop cx
pop bx
pop ax

mov dh, 17h ;; Número 17h volta ao fim da página
mov dl, 00
call gotoxy

ret

;;*******************************************************************  

gotoxy:

;; Em dh a linha
;; Em dl a coluna

        push ax
        push bx
        push dx
        mov ah, 02h
        mov bh, 0
        int 10h
        pop dx
        pop bx
        pop ax
		
		ret

;;*******************************************************************   

pintartela:

push ax

mov     ah, 00h
mov     al, 03h
int     10h


mov     ax, 1003h
mov     bx, 0      
int     10h

pop ax


cmp ax, 1
je chamar_azul_branco

cmp ax, 2
je chamar_cinza_verde

cmp ax, 3
je chamar_ciano_roxo

cmp ax, 4
je chamar_vermelho_azul

cmp ax, 5
je chamar_vermelho_ciano

cmp ax, 6
je chamar_vermelhoesc_branco

cmp ax, 7
je chamar_branco_laranja

ret

;;*******************************************************************  

chamar_azul_branco:

call azul_branco
ret

chamar_branco_laranja:

call branco_laranja
ret

chamar_cinza_verde:
call cinza_verde
ret

chamar_ciano_roxo:
call ciano_roxo
ret

chamar_vermelho_azul:
call vermelho_azul
ret

chamar_vermelho_ciano:
call vermelho_ciano
ret

chamar_vermelhoesc_branco:
call vermelhoesc_branco
ret


;;*******************************************************************  

branco_laranja:                  ;; Limpa a Tela

        push    ax      
        push    ds      
        push    bx      
        push    cx      
        push    di      

        mov     ax, 40h
        mov     ds, ax 
        mov     ah, 06h 
        mov     al, 0   
        mov     bh, 0110_0000b  ;; Laranja/Branco
        mov     ch, 0   
        mov     cl, 0   
        mov     di, 84h 
        mov     dh, [di] 
        mov     di, 4ah 
        mov     dl, [di]
        dec     dl      
        int     10h

       
        mov     bh, 0   
        mov     dl, 0   
        mov     dh, 0   
        mov     ah, 02
        int     10h

        pop     di      
        pop     cx      
        pop     bx      
        pop     ds      
        pop     ax
           

		   ret
		   
;;*******************************************************************

		   
azul_branco:
 
        push    ax      
        push    ds      
        push    bx      
        push    cx      
        push    di      

        mov     ax, 40h
        mov     ds, ax  
        mov     ah, 06h
        mov     al, 0   
        mov     bh, 1001_1111b  
        mov     ch, 0   
        mov     cl, 0   
        mov     di, 84h 
        mov     dh, [di] 
        mov     di, 4ah 
        mov     dl, [di]
        dec     dl      
        int     10h

        
        mov     bh, 0  
        mov     dl, 0   
        mov     dh, 0   
        mov     ah, 02
        int     10h

        pop     di      
        pop     cx      
        pop     bx      
        pop     ds      
        pop     ax      

        ret 
		
;;*******************************************************************  		

	cinza_verde:
 
        push    ax      
        push    ds      
        push    bx      
        push    cx      
        push    di      

        mov     ax, 40h
        mov     ds, ax  
        mov     ah, 06h
        mov     al, 0   
        mov     bh, 1000_1010b  
        mov     ch, 0   
        mov     cl, 0   
        mov     di, 84h 
        mov     dh, [di] 
        mov     di, 4ah 
        mov     dl, [di]
        dec     dl      
        int     10h

        
        mov     bh, 0  
        mov     dl, 0   
        mov     dh, 0   
        mov     ah, 02
        int     10h

        pop     di      
        pop     cx      
        pop     bx      
        pop     ds      
        pop     ax      

        ret 
		
;;*******************************************************************  		

ciano_roxo:
 
        push    ax      
        push    ds      
        push    bx      
        push    cx      
        push    di      

        mov     ax, 40h
        mov     ds, ax  
        mov     ah, 06h
        mov     al, 0   
        mov     bh, 0011_0101b  
        mov     ch, 0   
        mov     cl, 0   
        mov     di, 84h 
        mov     dh, [di] 
        mov     di, 4ah 
        mov     dl, [di]
        dec     dl      
        int     10h

        
        mov     bh, 0  
        mov     dl, 0   
        mov     dh, 0   
        mov     ah, 02
        int     10h

        pop     di      
        pop     cx      
        pop     bx      
        pop     ds      
        pop     ax      

        ret 
		
;;*******************************************************************  	

vermelho_azul:
 
        push    ax      
        push    ds      
        push    bx      
        push    cx      
        push    di      

        mov     ax, 40h
        mov     ds, ax  
        mov     ah, 06h
        mov     al, 0   
        mov     bh, 1100_0001b  
        mov     ch, 0   
        mov     cl, 0   
        mov     di, 84h 
        mov     dh, [di] 
        mov     di, 4ah 
        mov     dl, [di]
        dec     dl      
        int     10h

        
        mov     bh, 0  
        mov     dl, 0   
        mov     dh, 0   
        mov     ah, 02
        int     10h

        pop     di      
        pop     cx      
        pop     bx      
        pop     ds      
        pop     ax      

        ret 
		
;;******************************************************************* 

vermelho_ciano:
 
        push    ax      
        push    ds      
        push    bx      
        push    cx      
        push    di      

        mov     ax, 40h
        mov     ds, ax  
        mov     ah, 06h
        mov     al, 0   
        mov     bh, 1100_1011b  
        mov     ch, 0   
        mov     cl, 0   
        mov     di, 84h 
        mov     dh, [di] 
        mov     di, 4ah 
        mov     dl, [di]
        dec     dl      
        int     10h

        
        mov     bh, 0  
        mov     dl, 0   
        mov     dh, 0   
        mov     ah, 02
        int     10h

        pop     di      
        pop     cx      
        pop     bx      
        pop     ds      
        pop     ax      

        ret 
		
;;*******************************************************************  	

vermelhoesc_branco:
 
        push    ax      
        push    ds      
        push    bx      
        push    cx      
        push    di      

        mov     ax, 40h
        mov     ds, ax  
        mov     ah, 06h
        mov     al, 0   
        mov     bh, 0100_1111b  
        mov     ch, 0   
        mov     cl, 0   
        mov     di, 84h 
        mov     dh, [di] 
        mov     di, 4ah 
        mov     dl, [di]
        dec     dl      
        int     10h

        
        mov     bh, 0  
        mov     dl, 0   
        mov     dh, 0   
        mov     ah, 02
        int     10h

        pop     di      
        pop     cx      
        pop     bx      
        pop     ds      
        pop     ax      

        ret 
		
;;*******************************************************************  
		 				 
%macro print 1+
     section .data    
 %%string:
     db %1,0
     section .text    
 
     mov si,%%string
     int 80h
	 
 %endmacro
