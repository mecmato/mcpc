/**     Implementacion de cola FIFO circular version 1.0

       
        |<-rd_idx->|<-------num_e--------------->|
        _0____1____2____3_____   ______________________Q_SIZE-1
        |  X |  X |  A |  B |     |  J |  K |  L |  X |  X |
        |____|____|____|____|__  _|____|____|____|____|____| >-------|
        ^                                                            |
        |<-----------------------------------------------------------|
        |
       queue->elments
         

        abril 2008 - Juan Pablo Gonzalez
        Sistemas Embebidos de Tiempo Real - IIE - Facultad de Ingenieria - UdelaR
*/

#include "q_func.h"
//#include "tools.h"
//#include <assert.h>

#define CIRCULAR_INDEX(I) (I)%QF_SIZE
#define INC_CIRC_INDEX(I) I=(++(I))%QF_SIZE


void init_queue(q_func_t* queue){
        queue->num_e = 0;
        queue->rd_idx = 0;
}

void add_element(q_func_t* queue,f_ptr_t e){
        int aux_idx;

        aux_idx = CIRCULAR_INDEX(queue->rd_idx + queue->num_e);  //indice de escritura
        *(queue->elements + aux_idx) = e;
        queue->num_e++;
}

f_ptr_t remove_element(q_func_t* queue){
        f_ptr_t aux_e;

        aux_e = *(queue->elements + queue->rd_idx);
        INC_CIRC_INDEX(queue -> rd_idx);
        queue->num_e--;
        return aux_e;
}

int is_empty(q_func_t* queue){
        return (queue->num_e == 0);
}

int is_full(q_func_t* queue){
        return (queue->num_e == QF_SIZE);
}



