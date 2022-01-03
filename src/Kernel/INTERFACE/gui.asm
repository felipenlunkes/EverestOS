;;*****************************************************************************
;;
;;         ____
;;        / __ \           Ambiente de Desenvolvimento para PX-DOS�
;;       / |__| \       Copyright � 2012-2016 Felipe Miguel Nery Lunkes
;;      /  /  \  \               Todos os direitos reservados
;;     /__/    \__\ssembly 
;;
;;
;;*****************************************************************************
;;
;; Sistema Operacional PX-DOS�. Copyright � 2012-2016 Felipe Miguel Nery Lunkes.
;; O Sistema Operacional PX-DOS� � protegido por direitos autorais.
;;
;;*****************************************************************************
;;
;;         A presente biblioteca est� protegida por direitos autorais.
;;   Sendo assim, medidas judiciais podem ser tomadas ap�s a reprodu��o de
;;  qualquer trecho do c�digo nela presente, salvo permiss�o por escrito de
;;                       seu desenvolvedor, acima citado.
;;
;;
;;*****************************************************************************

%define INTERFACE
%define MODO_GRAFICO

%ifdef MODO_GRAFICO

%define GUI

branco_verde equ 2Fh
branco_preto equ 7h
vermelho_verde equ 0A4h
branco_vermelho equ 0CFh
preto_branco  equ 0F0h
branco_marrom equ 60h

;;*******************************************************************

ativar_interface:

mov     ah, 00h
mov     al, 03h
int     10h


mov     ax, 1003h
mov     bx, 0      
int     10h

ret

;;*******************************************************************

criar_interface:

  push bx
  push cx

  ;; Controle das linhas horizontais - exaustivamente testados! :'( 
  
  mov ax, 0100h
  mov cx, 80
  
titulo_rodape: ;; Usado para desenhar as �reas de t�tulo e rodap�, al�m de
               ;; atualiz�-las para a mudan�a de conte�do

  mov ah, 01
  mov bl, ' '
  mov bh, 4fh
  call desenhar
  
  mov ah, 25
  call desenhar ;; Utiliza fun��es para escrever na tela
  
  inc al
  loop  titulo_rodape

  ;; Controle das linhas verticais - exaustivamente testados! :'( )
  
  mov ax, 0100h
  mov cx, 25
  
rolagem:

  mov al, 80   ;; Coluna 80
  mov bl, ' '
  mov bh, 6fh
  call desenhar
  
  mov al, 00   ;; Coluna 00
  call desenhar
  
  inc ah
  loop  rolagem



  pop cx
  pop bx
  ret

;;*******************************************************************
  
desenhar:

;; Coloca um char na linha e coluna escolhidas. ah=linha, al=coluna
;; Char a ser desenhado em bl

  push ax
  push cx
  push bx
  push dx
  push si
  push ds
  
;; Verifica se precisa decrementar os valores de linha e coluna


  cmp ah,0
  jz desenhar_nao_decrementa_linha

  dec ah

desenhar_nao_decrementa_linha:

  cmp al,0
  jz desenhar_nao_decrementa_coluna
  
  dec al
  
desenhar_nao_decrementa_coluna:

  mov cx, bx   ;; Salva o char a ser escrito
  mov bx, MEMORIA_VIDEO ;; Move para bx o valor do endere�o da mem�ria de v�deo
  mov ds, bx ;; Copia isso para o registrador de segmento de dados
  mov bx, ax   ;; Guarda um copia dos valores passados
  mov ax, 2*LARGURA ;; Cada char no buffer de video ocupa 2 bytes
  mov dl, bh   ;; Pega o valor da linha passada
  xor dh, dh   ;; Zera a parte alta de dx. (precau��o)
  mul dx
  xor bh, bh   ;; Tira de bx, o valor da linha, j� que agora adicionaremos apenas as colunas
  add ax, bx   ;; A posi��o escolhida est� agora em ax
  add ax, bx
  mov bx, cx   ;; Restaura o char e o atributo
  
  
  mov si, ax
  mov [ds:si], bx

  pop ds
  pop si
  pop dx
  pop bx
  pop cx
  pop ax
  ret

