;******************************************************************************
;  MSP430F54x Demo - Timer_B, Toggle P1.0, Overflow ISR, 32kHz ACLK
;
;  Description: Toggle P1.0 using software and the Timer_B overflow ISR.
;  In this example an ISR triggers when TB overflows. Inside the ISR P1.0
;  is toggled. Toggle rate is exactly 0.5Hz. Proper use of the TBIV interrupt
;  vector generator is demonstrated.
;  ACLK = TBCLK = 32768Hz, MCLK = SMCLK = default DCO ~1.045MHz
;
;           MSP430F5438
;         ---------------
;     /|\|               |
;      | |               |
;      --|RST            |
;        |               |
;        |           P1.0|-->LED
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
            bis.b   #BIT0,&P1DIR            ; P1.0 output
            mov.w   #TBSSEL_1 + MC_2 + TBCLR + TBIE,&TBCTL
                                            ; ACLK, contmode, clear TBR
                                            ; enable interrupt
            bis.w   #LPM0 + GIE,SR          ; Enter LPM0, enable interrupts 
            nop                             ; For debugger

;-------------------------------------------------------------------------------
TIMERB1_ISR                          ; Timer_B Interrupt Vector (TBIV) handler
;-------------------------------------------------------------------------------
            add.w   &TBIV,PC                ; Vector to ISR handler
            reti                            ; No interrupt
            reti                            ; CCR1 not used
            reti                            ; CCR2 not used
            reti                            ; CCR3 not used
            reti                            ; CCR4 not used
            reti                            ; CCR5 not used
            reti                            ; CCR6 not used
TBIFG_HND   xor.b   #BIT0,&P1OUT            ; Timer overflow handler 
            reti                            ; Return from interrupt 

;-------------------------------------------------------------------------------
                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".int59"     
            .short  TIMERB1_ISR
            .sect   ".reset"                ; POR, ext. Reset
            .short  RESET
            .end