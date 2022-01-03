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

NumerodoDrive: db 99		
						
SegmentodeBufferdeDisco: 		dw 0 ;; Segmento utilizado para operações de disco

BPBEntradasRaiz:         dw 224
BPBSetoresPorTrilha:     dw 18
BPBCabecas:    			dw 2

DISQUETE_arquivo_nao_encontrado:	db "O arquivo nao pode ser encontrado neste disco!", 0
DISQUETE_erro_disco:			db "Erro desconhecido no disco...", 0
DISQUETE_reset_disco:			db " [Reinicie o disco]", 0
DISQUETE_lendo_raiz:		db "> Diretorio raiz", 0
DISQUETE_lendo_FAT:				db "> FAT", 0
DISQUETE_lendo_CLUSTER:			db "> Cluster", 0

DISQUETE_segmento_buffer_nome_de_arquivo: dw 0
DISQUETE_offset_buffer_nome_de_arquivo: dw 0

DISQUETE_NomedeArquivo: 		db "00000000000",0

DISQUETE_segmento_destinacao_de_dados:  dw 0 
DISQUETE_cluster_atual_do_arquivo: 	 dw 0 ;; Número do cluster atual do arquivo
DISQUETE_ponteiro_de_destinacao_de_dados_do_arquivo: dw 0 ;; Ponteiro para a localização
                                                          ;; em memória do arquivo
;;*****************************************************************************

;; Entrada:
;;
;;		AX - Buffer de disco para o uso em operações de disco

DISQUETE_definir_buffer_segmento:

	pusha
	push ds
	
	push cs
	pop ds
	
	mov word [SegmentodeBufferdeDisco], ax
	
	pop ds
	popa
	ret

;;*****************************************************************************
									   
;; Entrada:
;;
;;		AL - Número do disco para ser usado em todas as operações

DISQUETE_definir_drive:

	pusha
	push ds
	
	push cs
	pop ds
	
	mov byte [NumerodoDrive], al
	
	pop ds
	popa
	ret

;;*****************************************************************************
	
;; Entrada:
;;
;;			DS:SI apontando para um buffer com o nome do arquivo
;;			ES:DI apontando para onde o arquivo deve ser carregado
;;
;; Saída:
;;
;;			Status em AL (0= sucesso, 1= não encontrado)

DISQUETE_carregar_arquivo_em_ponto_de_entrada:

	pushf
	push es
	push di
	
	push cs
	pop es
	mov di, DISQUETE_NomedeArquivo	;; ES:DI aponta para o endereço
	mov cx, 11				;; Copiando 11 bytes (8+3)
							;; DS:SI já aponta para o nome do arquivo
	cld
	rep movsb				;; Copiar!
	
	pop di
	pop es
	
	push cs
	pop ds							;; Apontar DS para este segmento
	
	mov word [DISQUETE_segmento_destinacao_de_dados], es
	mov word [DISQUETE_ponteiro_de_destinacao_de_dados_do_arquivo], di
	
	;; Primeiro passo: carregar o diretório raiz para a memória
	
DISQUETE_carregar_diretorio_raiz:

	;; | setor de boot | primeira FAT | segunda FAT | diretório raiz | área de dados |
	
	;; Cada FAT ocupa 9 setores
	
	mov ax, 19	;; Então, o diretório raiz começa no setor 19
	
	call DISQUETE_Logico_para_Fisico
	
	
	push word [SegmentodeBufferdeDisco]
	
	pop es							;; O diretório raiz será lido em ES:BX
	mov bx, 0
	
	mov ax, 020Eh	;; AH = função 2 da int 13h (ler setores)
					;; AL = ler 14 setores
					;;    Número máximo de entradas em diretório raiz no disquete: 224 
					;;    Bytes por entrada no diretório raiz: 32 bytes
					;;    Número de bytes por setor: 512 byte
					;;    224 * 32 / 512 = 14 setores
	
	int 13h			;; Ler o diretório raiz para ES:BX
	
	jnc DISQUETE_encontrar_entrada_diretorio_raiz	;; Se não tiver erros, continuar
	
	call DISQUETE_reiniciar			;; Reiniciar disquete
	
	jmp DISQUETE_carregar_diretorio_raiz		;; Tentar novamente
	
	;; Passo 2: pular para o início da entrada de 32 bytes do diretório raiz
	
DISQUETE_encontrar_entrada_diretorio_raiz:

	mov di, 0		            ;; ES:DI agora aponta para o início do diretório raiz
	mov bx, [BPBEntradasRaiz]	;; Número máximo de entradas
								;; Entradas serão checadas
								
