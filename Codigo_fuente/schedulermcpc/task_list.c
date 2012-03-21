#include "task_list.h"

///Define una interfaz para la manipulacion de tareas
// iterativas que se deben ejecutar segun una freuecnia relativa
/*
typedef struct{
        int counter;
        int max_count;
        f_ptr_t task;
        int hab;
} tarea_t;

typedef struct{
        int length;
        tarea_t tareas[LIST_SIZE];
} task_list_t;
*/

//inicializa la lista de tareas
void task_list_init(task_list_t* lista){
        lista->length = 0;
}

//agrega tarea en la lista, devuelve -1 si no se pudo aregar o el numero de tarea asignado en la lista.
//esta llamada debe ser atomica respecto de la lista.
int task_list_add(task_list_t* lista,tarea_t tarea){

        int ret = 0;

        if(lista->length == LIST_SIZE) return -1;

        ret = (lista->length)++;

        lista->tareas[(lista->length)-1] = tarea;

        return ret;

}

//devuelve un puntero a la tarea i-esima de la lista.
//esta llamada debe ser atomica respecto de la lista
tarea_t* task_list_geti(task_list_t* lista, int i){

        if(lista->length <= i) return 0;

        return &(lista->tareas[i]);

}

//devuelve el largo de la lista.
int task_list_length(task_list_t* lista){
        return lista->length;
}
