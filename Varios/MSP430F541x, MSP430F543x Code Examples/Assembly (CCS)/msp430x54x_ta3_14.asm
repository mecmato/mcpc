;******************************************************************************
;  MSP430F54x Demo - Timer_A3, Toggle P2.1/TA1.0, Up/Down Mode, 32kHz ACLK
;
;  Description: Toggle P2.1 using hardware TA1.0 output. Timer1_A is configured
;  for up/down mode with CCR0 defining period, TA1.0 also output on P2.1. In
;  this example, CCR0 is loaded with 5 and TA1.0 will toggle P2.1 at TACLK/2*5.
;  Thus the output frequency on P2.1 will be the TACLK/20. No CPU or software
;  resources required. Normal operating mode is LPM3.
;  As coded with TACLK = ACLK, P2.1 output frequency = 32768/20 = 1.6384kHz
;  ACLK = TACLK = 32kHz, MCLK = default DCO ~1.045MHz
;
;                MSP430F5438
;            -------------------
;        /|\|                   |
;         | |                   |
;         --|RST                |
;           |                   |
;           |         P2.1/TA1.0|-->ACLK/20
;
;   M. Morales
;   Texas Instruments Inc.
;   September 2008
;   Built with Code Composer Essentials v3.x
;******************************************************************************

    .cdecls C,LIST,"msp430x54x.h"

;-------------------------------------------------------------------------------
            .global _main 
            .text                           ; Assemble to Flash memory
;-------------------------------------------------------------------------------
_main
RESET       mov.w   #0x5C00,SP              ; Initialize stackpointer
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT    
            bis.b   #BIT1,&P2DIR            ; P2.1 output
            bis.b   #BIT1,&P2SEL            ; P2.1 option select
            mov.w   #OUTMOD_4,&TA1CCTL0     ; CCR0 toggle mode
            mov.w   #5,&TA1CCR0 
            mov.w   #TASSEL_1 + MC_3 + TACLR,&TA1CTL
                                            ; ACLK, up-downmode, clear TAR

            bis.w   #LPM3,SR                ; Enter LPM3
            nop                             ; For debugger
            
;-------------------------------------------------------------------------------
                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; POR, ext. Reset
            .short  RESET
            .end