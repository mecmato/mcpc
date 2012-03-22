#ifndef Q_FUNC_H
#define Q_FUNC_H

/** Cola de enteros circular de proposito general (FIFO)
        creada para el curso sistemas enbebidos de Tiempo Real - IIE - Facultad de Ingenieria - UdelaR
        abril de 2008 - Juan Pablo Gonzalez
*/

/// descomentar #define para hacer debug con la funcion degug_print_queue(...)
//#define DEBUG_QF

/** Tamaño de la cola*/
#define QF_SIZE 3

/** Estructura representativa de la cola 
       
        |<-rd_idx->|<-------num_e--------------->|
        _0____1____2____3_____   ______________________Q_SIZE-1
        |  X |  X |  A |  B |     |  J |  K |  L |  X |  X |
        |____|____|____|____|__  _|____|____|____|____|____| >-------|
        ^                                                            |
        |<-----------------------------------------------------------|
        |
       queue->elments
         

*/
typedef void (*f_ptr_t)(void);

typedef struct{
        f_ptr_t elements[QF_SIZE];   ///buffer para los datos
        int num_e;              ///cantidad de elementos en la cola
        int rd_idx;             ///indice a la posicion actual de lectura, 
                                ///la posicion de escritura es (rd_idx+num_e) MOD Q_SIZE
} q_func_t;


/** Inicializa la cola 
        @param queue Puntero a la estructura de cola
*/
void init_queue(q_func_t* queue);

/** Agrega un elemento en la cola
        @param queue Cola donde se guarda el elemento
        @param e untero a funcion void sin parametros a guardar
*/
void add_element(q_func_t* queue,f_ptr_t e);

/** Extrae un elemento del principio de la cola
        @param queue Cola de la cual se extrae el elemento
        @return puntero a funcion void sin parametros al principio de la cola
*/
f_ptr_t remove_element(q_func_t* queue);

/** Retorna verdadero si la cola esta vacia
        @param queue Cola por la cual se pregunta su estado
        @return Verdadero si esta vacia
*/
int is_empty(q_func_t* queue);

/** Retorna verdadero si la cola esta llena
        @param queue Cola por la cual se pregunta su estado
        @return Verdadero si esta llena
*/
int is_full(q_func_t* queue);

        #ifdef DEBUG_QF
        /** Herramienta para debug
                @param queue Cola que sera imprimida en la salida estandar
                @param message Mensaje para imprimir junto con la cola
        */
        void debug_print_queue(q_func_t* queue,char* message);

        #endif
#endif
