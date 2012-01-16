/**
 * Aqui se declaran las funciones y tipos utilizados en el el modulo I2C
 *
 */

typedef void (*on_i2c_rcv)(int, int, char*);

int i2c_transmit (unsigned char destino, unsigned int largo, char* data);
int i2c_set_rcv_callback (on_i2c_rcv cb);


