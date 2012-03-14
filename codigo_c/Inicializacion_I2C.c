

// Se puede hacer uso de la función TI_USI_I2C_Init() de la libreria I2C


               /* Configuracion de USCR - I2C */
  
UCTBxCTL0 = CONFIG_I2C;            // BYTE 00101111
UCTBxCTL1 = CONFIG_USCB1;          // BYTE 
UCBxI2COA = DIR_PROPIA;            // 2 BYTES 1xxxxxxxDIR
UCBx12CSA = DIR_ESCLAVO            // PUEDE SER UN PARAMETRO DE ENTRADA
UCBxBR0 = BAUDS_LOW                // BYTE A DEFINIR
UCBxBR1 = BAUDS_HIGH               // BYTE A DEFINIR
UCBxIE = CONFIG_INTERR             // BYTE A DEFINIR
UCBxIV = VECT_INTERR               // 2 BYTES CON DIR DE SUBRUTINA 
 

                /* Configuracion de puertos */

P3SEL |= 0x06;                     //
}