;******************************************************************************
;   MSP430F54x Demo - 8x8 Signed Multiply
;
;   Description: Hardware multiplier is used to multiply two numbers.
;   The calculation is automatically initiated after the second operand is
;   loaded. Results are stored in RESLO, RESHI and SUMEXT = FFFF if result is
;   negative, SUMEXT = 0 otherwise.
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

#define     value1    R4
#define     value2    R5

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT    

            mov.b   #0x04,value1            ; Assign operands for signed mult
            mov.b   #0x84,value2

            mov.b   value1,&MPYS_B          ; Load MPYS to denote signed operation
            mov.b   value2,&OP2_B           ; Load OP2 with byte access to avoid
                                            ; ... the need for sign extension
            
            bis.w   #LPM4,SR                ; Enter LPM4
            nop                             ; For debugger 

;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END