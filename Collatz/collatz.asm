LCDCOM  equ 2
LCDCHR  equ 3

LEDDIS  equ 4

    org 0

    LD   A, 38H      ; function set.
    OUT  LCDCOM, A

    LD   A, 0CH      ; display on
    OUT  LCDCOM, A

    LD   A, 01H      ; clear display
    OUT  LCDCOM, A

    LD   A, 06H      ; entry mode
    OUT  LCDCOM, A

    ; Display set up is now finished
    ; Initalising variables
    LD   SP, 80FFH   ; Setting stackpointer to highest point in RAM

    LD   A, 0
    LD   (8001h), A  ; Number of characters current displayed

    LD   A, 0
    LD   (8002h), A  ; Current line

    LD   A, 0
    LD   (8003h), A  ; Current index

    LD   A, 06H      ; Hard coded input. Change to user entry later.

begin:
    CALL OUTCHAR    ; Output A

    LD  HL, 8001h   ; number of characters
    LD  A, (HL)     ; loads it into A
    CP  A, 13       ; Is it greater or equal to 13?
    JP  p, newline  ; If so, add a new line
    JP  continue    ; If not, carry on.

newline:
    LD  A, 20h      ; Space character
    OUT LCDCHR, A   ; Output it
    LD  HL, 8001h   ; Number of characters variable
    INC (HL)        ; Plus one
    LD  A, (HL)     ; The second lines begins after 39 characters
    CP  A, 40       ; Is it on the next line?
    JP  nz, newline ; If not, try again

    LD  (HL), 0     ; Sets the number of characters back to 0

continue:
    LD  A, (8000h)  ; set A back to original

    CP  A, 1        ; Is A equal to 1?
    JP  z, end      ; If so jump to end. Halt.

    BIT  0, A       ; Is A even?
    JP   z, even    ; If so, jump to even
    LD   B, A       ; \
    ADD  A, A       ; | 3n
    ADD  A, B       ; |
    INC  A          ; / +1
    JP   begin      ; Jump back to the beginning

end:
    HALT            ; End

even:
    RR   A          ; Divide A by 2
    JP   begin      ; Jump back to beginning


OUTCHAR:
    LD   (8000h), A    ; temporarily store A at memory location 8000

    ; most significant digit

    RR   A              ; \ 
    RR   A              ; | Moving left most bits to the right
    RR   A              ; |
    RR   A              ; /


    AND  0Fh            ; A is now within the range 0-F
    CP   A, 0           ; Is A 0?
    JP   z, LSD         ; If so, dont bother printing leading digit
                        ; Else, continue printing leading digit

    LD   HL, characters ; loading the start of array into HL
    ADD  A, L           ; indexing the array
    LD   L, A           ; loading the new index into L
    LD   A, (HL)        ; loading the element into A 
    OUT  LCDCHR, A      ; output digit
    LD   HL, 8001h      ; Number of characters variable
    INC (HL)            ; Plus one

    ; least significant digit
LSD:
    LD   A, (8000h)     ; setting A back to original

    AND  0Fh            ; A is now within the range 0-F

    
    LD   HL, characters ; loading the start of array into HL
    ADD  A, L           ; indexing the array
    LD   L, A           ; loading the new index into L
    LD   A, (HL)        ; loading the element into A 
    OUT  LCDCHR, A      ; output digit

    ; printing a space

    LD   A, 20H         ; ' ' character
    OUT  LCDCHR, A      ; output character

    ; cleaning up after ourselves

    LD   A, (8000h)     ; put the original value of A back into A.
    LD   HL, 8001h      ; Number of characters variable
    INC (HL)            ; Plus one (Least significant digit)
    INC (HL)            ; Plus one (SPACE)

    ; returning

    ret

characters: .ascii "0123456789ABCDEF"
