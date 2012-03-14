//******************************************************************************
//                       MSP430_I2C_Command.c
//      Transmision de un byte al esclavo asociado a una instruccion. 
//  Los parametros I2C: Direcciond el Esclavo y Puerto I2C deben ser definidos
//  antes de invocar a esta funcion
// 
//  Se utiliza parte del codigo del archivo MSP430x54x_uscib0_i2c_06.c, 
//  cuya desscripcion se incluye a a continuacion. A differencia del archivo 
//  original, este no manda la informacion en forma repetida, si no que lo hace
//  solo una vez.
// 
//******************************************************************************
//
//******************************************************************************
//  MSP430F54x Demo - USCI_B0 I2C Master TX single bytes to MSP430 Slave
//
//  Description: This demo connects two MSP430's via the I2C bus. The master
//  transmits to the slave. This is the master code. It continuously
//  transmits 00h, 01h, ..., 0ffh and demonstrates how to implement an I2C
//  master transmitter sending a single byte using the USCI_B0 TX interrupt.
//  ACLK = n/a, MCLK = SMCLK = BRCLK = default DCO = ~1.045MHz
//
//                                /|\  /|\
//                MSP430F5438     10k  10k     MSP430F5438
//                   slave         |    |         master
//             -----------------   |    |   -----------------
//           -|XIN  P3.1/UCB0SDA|<-|----+->|P3.1/UCB0SDA  XIN|-
//            |                 |  |       |                 |
//           -|XOUT             |  |       |             XOUT|-
//            |     P3.2/UCB0SCL|<-+------>|P3.2/UCB0SCL     |
//            |                 |          |                 |
//
//   M Smertneck / W. Goh
//   Texas Instruments Inc.
//   September 2008
//   Built with CCE Version: 3.2.2 and IAR Embedded Workbench Version: 4.11B
//******************************************************************************

#include "msp430x54x.h"
unsigned char Inst;



void MSP430_I2C_Command(unsigned char Inst)
{
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT- Por el debugger
  
  UCB0CTL1 |= UCSWRST;                      // Enable SW reset
  UCB0CTL0 = UCMST + UCMODE_3 + UCSYNC;     // I2C Master, synchronous mode
  UCB0CTL1 = UCSSEL_2 + UCSWRST;            // Use SMCLK, keep SW reset
  UCB0BR0 = 12;                             // fSCL = SMCLK/12 = ~100kHz
  UCB0BR1 = 0;
 
  UCB0CTL1 &= ~UCSWRST;                     // Clear SW reset, resume operation
  UCB0IE |= UCTXIE;                         // Enable TX interrupt

             
  while (UCB0CTL1 & UCTXSTP);             // Ensure stop condition got sent
  UCB0CTL1 |= UCTR + UCTXSTT;             // I2C TX, start condition
   
  __bis_SR_register(LPM0_bits + GIE);     // Enter LPM0 w/ interrupts
  __no_operation();                       // Remain in LPM0 until all data
                                            // is TX'd
                                              
    
 }

//------------------------------------------------------------------------------
// The USCIAB0_ISR is structured such that it can be used to transmit any
// number of bytes by pre-loading TXByteCtr with the byte count.
//------------------------------------------------------------------------------
#pragma vector = USCI_B0_VECTOR
__interrupt void USCI_B0_ISR(void)
{
  switch(__even_in_range(UCB0IV,12))
  {
  case  0: break;                           // Vector  0: No interrupts
  case  2: break;                           // Vector  2: ALIFG
  case  4: break;                           // Vector  4: NACKIFG
  case  6: break;                           // Vector  6: STTIFG
  case  8: break;                           // Vector  8: STPIFG
  case 10: break;                           // Vector 10: RXIFG
  case 12:                                  // Vector 12: TXIFG              
        UCB0TXBUF = Inst;                   // Load Inst in buffer      
    break;
  default: break;
  }
}

/******************************************************************************
               Lineas que saco del codigo original
 
La seleccion del puerto para I2C la debe hacer cada dispositivo

P3SEL |= 0x06;                            // Assign I2C pins to USCI_B0

La direccion del esclavo se onfigura en el switch-case

 UCB0I2CSA = 0x48;                         // Slave Address is 048h

Lineas que no aplican a esta funcion

unsigned char TXData;
unsigned char TXByteCtr;
TXData = 0x01;
TXData++;                               // Increment data byte
TXByteCtr--;                          // Decrement TX byte counter
}
    else
    {
      UCB0CTL1 |= UCTXSTP;                  // I2C stop condition
      UCB0IFG &= ~UCTXIFG;                  // Clear USCI_B0 TX int flag
      __bic_SR_register_on_exit(LPM0_bits); // Exit LPM0
    }


    TXByteCtr = 1;                          // Load TX byte counter      */
