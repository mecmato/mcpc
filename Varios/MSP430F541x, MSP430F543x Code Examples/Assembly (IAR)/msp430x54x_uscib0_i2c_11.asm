;*******************************************************************************
;  MSP430F54x Demo - USCI_B0 I2C Slave TX multiple bytes to MSP430 Master
;
;  Description: This demo connects two MSP430's via the I2C bus. The slave
;  transmits to the master. This is the slave code. The interrupt driven
;  data transmission is demonstrated using the USCI_B0 TX interrupt.
;  ACLK = n/a, MCLK = SMCLK = default DCO = ~1.045MHz
;
;                                /|\  /|\
;               MSP430F5438      10k  10k     MSP430F5438
;                   slave         |    |        master
;             -----------------   |    |   -----------------
;            |     P3.1/UCB0SDA|<-|----+->|P3.1/UCB0SDA     |
;            |                 |  |       |                 |
;            |                 |  |       |                 |
;            |     P3.2/UCB0SCL|<-+------>|P3.2/UCB0SCL     |
;            |                 |          |                 |
;
;   W. Goh
;   Texas Instruments Inc.
;   September 2008
;   Built with IAR Embedded Workbench Version: 4.11B
;*******************************************************************************

#include "msp430x54x.h"

#define     PTxData   R5

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
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
            bis.b   #UCTXIE + UCSTPIE + UCSTTIE,&UCB0IE
                                            ; Enable TX, Start Stop interrupt
Mainloop
            mov.w   #TxData,PTxData         ; Start of TX buffer
            bis.b   #LPM0 + GIE,SR          ; Enter LPM0, enable interrupts
                                            ; Remain in LPM0 until master
                                            ; finishes RX
            nop                             ; Set breakpoint >>here<< and
                                            ; read out the TXByteCtr counter
            jmp    Mainloop                 ; Repeat

;-------------------------------------------------------------------------------
; The USCI_B0 data ISR TX vector is used to move data from MSP430 memory to the
; I2C master. PTxData points to the next byte to be transmitted.
;-------------------------------------------------------------------------------
; The USCI_B0 state ISR stop vector is used to wake up the CPU from LPM0 in
; order to do processing in the main program after data has been transmitted.
; LPM0 is only exit in case of a (re-)start or stop condition when actual data
; was transmitted.
;-------------------------------------------------------------------------------
USCI_B0_ISR;        USCI_B0 Interrupt Handler ISR
;-------------------------------------------------------------------------------
            add.w   &UCB0IV,PC              ; Add offset to PC
            reti                            ; Vector 0: No interrupt
            reti                            ; Vector 2: ALIFG
            reti                            ; Vector 4: NACKIFG
            jmp     STTIFG_ISR              ; Vector 6: STTIFG
            jmp     STPIFG_ISR              ; Vector 8: STPIFG
            reti                            ; Vector 10: RXIFG
            jmp     TXIFG_ISR               ; Vector 12: TXIFG
                                            ;
STTIFG_ISR                                  ; STT Interrupt Handler
            bic.b   #UCSTTIFG,&UCB0IFG      ; Clear start condition int flag
            reti                            ;
STPIFG_ISR                                  ; STP Interrupt Handler
            bic.b   #UCSTPIFG,&UCB0IFG      ; Clear stop condition int flag
            bic.w   #LPM0,0(SP)             ; Clear LPM0
            reti
TXIFG_ISR                                   ; TXIFG Interrupt Handler
            mov.b   @PTxData+,&UCB0TXBUF    ; TX data
            reti                            ;
                                            ;
;-------------------------------------------------------------------------------
TxData;     Table of data to transmit
;-------------------------------------------------------------------------------
            DB      011h
            DB      022h
            DB      033h
            DB      044h
            DB      055h
;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     USCI_B0_VECTOR          ; USCI_BO Interrupt Vector
            DW      USCI_B0_ISR
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END