DISQUETE_encontrar_entrada_diretorio_raiz_checar_arquivo:

	push di
	
	mov si, DISQUETE_NomedeArquivo	;; DS:SI agora aponta para o início da String
							        ;; Contendo o nome de arquivo que se procura
							
	mov cx, 11		

	cld
	repe cmpsb		;; Comparar 11 bytes contínuos
	
	jz DISQUETE_encontrar_entrada_diretorio_raiz_encontrada	
	
	dec bx
	cmp bx, 0		;; Estamos fora das entradas?
	
	je DISQUETE_encontrar_entrada_diretorio_raiz_nao_encontrada
	
	;; Tentar próxima entrada, avançando 32 bytes
	
	pop di		;; Aponta para a entrada já checada
				
	add di, 32	;; Move DI para a próxima entrada
	
	jmp DISQUETE_encontrar_entrada_diretorio_raiz_checar_arquivo
	
DISQUETE_encontrar_entrada_diretorio_raiz_nao_encontrada:

	pop bx					;; Não existe mais entradas
	mov al, 1				;; 1 significa não encontrado
	
	popf
	
	ret

;;*****************************************************************************
	
DISQUETE_encontrar_entrada_diretorio_raiz_encontrada:

	pop di					;; DI = início da entrada no diretório raiz
	
	mov ax, word [es:di+26]
	
	mov word [DISQUETE_cluster_atual_do_arquivo], ax	;; Extrair primeiro cluster do arquivo
								                		;; nos bytes 26-27 da entrada
	

;; Passo 3: ler a FAT para a memória
	
DISQUETE_lerFAT:

	mov ax, 1			;; A primeira FAT se inicia no primeiro setor após o de boot (setor 0)
	
	call DISQUETE_Logico_para_Fisico
	
	mov bx, 0
	mov ax, 0212h		;; Função 2 da int 13h (ler setores)
						;;Serão lidos 12h (18) setores da FAT
	int 13h				;; Copiar FAT para ES:BX
						;; ES aponta para o segmento de operações de disco
	
	jnc DISQUETE_lerFAT_sucesso	; if there were no errors (carry flag=0), proceed		
	
	call DISQUETE_reiniciar			;; Reiniciar
	
	jmp DISQUETE_lerFAT				;; Tentar novamente
	
DISQUETE_lerFAT_sucesso:	

	;; A FAT está carregada em SegmentodeBufferdeDisco:0000
	;; Já sabemos o primeiro cluster
	
	push word [DISQUETE_segmento_destinacao_de_dados]	;; Local para carregamento de arquivos
	pop es							;; ES = segmento dp aplicativo
	
	mov ax, word [DISQUETE_cluster_atual_do_arquivo]	;; AX = número do primeiro cluster

;;*****************************************************************************
	
;; Passo 4: ler arquivo cluster por cluster, no local de destino

DISQUETE_ler_conteudo_cluster:

	add ax, 31			;; Offset para o primeiro cluster de dados
						;; Note que o cluster 2 é o primeiro de dados
						;; Então se tem:
						;;	1 setor de boot
						;;   2*9 setores da FAT 
						;;  14 setores de diretório raiz
						;;  = 33 setores antes da área de dados
						;; Mas como o cluster 2 é o primeiro de dados, deve-se subtrair
						;; 2. Então, fica 31.

DISQUETE_ler_conteudo_cluster_fazer:		
				
	push ax				;; Preservar setor lógico, em caso de tentar de novo
	
	call DISQUETE_Logico_para_Fisico

	mov ax, 0201h	;; Função 2 da int 13h (ler setores)
					;; Ler um setor (cada cluster apresenta um setor no disquete)
	
	mov bx, [DISQUETE_ponteiro_de_destinacao_de_dados_do_arquivo]
	
	int 13h

	jnc DISQUETE_ler_conteudo_cluster_sucesso	
	
	call DISQUETE_reiniciar					;; Reiniciar
	
	pop ax								;; Restaurar setor lógico
	
	jmp DISQUETE_ler_conteudo_cluster_fazer	;; Tentar novamente

;;*****************************************************************************

DISQUETE_ler_conteudo_cluster_sucesso:

	pop ax				;; O setor lógico não é mais necessário

;; Já sabemos o primeiro cluster e agora devemos ir a FAT para encontrar o próximo na
;; cadeia. Cada cluster na tabela tem 3 nibbles (total de 12 bits).
;;
; cluster 0: 0x012
;; cluster 1: 0x345
;; cluster 2: 0x678
;; cluster 3: 0x9AB

DISQUETE_calcular_proximo_cluster:

	mov ax, [DISQUETE_cluster_atual_do_arquivo]
	mov bx, 3
	mul bx			;; DX:AX = 3 * número do cluster
					;; Nota: camo o disquete tem apenas 2880 setores, a multiplicação
					;; irá deixar DX com valor 0
					
	dec bx			;; BX = 2 
	div bx			;; AX = (3 * número do cluster) / 2
					;; DX = (3 * número do cluster) % 2

	
	push ds						;; Restaurar para o setor de inicialização
								
	
	push word [SegmentodeBufferdeDisco]	
	
	pop ds						;; DS = segmento de buffer de disco
								;; para preparar para a leitura da FAT
	mov si, ax
	mov ax, word [ds:si]		;; AX = word na FAT para o cluster 12 bytes
	
	pop ds
	
	dec dx				;; DX deve ter 1 ou 0
	
	jnz DISQUETE_cluster_e_par	
	
