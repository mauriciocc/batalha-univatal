org 100h           

.DATA

    mensagem_inicial DB "BEM VINDO AO UNIVATAL, FAVOR DIGITE EM MAIUSCULO, A POSICAO DE SEUS NAVIOS:"
    mensagem_inicial_size = $ - mensagem_inicial
         
    mensagem_valor1   DB "ESCOLHA UM DOS SEGUINTES OBJETOS QUE DESEJA POSICIONAR NO TABULEIRO:"
    mensagem_valor1_size = $ - mensagem_valor1
     
    mensagem_valor1_2 DB "{1}- BARRIL, {2}- BOTE, {3}- LANCHA, {4}- BARCACA"
    mensagem_valor1_2_size = $ - mensagem_valor1_2
    
    mensagem_valor2 DB "DIGITE A ORIENTACAO DO OBJETO: "
    mensagem_valor2_size = $ - mensagem_valor2
    
    mensagem_valor3 DB "DIGITE O NUMERO COLUNA E O NUMERO DA LINHA DE 1 A 8 "
    mensagem_valor3_size = $ - mensagem_valor3
    
    ; Constantes de desenho
    const_popa_horizontal       EQU '<'    
    const_proa_horizontal       EQU '>'
    const_popa_vertical         EQU '^'
    const_proa_vertical         EQU 'Y'
    const_conves                EQU '0'
    const_barril                EQU 'O'
    const_agua                  EQU ' '
    const_agua_atingida         EQU 178
    const_embarcacao_atingida   EQU '*'
    const_posicao_tiro_feito    EQU '.'
    
    
    const_barril_arr         DB const_barril,0
    const_bote_horizontal    DB const_popa_horizontal, const_proa_horizontal,0
    const_bote_vertical      DB const_popa_vertical, const_proa_vertical,0
    const_lancha_horizontal  DB const_popa_horizontal, const_conves, const_proa_horizontal,0
    const_lancha_vertical    DB const_popa_vertical, const_conves, const_proa_vertical,0
    const_barcaca_horizontal DB const_popa_horizontal, const_conves, const_conves, const_proa_horizontal,0
    const_barcaca_vertical   DB const_popa_vertical, const_conves, const_conves, const_proa_vertical,0
    
    ; Constantes para utilizar no "var_objeto"
    const_objeto_barril EQU 1
    const_objeto_bote EQU 2
    const_objeto_lancha EQU 3
    const_objeto_barcaca EQU 4

    ; Constantes para utilizar no "orientacao_escrita" 
    const_horizontal            EQU 'H'
    const_vertical              EQU 'V'
    
    
    ; Constantes do tabuleiro    
    const_char_inicio_colunas        EQU 'A'
    const_char_inicio_linhas         EQU '1'
    
    ; Posicoes iniciais dos tabuleiros
    const_tabuleiro1_x          EQU 1
    const_tabuleiro1_y          EQU 5 
    
    const_tabuleiro2_x          EQU 41
    const_tabuleiro2_y          EQU 5      
    
    ; Tamanho do tabuleiro
    const_numero_colunas EQU 8
    const_numero_linhas  EQU 8
    numero_1 EQU 31h
    numero_8 EQU 38h
    
    
    ; Variavel para informar metodos a respeito de qual tabuleiro esta sendo realizada a operacao (1 ou 2)
    var_tabuleiro DB 1
    
    ; Aqui guarda as informacoes do tabuleiro, onde estao os barcos, disparos, etc. (matriz 8x8 = 64 posicoes)
    var_status_tabuleiro1 DB 64 DUP(const_agua)
    var_status_tabuleiro2 DB 64 DUP(const_agua)
    var_disparos_outro_player DB 64 DUP(const_agua)
    

    posX DW 0
    posY DW 0   
    posicao DW 0
    
    
    ; Controla a orientacao da funcao _escreve_char (usar constantes const_horizontal e const_vertical)
    orientacao_escrita DB const_horizontal
    
    ; Controla o que sera desenhado ao chamar a funcao _desenha_objeto
    var_objeto DB const_objeto_barril       
    
    mult DB 0
    aux  DB 0
    
    str_buffer DB 64 DUP(?)

.CODE

MOV AX, 0B800h
MOV ES, AX  

TELA_INICIAL:
mov posX, 1
mov posY, 1
lea bp, mensagem_inicial
mov cx, mensagem_inicial_size 
call _fast_string_write                          
   

