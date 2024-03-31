; Program for outputting text from a keyboard
; Written by github.com/coolbassist


; +------+------------------------------------------------------+
; | ADDR | Function                                             |
; +------+------------------------------------------------------+
; |8000h | Temporary location for the A register (outputchar)   |
; |8001h | Number of characters on current line                 |
; |8002h | Temporary location for H                             |
; |8003h | Temporary location for L                             |
; |8004h | Current line number (0 or 1)                         |
; |8005h | Temporary location for the A register (outputnum)    |
; |8006h | Write pointer for CB                                 |
; |8007h | Read pointer for CB                                  |
; |   ....                                                      |
; |8010h | Begin circular buffer                                |
; |   ....                                                      |
; |804Fh | End circular buffer                                  |
; +------+------------------------------------------------------+
 
; +-------+----------------------------------------------+
; |  REG  | Function                                     |
; +-------+----------------------------------------------+
; |   A   | Main register                                |
; |   B   | Used for temporarily holding values from A   |
; |   C   | How many characters are on the current line  |
; |   D   | Used for holding what line we're on          |
; |   E   | ~Unused~                                     |
; |   H   | Used for holding the high byte of addresses  |
; |   L   | Used for holding the low byte of addresses   |
; +-------+----------------------------------------------+

LCDCOM	equ 2			; For sending a command to the LCD
LCDCHR	equ 3			; For sending a character to the LCD

T_A		equ 8000h		; Temporary A
T_HL		equ 8001h		; temporary HL
;		equ 8002h		; reserve 8002h for HL
CB_WR		equ 8003h		; Circular Buffer write 
CB_RD		equ 8004h		; Circular Buffer read
CB_ST		equ 10h		; Circular Buffer start
CB_END	equ 4Fh		; Circular Buffer end

	org 0

	; Setting up the LCD display

	LD	A, 38H		; function set.
	OUT	LCDCOM, A

	LD	A, 0FH		; display on
	OUT	LCDCOM, A

	LD	A, 01H		; clear display
	OUT	LCDCOM, A

	LD	A, 06H		; entry mode
	OUT	LCDCOM, A

	; Display set up is now finished

	LD	SP, 80FFH		; Setting stackpointer to highest point in RAM

	LD	C, 0			; Number of characters on the current line
	LD	D, 0			; Current line

	LD	A, CB_ST
	LD	(CB_WR), A		; Write pointer for CB
	LD	(CB_RD), A		; Read pointer for CB

	EI				; enable interrupts

	IM	1			; interrupt mode 1

	LD	A, '>'
	CALL	outputchar

	JP	start

	org	38h			; begin interupt sequence

	DI				; Disable interrupts

	EX	AF, AF'		; Save the current register state
	EXX

	IN	A, 0h			; get user input
	LD	HL, CB_WR		; load read pointer into HL
	LD	L, (HL)		; deferencing pointer
	LD	(HL), A		; Load the user input into the read pointer
	LD	HL, CB_WR
	INC	(HL)			; increment write pointer
	LD	A, (HL)
	CP	CB_END
	JP	NZ, intreturn
	LD	A, CB_ST
	LD	(CB_WR), A

intreturn:
	EXX
	EX	AF, AF'
	EI
	RET

start:
	LD	HL, CB_WR
	LD	A, (HL)		; Loads the write pointer into A
	INC	HL			; HL now contains read pointer
	CP	(HL)			; If the read and write pointers are equal, theres nothing to do.
	JP	Z, start

	; Special key checking
	LD	A, (CB_RD)
	LD	L, A
	LD	A, (HL)

	; Backspace checking
	CP	127			; Is a backspace?
	JP	Z, backspace	; If it is, go to backspace subroutine

	; End special key checking, assume its an ASCII character.

	LD	HL, CB_RD		; Load read pointer into HL
	LD	L, (HL)		; Dereferencing pointer
	LD	A, (HL)		; Load the value at RP into A
	CALL	outputchar		; Output value.
	LD	HL, CB_RD
	INC	(HL)			; Increment the RP
	LD	A, (HL)		; Load the inc RP into mem
	CP	CB_END		; Is it at the end of the CB?
	JP	NZ, start		; If not go back.
	LD	A, CB_ST
	LD	(CB_RD), A		; If so, reset the read pointer

	JP	start			; Creates infinite loop

outputchar:
	LD	(T_HL), HL		; Stores HL into a temporary location
	LD	(T_A), A		; Stores A  into a temporary location

	; Do we need to go onto a new line?
	LD	A, C
	CP	A, 16			; Is the current number of characters equal to 16?
	CALL	Z, lb			; If so, put a line break

	LD	A,  (T_A)		; Restores A
	CP	A,  13		; Is the current character a line break?
	JP	nz, nonlb		; If not, continue to the non line break section

lb:
	LD	A, D
	CP	A, 1			; Are we currently on the second line?
	JP	Z, clear		; If so, clear the screen
	LD	A, 0A8h		; A is equal to 40, the location of the second line
	OUT	LCDCOM, A		; Puts the cursor on the second line
	LD	C, 0			; sets the current number of characters to 0
	INC	D			; increments the current line number
	JP	charcleanup
nonlb:
	INC	C			; Plus one
	OUT	LCDCHR, A
charcleanup:
	LD	HL, (T_HL)		; restores HL
	LD	A, (T_A)		; restores A
	RET
clear:
	LD	A, 01h
	OUT	LCDCOM, A
	LD	D, 0			; resets the line number
	LD	C, 0			; sets the current number of characters to 0
	RET				; returns back to the call in outputchar

backspace:
	LD	HL, CB_WR		; \
	DEC	(HL)			; / decrement value held at the write pointer

	LD	A, C 
	CP	0
	JP	Z, start		; are we on the far left? If so, just go back.

	DEC	A			; since we're deleting a character decrement
	LD	C, A			; how many characters are on the line

	LD	A, D
	CP	1			; are we on the second line?

	LD	A, C

	JP	NZ, bs_end		; if not just jump to end

	ADD	A, 40h

bs_end:
	OR	80h			; 1xxx xxxx instructions move the cursor on the LCD
	LD	B, A			; Temporarily store A in B

	OUT	LCDCOM, A		; Move the cursor back   
	LD	A, ' '      
	OUT	LCDCHR, A		; Print a space

	LD	A, B
	OUT	LCDCOM, A		; Move the cursor back again

	JP	start