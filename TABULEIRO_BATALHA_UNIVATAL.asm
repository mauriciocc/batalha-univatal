;; JEREMIAS 11/04/2016
;; UTILIZEI A FUNCAO DO POSICIONAMENTO DA TELA E COLOQUEI A MONTAGEM DOS TABULEIROS 
;; QUALQUER COISA QUE QUISEREM MELHORAR, SÓ ALTERAR.


org 100h           

.DATA

    posX DW 0
    posY DW 0
    mult DB 0
    aux  DB 0
    posicao DW 0

.CODE

MOV AX, 0B800h
MOV ES, AX  

TELA_INICIAL:
    MOV SI, offset INICIO 
    CALL ESCREVE_VETOR
                 
                 
                                  
mov posX, 10
mov posY, 4
call _gotoXY



;********* CHAMA TABULEIROS EM BRANCO **********


TAB_JOGADOR_1:

    MOV SI,offset TABULEIRO1
    CALL TABULEIRO


TAB_JOGADOR_2:

    inc aux
    CMP AUX, 2
    JZ FIM
    mov posX, 50
    mov posY, 4
    call _gotoXY
    MOV SI,offset TABULEIRO2 
    mov mult,0
    CALL TABULEIRO
;***********************************************



;******************* TELA **********************

TABULEIRO:

    INC mult
    CALL ESCREVE_CARACTER


ESCREVE_COLUNA:
    
    INC posX
    call _gotoXY
    CALL ESCREVE_CARACTER
    inc mult
    CMP mult, 9
    
    JNZ ESCREVE_COLUNA
    
    mov mult,0
    sub posX, 9 
    INC posY
    call _gotoXY       

    CALL ESCREVE_COLUNA  

ret        

ESCREVE_CARACTER:

MOV AL, [SI]
MOV ES:[DI], AL ; ESCREVE CARACTER
MOV ES:[DI+1], 00011111b ;10101110b ; ESCREVE ATRIBUTO
INC DI
INC DI
INC SI

CMP AL, 0

JZ TAB_JOGADOR_2         

ret

;**********************************************

ESCREVE_VETOR:

MOV AL, [SI]
MOV ES:[DI], AL ; ESCREVE CARACTER
MOV ES:[DI+1], 00011111b ;10101110b ; ESCREVE ATRIBUTO
INC DI
INC DI
INC SI

CMP AL, 0

JNZ ESCREVE_VETOR

ret


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

FIM:
  
$

INICIO:
    db "BEM VINDO AO UNIVATAL, FAVOR DIGITE EM MAIUSCULO, A POSICAO DE SEUS NAVIOS:",0

TABULEIRO1:
    db " ABCDEFGH1........2........3........4........5........6........7........8........",0
TABULEIRO2:
    db " ABCDEFGH1........2........3........4........5........6........7........8........",0


