;******************************************************************************
;  MSP430F54x Demo - Timer_A3, Toggle P2.1/TA1.0, Up/Down Mode, DCO SMCLK
;
;  Description: Toggle P2.1 using hardware TA1.0 output. Timer1_A is configured
;  for up/down mode with CCR0 defining period, TA1.0 also output on P1.1. In
;  this example, CCR0 is loaded with 250 and TA1.0 will toggle P1.1 at
;  TACLK/2*250. Thus the output frequency on P1.1 will be the TACLK/1000.
;  No CPU or software resources required.
;  As coded with TACLK = SMCLK, P2.1 output frequency is ~1.045M/1000.
;  SMCLK = MCLK = TACLK = default DCO ~1.045MHz
;
;                MSP430F5438
;            -------------------
;        /|\|                   |
;         | |                   |
;         --|RST                |
;           |                   |
;           |         P2.1/TA1.0|--> SMCLK/1000
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
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT    
            bis.b   #BIT1,&P2DIR            ; P2.1 output
            bis.b   #BIT1,&P2SEL            ; P2.1 option select
            mov.w   #OUTMOD_4,&TA1CCTL0     ; CCR0 toggle mode
            mov.w   #250,&TA1CCR0          
            mov.w   #TASSEL_2 + MC_3 + TACLR,&TA1CTL
                                            ; SMCLK, up-downmode, clear TAR
            bis.w   #LPM0,SP                ; Enter LPM0
            nop                             ; For debugger

;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END
            