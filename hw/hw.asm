    org 0

LCDCOM  equ 0h
LCDCHAR equ 1h


    LD  A,  38h ; FUNCTION SET. 00  0011 1000 
    OUT LCDCOM, A 
    OUT LCDCOM, A

    LD  A,  0Ch ; DISPLAY ON.   00  0000 1100 
    OUT LCDCOM, A

    LD  A,  1h  ; CLEAR DISP.   00  0000 0001
    OUT LCDCOM, A

    LD  A,  6h  ; ENTRY MODE.   00  0000 0110
    OUT LCDCOM, A

    LD  A, "H"  ; CHARACTER.    'H'
    OUT LCDCHAR, A

    LD  A, "e"  ; CHARACTER.    'e'
    OUT LCDCHAR, A

    LD  A, "l"  ; CHARACTER.    'l'
    OUT LCDCHAR, A

    LD  A, "l"  ; CHARACTER.    'l'
    OUT LCDCHAR, A

    LD  A, "o"  ; CHARACTER.    'o'
    OUT LCDCHAR, A

    LD  A, ","  ; CHARACTER.    ','
    OUT LCDCHAR, A

    LD  A, " "  ; CHARACTER.    ' '
    OUT LCDCHAR, A

    LD  A, "w"  ; CHARACTER.    'w'
    OUT LCDCHAR, A

    LD  A, "o"  ; CHARACTER.    'o'
    OUT LCDCHAR, A

    LD  A, "r"  ; CHARACTER.    'r'
    OUT LCDCHAR, A

    LD  A, "l"  ; CHARACTER.    'l'
    OUT LCDCHAR, A

    LD  A, "d"  ; CHARACTER.    'd'
    OUT LCDCHAR, A

    LD  A, "!"  ; CHARACTER.    '!'
    OUT LCDCHAR, A


l1:
    JP l1




