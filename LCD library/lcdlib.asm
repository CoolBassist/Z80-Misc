; Program for outputting text from a keyboard.
; 213 bytes total.

; Written by github.com/coolbassist


; +-------+------------------------------------------------------+
; |  ADDR | Function                                             |
; +-------+------------------------------------------------------+
; | 8000h | Temporary location for H                             |
; | 8001h | Temporary location for L                             |
; +-------+------------------------------------------------------+
 
; +-------+------------------------------------------------------+
; |  REG  | Function                                             |
; +-------+------------------------------------------------------+
; |   A   | Main register                                        |
; |   B   | Holding values for comparing, or temp storage        |
; |   C   | How many characters are on the current line          |
; |   D   | Used for holding what line we're on                  |
; |   E   | Used for temporarily holding A                       |
; |   H   | Used for holding the high byte of addresses          |
; |   L   | Used for holding the low byte of addresses           |
; +-------+------------------------------------------------------+

LCDCOM      equ 2             ; For sending a command to the LCD
LCDCHR      equ 3             ; For sending a character to the LCD

T_HL        equ 8000h         ; Temporary H
;           equ 8001h         ; Temporary L

      org 0

      ; Setting up the LCD display

      LD    A, 38H            ; Function set.
      OUT   LCDCOM, A

      LD    A, 0FH            ; Display on
      OUT   LCDCOM, A

      LD    A, 01H            ; Clear display
      OUT   LCDCOM, A

      LD    A, 06H            ; Entry mode
      OUT   LCDCOM, A

      ; Display set up is now finished

      LD    SP, 80FFH         ; Setting stackpointer to highest point in RAM

      LD    C, 0              ; Number of characters on the current line
      LD    D, 0              ; Current line





      ; /-----------------------\
      ; | Put the program here! |
      ; \-----------------------/





      HALT


outputchar:
      LD    (T_HL), HL        ; Stores HL into a temporary location
      LD    E, A              ; Stores A  into a temporary location

      ; Do we need to go onto a new line?
      LD    A, C
      CP    A, 16             ; Is the current number of characters equal to 16?
      CALL  Z, lb             ; If so, put a line break

      LD    A,  E             ; Restores A
      CP    A,  13            ; Is the current character a line break?
      JP    nz, nonlb         ; If not, continue to the non line break section

lb:
      LD    A, D
      CP    A, 1              ; Are we currently on the second line?
      JP    Z, clear          ; If so, clear the screen
      LD    A, 0A8h           ; A is equal to 40, the location of the second line
      OUT   LCDCOM, A         ; Puts the cursor on the second line
      LD    C, 0              ; Sets the current number of characters to 0
      INC   D                 ; Increments the current line number
      JP    charcleanup
nonlb:
      INC   C                 ; Plus one
      OUT   LCDCHR, A
charcleanup:
      LD    HL, (T_HL)        ; Restores HL
      LD    A, E              ; Restores A
      RET
clear:
      LD    A, 01h
      OUT   LCDCOM, A
      LD    D, 0              ; Resets the line number
      LD    C, 0              ; Sets the current number of characters to 0
      RET                     ; Returns back to the call in outputchar

outputstring:
      LD    A, (HL)
      CALL  outputchar
      INC   HL
      LD    A, (HL)
      CP    A, 0
      JP    NZ, outputstring
      RET

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
      CALL  outputchar        ; output digit

    ; least significant digit
LSD:
      LD    A, C        ; setting A back to original
      AND   0Fh               ; A is now within the range 0-F
      LD    HL, characters    ; loading the start of array into HL
      ADD   A, L              ; indexing the array
      LD    L, A              ; loading the new index into L
      LD    A, (HL)           ; loading the element into A 
      CALL  outputchar        ; output digit

      LD    A, C              ; put the original value of A back into A.
      RET ; returning

characters: .ascii "0123456789ABCDEF"