; Aqui precisamos coletar as posicoes do usuario
;;;;;;;;;**************************************************************
mov var_tabuleiro, 1           
call _desenha_tabuleiro

volta_msgm:


mov posX, 1
mov posY, 15    

lea bp, mensagem_valor1 
mov cx, mensagem_valor1_size
CALL _fast_string_write

add posX, 10
inc posY
lea bp, mensagem_valor1_2 
mov cx, mensagem_valor1_2_size
CALL _fast_string_write

CALL SEL_OBJETO

mov posX, 1
inc posY
lea bp, mensagem_valor2 
mov cx, mensagem_valor2_size
CALL _fast_string_write


CALL ORIENTACAO

mov posX, 1
inc posY
lea bp, mensagem_valor3 
mov cx, mensagem_valor3_size
CALL _fast_string_write


CALL AGUARDA_NUMERO
    MOV posX, AX          ; SALVA VALOR DIGITADO DA COLUNA
CALL AGUARDA_NUMERO
    MOV posY, AX          ; SALVA VALOR DIGITADO DA LINHA

mov var_tabuleiro, 1
call _desenha_objeto
jmp volta_msgm

mov var_tabuleiro, 2
call _desenha_tabuleiro

ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;; FUNCOES DE LEITURA DO DE TECLAS ;;;;;;;;;;;;;;;;

ORIENTACAO:
    MOV BL, 48h       ;LETRA H
    MOV BH, 56h       ;LETRA V
    MOV AX,0               ;CHAMA O SERVICO 0
    INT 16h                ;DO INT 16h (FUNCAO QUE ESPERA A TECLA)   

TESTA_ORIENTACAO:    
    
    CMP AL, BL             ; COMPARA SE VALOR DIGITADA EH IGUAL 
    JE SALVA_ORIENTACAO         ; SE SIM IRA SALVAR A LETRA NO VETOR DE JOGADAS          
    CMP AL,BH              ; UTILIZA UM CONTADOR AUXILIAR PARA COMPARAR SE VALOR DIGITADO EH MAIOR QUE "H" OU MENOR QUE "A"
    JE SALVA_ORIENTACAO      ; VALOR DEVE APRESENTAR CARRY, CASO CONTRARIO VALOR NAO EH ACEITO
  
                          ; INCREMENTA CONTADOR
    JMP ORIENTACAO        ; RECURSAO       

SALVA_ORIENTACAO:
    mov orientacao_escrita,AL

ret

SEL_OBJETO:

    MOV BL, 31h            ;REGISTRADOR AUXILIAR
    MOV BH, 34h 
    MOV AX,0               ;CHAMA O SERVICO 0
    INT 16h                ;DO INT 16h (FUNCAO QUE ESPERA A TECLA)   

TESTA_OBJETO:    
    
    CMP AL, BL             ; COMPARA SE VALOR DIGITADA EH IGUAL 
    JE SALVA_OBJETO        ; SE SIM IRA SALVAR A LETRA NO VETOR DE JOGADAS          
  
    MOV CL,BL              ; UTILIZA UM CONTADOR AUXILIAR PARA COMPARAR SE VALOR DIGITADO EH MAIOR QUE "H" OU MENOR QUE "A"
    SUB CL,BH
    JNC SEL_OBJETO         ; VALOR DEVE APRESENTAR CARRY, CASO CONTRARIO VALOR NAO EH ACEITO
  
    INC BL                 ; INCREMENTA CONTADOR
    JMP TESTA_OBJETO       ; RECURSAO       

SALVA_OBJETO:
    
    SUB AL,48
    mov var_objeto,AL

ret


                 

                 
AGUARDA_NUMERO:
                                 
    MOV BL, numero_1       ;REGISTRADOR AUXILIAR
    MOV BH, numero_8 
    MOV AX,0               ;CHAMA O SERVICO 0
    INT 16h                ;DO INT 16h (FUNCAO QUE ESPERA A TECLA)   
           
TESTA_NUMERO:        
  
    CMP AL, BL             ; COMPARA SE VALOR DIGITADA EH IGUAL 
    JE SALVA_NUMERO         ; SE SIM IRA SALVAR A LETRA NO VETOR DE JOGADAS          
  
    MOV CL,BL              ; UTILIZA UM CONTADOR AUXILIAR PARA COMPARAR SE VALOR DIGITADO EH MAIOR QUE "H" OU MENOR QUE "A"
    SUB CL,BH
    JNC AGUARDA_NUMERO      ; VALOR DEVE APRESENTAR CARRY, CASO CONTRARIO VALOR NAO EH ACEITO
  
    INC BL                 ; INCREMENTA CONTADOR
    JMP TESTA_NUMERO        ; RECURSAO       

