[BITS 16]

org 7C00h

jmp carregar_kernel

;;*****************************************************************************
	
times $$ + 3 - $ nop	

;;************************************************************
;;
;; BIOS Parameter Block
;;
;;************************************************************

bpbOEM 					     db "EVEREST "   ;; 8 bytes para OEM
bpbBytesPorSetor:            dw 512
bpbSetoresPorCluster:        db 1
bpbSetoresReservados:        dw 1	;; Apenas um setor de inicialização
bpbNumerodeFATs:             db 2
bpbEntradasnaRaiz:           dw 224
bpbTotalSetores:             dw 2880
bpbMedia:                    db 0F0h
bpbSetoresPorFAT:            dw 9
bpbSetoresPorTrilha:         dw 18
bpbCabecas:    			     dw 2

bpbSetoresOcultos:           dd 0 	;; Ignorado para FAT12
bpbTotalSetoresGrandes:      dd 0 	;; 0 para FAT12

bpbNumeroDrive:              db 0 	;; Ignorado para FAT12
bpbAssinaturaBoot:           db 151 ;; Utilizado para verificar a legitimidade do Boot Loader

bpbAssinaturaBootExtendida:  db 29h
bpbNumeroSerial:             dd 538A538Ah
bpbRotuloVolume:             db "EVEREST  OS"
bpbSistemadeArquivos:        db "FAT12   "

;;************************************************************
;;
;; Fim do BIOS Parameter Block
;;
;;************************************************************

;;*****************************************************************************

SEGMENTO_CARREGADOR_INICIALIZACAO equ 0000h
SEGMENTO_PILHA			          equ 1000h
SEGMENTO_KERNEL			          equ 1000h
SEGMENTO_BUFFER_DE_DISCO		  equ 2000h

;;*****************************************************************************

NumeroDrivedeBoot: 		db 0

MENSAGEM_Carregando: db "Carregando o Everest(R)...",10,13,0
MENSAGEM_SemKernel:	         db "Onde esta o Kernel?", 0
MENSAGEM_ErroDisquete:       db "Erro no disco!", 0
MENSAGEM_ReinicioDisquete:   db "Reiniciar!", 0
MENSAGEM_CarregandoRaiz:     db "",0
MENSAGEM_LendoFAT:           db "",0
MENSAGEM_LendoCluster:       db "", 0
MENSAGEM_LendoClusterIncremento: db "", 0

NomeKernel: db "EVEREST SIS" ;; Nome do arquivo no formato FAT12

ClusterAtualKernel: dw 0		;; Número do cluster atual do Kernel
PonteiroDestinoKernel: dw 0		;; Ponteiro de memória para onde o Kernel será copiado

;;*****************************************************************************									
carregar_kernel:

	cld			
	
	push word SEGMENTO_CARREGADOR_INICIALIZACAO
	pop ds							;; Apontar DS para este segmento
	
	mov byte [NumeroDrivedeBoot], dl	;; Salvar número do drive
	
	;; Definindo a pilha para começar em 0FFFFh
	
	cli					
	mov ax, SEGMENTO_PILHA
	mov ss, ax				
	mov ax, 0FFFFh			
	mov sp, ax	
	sti

	mov si, MENSAGEM_Carregando
	call IMPRIMIR_string

;;*****************************************************************************
	
	;; Primeiro passo: carregar o diretório raiz para a memória
	
CARREGAR_diretorio_raiz:

	mov si, MENSAGEM_CarregandoRaiz
	call IMPRIMIR_string
	
	;; | setor de inicialização | primeira FAT | segunda FAT | diretório raiz | área de dados |
	;; Cada FAT apresenta 9 setores
	
	mov ax, 19	;; Assim, ela se inicia no setor 19
	
	call DISQUETE_logico_para_fisico
	

	push word SEGMENTO_BUFFER_DE_DISCO
	
	pop es							;; O diretório raiz será lido em ES:BX
	
	mov bx, 0
	
	mov ax, 020Eh	;; AH = int 13h função 2 (ler setores)
					;; AL = ler 14 setores
					;;	224 entradas máximas no diretório raiz para disquete
					;;    32 bytes por entrada no diretório raiz
					;;   512 bytes por setor
					;; 224 * 32 / 512 = 14 setores
	
	int 13h			;; Ler o diretório raiz em ES:BX
	
	jnc encontrar_entrada_diretorio_raiz	;; Se não ocorrerem erros, continuar
	
	call reiniciar_disquete			;; Reiniciar
	
	jmp CARREGAR_diretorio_raiz		;; Tentar novamente
	
