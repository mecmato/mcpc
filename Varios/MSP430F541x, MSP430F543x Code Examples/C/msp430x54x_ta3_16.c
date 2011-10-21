//*******************************************************************************
//  MSP430F54x Demo - Timer_A3, PWM TA1.1-2, Up Mode, DCO SMCLK
//
//  Description: This program generates two PWM outputs on P2.2,P2.3 using
//  Timer1_A configured for up mode. The value in CCR0, 512-1, defines the PWM
//  period and the values in CCR1 and CCR2 the PWM duty cycles. Using ~1.045MHz
//  SMCLK as TACLK, the timer period is ~500us with a 75% duty cycle on P2.2
//  and 25% on P2.3.
//  ACLK = n/a, SMCLK = MCLK = TACLK = default DCO ~1.045MHz.
//
//                MSP430F5438
//            -------------------
//        /|\|                   |
//         | |                   |
//         --|RST                |
//           |                   |
//           |         P2.2/TA1.1|--> CCR1 - 75% PWM
//           |         P2.3/TA1.2|--> CCR2 - 25% PWM
//
//   M Smertneck / W. Goh
//   Texas Instruments Inc.
//   September 2008
//   Built with CCE Version: 3.2.2 and IAR Embedded Workbench Version: 4.11B
//******************************************************************************

#include "msp430x54x.h"

void main(void)
{
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
  P2DIR |= 0x0C;                            // P2.2 and P2.3 output
  P2SEL |= 0x0C;                            // P2.2 and P2.3 options select
  TA1CCR0 = 512-1;                          // PWM Period
  TA1CCTL1 = OUTMOD_7;                      // CCR1 reset/set
  TA1CCR1 = 384;                            // CCR1 PWM duty cycle
  TA1CCTL2 = OUTMOD_7;                      // CCR2 reset/set
  TA1CCR2 = 128;                            // CCR2 PWM duty cycle
  TA1CTL = TASSEL_2 + MC_1 + TACLR;         // SMCLK, up mode, clear TAR

  __bis_SR_register(LPM0_bits);             // Enter LPM0
  __no_operation();                         // For debugger
}

