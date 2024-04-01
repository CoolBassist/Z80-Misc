; Program for printing out the collatz sequence for a given number.
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
; 8010h | Begin circular buffer
;    ....
; 804Fh | End circular buffer

LCDCOM      equ 2     ; For sending a command to the LCD
LCDCHR      equ 3     ; For sending a character to the LCD

T_A_C       equ 8000h ; Temporary A for char
NO_CHR      equ 8001h ; no of characters on the line
T_HL        equ 8002h ; temporary HL

CUR_LINE    equ 8004h ; Current line number
T_A_N       equ 8005h ; temporary A for num
CB_WR       equ 8006h ; Circular Buffer write 
CB_RD       equ 8007h ; Circular Buffer read
HAS_START   equ 8008h ; Has the program started?
CB_ST       equ 10h   ; Circular Buffer start
CB_END      equ 4Fh   ; Circular Buffer end

	org 0

    ; Setting up the LCD display

	LD    A, 38H      ; function set.
	OUT   LCDCOM, A

	LD    A, 0FH      ; display on
	OUT   LCDCOM, A

	LD    A, 01H      ; clear display
	OUT   LCDCOM, A

	LD    A, 06H      ; entry mode
	OUT   LCDCOM, A

    ; Display set up is now finished

	LD    SP, 80FFH   ; Setting stackpointer to highest point in RAM

	LD    A, 0
	LD    (NO_CHR), A  ; Number of characters on the current line
	LD    (CUR_LINE), A  ; Current line

      LD    A, CB_ST
      LD    (CB_WR), A ; Write pointer for CB
      LD    (CB_RD), A ; Read pointer for CB

	EI                ; enable interrupts

	IM    1           ; interrupt mode 1

      LD    HL, HAS_START
      LD    (HL), 0

	JP    start

	org   38h ; begin interupt sequence

	DI      ; Disable interrupts

	EX    AF, AF'  ; Save the current register state
	EXX

	IN    A, 0h         ; get user input
      LD    HL, CB_WR     ; load read pointer into HL
      LD    L, (HL)       ; deferencing pointer
      LD    (HL), A       ; Load the user input into the read pointer
      LD    HL, CB_WR
      INC   (HL)          ; increment read pointer
      LD    A, (HL)
      LD    B, CB_END
      CP    B
      JP    NZ, intreturn
      LD    A, CB_ST
      LD    (CB_WR), A

intreturn:
	EXX
	EX    AF, AF'
	EI
	RET

start:
      LD    HL, CB_WR
      LD    A, (HL)    ; loads the write pointer into A
      INC   HL         
      LD    B, (HL)    ; loads the read pointer into B
      CP    B          ; If the read and write pointers are equal, theres nothing to do.
      JP    Z, start
      ; checking for special keys
      LD    A, (CB_RD)
      LD    L, A
      LD    A, (HL)
      CP    127                ; is a backspace?
      JP    Z, backspace       ; yes it is, go to backspace subroutine
      CP    13                 ; is it an enter? To start the program
      JP    Z, startprogram    ; yes it is, start the program
      ; check for backspace,
      ; and other keys here
      LD    HL, CB_RD      ; Load read pointer into HL
      LD    L, (HL)        ; dereferencing pointer
      LD    A, (HL)        ; load the value at RP into A
      CALL  outputchar     ; output value.
      LD    HL, CB_RD
      INC   (HL)           ; increment the RP
      LD    A, (HL)           ; load the inc RP into mem
      LD    B, CB_END         ; 
      CP    B              ; is it at the end of the CB?
      JP    NZ, start      ; if not go back.
      LD    A, CB_ST         
      LD    (CB_RD), A     ; if so, reset the read pointer
    
      JP    start

	HALT    ; Program should never get here.

startprogram:
      LD    HL, HAS_START
      LD    A, (HL)
      CP    1
      JP    Z, startcollatz
      LD    H, 80h
      LD    L, CB_ST
      LD    A, (HL)
      SUB   30h

      LD    HL, atn     ; loading the start of array into HL
      ADD   A, L        ; indexing the array
      LD    L, A        ; loading the new index into L
      LD    A, (HL)     ; loading the element into A

      RL    A
      LD    D, A
      RL    A
      RL    A
      ADD   D

      LD    C, A        ; Store the tens number in C

      LD    H, 80h
      LD    L, CB_ST
      INC   HL
      LD    A, (HL)
      SUB   30h


      LD    HL, atn     ; loading the start of array into HL
      ADD   A, L        ; indexing the array
      LD    L, A        ; loading the new index into L
      LD    A, (HL)     ; loading the element into A

      ADD   C           ; The two bytes combined into one number
      LD    D, A  

      LD    HL, HAS_START
      LD    (HL), 1h

      LD    A,    13
      CALL  outputchar
      CALL  outputchar

