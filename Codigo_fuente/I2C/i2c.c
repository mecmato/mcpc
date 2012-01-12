/**
Definicion de paquetes
*/

#include <i2c.h>
#include <stdio.h>
#include <USI_I2CMaster.h>                  // Para usar el módulo USI
#include <MSP430_SWI2C_Master.h>            // Para usar el bit-banging de GPIO


/** variables
*/
on_i2c_rcv rcv_cb;


/**
Definicion de funciones
*/
int i2c_set_rcv_callback (on_i2c_rcv cb);
int i2c_transmit (int dest, int len, char* data);


/**
 * La funcion i2c_transmit esta encargada de la transmisión de datos al bus I2C
 * Recibe como parámetros el destino de la transmisión de datos (int), el la cantidad de bytes a transmitir (int largo),
 * y un string con los datos a transmitir.
 * La salida es un entero que establece si la transmisión fue realizada con éxito o no.
 */

int i2c_transmit (unsigned char destino, int largo, char* data)
{

}



/**
 * La funcion i2c_set_rcv_callback setea la direccion en memoria a la cual referirse si el modulo I2C recibe un dato.
 */

int i2c_set_rcv_callback (on_i2c_rcv cb)
{
	if(cb != NULL){
		rcv_cb = cb;
		return 1;
	}else
		return 0;
}

