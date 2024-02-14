;==============================================================================
; Contents of this file are copyright Phillip Stevens
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement to myself.
;
; https://github.com/feilipu/
;
; https://feilipu.me/
;
;==============================================================================

.section .v_rst
;==============================================================================
;
; Z80 INTERRUPT ORIGINATING VECTOR TABLE
;
;==============================================================================

;------------------------------------------------------------------------------
; RST 00 - RESET / TRAP
.org     0000H, 0xFF
                JP      RST_00            ; Initialize Hardware and go

;------------------------------------------------------------------------------
; RST 08
.org     0008H, 0xFF
                JP      RST_08_ADDR

;------------------------------------------------------------------------------
; RST 10
.org     0010H, 0xFF
                JP      RST_10_ADDR

;------------------------------------------------------------------------------
; RST 18
.org     0018H, 0xFF
                JP      RST_18_ADDR

;------------------------------------------------------------------------------
; RST 20
.org     0020H, 0xFF
                JP      RST_20_ADDR

;------------------------------------------------------------------------------
; RST 28
.org     0028H, 0xFF
                JP      RST_28_ADDR

;------------------------------------------------------------------------------
; RST 30
.org     0030H, 0xFF
                JP      RST_30_ADDR

;------------------------------------------------------------------------------
; RST 38 - INTERRUPT VECTOR INT [ with IM 1 ]

.org     0038H, 0xFF
                JP      INT_INT0_ADDR

.section         .v_nmi
;------------------------------------------------------------------------------
; NMI - INTERRUPT VECTOR NMI

                JP      INT_NMI_ADDR

.section         .v_tab_p
;==============================================================================
;
; Z80 INTERRUPT VECTOR TABLE PROTOTYPE
;
; WILL BE DUPLICATED DURING INIT TO:
;
;               ORG     VECTOR_BASE

RST_00_LBL:
                JP      RST_00
                NOP
RST_08_LBL:
                JP      RST_08
                NOP
RST_10_LBL:
                JP      RST_10
                NOP
RST_18_LBL:
                LD      A,(serRxBufUsed)    ; this is called each token,
                RET                         ; so optimise it to here
RST_20_LBL:
                JP      RST_20
                NOP
RST_28_LBL:
                JP      RST_28
                NOP
RST_30_LBL:
                JP      RST_30
                NOP
INT_INT_LBL:
                JP      INT_INT
                NOP
INT_NMI_LBL:
                JP      INT_NMI
                NOP

.section         .v_nullr
;------------------------------------------------------------------------------
; NULL RETURN INSTRUCTIONS

INT_NMI:
                RETN

;==============================================================================

