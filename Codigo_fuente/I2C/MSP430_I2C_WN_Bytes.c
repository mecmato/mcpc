//*****************************************************************************
//                         MSP430 Envio_N_Bytes
// Transmision de una instruccion seguida de un detreminado numero de bytes
// desde un MSP430 a otro MSP430.
// Esta funcion se invoca a continuacion de la MSP430_I2C_Command.c, funcion 
// que no genera una condicion de stop para no perder control sobre el bus.
// 
// !!!!!!Considerar que si esto no funciona es necesario implementar el envio 
// de la instruccion dentro de esta funcion. Otra opcion es gnerar una 
// condicion de Start repetida con la misma dir del esclavo.
//
// Manejar la posibilidad de pasarle como parametro una estructura con los 
// datos en lugar de declarar variables y utilizar un switch.
//
//  Se utiliza parte del codigo del archivo MSP430x54x_uscib0_i2c_08.c,
//  cuya desscripcion se incluye a a continuacion. A differencia del archivo 
//  original, este no manda la informacion en forma repetida, si no que lo hace
//  solo una vez.
//*****************************************************************************
//
//******************************************************************************
//  MSP430F54x Demo - USCI_B0 I2C Master TX multiple bytes to MSP430 Slave
//
//  Description: This demo connects two MSP430's via the I2C bus. The master
//  transmits to the slave. This is the MASTER CODE. It cntinuously
//  transmits an array of data and demonstrates how to implement an I2C
//  master transmitter sending multiple bytes using the USCI_B0 TX interrupt.
//  ACLK = n/a, MCLK = SMCLK = BRCLK = default DCO = ~1.045MHz
//
//                                /|\  /|\
//                MSP430F5438     10k  10k      MSP430F5438
//                   slave         |    |         master
//             -----------------   |    |   -----------------
//           -|XIN  P3.1/UCB0SDA|<-|----+->|P3.1/UCB0SDA  XIN|-
//            |                 |  |       |                 |
//           -|XOUT             |  |       |             XOUT|-
//            |     P3.2/UCB0SCL|<-+------>|P3.2/UCB0SCL     |
//            |                 |          |                 |
//
//   P. Thanigai / W. Goh
//   Texas Instruments Inc.
//   November 2008
//   Built with CCE Version: 3.2.2 and IAR Embedded Workbench Version: 4.11B
//******************************************************************************

#include "msp430x54x.h"
#include "I2C_Defines.h"


unsigned char* PTxData;              //Defino puntero
int TXByteCtr;                       //Defino contador/param_I2C par;                    //Defino la estructura para la rutina de int
//unsigned char* Ptr_Tx;             //Defino puntero a una dir de memoria
//unsigned char* PTxData;

void MSP430_I2C_N_Bytes(param_I2C par)   
{
  
  
  
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT - por el debugger
  UCB0CTL1 |= UCSWRST;                      // Enable SW reset
  UCB0CTL0 = UCMST + UCMODE_3 + UCSYNC;     // I2C Master, synchronous mode
  UCB0CTL1 = UCSSEL_2 + UCSWRST;            // Use SMCLK, keep SW reset
  UCB0BR0 = 12;                             // fSCL = SMCLK/12 = ~100kHz
  UCB0BR1 = 0;
  UCB0CTL1 &= ~UCSWRST;                     // Clear SW reset, resume operation
  UCB0IE |= UCTXIE;                         // Enable TX interrupt
  UCB0I2CSA = par.Dir_Esclavo;             // Slave Address is 048h
  
  
   TXByteCtr = 0; 
   __delay_cycles(50);                     // Delay required between transaction
   PTxData = par.TxData;                      // TX array start address
                                            // Place breakpoint here to see each
                                            // transmit operation.
   UCB0CTL1 |= UCTR + UCTXSTT;             // I2C TX, start condition

   __bis_SR_register(LPM0_bits + GIE);     // Enter LPM0, enable interrupts
   __no_operation();                       // Remain in LPM0 until all data
                                            // is TX'd
   while (UCB0CTL1 & UCTXSTP);             // Ensure stop condition got sent
   
}

//------------------------------------------------------------------------------
// The USCIAB0TX_ISR is structured such that it can be used to transmit any
// number of bytes by pre-loading TXByteCtr with the byte count. Also, TXData
// points to the next byte to transmit.
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
  case 10:                                  // Vector 10: RXIFG
     Count++;                           // Increment RX byte counter
    if (Count)
    {
      *par.RxData = UCB0RXBUF;              // Move RX data to address par.RxData
      if ((par.Num_Bytes-Count) == 1)       // Only one byte left?
        UCB0CTL1 |= UCTXSTP;                // Generate I2C stop condition
    }
    else
    {
      *PRxData = UCB0RXBUF;                 // Move final RX data to PRxData
      __bic_SR_register_on_exit(LPM0_bits); // Exit active CPU
    }
    break;                           
  case 12:                                  // Vector 12: TXIFG
    
    if (Count == 0)
    {
      UCB0TXBUF = par.Instruccion;         // Check TX byte counter if counter
                                           // is cero an instruction is transm
    if (par.Lec_Esc == 0)                  // Instruction means reading N Bytes
      {
        UCB0IE |= UCRXIE;                  // Enable RX interrupt
        UCB0CTL1 |= UCTXSTT;               // Repeated I2C start condition
      }
    }   
    else
    {      
      if (TXByteCtr <= par.Num_Bytes )                       
      {
        UCB0TXBUF = *PTxData++;               // Load TX buffer
        Count++;                          // Decrement TX byte counter
      }
    }
      else
      {
        UCB0CTL1 |= UCTXSTP;                  // I2C stop condition
        UCB0IFG &= ~UCTXIFG;                  // Clear USCI_B0 TX int flag
        __bic_SR_register_on_exit(LPM0_bits); // Exit LPM0
      }
    }
  default: break;
  }
}



/******************************************************************************

 P3SEL |= 0x06;                            // Assign I2C pins to USCI_B0
 
 */