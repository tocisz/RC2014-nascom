;==============================================================================
;
; The rework to support MS Basic HLOAD, RESET, MEEK, MOKE,
; and the Z80 instruction tuning are copyright (C) 2020-23 Phillip Stevens
;
; This Source Code Form is subject to the terms of the Mozilla Public
; License, v. 2.0. If a copy of the MPL was not distributed with this
; file, You can obtain one at http://mozilla.org/MPL/2.0/.
;
; The HLOAD function supports Intel HEX encoded program upload.
; Updates LSTRAM and STRSPC, adds program origin address to USR+1.
; It resets and clears runtime variables.
;
; The RESET function returns to cold start status.
;
; feilipu, August 2020
;
;==============================================================================
;
; The updates to the original BASIC within this file are copyright Grant Searle
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement to myself.
;
; http://searle.wales/
;
;==============================================================================
;
; NASCOM ROM BASIC Ver 4.7, (C) 1978 Microsoft
; Scanned from source published in 80-BUS NEWS from Vol 2, Issue 3
; (May-June 1983) to Vol 3, Issue 3 (May-June 1984)
; Adapted for the freeware Zilog Macro Assembler 2.10 to produce
; the original ROM code (checksum A934H). PA
;
;==============================================================================

.section .text

.global RST_20
.global RST_28
.global RST_30

; BASIC ERROR CODE VALUES

NF      =   00H ; NEXT without FOR
SN      =   02H ; Syntax error
RG      =   04H ; RETURN without GOSUB
OD      =   06H ; Out of DATA
FC      =   08H ; Function call error
OV      =   0AH ; Overflow
OM      =   0CH ; Out of memory
UL      =   0EH ; Undefined line number
BS      =   10H ; Bad subscript
DD      =   12H ; Re-DIMensioned array
DZ      =   14H ; Division by zero (/0)
ID      =   16H ; Illegal direct
TM      =   18H ; Type miss-match
OS      =   1AH ; Out of string space
LS      =   1CH ; String too long
ST      =   1EH ; String formula too complex
CN      =   20H ; Can't CONTinue
UF      =   22H ; UnDEFined user function FN
MO      =   24H ; Missing operand
HX      =   26H ; HEX error

; BASIC CODE COMMENCES

COLD:   JP      CSTART          ; Jump in for cold start (0x0240)
WARM:   JP      WARMST          ; Jump in for warm start (0x0243)

CSTART:
WARMST: NOP

RST_20:
RST_28:
RST_30:
UFERR:  LD      E,UF            ; ?UF Error
        .byte    01H             ; Skip "LD E,OV