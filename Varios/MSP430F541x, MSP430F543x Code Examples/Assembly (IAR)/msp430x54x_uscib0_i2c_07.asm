;*******************************************************************************
;  MSP430F54x Demo - USCI_B0 I2C Slave RX single bytes from MSP430 Master
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

#define     RXData    R5

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT

            bis.b   #0x06,&P3SEL            ; Assign I2C pins to USCI_B0
            bis.b   #UCSWRST,&UCB0CTL1      ; **Put state machine in reset**
            mov.b   #UCMODE_3 + UCSYNC,UCB0CTL0; I2C Slave, synchronous mode
            mov.w   #0x48,&UCB0I2COA        ; Own Address is 048h
            bic.b   #UCSWRST,&UCB0CTL1      ; **Initialize USCI state machine**
            bis.b   #UCRXIE,&UCB0IE         ; Enable RX interrupt

Mainloop    bis.b   #LPM0 + GIE,SR          ; Enter LPM0, enable interrupts
            nop                             ; Set breakpoint >>here<< and read
            jmp     Mainloop                ; RXData
                                            ;
;-------------------------------------------------------------------------------
USCI_B0_ISR;        USCI_B0 Interrupt Handler ISR
;-------------------------------------------------------------------------------
            add.w   &UCB0IV,PC              ; Add offset to PC
            reti                            ; Vector 0: No interrupt
            reti                            ; Vector 2: ALIFG
            reti                            ; Vector 4: NACKIFG
            reti                            ; Vector 6: STTIFG
            reti                            ; Vector 8: STPIFG
            jmp     RXIFG_ISR               ; Vector 10: RXIFG
            reti                            ; Vector 12: TXIFG
                                            ;
RXIFG_ISR                                   ; RXIFG Interrupt Handler
            mov.b   &UCB0RXBUF,RXData       ; Get RX data
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
