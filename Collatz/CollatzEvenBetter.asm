; Program for printing out the collatz sequence for a given number.
; Written by github.com/coolbassist

LCDCOM  equ 2
LCDCHR  equ 3

    org 0

    ; Setting up the LCD display

    LD  A, 38H      ; function set.
    OUT LCDCOM, A

    LD  A, 0CH      ; display on
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