;******************************************************************************
;   MSP430F54x Demo - WDT, Toggle P1.0, Interval Overflow ISR, 32kHz ACLK
;
;  Description: Toggle P1.0 using software timed by WDT ISR. Toggle rate is
;  exactly 250ms based on 32kHz ACLK WDT clock source. In this example the
;  WDT is configured to divide 32768 watch-crystal(2^15) by 2^13 with an ISR
;  triggered @ 4Hz = [WDT CLK source/32768].
;  ACLK = REFO , MCLK = SMCLK = default DCO ~1.045MHz
;
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
            mov.w   #WDT_ADLY_250,&WDTCTL   ; WDT 250ms, ACLK, interval timer
            bis.w   #WDTIE,&SFRIE1          ; Enable WDT interrupt
            bis.b   #BIT0,&P1DIR            ; Set P1.0 to output direction

            bis.w   #LPM3 + GIE,SR          ; Enter LPM3 w/interrupts enabled
            nop                             ; For debugger
            
;-------------------------------------------------------------------------------
WDT_ISR
;-------------------------------------------------------------------------------
            xor.b   #BIT0,&P1OUT            ; Toggle P1.0 using exclusive-OR
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

