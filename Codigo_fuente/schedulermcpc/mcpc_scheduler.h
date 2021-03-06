#ifndef MCPC_SCHEDULER_H
#define MCPC_SCHEDULER_H

#include "q_func.h"
#include "task_list.h"

//tipo funcion void que devuelve void
typedef void (*mcpc_task_t)(void);

//inicializa el scheduler
void mcpc_scheduler_init(tarea_t lista_tareas[]);

//planifica una tarea
int mcpc_scheduler_add(mcpc_task_t task, int max_count, int init_count, int habilita);

/** Resetea el periodo de ejecucion de la tarea que tiene el numero i asignado.
* @param i numero asignado a la tarea por el scheduler
* @param maxcounter nuevo periodo de ejecucion para la tarea.
* OBS: el nuevo periodo se aplica a partir de la proxima ejecucion de la tarea y corresponde a un numero
* entero de ejecuciones del planificador.
*/
void mcpc_scheduler_reseti(int i, int maxcounter);


//agrega una tarea para ejecutar
//@return 1 si hubo exito, 0 si no se pudo encolar la tarea
int mcpc_scheduler_ejecutar(mcpc_task_t);

//comienza la ejecucion de tareas
void mcpc_scheduler_start(void);

void atencion_interrupcion(void);

#endif