SALVA_NUMERO:                 
  
    ;mov aux, AL
    MOV AH, 0 
    SUB AL,48
    

ret

                 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                 
                 



; Logica ----------------------------------------
                                                              

;-------------------------------------------------------------
; Efetua disparo na posicao especificada (grava na variavel var_status_tabuleiro2)
;
; Parametros:
;  - posX
;  - posY
;
; Retorna:
;  - AL = 0 se disparo nao pode ser efetuado
;  - AL = 1 se disparo foi efetuado
;
; Exemplo de uso
;
;mov posX, 2
;mov posY, 2
;call _efetua_disparo
_efetua_disparo:
    push si
    
        call _valida_disparo
        
        cmp al, 1
        
        je __ed_run
            jmp __ed_end
        __ed_run:
        
        call _calcula_posicao_memoria    
        mov si, ax
        mov var_status_tabuleiro2[si], const_posicao_tiro_feito
        
        mov ax,1
    
    __ed_end:
    pop si        

ret

;-------------------------------------------------------------
; Busca por disparo efetuado (var_disparos_outro_player) e 
; altera em memoria com os resultados 
; (var_disparos_outro_player e var_status_tabuleiro1)
;
; Variaveis utilizadas:
;   - var_disparos_outro_player 
;   - var_status_tabuleiro1
;
; O retorno e feito no registrador AX:
;  1 -> caso tenha acertado algo
;  0 -> nao acertou nada
; Exemplo de uso:
;
;; Insere disparo na posicao 2
;lea si, var_disparos_outro_player
;add si, 2
;mov [si], const_posicao_tiro_feito
;
;; Insere barril na posicao 2
;lea si, var_status_tabuleiro1
;add si, 2
;mov [si], const_barril
;
;call _substitui_disparo_outro_player
_substitui_disparo_outro_player:
    push si
    push bx
    
        lea si, var_disparos_outro_player
        call _busca_disparo_outro_player
        
        cmp ax, -1
        
        jne __sdop_encontrou_disparo
            mov ax, 0
            ret
        __sdop_encontrou_disparo:
        
        ;checa se acertou algo
        
        lea si, var_status_tabuleiro1
        add si, ax
        
        push ax
            mov al, [si]    
            call _acertou_algo
            cmp al, 1
        pop ax
        
        je __sdop_acertou_algo
            ;aqui nao acertou
            mov bl, const_agua_atingida
            mov bh, 0       
            jmp __sdop_acertou_algo_end
        __sdop_acertou_algo:  
            ;aqui quer dizer que acertou
            mov bl, const_embarcacao_atingida
            mov bh, 1
        __sdop_acertou_algo_end:    
                  
        
        ;pega caracter e substui nas memorias    
        lea si, var_disparos_outro_player
        add si, ax
        mov [si], bl
        
        lea si, var_status_tabuleiro1
        add si, ax
        mov [si], bl
        
        mov ax, 0
        mov al, bh
        
    pop bx    
    pop si

ret


;-------------------------------------------------------------
; Realiza busca por disparo efetuado (ver constante "const_posicao_tiro_feito")
; Parametros:
;  - SI (deve estar setado no offset do vetor a ser verificado, acredito que sera "var_disparos_outro_player")
; Logica:
;  Busca no vetor um valor igual a "const_posicao_tiro_feito"
;  Caso encontre: retorna o indice do elemento dentro do vetor no registrador AX
;  Caso nao econtre: retorna no AX -> -1
; 
; Exemplo de uso:

;; Escreve disparo na posicao 3 do vetor (si+2)
;lea si, var_disparos_outro_player
;add si, 2
;mov [si], const_posicao_tiro_feito
;
;; Busca a posicao do disparo, apos chamada o registrador AX contera o valor 2
;lea si, var_disparos_outro_player
;call _busca_disparo_outro_player
 
_busca_disparo_outro_player:    
        
    mov ax, 0
    
    __bdop_loop:
        push si
            add si, ax
            mov bl, [si]
        pop si
        
        cmp bl, const_posicao_tiro_feito
        
        je __bdop_end_loop
        
        inc ax
        
        cmp ax, 64
        je __bdop_end_loop_not_found
            
        
    jmp __bdop_loop
    
    __bdop_end_loop_not_found:
    mov ax, -1
    __bdop_end_loop:  
