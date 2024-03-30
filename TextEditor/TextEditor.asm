; Program for outputting text from a keyboard
; Written by github.com/coolbassist


; Memory map
; ADDR  | Function
; ------|---------
; 8000h | Temporary location for the A register (outputchar)
; 8001h | Number of characters on current line
; 8002h | Temporary location for H
; 8003h | Temporary location for L
; 8004h | Current line number (0 or 1)
; 8005h | Temporary location for the A register (outputnum)
; 8006h | Write pointer for CB
; 8007h | Read pointer for CB
;    ....
; 800Ah | Begin circular buffer
;    ....
; 801Ah | End circular buffer

LCDCOM  equ 2
LCDCHR  equ 3

CB_WR   equ 8006h
CB_RD   equ 8007h


	org 0

    ; Setting up the LCD display

	LD  A, 38H      ; function set.
	OUT LCDCOM, A

	LD  A, 0FH      ; display on
	OUT LCDCOM, A

	LD  A, 01H      ; clear display
	OUT LCDCOM, A

	LD  A, 06H      ; entry mode
	OUT LCDCOM, A

    ; Display set up is now finished

	LD  SP, 80FFH   ; Setting stackpointer to highest point in RAM

	LD  A, 0
	LD  (8001h), A  ; Number of characters on the current line
	LD  (8004h), A  ; Current line

    LD  A, 0Ah
    LD  (CB_WR), A ; Write pointer for CB
    LD  (CB_RD), A ; Read pointer for CB

	EI                ; enable interrupts

	IM 1           ; interrupt mode 1

	LD A, '>'
	CALL  outputchar

	JP start

	org 38h ; begin interupt sequence

	DI      ; Disable interrupts

	EX AF, AF'  ; Save the current register state
	EXX

	IN    A, 0h         ; get user input
    LD    HL, CB_WR     ; load read pointer into HL
    LD    L, (HL)       ; deferencing pointer
    LD    (HL), A       ; Load the user input into the read pointer
    LD    HL, CB_WR
    INC   (HL)          ; increment read pointer
    LD    A, L
    LD    B, 1Ah
    CP    B
    JP    NZ, intreturn
    LD    A, 0Ah
    LD    (CB_WR), A

intreturn:
	EXX
	EX AF, AF'
	EI
	RET

start:
    LD   HL, CB_WR
    LD   A, (HL)    ; loads the write pointer into A
    INC  HL         
    LD   B, (HL)    ; loads the read pointer into B
    CP   B          ; If the read and write pointers are equal, theres nothing to do.
    JP   Z, start
    ; checking for special keys
    LD   A, (CB_RD)
    LD   L, A
    LD   A, (HL)
    CP   127               ; is a backspace?
    JP   Z, backspace      ; yes it is, go to backspace subroutine
	; check for backspace,
    ; and other keys here
    LD   HL, CB_RD      ; Load read pointer into HL
    LD   L, (HL)        ; dereferencing pointer
    LD   A, (HL)        ; load the value at RP into A
    call outputchar     ; output value.
    LD   HL, CB_RD
    INC  (HL)           ; increment the RP
    LD   A, L           ; load the inc RP into mem
    LD   B, 1Ah         ; 
    CP   B              ; is it at the end of the CB?
    JP   NZ, start      ; if not go back.
    LD   A, 0Ah         
    LD   (CB_RD), A     ; if so, reset the read pointer
    
    JP   start

	HALT    ; Program should never get here.

outputchar:
    LD    (8002h), HL ; Stores HL into a temporary location
    LD    (8000h), A  ; Stores A  into a temporary location


    ; Do we need to go onto a new line?

    LD    HL, 8001h
    LD    A, (HL)
    CP    A, 16       ; Is the current number of characters equal to 16?
    CALL  Z, lb       ; If so, put a line break
      


    LD    A,  (8000h) ; restores A
    CP    A,  13      ; Is the current character a line break?
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

backspace:
    
    LD  HL, CB_WR   ; \
    DEC (HL)        ; / decrement value held at the write pointer

    LD  A, (8001h)  ; 
    CP  0
    JP  Z, start    ; are we on the far left? If so, just go back.

    DEC A
    LD  (8001h), A

    LD  A, (8004h)
    LD  B, 1
    CP  B        ; are we on the second line?

    LD  A, (8001h)

    JP  NZ, backspaceend ; if not just jump to end

    ADD A, 40h

backspaceend:
    OR  80h
    LD  B, A

    OUT LCDCOM, A
    LD  A, ' '
    OUT LCDCHR, A

    LD  A, B
    OUT LCDCOM, A

    
    JP  start
    
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