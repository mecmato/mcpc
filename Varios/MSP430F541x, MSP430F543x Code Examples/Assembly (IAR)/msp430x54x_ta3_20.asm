;*******************************************************************************
;  MSP430F54x Demo - Timer_A3, PWM TA1.1-2, Up/Down Mode, 32kHz ACLK
;
;  Description: This program generates two PWM outputs on P2.2, P2.3 using
;  Timer1_A configured for up/down mode. The value in CCR0, 128, defines the
;  PWM period/2 and the values in CCR1 and CCR2 the PWM duty cycles. Using
;  32kHz ACLK as TACLK, the timer period is 7.8ms with a 75% duty cycle
;  on P2.2 and 25% on P2.3. Normal operating mode is LPM3
;  ACLK = TACLK = LFXT1 = 32768Hz, MCLK = default DCO ~1.045MHz.
;
;                MSP430F5438
;            -------------------
;        /|\|                   |
;         | |                   |
;         --|RST                |
;           |                   |
;           |         P2.2/TA1.1|--> CCR1 - 75% PWM
;           |         P2.3/TA1.2|--> CCR2 - 25% PWM
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
            bis.b   #BIT2 + BIT3,&P2DIR     ; P2.2 and P2.3 output
            bis.b   #BIT2 + BIT3,&P2SEL     ; P2.2 and P2.3 options select
            mov.w   #128,&TA1CCR0           ; PWM Period/2
            mov.w   #OUTMOD_6,&TA1CCTL1     ; CCR1 toggle/set
            mov.w   #32,&TA1CCR1            ; CCR1 PWM duty cycle
            mov.w   #OUTMOD_6,&TA1CCTL2     ; CCR2 toggle/set
            mov.w   #96,&TA1CCR2            ; CCR2 PWM duty cycle
            mov.w   #TASSEL_1 + MC_3,&TA1CTL; ACLK, up-down mode

            bis.w   #LPM3,SR                ; Enter LPM3  
            nop                             ; For debugger
            
;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END