;;*******************************************************************

adaptar_interface: 

;; Entrada:
;;
;; ah: Posi��o do T�tulo
;; al: Posi��o do Rodap�
;; bx: Texto a ser usado como t�tulo
;; cx: Texto a ser usado como rodap�

push ax		   

mov dh, 00
mov dl, 02
call gotoxy

print ">",0 ;; �cone de janela

;; Adicionar um t�tulo

pop ax

mov dh, 00
mov dl, ah;

push ax

call gotoxy

mov si, bx
call escrever


;; Adicionar um rodap�

mov dh, 00
mov dl, 75
call gotoxy

print "- X",0

pop ax

mov dh, 24
mov dl, al;
call gotoxy

mov si, cx
call escrever

mov dh, 00
mov dl, 00
call gotoxy

print "-",0

mov dh, 24
mov dl, 00
call gotoxy

print "+",0

ret


;;************************************************************

adaptar_pagina: ;; ah: Linha - Para texto, comece sempre com ah=02!
                ;; al: Coluna

mov dh, ah	
mov dl, al		
call gotoxy

ret

;;************************************************************

atualizar_interface:

push ax
push bx
push cx

call clrscr

call ativar_interface

call criar_interface

pop cx
pop bx
pop ax

call adaptar_interface


ret


;;************************************************************

matar_interface:

call mostrar_cursor ;; Mostra o cursor, importante para outros programas

call clrscr ;; Limpa a tela

mov     ah, 00h 
mov     al, 03h
int     10h

ret

;;*******************************************************************

criar_caixa_mensagem:

  push bx
  push cx

  ;; Controle das linhas horizontais - exaustivamente testados! :'( )
  
  mov ax, 15h
  mov cx, 40
  
.titulo_rodape: ;; Usado para desenhar as �reas de t�tulo e rodap�, al�m de
               ;; atualiz�-las para a mudan�a de conte�do

  mov ah, 5
  mov bl, ' '
  mov bh, 4fh
  call desenhar
  
  mov ah, 20
  call desenhar ;; Utiliza fun��es para escrever na tela
  
  inc al
  loop  .titulo_rodape
  
  ;; Controle das linhas verticais - exaustivamente testados! :'( )

  mov ax, 500h
  mov cx, 16
  
.rolagem:

  mov al, 60   ;; Coluna 60
  mov bl, ' '
  mov bh, 6fh
  call desenhar
  
  mov al, 20   ;; Coluna 20
  call desenhar
  
  inc ah
  loop  .rolagem



  pop cx
  pop bx
  
  ret

;;************************************************************

criar_dialogo:

call clrscr

call ativar_interface

call criar_interface

call criar_caixa_mensagem

ret

;;*******************************************************************

criar_caixa_opcoes:

  push bx
  push cx

  ;; Controle das linhas horizontais - exaustivamente testados! :'( )
  
  mov ax, 19h
  mov cx, 11
  
.linha_horizontal_sim: ;; Usado para desenhar linhas horizontais

  mov ah, 16
  mov bl, ' '
  mov bh, 1fh  ;; Cor azul
  call desenhar
  
  mov ah, 18
  call desenhar ;; Utiliza fun��es para escrever na tela
  
  inc al
  loop  .linha_horizontal_sim
  
  ;; Controle das linhas verticais - exaustivamente testados! :'( )

  mov ax, 1000h
  mov cx, 3
  
.linha_vertical_sim: ;; Usado para desenhar as linhas verticais

  mov al, 24   ;; Coluna 24
  mov bl, ' '
  mov bh, 1fh  ;; Cor azul
  call desenhar
  
  mov al, 36   ;; Coluna 36
  call desenhar
  
  inc ah
  loop  .linha_vertical_sim

  ;;
  
  mov ax, 2Dh
  mov cx, 11
  
