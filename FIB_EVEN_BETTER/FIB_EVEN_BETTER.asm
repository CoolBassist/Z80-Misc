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

        LD  A, 1h
        LD  B, 1h

begin:  
        CALL    displayA
        ADD A,  B 
        LD  C,  A 
        LD  A,  B 
        LD  B,  C 
        JP  NC, begin

        HALT


displayA:
        LD      D,  A   ; temporarily stores A in D
        