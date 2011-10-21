;*******************************************************************************
;  MSP430F54x Demo - USCI_B0 I2C Master TX single bytes to MSP430 Slave
;
;  Description: This demo connects two MSP430's via the I2C bus. The master
;  transmits to the slave. This is the master code. It continuously
;  transmits 00h, 01h, ..., 0ffh and demonstrates how to implement an I2C
;  master transmitter sending a single byte using the USCI_B0 TX interrupt.
;  ACLK = n/a, MCLK = SMCLK = BRCLK = default DCO = ~1.045MHz
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

#define     TXData    R5
#define     TXByteCtr R6

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT

            bis.b   #0x06,&P3SEL            ; Assign I2C pins to USCI_B0
            bis.b   #UCSWRST,&UCB0CTL1      ; **Put state machine in reset**
            mov.b   #UCMST + UCMODE_3 + UCSYNC,UCB0CTL0 ; I2C Master, synchronous mode
            mov.b   #UCSSEL_2 + UCSWRST,UCB0CTL1 ; Use SMCLK, keep SW reset
            mov.b   #12,&UCB0BR0            ; fSCL = SMCLK/12 = ~100kHz
            mov.b   #0,&UCB0BR1             ;
            mov.w   #0x48,&UCB0I2CSA        ; Slave Address is 0x48
            bic.b   #UCSWRST,&UCB0CTL1      ; **Initialize USCI state machine**
            bis.b   #UCTXIE,&UCB0IE         ; Enable TX interrupt

            clr.b   TXData                  ; Load TX data into R5

Mainloop    mov.w   #1,TXByteCtr            ; Load TX byte counter

Mainloop_1  bit.b   #UCTXSTP,&UCB0CTL1      ; Loop until I2C STP got sent
            jc      Mainloop_1
            bis.b   #UCTR + UCTXSTT,&UCB0CTL1; I2C TX, start condition

            bis.b   #LPM0 + GIE,SR          ; Enter LPM0 w/ interrupts
            nop                             ; Remain in LPM0 until all data
                                            ; is TX'd
            inc.b   TXData                  ; Increment data byte
            jmp     Mainloop

;-------------------------------------------------------------------------------
; The USCIAB0_ISR is structured such that it can be used to transmit any
; number of bytes by pre-loading TXByteCtr with the byte count.
;-------------------------------------------------------------------------------
USCI_B0_ISR;        USCI_B0 Interrupt Handler ISR
;-------------------------------------------------------------------------------
            add.w   &UCB0IV,PC              ; Add offset to PC
            reti                            ; Vector 0: No interrupt
            reti                            ; Vector 2: ALIFG
            reti                            ; Vector 4: NACKIFG
            reti                            ; Vector 6: STTIFG
            reti                            ; Vector 8: STPIFG
            reti                            ; Vector 10: RXIFG
            jmp     TXIFG_ISR               ; Vector 12: TXIFG
                                            ;
TXIFG_ISR                                   ; TXIFG Interrupt Handler
            tst.w   TXByteCtr               ; Check TX byte counter
            jz      USCIAB0TX_ISR_1         ; Jump if all bytes were TX'd

            mov.b   TXData,&UCB0TXBUF       ; Load TX buffer

            dec.w   TXByteCtr               ; Decrement TX byte counter
            reti

USCIAB0TX_ISR_1
            bis.b   #UCTXSTP,&UCB0CTL1      ; I2C stop condition
            bic.b   #UCTXIFG,&UCB0IFG       ; Clear USCI_B0 TX int flag
            bic.b   #LPM0,0(SP)             ; Exit LPM0
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