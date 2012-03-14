
//******************************************************************************
//                           Lista de parametros y definiciones
//******************************************************************************

//****************            MSP430_I2C_Command.c          ********************








//****************           MSP430_I2C_WN_Bytes.c         *********************

typedef struct 
{
  int Inst
  char* TxData;
  char* RxData;
  int   Num_Bytes;
  int   Lec_Esc;
}param_I2C_t;

#define max_ints 