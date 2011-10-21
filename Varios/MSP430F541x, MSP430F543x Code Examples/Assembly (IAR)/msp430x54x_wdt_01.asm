;******************************************************************************
;  MSP430FG54x Demo - WDT, Toggle P1.0, Interval Overflow ISR, DCO SMCLK
;
;  Description: Toggle P1.0 using software timed by the WDT ISR. Toggle rate
;  is approximately 30ms = {(default DCO 1.045MHz) / 32768} based on default
;  DCO/SMCLK clock source used in this example for the WDT.
;  ACLK = n/a, MCLK = SMCLK = default DCO ~1.045MHz
;
;                MSP430F5438
;             -----------------
;         /|\|                 |
;          | |                 |
;          --|RST              |
;            |                 |
;            |             P1.0|-->LED
;
;   M. Morales
;   Texas Instruments Inc.
;   September 2008
;   Built with IAR Embedded Workbench Version: 4.11B
;******************************************************************************

#include "msp430x54x.h"

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDT_MDLY_32,&WDTCTL    ; WDT 32ms, SMCLK, interval timer
            bis.w   #WDTIE,&SFRIE1          ; Enable WDT interrupt
            bis.b   #BIT0,&P1DIR            ; Set P1.0 to output direction

            bis.w   #LPM0 + GIE,SR          ; Enter LPM0, enable interrupts 
            nop                             ; For debugger

;-------------------------------------------------------------------------------
WDT_ISR
;-------------------------------------------------------------------------------
            xor.b   #BIT0,&P1OUT            ; Toggle P1.0 (LED)
            nop                             ; Set breakpoint here 
            reti                            ; Return from interrupt 

;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     WDT_VECTOR
            DW      WDT_ISR
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END
            