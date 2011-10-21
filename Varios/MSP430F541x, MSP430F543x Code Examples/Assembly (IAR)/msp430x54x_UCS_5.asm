;******************************************************************************
;  MSP430F54x Demo - VLO sources ACLK
;
;  Description: This program demonstrates using VLO to source ACLK
;  ACLK = VLO = ~9kHz	
;
;                 MSP430F5438
;             -----------------
;         /|\|                 |
;          | |                 |
;          --|RST              |
;            |                 |
;            |                 |
;            |            P11.0|--> ACLK = ~9kHz
;            |                 |
;
;   W. Goh
;   Texas Instruments Inc.
;   April 2009
;   Built with IAR Embedded Workbench Version: 4.11B
;******************************************************************************

#include <msp430x54x.h>

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDT_ADLY_250,&WDTCTL   ; WDT ~1000ms, ACLK, interval timer
            bis.w   #WDTIE,&SFRIE1          ; Enable WDT interrupt

            bis.b   #BIT0,&P1DIR;           ; P1.0 to output direction
            bis.b   #BIT0,&P11DIR           ; P11.0 to output direction
            bis.b   #BIT0,&P11SEL           ; P11.0 to output ACLK

            bis.w   #SELA_1,&UCSCTL4        ; VLO Clock Sources ACLK

            bis.w   #LPM3 + GIE,SR          ; Enter LPM3 w/ interrupts
            nop                             ; For debugger

;-------------------------------------------------------------------------------
WDT_ISR;    Watchdog Timer interrupt service routine
;-------------------------------------------------------------------------------
            xor.b   #0x01,&P1OUT            ; Toggle P1.0 using exclusive-OR
            reti
;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     WDT_VECTOR              ; WDT Vector
            DW      WDT_ISR
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END