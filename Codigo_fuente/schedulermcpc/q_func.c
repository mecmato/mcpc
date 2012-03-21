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

        //assert(!is_full(queue));
        //assert_t(!is_full(queue),"Queue is full, can't add more elements.\n... exited.");

        
        aux_idx = CIRCULAR_INDEX(queue->rd_idx + queue->num_e);  //indice de escritura
        *(queue->elements + aux_idx) = e;
        queue->num_e++;
}

f_ptr_t remove_element(q_func_t* queue){
        f_ptr_t aux_e;

        //assert(!is_empty(queue));
        //assert_t(!is_empty(queue),"Queue is empty, can't remove any element.\n... exited.");

        aux_e = *(queue->elements + queue->rd_idx);
        INC_CIRC_INDEX(queue->rd_idx);
        queue->num_e--;
        return aux_e;
}

int is_empty(q_func_t* queue){
        return (queue->num_e == 0);
}

int is_full(q_func_t* queue){
        return (queue->num_e == QF_SIZE);
}

#ifdef DEBUG_QF
        #include <stdio.h>
        void debug_print_queue(q_func_t* queue,char* message){
                int i;

                printf("%s\n",message);
                printf("Queue struct print for debug:\n");

                printf("        queue->num_e = %d\n",queue->num_e);

                printf("        queue->elements = { %p",*(queue->elements));
                for(i=1;i<QF_SIZE;i++) printf(", %p",*(queue->elements + i));
                printf(" }\n");
                
                printf("        queue->rd_idx = %d\n",queue->rd_idx);
                printf("        is_mpty(queue) = %d\n",is_empty(queue));
                printf("        is_full(queue) = %d\n",is_full(queue));
        }
#endif