ret                                                              

;-------------------------------------------------------------
; Verifica se posicao selecionada para disparo ja nao foi utilizada
; Parametros:
;  - posX
;  - posY
; Logica:
;  Checa na variavel "var_status_tabuleiro2" se ja nao houve disparo na posicao
; O retorno e feito no registrador AL
; caso retorne 1 -> quer dizer que pode disparar
; caso retorne 0 -> quer dizer que ja houve disparo
_valida_disparo:
    push bx
    push si
    
    call _calcula_posicao_memoria 
       
    mov si, ax
    mov al, var_status_tabuleiro2[si]
    
    cmp al, const_agua
    
    jne __vd_diferente
        mov al, 1    
        jmp __vd_fim    
    __vd_diferente:
        mov al, 0      
    __vd_fim: 
    pop si
    pop bx    




;-------------------------------------------------------------
; Verifica se a posicao para posicionamento do objeto e valida
;
; NOTA: posX e posY em relacao ao tabuleiro (8x8 neste caso) 
;
; Parametros:
;  - posX
;  - posY
;  - orientacao_escrita
;  - var_objeto
;
; Logica:
;  - Calcula tamanho do objeto
;  - Verifica se ele vai ser desenhado ao longo do X ou Y
;  - Incrementa o valor da posicao X ou Y dependendo da orientacao da escrita
;  - Verifica se os valores nao estouram o tamanho do tabuleiro
;  - Checa se o posicionamento da embarcacao nao ira sobrepor outra embarcacao
;
; O retorno e feito no registrador AL
; caso retorne 1 -> quer dizer que a posicao e valida
; caso retorne 0 -> quer dizer que a posicao e invalida
_valida_posicao_objeto:
    
    push posX
    push posY
    
    mov ax, 0
    mov al, var_objeto
    mov cx, ax
    dec al    
    
    cmp orientacao_escrita, const_horizontal
    
    jne __vpo_vertical
        add posX, ax      
        jmp __vpo_fim_orientacao 
    __vpo_vertical:
        add posY, ax
    
    __vpo_fim_orientacao:    
    
    cmp posX, const_numero_colunas    
    jng  __vpo_nao_e_maior_x
        mov al, 0
        jmp __vpo_fim   
    __vpo_nao_e_maior_x:
     
    cmp posY, const_numero_linhas    
    jng  __vpo_nao_e_maior_y
        mov al, 0
        jmp __vpo_fim   
     __vpo_nao_e_maior_y:
    
	
	pop posY
    pop posX
    
	push posX
    push posY
	
	__vpo_loop_validacao:
	
        ; Valida se a posicao contem agua        
		call _calcula_posicao_memoria
		push si
			mov si, ax			
			cmp var_status_tabuleiro1[si], const_agua
		pop si
		je __vpo_agua_encontrada
			mov ax, 0				
			jmp __vpo_fim
		__vpo_agua_encontrada:
		
		; Incrementa X ou Y
		cmp orientacao_escrita, const_horizontal
		jne __vpo_loop_vertical
		    inc posX
		    jmp	__vpo_loop_orientacao	
		__vpo_loop_vertical:
		    inc posY
		
		__vpo_loop_orientacao:	
	loop __vpo_loop_validacao
    
	
    mov ax, 1    
    
    __vpo_fim:
    pop posY
    pop posX
    
ret

_calcula_posicao_memoria:
	push bx
		mov ax, posY
		dec ax
		mov bl, const_numero_colunas
		mul bl
		add ax, posX	
		dec ax
	pop bx
ret
                                                              
;-------------------------------------------------------------
; Traduz um caracter ASCII (A...H) para um valor (1,2,3...) (usado para colunas)
; Parametro deve estar no registrador AL e o retorno e feito 
; atraves do mesmo registrador

_letra_para_valor:
    SUB AL, 64
ret

;-------------------------------------------------------------
; Checa se o disparo acertou algo
; Logica: 
;
; Se AL for maior que 46(const_posicao_tiro_feito) e menor que 178(const_agua_atingida)
; quer dizer que acertou algo
;
; O retorno e feito no registrador AL
; caso retorne 1 -> quer dizer que acertou
; caso retorne 0 -> quer dizer que nao acertou nada

