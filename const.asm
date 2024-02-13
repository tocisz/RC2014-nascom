;==============================================================================
;
; Some definitions used with the RC2014 on-board peripherals:
;

; General TTY

.global CTRLC
.global CTRLG
.global BEL
.global BKSP
.global LF
.global FF
.global CS
.global CR
.global CTRLO
.global CTRLQ
.global CTRLR
.global CTRLS
.global CTRLU
.global ESC
.global DEL

CTRLC           =    03H     ; Control "C"
CTRLG           =    07H     ; Control "G"
BEL             =    07H     ; Bell
BKSP            =    08H     ; Back space
LF              =    0AH     ; Line feed
FF              =    0CH     ; Form feed
CS              =    0CH     ; Clear screen
CR              =    0DH     ; Carriage return
CTRLO           =    0FH     ; Control "O"
CTRLQ           =    11H     ; Control "Q"
CTRLR           =    12H     ; Control "R"
CTRLS           =    13H     ; Control "S"
CTRLU           =    15H     ; Control "U"
ESC             =    1BH     ; Escape
DEL             =    7FH     ; Delete