;;*****************************************************************************
	
DISQUETE_cluster_e_impar:

	shr ax, 4	;; Para entradas ímpares, dar shift para a esquerda
	
	jmp DISQUETE_calcular_proximo_cluster_armazenar

;;*****************************************************************************
	
DISQUETE_cluster_e_par:

	and ax, 0FFFh	;; Para ímpar, descartar último nibble

	;; AX contêm o próximo cluster
	
;;*****************************************************************************
	
DISQUETE_calcular_proximo_cluster_armazenar:

	mov word [DISQUETE_cluster_atual_do_arquivo], ax
	
	cmp ax, 0FF8h				            ;; 0x0FF8 a 0x0FFF significa "último cluster"
	jae DISQUETE_carregar_arquivo_pronto	;; Se encontrado isso, tudo pronto

	add word [DISQUETE_ponteiro_de_destinacao_de_dados_do_arquivo], 512 ;; O próximo cluster
	                                                                    ;; será copiado 512 bytes
																		;; após este
																		
	jmp DISQUETE_ler_conteudo_cluster	;; AX = DISQUETE_cluster_atual_do_arquivo neste ponto
	
	;; Tudo pronto lendo este arquivo
	
;;*****************************************************************************	
	
DISQUETE_carregar_arquivo_pronto:

	mov al, 0					;; 0 significa "sucesso"
	
	popf
	
	ret

;;*****************************************************************************

;; Converter setor lógico para físico
;;
;; Número setor lógico = (C * N° cabeças + H) * N° setores + (S − 1)
;; 	em que  C = cilindro, H = cabeça, e S = setor
;;
;; Entrada:
;;
;; Número de setor lógico em AX
;;			

DISQUETE_Logico_para_Fisico:	

	push ax				;; Setor lógico

	mov dx, 0
	
	div word [BPBSetoresPorTrilha]	
				;; AX = número do setor lógico / setores por trilha
				;; DX = número do setor lógico % setores por trilha
				
	inc dl			;; A numeração de setor físico é 1-based
	mov cl, dl		;; Deve ficar CL para a int 13h
	
	pop ax				;; AX = setor lógico
	
	mov dx, 0
	
	div word [BPBSetoresPorTrilha] 	
	
				;; AX = número de setor lógico / setores por trilha
			
									
	mov dx, 0
	div word [BPBCabecas]		;; AX = número lógico da trilha / cabeças
								;; DX = número lógico da trilha % cabeças
	
	mov dh, dl			
	mov ch, al					;; Número da trilha física
								
	mov dl, byte [NumerodoDrive]
	
	ret

;;*****************************************************************************

DISQUETE_reiniciar:

	pusha
	
	mov cx, 10						;; Tentará reiniciar 10 vezes
	
DISQUETE_reiniciar_loop:

	mov ah, 0
	mov dl, byte [NumerodoDrive]
	
	clc
	
	int 13h							;; int 13h função 0 - reiniciar drive
	
	jnc DISQUETE_reiniciar_sucesso		
	
	dec cx
	
	jcxz DISQUETE_reiniciar_falha		
									
	jmp DISQUETE_reiniciar_loop
	
;;*****************************************************************************
	
DISQUETE_reiniciar_sucesso:	

	popa
	
	ret

;;*****************************************************************************
	
DISQUETE_reiniciar_falha:

	mov si, DISQUETE_erro_disco
	
	call DEBUG_imprimir_string
	
	popa						

;;*****************************************************************************
	
congelar_cpu:

	cli							
	hlt							
	
;;*****************************************************************************
	
;; Entrada:
;;
;;			ES:DI aponta para o local de carregamento do diretório raiz
;;
;; Saída:
;;
;;			Número de entradas em AX

DISQUETE_carregar_root_em_ponto_de_entrada:

	push ds
	pusha

	push cs
	pop ds		;; Aponta DS para este segmento, para ler variáveis
				
DISQUETE_carregar_root_pontodeEntrada_tentar:

	
	
	mov ax, 19	
	call DISQUETE_Logico_para_Fisico
	
	mov bx, di		
	
	mov ax, 020Eh	
					
					
	int 13h			
	
	jnc DISQUETE_carregar_root_pontodeEntrada_sucesso
	
	call DISQUETE_reiniciar		
	
	jmp DISQUETE_carregar_root_pontodeEntrada_tentar	

DISQUETE_carregar_root_pontodeEntrada_sucesso:

	popa
	mov ax, word [BPBEntradasRaiz]	;; Contagem de entradas em AX
									
	pop ds
	ret