;;*****************************************************************************	
	
	;; Passo 2: Pular para o início dos registros atrás do nome do arquivo de Kernel
	
encontrar_entrada_diretorio_raiz:

	mov di, 0				    ;; ES:DI aponta para o início do diretório raiz
	mov bx, [bpbEntradasnaRaiz]	;; Número máximo de entradas possíveis
								
;;*****************************************************************************
								
encontrar_no_dir_raiz_entrada_checar_arquivo:

	push di
	
	mov si, NomeKernel	    ;; DS:SI aponta para o início da string
							;; que está com o nome do arquivo a ser encontrado
							
	mov cx, 11				;; O nome de arquivo é fixo em 11 caracteres
							;; em cada entrada de 32 bytes
	repe cmpsb				;; Comparar 11 bytes contínuos
	
	jz encontrar_no_dir_raiz_entrada_encontrada	;; Arquivo encontrado
	
	dec bx
	cmp bx, 0		;; Acabaram as entradas?
	
	je encontrar_no_dir_raiz_kernel_nao_encontrado
	
	;; Tentar na próxima entrada, 32 bytes após esta
	
	pop di		;; Aponta para a entrada sendo checada
	
	add di, 32	;; Move DI para 32 bytes após a entrada, chegando à próxima entrada
	
	jmp encontrar_no_dir_raiz_entrada_checar_arquivo

;;*****************************************************************************
	
encontrar_no_dir_raiz_kernel_nao_encontrado:

	pop bx			
	
	mov si, MENSAGEM_SemKernel
	call IMPRIMIR_string
	
	jmp SUSPENDER_cpu

;;*****************************************************************************
	
encontrar_no_dir_raiz_entrada_encontrada:

	pop di				;; DI = início da entrada do Kernel
	
	mov ax, word [es:di+26]
	mov word [ClusterAtualKernel], ax	;; Extrair primeiro cluster do Kernel
										;; dos bytes bytes 26-27 da entrada
	
;; Como o diretório raiz, a FAT, e a área de dados funcionam em conjunto:
;;
;; [diretório raiz]              [FAT]             [área de dados]
;; [   entrada    ]
;;
;;  bytes 26-27      --->  segundo cluster
;; (primeiro cluster)  ------------|-|------> dados do arquivo no primeiro cluster
;;                                 |  \
;;                                 |   -----> dados do arquivo no segundo cluster
;;                                 v
;;                            terceiro clsuter

;;*****************************************************************************

;; Passo 3: ler a FAT para a memória
	
LER_FAT:

	mov si, MENSAGEM_LendoFAT
	call IMPRIMIR_string
	
	mov ax, 1			;; A primera FAT começa no segundo setor lógico
	
	call DISQUETE_logico_para_fisico
	
	mov bx, 0
	mov ax, 0212h		;; int 13h função 2 (ler setores)
						;; Serão lidos 12h (18) setores da FAT
	int 13h				;; Ler FAT em ES:BX
						;; Em que ES aponta para o Buffer de operações de disco
	
	jnc LER_FAT_sucesso	;; Se tudo deu certo, continuar
	
	call reiniciar_disquete	;; Reiniciar
	
	jmp LER_FAT	;; Tentar novamente

;;*****************************************************************************
	
LER_FAT_sucesso:
	
	;;  A FAT está agora carregada em SEGMENTO_BUFFER_DE_DISCO:0000
	;; e já sabemos o primeiro cluster do arquivo
	
	push word SEGMENTO_KERNEL	;; Destino do Kernel
	pop es						;; ES = segmento do Kernel
	
	mov ax, word [ClusterAtualKernel]	;; AX = número do primeiro cluster

