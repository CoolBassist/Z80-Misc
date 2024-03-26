    org 0

    LD  A,  1H
    LD  B,  1H

l1: OUT 0H, A
    ADD A,  B
    LD  C,  A
    LD  A,  B
    LD  B,  C
    JP  NC, l1

    HALT