_acertou_algo:

    CMP AL, const_posicao_tiro_feito
    
    ; SE AL <= PULA
    JLE __aa_nao_acertou
    
    CMP AL, const_agua_atingida
    
    ; SE AL >= PULA
    JLE __aa_nao_acertou
    
    mov al, 1
    ret


    __aa_nao_acertou:
    mov al, 0
ret 




; Interface grafica ----------------------------------------

; Posiciona na posicao X Y setadas nas variaveis posX e posY
_gotoXY:
 
    push ax
    push bx
    
    mov ax, posY
    mov bl, 160
    
    dec ax
    
    mul bl
    
    mov bx, posX
    dec bx
    
    add ax, bx
    add ax, bx
    
    mov posicao, ax
    mov di, ax
    
    pop bx
    pop ax
    
ret

; Desenha tabuleiro (setar variavel "var_tabuleiro" para o tabuleiro desejado (1 ou 2))
_desenha_tabuleiro:
    push ax
    push bx
    push cx    
    mov ah, orientacao_escrita ; Salva orientacao            


    cmp var_tabuleiro, 1

    jne __dt_pos_tabuleiro2
        mov posX, const_tabuleiro1_x
        mov posY, const_tabuleiro1_y
        mov bx, offset var_status_tabuleiro1
        jmp __dt_pos_fim
    __dt_pos_tabuleiro2:
        mov posX, const_tabuleiro2_x
        mov posY, const_tabuleiro2_y
        mov bx, offset var_status_tabuleiro2
    __dt_pos_fim:

    push posX
    push posY    
       
    ; Constroi cabecalho do tabuleiro

    mov cx, const_numero_colunas        
    mov al, const_char_inicio_colunas
    
    mov orientacao_escrita, const_horizontal
    
    mov di, 1
    mov str_buffer[0], ' '
    
    
    dt_loop_cols:
        mov str_buffer[di], al        
        inc al
        inc di
    loop dt_loop_cols
    
    lea bp, str_buffer
    mov cx, const_numero_colunas+1    
    call _fast_string_write


    ; Constroi corpo do tabuleiro
    mov cx, 0         
    mov al, const_char_inicio_linhas
    mov orientacao_escrita, const_vertical
    mov si, bx
    dt_loop_rows:

        inc posY ; Proxima linha
        mov str_buffer[0], al ; Move o numero da coluna
        mov di, 1

         __dt_stat_loop_cols:
            push ax
                mov al, cl
                mov ah, const_numero_colunas
                mul ah
                add al, ch
                push si
                    add si, ax
                    mov al, [si]
                    mov str_buffer[di], al
                pop si
            pop ax

        inc di
        inc ch        
        cmp ch, const_numero_colunas
        jl __dt_stat_loop_cols

        push cx
            lea bp, str_buffer
            mov cx, const_numero_colunas+1    
            call _fast_string_write
        pop cx

        inc al            
        inc cl
        cmp cl, const_numero_linhas

    jne dt_loop_rows

    pop posY
    pop posX

    mov orientacao_escrita, ah; Restaura orientacao
    pop cx
    pop bx
    pop ax
ret  

 

;-----------------------------------------------------------

; Desenha objeto considerando as variaveis:
; - posX: posicao aonde sera desenhado no X do tabuleiro (1 ate 8 neste caso)
; - posY: posicao aonde sera desenhado no Y do tabuleiro (1 ate 8 neste caso)
; - var_objeto: define qual objeto desenhar (ver constantes)
; - orientacao_escrita: define a orientacao do desenho (ver constantes)
; - var_tabuleiro

