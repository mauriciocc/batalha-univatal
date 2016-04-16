org 100h           

.DATA

    mensagem_inicial DB "BEM VINDO AO UNIVATAL, FAVOR DIGITE EM MAIUSCULO, A POSICAO DE SEUS NAVIOS:",0

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
    
    
    ; Variavel para informar metodos a respeito de qual tabuleiro esta sendo realizada a operacao (1 ou 2)
    var_tabuleiro DB 1
    
    ; Aqui guarda as informacoes do tabuleiro, onde estao os barcos, disparos, etc. (matriz 8x8 = 64 posicoes)
    var_status_tabuleiro1 DB 64 DUP(const_agua)
    var_status_tabuleiro2 DB 64 DUP(const_agua)
    

    posX DW 0
    posY DW 0   
    posicao DW 0
    
    
    ; Controla a orientacao da funcao _escreve_char (usar constantes const_horizontal e const_vertical)
    orientacao_escrita DB const_horizontal
    
    ; Controla o que sera desenhado ao chamar a funcao _desenha_objeto
    var_objeto DB const_objeto_barril       
    
    mult DB 0
    aux  DB 0

.CODE


MOV AX, 0B800h
MOV ES, AX  

;TELA_INICIAL:
;    MOV SI, offset mensagem_inicial 
;    CALL _escreve_vetor_char



; Aqui precisamos coletar as posicoes do usuario



mov var_tabuleiro, 1
call _desenha_tabuleiro

mov posX, 2
mov posY, 2
mov var_objeto, const_objeto_barril
mov orientacao_escrita, const_vertical
mov var_tabuleiro, 1
call _desenha_objeto

mov var_tabuleiro, 2
call _desenha_tabuleiro

ret



; Logica ----------------------------------------
                                                              

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
    
    mov ax, posX    
    mul posY
    
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

ret



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
;
; O retorno e feito no registrador AL
; caso retorne 1 -> quer dizer que a posicao e valida
; caso retorne 0 -> quer dizer que a posicao e invalida
_valida_posicao_objeto:
    
    push posX
    push posY
    
    mov ax, 0
    mov al, var_objeto
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
     
     mov al, 1
    
    
    __vpo_fim:
    pop posY
    pop posX
    
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

    call _gotoXY

    push posX
    push posY    
       

    mov cx, const_numero_colunas        
    mov al, const_char_inicio_colunas
    
    mov orientacao_escrita, const_horizontal
    
    call _escreve_espaco
    
    dt_loop_cols:
    
        call _escreve_char        
        inc al            
        
    loop dt_loop_cols
    
    
    pop posY
    pop posX

    push posX
    push posY
    
    inc posY
    
    call _gotoXY
    
    mov cx, const_numero_linhas        
    mov al, const_char_inicio_linhas
    mov orientacao_escrita, const_vertical
    
    dt_loop_rows:
    
        call _escreve_char        
        inc al            
        
    loop dt_loop_rows

    pop posY
    pop posX

    inc posX
    mov cx, posX
    
    inc posY
    call _gotoXY
    
    mov si, bx
    mov bx, 0
    mov orientacao_escrita, const_horizontal
    __dt_stat_loop_linhas:
    
        __dt_stat_loop_cols:

            mov al, bl
            mul bh
            push si
            add si, ax
            mov al, [si]
            call _escreve_char
            pop si

        inc bh        
        cmp bh, const_numero_colunas
        jl __dt_stat_loop_cols

    mov posX, cx
    inc posY
    call _gotoXY
    mov bh, 0
    inc bl
    cmp bl, const_numero_linhas
    jl __dt_stat_loop_linhas

    
   
        
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