	org	0
	LD	SP, 809BH
	JP	main
	HALT

main:

LCDCOM  equ 2     ; For sending a command to the LCD
LCDCHR  equ 3     ; For sending a character to the LCD

    ; Setting up the LCD display

    LD    A, 38H      ; function set.
    OUT   LCDCOM, A

    LD    A, 0CH      ; display on
    OUT   LCDCOM, A

    LD    A, 01H      ; clear display
    OUT   LCDCOM, A

    LD    A, 06H      ; entry mode
    OUT   LCDCOM, A

    ; end beginning asm.
	LD	A, 5

	LD	HL, 33023
	LD	(HL), A

    ; begin second asm.
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

characters: .ascii '0123456789ABCDEF'