.linha_horizontal_nao: ;; Usado para desenhar linhas horizontais

  mov ah, 16
  mov bl, ' '
  mov bh, 1fh  ;; Cor azul
  call desenhar
  
  mov ah, 18
  call desenhar ;; Utiliza fun��es para escrever na tela
  
  inc al
  loop  .linha_horizontal_nao
  
  ;; Controle das linhas verticais - exaustivamente testados! :'( )

  mov ax, 1000h
  mov cx, 3
  
.linha_vertical_nao:  ;; Usado para desenhar as linhas verticais

  mov al, 44   ;; Coluna 44
  mov bl, ' '
  mov bh, 1fh  ;; Cor azul
  call desenhar
  
  mov al, 56   ;; Coluna 56
  call desenhar
  
  inc ah
  loop  .linha_vertical_nao

  pop cx
  pop bx
  
  ret

;;************************************************************

criar_sim_nao:

mov ah, 07
call adaptar_pagina

call escrever

mov ah, 16
mov al, 25
call adaptar_pagina

call criar_caixa_opcoes

print "Sim - [S]",0

mov ah, 16
mov al, 45
call adaptar_pagina

print "Nao - [N]",0

ret

;;************************************************************

mostrar_cursor:


pusha

mov bh, 0
mov ah, 2
int 10h				

popa

ret
	
;;************************************************************

esconder_cursor:

pusha

mov ah, 01h ;; Fun��o para defini��o de cursor
mov cl, 05h ;;
mov ch, 20h ;; Deve ficar invis�vel aqui
int 10h  

mov dl, 79  ;;  local para onde ser� mandado - canto superior direito do v�deo
mov dh, 0   ;; Linha 0 - N�o tem bot�es nesta �rea
mov bh, 0   ;; P�gina
mov ah, 2   ;; Fun��o para mover o cursor
int 10h				

popa

ret

;;************************************************************

limpar_linha: ;; Par�metros: ah: linha + 1

  mov al, 02h ;; In�cio: coluna 02h, sempre! Coluna 00 e 79 reservadas!
  mov cx, 78  ;; N�mero de repeti��es (78 = colunas dispon�veis para uso)
  
.limpar:       ;; Usado para limpar da mam�ria algo previamente escrito
               ;; atualizando a interface.

  mov bl, ' '  ;; O que dever� ser escrito na mem�ria de v�deo
  mov bh, 7h  ;; O atributo (7h = Branco no preto padr�o)
  call desenhar
  
  inc al
  loop  .limpar

ret

;;************************************************************

marcar_linha: ;; Par�metros: ah: linha + 1


  mov al, 02h ;; In�cio: coluna 02h, sempre! Coluna 00 e 79 reservadas!
  mov cx, 78  ;; N�mero de repeti��es (78 = colunas dispon�veis para uso)
  
.marcar:       ;; Usado para marcar uma linha, destacando-a, diretamente na
               ;; mem�ria de v�deo.

  mov bl, ' '  ;; O que dever� ser escrito na mem�ria de v�deo
  mov bh, 8Fh  ;; O atributo (8Fh = Branco no cinza)
  call desenhar
  
  inc al
  loop  .marcar

ret

;;************************************************************

colorir_linha: ;; Par�metros: dl: cor da linha

  mov al, 02h ;; In�cio: coluna 02h, sempre! Coluna 00 e 79 reservadas!
  mov cx, 78  ;; N�mero de repeti��es (78 = colunas dispon�veis para uso)
  
.marcar:       ;; Usado para marcar uma linha, destacando-a, diretamente na
               ;; mem�ria de v�deo.

  mov bl, ' '  ;; O que dever� ser escrito na mem�ria de v�deo
  mov bh, dl   ;; O atributo de cor
  call desenhar
  
  inc al
  loop  .marcar

ret

;;************************************************************

MEMORIA_VIDEO equ 0xb800  ;; Acesso direto � mem�ria
ALTURA  equ 25            ;; N�mero de linhas
LARGURA equ 80            ;; N�mero de colunas


%endif 