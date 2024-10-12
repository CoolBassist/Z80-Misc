LCDCOM      equ 2             ; For sending a command to the LCD
LCDCHR      equ 3             ; For sending a character to the LCD

      .org        0

      ; Setting up the LCD display

      ;LD    A, 38H            ; Function set.
      ;OUT   LCDCOM, A

      ;LD    A, 0FH            ; Display on
      ;OUT   LCDCOM, A

      ;LD    A, 01H            ; Clear display
      ;OUT   LCDCOM, A

      ;LD    A, 06H            ; Entry mode
      ;OUT   LCDCOM, A

      ; Display set up is now finished

      ;LD    A, 10h
      ;LD    B, 4h
      ;CALL  mult

      ;CALL displayAnswer
      
      ;LD    A, 10h
      ;LD    B, 1h
      ;CALL  mult

      ;CALL displayAnswer

      ;LD    A, 10h
      ;LD    B, 0h
      ;CALL  mult

      ;CALL displayAnswer

      LD    A, 03h
      LD    B, 02h
      CALL  mult
      CALL  outputnumber
      HALT


add:
      ADD   A, B 
      ret

sub:
      SUB   B
      ret



; Multiplies the numbers stored in A and B, result in A
mult: 
      LD    C, A              ; Temporarily store A in C
      LD    A, 0h             ; Removes the need to dec B
mult1:
      LD    D, A              ; Temporarily store A
      LD    A, 0h             ; Set A to 0 for comparison
      XOR   B                 ; Is B equal to 0? Sets the Z flag
      LD    A, D              ; Restore A
      JP    z, multend        ; if Z flag is set go to the end,
      ADD   A, C              ; The addition
      DEC   B                 ; 
      JP    mult1             ; Go back to the beginning
multend:
      ret

div:
      LD    C, 0
div1:
      SUB   B
      INC   C
      JP    NC, div1
      ret


outputnumber:
      LD   E, A               ; temporarily store A in E

    ; most significant digit

      RR    A                 ; \ 
      RR    A                 ; | Moving left most bits to the right
      RR    A                 ; |
      RR    A                 ; /


      AND   0Fh               ; A is now within the range 0-F
      CP    A, 0              ; Is A 0?
      JP    z, LSD            ; If so, dont bother printing leading digit

      LD    HL, characters    ; loading the start of array into HL
      ADD   A, L              ; indexing the array
      LD    L, A              ; loading the new index into L
      LD    A, (HL)           ; loading the element into A 
      OUT   LCDCHR, A         ; output digit

    ; least significant digit
LSD:
      LD    A, C              ; setting A back to original
      AND   0Fh               ; A is now within the range 0-F
      LD    HL, characters    ; loading the start of array into HL
      ADD   A, L              ; indexing the array
      LD    L, A              ; loading the new index into L
      LD    A, (HL)           ; loading the element into A 
      OUT   LCDCHR, A         ; output digit

      LD    A, C              ; put the original value of A back into A.
      RET ; returning

displayAnswer:
      LD    B, A
      LD    A, 0Ah
      OUT   LCDCHR, A
      LD    A, 3Eh
      OUT   LCDCHR, A
      LD    A, 20h
      OUT   LCDCHR, A
      LD    A, B
      CALL  outputnumber
      ret

clear:
      LD    A, 01h
      OUT   LCDCOM, A
      ret

characters: .ascii "0123456789ABCDEF"