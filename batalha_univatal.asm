org 100h           

.DATA

    posX DW 0
    posY DW 0
    
    posicao DW 0

.CODE

MOV AX, 0B800h
MOV ES, AX  

mov posX, 80
mov posY, 25
call _gotoXY

MOV AL, '_'
MOV ES:[DI], AL ; ESCREVE CARACTER
MOV ES:[DI+1], 00011111b ;10101110b ; ESCREVE ATRIBUTO


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
