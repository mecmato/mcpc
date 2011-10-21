;******************************************************************************
;  MSP430F54x Demo - Timer_A3, Toggle P1.0, Overflow ISR, 32kHz ACLK
;
;  Description: Toggle P1.0 using software and the Timer1_A overflow ISR.
;  In this example an ISR triggers when TA overflows. Inside the ISR P1.0
;  is toggled. Toggle rate is exactly 0.5Hz. Proper use of the TAIV interrupt
;  vector generator is demonstrated.
;  ACLK = TACLK = 32768Hz, MCLK = SMCLK = default DCO ~1.045MHz
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
            mov.w   #TASSEL_1 + MC_2 + TACLR + TAIE,&TA1CTL
                                            ; ACLK, contmode, clear TAR
                                            ; enable interrupt
            bis.w   #LPM0 + GIE,SR          ; Enter LPM0, enable interrupts 
            nop                             ; Enable interrupts
            
;-------------------------------------------------------------------------------
TIMER1_A1_ISR              ; Timer_A3 Interrupt Vector (TAIV) handler
;-------------------------------------------------------------------------------
            add.w  #TA1IV,PC                ; Vector to ISR handler
            reti                            ; No interrupt
            reti                            ; CCR1 not used
            reti                            ; CCR2 not used
            reti                            ; Reserved
            reti                            ; Reserved
            reti                            ; Reserved
            reti                            ; Reserved
TA1IFG_HND  xor.b  #BIT0,&P1OUT             ; Timer overflow handler 
            reti                            ; Return from interrupt 

;-------------------------------------------------------------------------------
                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".int48"    
            .short  TIMER1_A1_ISR
            .sect   ".reset"                ; POR, ext. Reset
            .short  RESET
            .end