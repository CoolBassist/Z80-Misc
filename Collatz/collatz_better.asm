; Library for outputting to an LCD screen
; Written by github.com/coolbassist


LCDCOM  equ 2     ; For sending a command to the LCD
LCDCHR  equ 3     ; For sending a character to the LCD

      org 0

      ; Setting up the LCD display

      LD    A, 38H      ; function set.
      OUT   LCDCOM, A

      LD    A, 0CH      ; display on
      OUT   LCDCOM, A

      LD    A, 01H      ; clear display
      OUT   LCDCOM, A

      LD    A, 06H      ; entry mode
      OUT   LCDCOM, A

      ; Display set up is now finished



      LD   SP, 80FFH   ; Setting stackpointer to highest point in RAM

      LD   A, 0
      LD   (8001h), A  ; Number of characters current displayed
      LD   (8004h), A  ; Current line



      EI                ; enable interrupts

      IM    1           ; interrupt mode 1

      LD    HL, enternum
      CALL  outputstring



      JP    start

      org 38h ; begin interupt sequence

      DI

      EX    AF, AF'
      EXX
      
      
      IN    A, 0h

      LD    HL,   8006h
      LD    (HL), A

      LD    A, 0Ah
      CALL  outputchar ; clear the screen
      CALL  outputchar ; clear the screen
      
      EXX
      EX    AF, AF'

      EI

      CALL performcollatz

      RET
      

start:
      JP    start

performcollatz:
      LD    HL, 8006h
      LD    A,  (HL)    ; loads user input into A
      CALL  outputnumber

      CP    1           ; is A one?
      JP    nz, cont    ; if not, continue with the sequence.
      RET

cont: 
      BIT   0, A        ; else is A even?
      JP    z, even     ; yes it is. Perform even routine
      LD   B, A         ; \ No it isnt, perform odd routine
      ADD  A, A         ; | 3n
      ADD  A, B         ; |
      INC  A            ; / +1
      LD   HL, 8006h
      LD   (HL), A      ; store new A in 8006h
      JP   end

even:
      RR   A            ; Divide A by 2
      LD   HL, 8006h
      LD   (HL), A      ; store new A in 8006h

end:
      LD   A, ','
      CALL outputchar
      LD   A, ' '
      CALL outputchar
      JP   performcollatz   ; Jump back to the beginning




outputchar:
      LD    (8002h), HL ; Stores HL into a temporary location
      LD    (8000h), A  ; Stores A  into a temporary location


      ; Do we need to go onto a new line?

      LD    HL, 8001h
      LD    A, (HL)
      CP    A, 16       ; Is the current number of characters equal to 16?
      CALL  Z, lb       ; If so, put a line break
      


      LD    A,  (8000h) ; restores A
      CP    A,  0Ah     ; Is the current character a line break?
      JP    nz, nonlb   ; If not, continue to the non line break section
lb:
      LD    HL, 8004h   
      LD    A, (HL)     
      CP    A, 1              ; Are we currently on the second line?
      JP    Z, clearscreen    ; If so, clear the screen
      LD    A, 0A8h           ; A is equal to 40, the location of the second line
      OUT   LCDCOM, A         ; Puts the cursor on the second line
      LD    HL, 8001h   
      LD    (HL), 0           ; sets the current number of characters to 0
      LD    HL, 8004h   
      INC   (HL)              ; increments the current line number
      JP    charcleanup
nonlb:
      LD    HL, 8001h      ; Number of characters variable
      INC   (HL)           ; Plus one
      OUT   LCDCHR, A
charcleanup:
      LD    HL, (8002h)    ; restores HL
      LD    A, (8000h)     ; restores A
      RET
clearscreen:
      LD    A, 01h
      OUT   LCDCOM, A
      LD    HL, 8004h
      LD    (HL), 0        ; resets the line number
      LD    HL, 8001h   
      LD    (HL), 0        ; sets the current number of characters to 0

      RET                  ; returns back to the call in outputchar

outputstring:
      LD    A, (HL)
      CALL  outputchar
      INC   HL
      LD    A, (HL)
      CP    A, 0
      JP    NZ, outputstring
      RET

outputnumber:
      LD   (8005h), A   ; temporarily store A at memory location 8000

    ; most significant digit

      RR    A           ; \ 
      RR    A           ; | Moving left most bits to the right
      RR    A           ; |
      RR    A           ; /


      AND   0Fh         ; A is now within the range 0-F
      CP    A, 0        ; Is A 0?
      JP    z, LSD      ; If so, dont bother printing leading digit
                        ; Else, continue printing leading digit

      LD    HL, characters ; loading the start of array into HL
      ADD   A, L           ; indexing the array
      LD    L, A           ; loading the new index into L
      LD    A, (HL)        ; loading the element into A 
      CALL  outputchar     ; output digit

    ; least significant digit
LSD:
      LD    A, (8005h)     ; setting A back to original

      AND   0Fh            ; A is now within the range 0-F

    
      LD    HL, characters ; loading the start of array into HL
      ADD   A, L           ; indexing the array
      LD    L, A           ; loading the new index into L
      LD    A, (HL)        ; loading the element into A 
      CALL  outputchar     ; output digit

    ; cleaning up after ourselves

      LD    A, (8005h)     ; put the original value of A back into A.

    ; returning

      RET

characters: .ascii "0123456789ABCDEF"

enternum: .ascii "Enter number!", 0