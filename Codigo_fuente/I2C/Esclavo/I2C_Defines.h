
//******************************************************************************
//                           Lista de parametros y definiciones
//******************************************************************************

//****************            MSP430_I2C_Command.c          ********************

void MSP430_I2C_Command(unsigned int Inst);






//****************           MSP430_I2C_WN_Bytes.c         *********************


#define MAX_INTS
#define CERO 0



typedef struct            //Estrcutura para pasarle a la funcion como argumento
{
  int Inst;
  unsigned char* TxData;
  unsigned char* RxData;
  unsigned int   Num_Bytes;
  unsigned int   Lec_Esc;
  unsigned int   Dir_Esclavo;
  unsigned int   Instruccion;
} param_I2C;

//param_I2C par;

void MSP430_I2C_N_Bytes(param_I2C par);   //Funcion comunicacion I2C Maestro

//Funcion auxiliar para obtener los datos asociados a la instruccion
param_I2C get_param(int instruccion);  


