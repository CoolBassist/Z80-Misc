    .org 0
    LD  A, 10h
    LD  B, 3h
    ADD A, B
    XOR 12h
loop:
    JP nz, loop
    HALT 