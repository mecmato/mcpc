/******************************************************************************/
//                        I2C_MSP430_Esclavo.c
// Rutina de atención a interrupcion I2C
// Recibe un byte conteniendo una instruccion. Dependiendo de esta, recibira o 
// enviara un determinado numero de bytes. La instruccion tiene asociado tambien
// un lugar de memoria a partir del cual se van a guardar los datos recibidos o
// a partir del cual se guardan los datos a ser enviados.
//
// Se utiliza parte del codigo de los archivos:
//         - MSP430x54x_uscib0_i2c_05.c
//         - MSP430x54x_uscib0_i2c_07.c
//         - MSP430x54x_uscib0_i2c_09.c
//         - MSP430x54x_uscib0_i2c_11.c
//
/******************************************************************************/
//
//  MSP430F54x Demo - USCI_B0 I2C Slave TX multiple bytes to MSP430 Master
//
//  Description: This demo connects two MSP430's via the I2C bus. The slave
//  transmits to the master. This is the slave code. The interrupt driven
//  data transmission is demonstrated using the USCI_B0 TX interrupt.
//  ACLK = n/a, MCLK = SMCLK = default DCO = ~1.045MHz
//
//                                /|\  /|\
//               MSP430F5438      10k  10k     MSP430F5438
//                   slave         |    |        master
//             -----------------   |    |   -----------------
//            |     P3.1/UCB0SDA|<-|----+->|P3.1/UCB0SDA     |
//            |                 |  |       |                 |
//            |                 |  |       |                 |
//            |     P3.2/UCB0SCL|<-+------>|P3.2/UCB0SCL     |
//            |                 |          |                 |
//
//   M Smertneck / W. Goh
//   Texas Instruments Inc.
//   September 2008
//   Built with CCE Version: 3.2.2 and IAR Embedded Workbench Version: 4.11B
/******************************************************************************/



#include "msp430x54x.h"
#include "I2C_Defines.h"

unsigned char* PRxData;              //Defino puntero de recepcion de datos
unsigned char* PTxData;              //Defino puntero de trnasmision de datos
int Count;                          //Defino contador/param_I2C par;                    

//------------------------------------------------------------------------------
// The USCI_B0 data ISR TX vector is used to move data from MSP430 memory to the
// I2C master. PTxData points to the next byte to be transmitted, and TXByteCtr
// keeps track of the number of bytes transmitted.
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// The USCI_B0 state ISR TX vector is used to wake up the CPU from LPM0 in order
// to do processing in the main program after data has been transmitted. LPM0 is
// only exit in case of a (re-)start or stop condition when actual data
// was transmitted.
//------------------------------------------------------------------------------
#pragma vector = USCI_B0_VECTOR
__interrupt void USCI_B0_ISR(void)
{
  int aux_inst;
  int cont;
  param_I2C par;                           // Declaro una variable del tipo 
  unsigned char* PRxData;                  // estructura.
  unsigned char* PTxData;
  cont = CERO;
  
  switch(__even_in_range(UCB0IV,12))
  {
  case  0: break;                           // Vector  0: No interrupts
  case  2: break;                           // Vector  2: ALIFG
  case  4: break;                           // Vector  4: NACKIFG
  case  6:                                  // Vector  6: STTIFG
    UCB0IFG &= ~UCSTTIFG;                   // Clear start condition int flag
    break;
  case  8:                                  // Vector  8: STPIFG
    UCB0IFG &= ~UCSTPIFG;                   // Clear stop condition int flag
    __bic_SR_register_on_exit(LPM0_bits);   // Exit LPM0 if data was transmitted
    break;
  case 10:                          // Vector 10: RXIFG
    if (cont == CERO){   
    aux_inst =(int)UCB0RXBUF;              // Get RX'd byte into buffer
    par = get_param(aux_inst);            // Obtengo parametros asociados a la
    PRxData = par.RxData;               // instruccion y asigno a variables locales
    PTxData = par.TxData;
      if (par.Lec_Esc){
        UCB0IE |= UCTXIE + UCSTPIE + UCSTTIE; // Enable STT and STP interrupt
                                              // Enable TX interrupt
      }
    }else{                                  
    *PRxData++ = UCB0RXBUF;                  // Get RX data
    __bic_SR_register_on_exit(LPM0_bits);      // Exit LPM0
         
    }
   break;
    
  case 12:                                  // Vector 12: TXIFG  
    UCB0TXBUF = *PTxData++;               // Transmit data at address PTxData
    break;
  default: break;
  }
}