startcollatz:
      LD    HL, CB_WR   ; \
      DEC   (HL)        ; / decrement value held at the write pointer
      LD    A, D
      CALL  outputnumber
      BIT   0, A
      JP    Z, evenroutine
      ; its odd
      LD    C, A
      ADD   A, A
      ADD   A, C  ; 3n
      INC   A     ; +1
      LD    D, A
      LD    A, ' '
      CALL  outputchar
      JP    start
evenroutine:
      RR    A     ; n/2
      AND   7Fh
      LD    D, A
      LD    A, ' '
      CALL  outputchar
      JP    start

outputchar:
      LD    (T_HL), HL ; Stores HL into a temporary location
      LD    (T_A_C), A  ; Stores A  into a temporary location


    ; Do we need to go onto a new line?

      LD    HL, NO_CHR
      LD    A, (HL)
      CP    A, 16       ; Is the current number of characters equal to 16?
      CALL  Z, lb       ; If so, put a line break
      


      LD    A,  (T_A_C) ; restores A
      CP    A,  13      ; Is the current character a line break?
      JP    nz, nonlb   ; If not, continue to the non line break section
lb:
      LD    HL, CUR_LINE   
      LD    A, (HL)     
      CP    A, 1              ; Are we currently on the second line?
      JP    Z, clearscreen    ; If so, clear the screen
      LD    A, 0A8h           ; A is equal to 40, the location of the second line
      OUT   LCDCOM, A         ; Puts the cursor on the second line
      LD    HL, NO_CHR   
      LD    (HL), 0           ; sets the current number of characters to 0
      LD    HL, CUR_LINE   
      INC   (HL)              ; increments the current line number
      JP    charcleanup
nonlb:
      LD    HL, NO_CHR      ; Number of characters variable
      INC   (HL)           ; Plus one
      OUT   LCDCHR, A
charcleanup:
      LD    HL, (T_HL)    ; restores HL
      LD    A, (T_A_C)     ; restores A
      RET
clearscreen:
      LD    A, 01h
      OUT   LCDCOM, A
      LD    HL, CUR_LINE
      LD    (HL), 0        ; resets the line number
      LD    HL, NO_CHR   
      LD    (HL), 0        ; sets the current number of characters to 0

      RET                  ; returns back to the call in outputchar

backspace:
      LD    HL, CB_WR   ; \
      DEC   (HL)        ; / decrement value held at the write pointer
      LD    A, (NO_CHR)  ; 
      CP    0
      JP    Z, start    ; are we on the far left? If so, just go back.
      DEC   A
      LD    (NO_CHR), A
      LD    A, (CUR_LINE)
      LD    B, 1
      CP    B        ; are we on the second line?
      LD    A, (NO_CHR)
      JP    NZ, backspaceend ; if not just jump to end
      ADD   A, 40h

backspaceend:
      OR    80h
      LD    B, A
      OUT   LCDCOM, A
      LD    A, ' '
      OUT   LCDCHR, A
      LD    A, B
      OUT   LCDCOM, A
      JP    start
    
outputstring:
      LD    A, (HL)
      CALL  outputchar
      INC   HL
      LD    A, (HL)
      CP    A, 0
      JP    NZ, outputstring
      RET

outputnumber:
      LD   (T_A_N), A   ; temporarily store A at memory location 8005

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
      LD    A, (T_A_N)     ; setting A back to original
      AND   0Fh            ; A is now within the range 0-F
      LD    HL, characters ; loading the start of array into HL
      ADD   A, L           ; indexing the array
      LD    L, A           ; loading the new index into L
      LD    A, (HL)        ; loading the element into A 
      CALL  outputchar     ; output digit
      ; cleaning up after ourselves
      LD    A, (T_A_N)     ; put the original value of A back into A.
      RET ; returning

characters: .ascii "0123456789ABCDEF"

atn: .ascii 000102030405060708092020202020200A0B0C0D0E0Fh