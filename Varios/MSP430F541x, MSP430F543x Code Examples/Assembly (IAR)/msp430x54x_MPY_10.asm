;******************************************************************************
;   MSP430F54x Demo - 32x32 Signed Multiply
;
;   Description: Hardware multiplier is used to multiply two numbers.
;   The calculation is automatically initiated after the second operand is
;   loaded. Results are stored in RES0, RES1, RES2 and RES3.
;
;   ACLK = 32.768kHz, MCLK = SMCLK = default DCO
;
;                MSP430F5438
;             -----------------
;         /|\|                 |
;          | |                 |
;          --|RST              |
;            |                 |
;            |                 |
;
;   M Smertneck / W. Goh
;   Texas Instruments Inc.
;   September 2008
;   Built with CCE Version: 3.2.2 and IAR Embedded Workbench Version: 4.11B
;******************************************************************************

#include <msp430x54x.h>

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT    

            mov.w   #0x1234,&MPYS32L        ; Load lower 16 bits of operand 1
            mov.w   #0x1234,&MPYS32H        ; Load upper 16 bits of operand 1
            
            mov.w   #0x5678,&OP2L           ; Load lower 16 bits of operand 2
            mov.w   #0x5678,&OP2H           ; Load lower 16 bits of operand 2
                          
            bis.w   #LPM4,SR                ; Enter LPM4
            nop                             ; For debugger

;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END