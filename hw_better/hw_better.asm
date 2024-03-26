    org 0

LCDCOM  equ 2h  ; To send a command to the LCD display
LCDCHAR equ 3h  ; To send a character to the LCD display
LEDDIS  equ 4h  ; To send a number to the LED display

    LD  SP, 0FFFFh

    LD  A, 0h
    OUT LEDDIS, A


    LD  A,  38h ; FUNCTION SET. 00  0011 1000 
    OUT LCDCOM, A 
    OUT LCDCOM, A

    LD  A,  0Ch ; DISPLAY ON.   00  0000 1100 
    OUT LCDCOM, A

    LD  A,  1h  ; CLEAR DISP.   00  0000 0001
    OUT LCDCOM, A

    LD  A,  6h  ; ENTRY MODE.   00  0000 0110
    OUT LCDCOM, A

    LD  HL,  message

l1:
    LD  A,   (HL)
    OUT LCDCHAR, A
    INC HL
    OR  0h
    JP  NZ, l1

    LD  A, 0h

    LD  HL, 8000h

    LD  (HL), 55h
    LD  A, (HL)

    OUT LEDDIS, A
    
    nop
    nop

    LD  A, 0h
l2:
    OUT LEDDIS, A
    nop
    INC A
    JP  l2


    HALT

message: .ascii "Hello, world!", 0h





