
//               Main para prueba de MSP_I2C_WN_Bytes.c
//******************************************************************************

#include "I2C_Defines.h"
#include "msp430x54x.h"
#include "MSP430_I2C_WN_Bytes.c"

                                 
void main()
{
  param_I2C arg;                  // Defino una variable del tipo param_I2C_t
  P3SEL |= 0x06;                    // Assign I2C pins to USCI_B0
  P3DIR |= 0x06;                    // Set pins 1 and 2 as output
  int block[] = {1,2,3,4,5};        // Bloque de datos a enviar
  
/*Lleno los campos de la estructura, la idea es que esten def x inst en un .h*/
  
  arg.TxData =(unsigned char*)block;
  arg.Num_Bytes = 5;
  arg.Dir_Esclavo = 0x48;
  arg.Lec_Esc = 1;
  arg.Instruccion = 0x04;
  
  UCB0I2CSA = 0x48;                 // Slave Address is 048h
 
    MSP430_I2C_N_Bytes(arg);      
  
}

