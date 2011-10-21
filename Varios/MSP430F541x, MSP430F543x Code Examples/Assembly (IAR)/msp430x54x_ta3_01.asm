;******************************************************************************
;  MSP430F54x Demo - Timer_A3, Toggle P1.0, CCR0 Cont. Mode ISR, DCO SMCLK
;
;  Description: Toggle P1.0 using software and TA_0 ISR. Toggles every
;  50000 SMCLK cycles. SMCLK provides clock source for TACLK.
;  During the TA_0 ISR, P1.0 is toggled and 50000 clock cycles are added to
;  CCR0. TA_0 ISR is triggered every 50000 cycles. CPU is normally off and
;  used only during TA_ISR.
;  ACLK = n/a, MCLK = SMCLK = TACLK = default DCO ~1.045MHz
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
;   Built with IAR Embedded Workbench Version: 4.11B
;******************************************************************************

#include <msp430x54x.h>

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT    
  
            bis.b   #0x01,&P1DIR            ; P1.0 output
            mov.w   #CCIE,&TA1CCTL0         ; CCR0 interrupt enabled
            mov.w   #50000,&TA1CCR0         
            mov.w   #TASSEL_2 + MC_2 + TACLR,&TA1CTL
                                            ; SMCLK, contmode, clear TAR
            bis.w   #LPM0 + GIE,SR          ; Enter LPM0 w/ interrupt
            nop                             ; For debugger

;-------------------------------------------------------------------------------
TIMER1_A0_ISR                               ; Timer A0 interrupt service routine
;-------------------------------------------------------------------------------
            xor.b   #0x01,&P1OUT            ; Toggle P1.0
            add.w   #50000,&TA1CCR0         ; Add offset to CCR0
            reti                            ; Return from interrupt 

;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     TIMER1_A0_VECTOR
            DW      TIMER1_A0_ISR
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END