_desenha_objeto:    
    
    ; Posiciona no tabuleiro
    push posX
    push posY
    
    cmp var_tabuleiro, 1
    
    jne __do_pos_tabuleiro_2    
        add posX, const_tabuleiro1_x
        add posY, const_tabuleiro1_y
        jmp __do_pos
    __do_pos_tabuleiro_2:
        add posX, const_tabuleiro2_x
        add posY, const_tabuleiro2_y
        
    __do_pos:
    
    call _gotoXY
    
    pop posY
    pop posX
    
    ; Fim do posicionamento
                                
    push si
    
    ; Checa barril
    cmp var_objeto, const_objeto_barril
        
    JNE __do_pula_barril
        mov si, offset const_barril_arr
        jmp __db_fim
    __do_pula_barril:
     
    
    cmp orientacao_escrita, const_horizontal
    
    JNE __db_orientacao_vertical:    
        
        
        ; Checa bote
        cmp var_objeto, const_objeto_bote
        
        JNE __do_pula_bote_horizontal
            mov si, offset const_bote_horizontal                           
            jmp __db_fim
        __do_pula_bote_horizontal:
        
        ; Checa lancha
        cmp var_objeto, const_objeto_lancha
        
        JNE __do_pula_lancha_horizontal
            mov si, offset const_lancha_horizontal                           
            jmp __db_fim
        __do_pula_lancha_horizontal:
        
        ;Se nao for nenhum, e barcaca
        mov si, offset const_barcaca_horizontal                           
        jmp __db_fim        
                                   
                                        
     __db_orientacao_vertical:
        ; Checa bote
        cmp var_objeto, const_objeto_bote
        
        JNE __do_pula_bote_vertical
            mov si, offset const_bote_vertical                           
            jmp __db_fim
        __do_pula_bote_vertical:
        
        ; Checa lancha
        cmp var_objeto, const_objeto_lancha
        
        JNE __do_pula_lancha_vertical
            mov si, offset const_lancha_vertical                           
            jmp __db_fim
        __do_pula_lancha_vertical:
        
        ;Se nao for nenhum, e barcaca
        mov si, offset const_barcaca_vertical                           
           
        
    __db_fim:    
    push si
    call _escreve_vetor_char
    pop si
    ; Fim do desenha em tela                       
    
    
    ; Escreve na memoria
    push di
    push ax
    push bx

    mov ax, posY
    dec ax
    mov bx, const_numero_linhas
    mul bx
    add ax, posX
    dec ax    

    cmp var_tabuleiro, 1    
    jne __do_mem_tabuleiro2            
        
        add ax, offset var_status_tabuleiro1        
        mov di, ax
        call _escreve_vetor_char_mem            
        
    
    __do_mem_tabuleiro2:
    
    
    
    
    ; Fim da escrita em memoria
    pop bx
    pop ax
    pop di
    pop si
    
ret                                                         

;-----------------------------------------------------------

; Escreve um ' ' na posicao atual
_escreve_espaco:
    push ax
        mov al, ' '
        call _escreve_char
    pop ax
ret

; Escreve char que esta no registrador AL em tela
_escreve_char:        
    MOV ES:[DI], AL ; ESCREVE CARACTER
    MOV ES:[DI+1], 00011111b ;10101110b ; ESCREVE ATRIBUTO
    
    CMP orientacao_escrita, const_horizontal
    
    JNE __ec_orientacao_vertical:
        ADD DI, 2
        ret    
     __ec_orientacao_vertical:
        ADD DI, 160
ret


_escreve_vetor_char:     
    

    MOV AL, [SI]
    
    CMP AL, 0
    
    JZ __ev_fim
    
        call _escreve_char
            
        INC SI            
        
        JNZ _escreve_vetor_char
    
    __ev_fim:      
    

ret

; Escreve char que esta no registrador AL em memoria
; Escreve no endereco de DI
_escreve_char_memoria:        
    MOV [DI], AL ; ESCREVE CARACTER    
    
    CMP orientacao_escrita, const_horizontal
    
    JNE __ecm_orientacao_vertical:
        ADD DI, 1
        ret    
     __ecm_orientacao_vertical:
        ADD DI, const_numero_colunas
ret

; Escreve vetor do SI no DI
_escreve_vetor_char_mem:


    MOV AL, [SI]
    
    CMP AL, 0
    
    JZ __evcm_fim
    
        call _escreve_char_memoria
            
        INC SI            
        
        JNZ _escreve_vetor_char_mem
    
    __evcm_fim:      

ret

; cx - number of chars
; lea bp - message memory offset
; posX
; posY
;
; Exemplo:
;
;mov posX, 1
;mov posY, 1
;lea bp, mensagem_inicial
;mov cx, mensagem_inicial_size
;call _fast_string_write
;
_fast_string_write:
pusha
    push es
    
        MOV AX, 0700h
        MOV ES, AX
        
        mov     bh, 0    ; page.
        ;mov     bl, 00fh ; default attribute.
        mov bl, 00011111b
            
        mov     ax, posX
        dec     ax
        mov     dl, al    ; col.
        
        mov     ax, posY
        dec     ax
        mov     dh, al    ; row.
        
        mov     ah, 13h  ; function.
        mov     al, 1    ; sub-function.
        int     10h
    
    pop es    

popa

ret

_wait_key_press:
    ; wait for any key press....
    mov     ah, 0
    int     16h
ret