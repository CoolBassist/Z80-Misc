LED equ 4h

    org 0

    LD  A, 0h
    LD  HL, 8000h
    LD  (HL), A

cond0:
    LD  HL, 8000h
    LD  A,  (HL)

    LD  A, 10
    LD  HL, 0FFFFh
    XOR (HL)
    JP  nz, loop0
    JP  end0

loop0:
    LD  HL, 8000h
    LD  A, (HL)
    OUT LED, A

    LD  HL, 8000h
    LD  A, (HL)
    LD  HL, 0FFFFh
    LD  (HL), A
    LD  A, 1
    LD  HL, 0FFFFh
    ADD A, (HL)

    LD HL, 8000h
    LD (HL), A

    JP cond0

end0:
    HALT
