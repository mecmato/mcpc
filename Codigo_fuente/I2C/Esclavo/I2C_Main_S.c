//******************************************************************************
//               Main para prueba de MSP_I2C_Command.c
//******************************************************************************

#include "I2C_Defines.h"
#include "msp430x54x.h"



void main()
{
  P3SEL |= 0x06;                            // Assign I2C pins to USCI_B0
  UCB0I2CSA = 0x48;                        // Slave Address is 048h
  unsigned char Inst = 0x04;
    
  MSP430_I2C_Command(Inst);
  
}


void I2C_MSP430_Esclavo()
{
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
  P3SEL |= 0x06;                            // Assign I2C pins to USCI_B0
  P3DIR &= ~0x06;                           // Assing I2C pins as input
  UCB0CTL1 |= UCSWRST;                      // Enable SW reset
  UCB0CTL0 = UCMODE_3 + UCSYNC;             // I2C Slave, synchronous mode
  UCB0I2COA = 0x48;                         // Own Address is 048h
  UCB0CTL1 &= ~UCSWRST;                     // Clear SW reset, resume operation
  UCB0IE |= UCSTPIE + UCSTTIE + UCRXIE;     // Enable STT, STP & RX interrupt
                                            

 
    
    __bis_SR_register(LPM0_bits + GIE);     // Enter LPM0, enable interrupts
                                            // Remain in LPM0 until master
                                            // finishes RX
     __no_operation();                       // Set breakpoint >>here<< and
                                          // read out the TXByteCtr counter
}