;; Passo 4: ler arquivo do Kernel cluster por cluster, no segmento do Kernel	

	mov si, MENSAGEM_LendoCluster
	call IMPRIMIR_string
	
;; AX contêm o número do cluster sendo lido
	
;;*****************************************************************************
	
LER_conteudo_cluster:

	add ax, 31			;; Offset da primeira área de dados
						;; O cluster 2 é o primeiro da área de dados
						;; Então nós temos:
						;;	1 setor de boot
						;; 2*9 setores da FAT
						;;  14 setores do diretório raiz
						;;= 33 setores antes da área de dados
						;; Como o cluster 2 é o primeiro da área de dados,
						;; devemos subtrair 2, com total de offset de 31
						
;;*****************************************************************************						

LER_conteudo_cluster_realizar:		
				
	mov si, MENSAGEM_LendoClusterIncremento
	call IMPRIMIR_string
	
	push ax				;; Preservar setor lógico, em caso de tentariva
	call DISQUETE_logico_para_fisico

	mov ax, 0201h			;; int 13h função 2 (ler setores)
							;; Ler 1 setor (cada cluster = 1 setor no disquete)
	
	mov bx, [PonteiroDestinoKernel]
	int 13h

	jnc LER_conteudo_cluster_sucesso	
	
	call reiniciar_disquete	;; Reiniciar
	
	pop ax ;; Restaurar setor lógico
	
	jmp LER_conteudo_cluster_realizar ;; Tentar novamente

;;*****************************************************************************

LER_conteudo_cluster_sucesso:

	pop ax				;; O setor lógico não é mais necessário
	
;;*****************************************************************************

calcular_proximo_cluster:

	mov ax, [ClusterAtualKernel]
	mov bx, 3
	mul bx			;; DX:AX = 3 * número do cluster
					;; Como o disquete tem 2880 setores,
					;; a multiplicação irá definir DX como 0
					
	dec bx			;; BX = 2
	div bx			;; AX = (3 * número do cluster) / 2
					;; DX = (3 * número do cluster) % 2
	

	;; AX = (3 * número do cluster) / 2 = 9 / 2 = 4
	;; DX = (3 * número do cluster) % 2 = 9 % 2 = 1
	
	push ds						;; Restaurar DS para o segmento do carregador de inicialização
	
	push SEGMENTO_BUFFER_DE_DISCO	
	pop ds						;; DS = segmento do buffer de operações de disco
								;; Preparando para ler a FAT
	mov si, ax
	mov ax, word [ds:si]		;; AX = palavra na FAT para o cluster de 12 bytes
	pop ds
	
	
	dec dx				;; Neste ponto DX equivale a 0 ou a 1, recebendo o resto da divisão por 2
	
	jnz o_cluster_e_par
						
						;; Se o cluster foi par, soltar últimos 4 bits da palavra
						;; do próximo cluster. Se ímpar, soltar primeiros 4 bits
	
;;*****************************************************************************

o_cluster_e_impar:

	shr ax, 4	;; Para entradas ímpares, devemos deslocar um nibble para a direita
	
	jmp calcular_proximo_cluster_armazenar
	
;;*****************************************************************************
	
o_cluster_e_par:

	and ax, 0FFFh	;; Para pares, devemos descartar o nibble mais significante

	;; AX agora contêm o número do cluster

;;*****************************************************************************
	
calcular_proximo_cluster_armazenar:

	mov word [ClusterAtualKernel], ax

	cmp ax, 0FF8h					;; 0x0FF8 a 0x0FFF significa "last cluster"
	jae transferir_controle_ao_kernel	;; Se acontecer, terminamos e devemos transferir o
									    ;; controle ao Kernel

	add word [PonteiroDestinoKernel], 512 ;; O próximo cluster deve ser copiado 512 bytes após
	                                      ;; o anterior
	
	jmp LER_conteudo_cluster		;; AX = ClusterAtualKernel neste momento

;;*****************************************************************************
	
;; Passo 5: executar Kernel
	
