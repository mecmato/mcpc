;******************************************************************************
;   MSP430F54x Demo - 16x16 Signed Multiply
;
;   Description: Hardware multiplier is used to multiply two numbers.
;   The calculation is automatically initiated after the second operand is
;   loaded. Results are stored in RESLO, RESHI and SUMEXT = FFFF if result is
;   negative, SUMEXT = 0 otherwise. Result is also stored as Result variable.
;
;   ACLK = 32.768kHz, MCLK = SMCLK = default DCO
;
;               MSP430F5438
;             -----------------
;         /|\|                 |
;          | |                 |
;          --|RST              |
;            |                 |
;            |                 |
;
;   M. Morales
;   Texas Instruments Inc.
;   September 2008
;   Built with IAR Embedded Workbench Version: 4.11B
;******************************************************************************

#include "msp430x54x.h"

;-------------------------------------------------------------------------------
            RSEG    DATA16_N               ; Initialization values for vars
;-------------------------------------------------------------------------------
multiplier  DS16    1
operand     DS16    1    
result      DS32    1 

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT    
            mov.w   #0x1234,&multiplier     ; Initialize program variables
            mov.w   #-6578,&operand 
            mov.w   &multiplier,&MPYS       ; Load first operand -signed mult
            mov.w   &operand,&OP2           ; Load second operand

            mov.w   #result,R4              ; Move base address of result into R4
            mov.w   &RESHI,2(R4)            ; Move RESHI into upper word of result
            mov.w   &RESLO,0(R4)            ; Move RESLO into lower word of result
           
            bis.w   #LPM4,SR                ; Enter LPM4
            nop                             ; For debugger

;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END


