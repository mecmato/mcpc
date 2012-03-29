
#include "msp430x54x.h"
#include "mcpc_scheduler.h"
#include "task_list.h"

int fun_0(void);
int fun_1(void);
int fun_2(void);
int fun_3(void);
int fun_4(void);

void main(){
  
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
  P1DIR |= 0x01;                            // Set P1.0 to output direction
  TBCCTL0 = CCIE;                           // Interrupt enabled
  //TBCCR0 =1000-1;
  TBCCR0 =5000;
  TBCTL = TBSSEL_1 + MC_1 + TBCLR ;         // ACLK, upmode, clear TBR
  static tarea_t lista_tareas[LIST_SIZE];
      
  lista_tareas[0].counter = 3;
  lista_tareas[0].max_count = 3;
  lista_tareas[0].task = (f_ptr_t)fun_0;
  lista_tareas[0].hab = 1;

  lista_tareas[1].counter = 5;
  lista_tareas[1].max_count = 5;
  lista_tareas[1].task = (f_ptr_t)fun_1;
  lista_tareas[1].hab = 1;

  lista_tareas[2].counter = 2;
  lista_tareas[2].max_count = 2;
  lista_tareas[2].task = (f_ptr_t)fun_2;
  lista_tareas[2].hab = 1;

  lista_tareas[3].counter = 6;
  lista_tareas[3].max_count = 6;
  lista_tareas[3].task = (f_ptr_t)fun_3;
  lista_tareas[3].hab = 1;
  
  lista_tareas[4].counter = 1;
  lista_tareas[4].max_count = 1;
  lista_tareas[4].task = (f_ptr_t)fun_4;
  lista_tareas[4].hab = 1;
  
  mcpc_scheduler_init(lista_tareas);
  mcpc_scheduler_start();
  
  //sacar después
  //atencion_interrupcion();
  
  __bis_SR_register(LPM3_bits + GIE);       // Enter LPM3, enable interrupts
  __no_operation();                         // For debugger  

  
}

// Timer B0 interrupt service routine
#pragma vector=TIMERB0_VECTOR
__interrupt void TIMERB0_ISR(void)
{
    P1OUT ^= 0x01;                          // Toggle P1.0 using exclusive-OR
    TBCCR0 +=5000;
    atencion_interrupcion();                // Atencion a interrupcion
}



int fun_0(void){return 0;}
int fun_1(void){return 1;}
int fun_2(void){return 2;}
int fun_3(void){return 3;}
int fun_4(void){return 4;}