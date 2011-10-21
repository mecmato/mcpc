;******************************************************************************
;  MSP430F54x Demo - Reset on Invalid Address fetch, Toggle P1.0
;
;  Description: This program demonstrates how a reset is executed if the CPU
;  tries to fetch instructions from within the module register memory address
;  range (0x0100 --0x0FEF) or from within unused address ranges. Toggle P1.0
;  by xor'ing P1.0 inside of a software loop that ends with TAR loaded with
;  3FFFh - op-code for "jmp $". This simulates a code error. The MSP430F5438
;  will force a reset because it will not allow a fetch from within the address
;  range of the peripheral memory, as is seen by return to the mainloop and
;  LED flash.
;  ACLK = n/a, MCLK = SMCLK = default DCO ~1.045MHz
;
;                MSP430F5438
;             -----------------
;         /|\|                 |
;          | |                 |
;          --|RST              |
;            |                 |
;            |             P1.0|-->LED
;
;   M. Morales
;   Texas Instruments Inc.
;   September 2008
;   Built with IAR Embedded Workbench Version: 4.11B
;******************************************************************************

#include "msp430x54x.h"

#define     count   R4

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT   
            bis.b   #BIT0,&P1DIR            ; Set P1.0 to output direction
            bis.w   #0x3FFF,&TA0R           ; Valid opcode (for "jmp $")

while_loop  xor.b   #BIT0,&P1DIR            ; Toggle P1.0 (LED)
            mov.w   #50000,count            ; Load delay counter
delay_loop  dec.w   count                   ; Decrement delay counter    
            jne     delay_loop              
            mov.w   #0x0350,PC              ; attempt to execute an instruction
                                            ; from address 0x0350 (invalid fetch)
            jmp     while_loop

;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END
