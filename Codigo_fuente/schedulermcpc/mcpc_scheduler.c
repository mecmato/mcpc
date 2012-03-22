/**
Implementacion del scheduler: lista de tareas a ejecutar en el loop principal del sistema.
*/


#include "mcpc_scheduler.h"
#include "q_func.h"
#include "task_list.h"

//cola que contiene la lista de tareas a ejecutar en el loop principal
static volatile q_func_t mcpc_tasks_q;

//cola que contiene la lista fija de tareas que pueden ser ejecutadas en el loop principal
static volatile task_list_t lista_tareas;

static volatile int largo_lista, idx;
static volatile tarea_t* tarea_ptr;

static void task_empty(void);

//habilita la ISR del timer del scheduler
static void mcpc_scheduler_isr_ie(void){

	TBCCTL0 |= CCIE;

}

//deshabilita la ISR del timer del scheduler
static void mcpc_scheduler_isr_id(void){

	TBCCTL0 &= ~CCIE;

}



//inicializa el scheduler
void mcpc_scheduler_init(void){

	init_queue(&mcpc_tasks_q);
	task_list_init(&lista_tareas);
}

//planifica una tarea con la cuenta inicial y los turnos que se saltea. Devuelve el numero de tarea asignado
//para poder referenciarlo luego.
int mcpc_scheduler_add(mcpc_task_t task, int max_count, int init_count, int habilita){

if (habilita == 1){
  int ret = 0;

  tarea_t auxtask;
  
  auxtask.counter = init_count;
  auxtask.max_count = max_count;
  auxtask.task = (f_ptr_t)task;
  auxtask.hab = habilita;

  //deshabilito interrupciones del TIMER
  mcpc_scheduler_isr_id();

  ret = task_list_add(&lista,auxtask);

  //habilito interrupciones del TIMER
  mcpc_scheduler_isr_ie();

  return ret;
	}
}
//agrega una tarea para ejecutar. Esta pensada para que una tarea pueda
//agregar otra en la cola mientras se esta ejecutando. 
//no se debe usar dentro de una ISR
int mcpc_scheduler_ejecutar(mcpc_task_t task){

  int ret = 0;
  
  //deshabilito interrupciones
  mcpc_scheduler_isr_id();
  
  if(!is_full(&mcpc_tasks_q)){ 
    add_element(&mcpc_tasks_q,(f_ptr_t)task);
    ret = 1;
  }
  
  //habilito interrupciones
  mcpc_scheduler_isr_ie();

  return ret;  
}

//comienza la ejecucion de tareas
void mcpc_scheduler_start(void){

  int empty;
  f_ptr_t task =task_empty;

  while(1){

  //detiene las interrupciones para proteger la cola de tareas
  //si hay alguna tarea la saca para luego ejecutar.
  //en principio solo el Scheduler Timer ISR es el unico que 
  //puede insertar tareas en la cola de ejecucion.
    mcpc_scheduler_isr_id();

    empty = is_empty(&mcpc_tasks_q);
    if(!empty) task = remove_element(&mcpc_tasks_q);

  //habilita interrupciones
    mcpc_scheduler_isr_ie();

  //ejecuta la tarea
    if(!empty) task();

  }  
}

//permite resetear el periodo de ejecucion de una tarea que fue asignada.
//esta funcion debe ser llamada fuera de la ISR del timer del scheduler
void mcpc_scheduler_reseti(int i, int maxcounter){

  //deshabilito interrupciones
    mcpc_scheduler_isr_id();

    tarea_ptr = task_list_geti(&lista,i);
    tarea_ptr->max_count = maxcounter;

  //habilito interrupciones
    mcpc_scheduler_isr_ie();

}


//timer para la ejecucion periodica del envio de tareas
//la interrupcion recorre la lista de tareas planificadas,
//se decrementa el contador de cada tarea,
//si uno llega a cero se envia a ejecutar y se resetea su cuenta
void atencion_interrupcion(){
  
  largo_lista = task_list_length(&lista);

  //recorro la lista decrementando contadores, si una llega a cero la mando a ajecutar y reseteo el contador
  for(idx=0;idx<largo_lista;idx++){
  
    tarea_ptr = task_list_geti(&lista,idx);
    
    if(tarea_ptr->counter == 0){
      //si la cola de ejecucion no esta llena le agrega la tarea a ejecutar.
      if(!is_full(&mcpc_tasks_q)) add_element(&mcpc_tasks_q,tarea_ptr->task);
      //si no se pudo encolar se deja para la proxima vuelta
      tarea_ptr->counter = (tarea_ptr->max_count)+1;
    }
    
    (tarea_ptr->counter)--;

  }
}

static void task_empty(void){}

