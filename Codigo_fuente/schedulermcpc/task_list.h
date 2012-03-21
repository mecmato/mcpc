#ifndef TASK_LIST_H
#define TASK_LIST_H

#define LIST_SIZE

///Define una interfaz para la manipulacion de tareas
// iterativas que se deben ejecutar segun una freuecnia relativa
#include "q_func.h"


typedef struct{
        int counter;
        int max_count;
        f_ptr_t task;
        int hab;                       //Habilita o deshabilita tareas
} tarea_t;

typedef struct{
        int length;
        tarea_t tareas[LIST_SIZE];
} task_list_t;


//inicializa la lista de tareas
void task_list_init(task_list_t* lista);

//agrega tarea en la lista, devuelve -1 si no se pudo aregar.
//esta llamada debe ser atomica respecto de la lista.
int task_list_add(task_list_t* lista,tarea_t tarea);

//devuelve un puntero a la tarea i-esima de la lista.
//esta llamada debe ser atomica respecto de la lista
tarea_t* task_list_geti(task_list_t* lista, int i);

//devuelve el largo de la lista.
int task_list_length(task_list_t* lista);



#endif
