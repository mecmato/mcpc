;*******************************************************************************
;  MSP430F54x Demo - USCI_B0 I2C Slave RX multiple bytes from MSP430 Master
;
;  Description: This demo connects two MSP430's via the I2C bus. The master
;  transmits to the slave. This is the slave code. The interrupt driven
;  data receiption is demonstrated using the USCI_B0 RX interrupt.
;  ACLK = n/a, MCLK = SMCLK = default DCO = ~1.045MHz
;
;                                /|\  /|\
;                MSP430F5438     10k  10k     MSP430F5438
;                   slave         |    |         master
;             -----------------   |    |   -----------------
;           -|XIN  P3.1/UCB0SDA|<-|----+->|P3.1/UCB0SDA  XIN|-
;            |                 |  |       |                 |
;           -|XOUT             |  |       |             XOUT|-
;            |     P3.2/UCB0SCL|<-+------>|P3.2/UCB0SCL     |
;            |                 |          |                 |
;
;   W. Goh
;   Texas Instruments Inc.
;   September 2008
;   Built with IAR Embedded Workbench Version: 4.11B
;*******************************************************************************

#include "msp430x54x.h"

#define     PRxData     R5
#define     RXByteCtr   R6
#define     RXBuffSize  128

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    DATA16_N                ; RAM
;-------------------------------------------------------------------------------
RxBuffer    DS      RXBuffSize              ; Allocate 128 byte of RAM
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT

            bis.b   #0x06,&P3SEL            ; Assign I2C pins to USCI_B0
            bis.b   #UCSWRST,&UCB0CTL1      ; **Put state machine in reset**
            mov.b   #UCMODE_3 + UCSYNC,&UCB0CTL0
                                            ; I2C Slave, synchronous mode
            mov.w   #0x48,&UCB0I2COA        ; Own Address is 048h
            bic.b   #UCSWRST,&UCB0CTL1      ; **Initialize USCI state machine**
            bis.b   #UCSTPIE + UCSTTIE + UCRXIE,&UCB0IE
                                            ; Enable Start, Stop & RX interrupt
Mainloop    mov.w   #RxBuffer,PRxData       ; Start of RX buffer
            clr.w   RXByteCtr               ; Clear RX byte count
            bis.b   #LPM0 + GIE,SR          ; Enter LPM0, enable interrupts
                                            ; Remain in LPM0 until master
                                            ; finishes TX
            nop                             ; Set breakpoint >>here<< and read
            jmp     Mainloop                ; Repeat
                                            ;
;-------------------------------------------------------------------------------
; The USCI_B0 state ISR is used to wake up the CPU from LPM0 in order to
; process the received data in the main program. LPM0 is only exit in case
; of a (re-)start or stop condition when actual data was received.
;-------------------------------------------------------------------------------
USCI_B0_ISR;        USCI_B0 Interrupt Handler ISR
;-------------------------------------------------------------------------------
            add.w   &UCB0IV,PC              ; Add offset to PC
            reti                            ; Vector 0: No interrupt
            reti                            ; Vector 2: ALIFG
            reti                            ; Vector 4: NACKIFG
            jmp     STTIFG_ISR              ; Vector 6: STTIFG
            jmp     STPIFG_ISR              ; Vector 8: STPIFG
            jmp     RXIFG_ISR               ; Vector 10: RXIFG
            reti                            ; Vector 12: TXIFG
                                            ;
STTIFG_ISR                                  ; STT Interrupt Handler
            bic.b   #UCSTTIFG,&UCB0IFG      ; Clear start condition int flag
            reti                            ;
STPIFG_ISR                                  ; STP Interrupt Handler
            bic.b   #UCSTPIFG,&UCB0IFG      ; Clear stop condition int flag
            tst.w   RXByteCtr               ; Check RX byte counter
            jz      USCIAB0RX_ISR_1         ; Jump if nothing was received
            bic.b   #LPM0,0(SP)             ; Clear LPM0
USCIAB0RX_ISR_1
            reti
RXIFG_ISR                                   ; RXIFG Interrupt Handler
            mov.b   UCB0RXBUF,0(PRxData)    ; Get RX'd byte into buffer
            inc.w   PRxData                 ; Increment Pointer
            inc.w   RXByteCtr               ;
            reti                            ;
                                            ;
;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     USCI_B0_VECTOR          ; USCI_BO Interrupt Vector
            DW      USCI_B0_ISR
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END
