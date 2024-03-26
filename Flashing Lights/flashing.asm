    org 0

LCDCOM  equ 2h
LCDCHAR equ 3h
LEDDIS  equ 4h

    LD A, 0h
l2:
    OUT LEDDIS, A
    INC A
    JP l2