transferir_controle_ao_kernel:

	mov al, byte [NumeroDrivedeBoot]	
	
	jmp SEGMENTO_KERNEL:0000		;; Transferir o controle ao Kernel
									;; O controle não voltará ao carregador de inicialização

;;*****************************************************************************

;; Converter número do setor lógico em especificações físicas
;; (Também chamado de tradução LBA a CHS, porque ele converte um bloco lógico
;;  em cabeça - setor - cilindro)
;; Estes valores são devolvidos nos registradores adequados, em preparação
;; para uma chamada int 13h
;;
;; Número do setor lógico = (C * Ncabeças + H) * Nsetores + (S - 1)
;; onde C = cilindros , H = cabeça, e S = setor
;;
;; Entrada:
;;
;; Número do setor lógico em AX
;;
;; Saída:
;;
;; Vários registos modificados em preparação para uma chamada int 13h 
;; e contendo valores para C, H, S, e o número da unidade
;;
;; Não conserva registradores!


DISQUETE_logico_para_fisico:	

	push ax				;; Setor lógico

	mov dx, 0
	div word [bpbSetoresPorTrilha]	
	
			;; AX = número de setor lógico / setores por trilha
			;; O que equivale ao número lógico de trilha
            ;; DX = setor lógico número % setores por trilha
            ;; O que equivale ao número do setor físico		
			
	inc dl     ;; A numeração de setor físico se baseia em -1
    mov cl, dl ;; Número do setor físico presente em CL para chamadas int 13h
	
	pop ax				;; AX = setor lógico
	
	mov dx, 0
	div word [bpbSetoresPorTrilha] 
	
        ;; AX = número setor lógico / setores por trilha
        ;; O que equivale ao número lógico de trilha
									
	mov dx, 0
	div word [bpbCabecas]		;; AX = número lógico da trilha / cabeças
                                ;; DX = número lógico da trilha % cabeças
	
	mov dh, dl			;; O número da cabeça física permanece em DH para chamadas a int 13h
	mov ch, al			;; Trilha física (cilindro) permanece em CH para chamadas a int 13h
					
	mov dl, byte [NumeroDrivedeBoot]	;; O número do Drive permanece em DL para chamdas a int 13h
	
	ret

;;*****************************************************************************

reiniciar_disquete:

	pusha
	mov cx, 10					;; Serão tentadas 10 vezes

;;*****************************************************************************
	
reiniciar_disquete_loop:	

	mov si, MENSAGEM_ReinicioDisquete
	call IMPRIMIR_string
	
	mov ah, 0
	mov dl, byte [NumeroDrivedeBoot]
	clc
	int 13h							;; int 13h função 0 - reiniciar drive
	jnc reiniciar_disquete_sucesso		
	
	dec cx
	jcxz reiniciar_disquete_falha		;; Se já esgotou as tentativas, suspender a CPU
	
	jmp reiniciar_disquete_loop

;;*****************************************************************************
	
reiniciar_disquete_sucesso:	

	popa
	
	ret

;;*****************************************************************************
	
reiniciar_disquete_falha:

	mov si, MENSAGEM_ErroDisquete
	call IMPRIMIR_string

;;*****************************************************************************
	
SUSPENDER_cpu:

	cli							;; Sem interrupções
	hlt							;; Suspender CPU

;;*****************************************************************************
;;
;; Utilidades
;;
;;*****************************************************************************


;; Entrada:
;;
;;		DS:SI apontando para a string

IMPRIMIR_string:

	pusha
	mov ah, 0Eh
	mov bx, 0007h	;; Cinza no fundo preto

;;*****************************************************************************
	
IMPRIMIR_string_loop:

	lodsb
	
	cmp al, 0		;; Strings terminam em 0
	je IMPRIMIR_string_fim
	
	int 10h
	
	jmp IMPRIMIR_string_loop

;;*****************************************************************************
	
IMPRIMIR_string_fim:

	popa
	
	ret


;;*****************************************************************************
	
	times 512 - 2 - ($ - $$)  db 0		;; Total de 510 bytes
	
 
	dw 0AA55h		;; Assinatura para a BIOS
