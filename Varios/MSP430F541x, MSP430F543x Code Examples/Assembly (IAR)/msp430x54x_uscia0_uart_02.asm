;******************************************************************************
;   MSP430F54x Demo - USCI_A0, Ultra-Low Pwr UART 2400 Echo ISR, 32kHz ACLK
;
;   Description: Echo a received character, RX ISR used. Normal mode is LPM3,
;   USCI_A0 RX interrupt triggers TX Echo.
;   ACLK = REFO = ~32768Hz, MCLK = SMCLK = DCO ~1.045MHz
;   Baud rate divider with 32768Hz XTAL @2400 -- from User's Guide
;   See User Guide for baud rate divider table
;
;                 MSP430F5438
;             -----------------
;         /|\|                 |
;          | |                 |
;          --|RST              |
;            |                 |
;            |     P3.4/UCA0TXD|------------>
;            |                 | 2400 - 8N1
;            |     P3.5/UCA0RXD|<------------
;
;   M. Morales
;   Texas Instruments Inc.
;   September 2008
;   Built with IAR Embedded Workbench Version: 4.11B
;******************************************************************************

#include <msp430x54x.h>

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT    
            mov.b   #0x30,&P3SEL            ; P3.4,5 = USCI_A0 TXD/RXD
  
            bis.b   #UCSWRST,&UCA0CTL1      ; **Put state machine in reset**
            bis.b   #UCSSEL_1,&UCA0CTL1     ; CLK = ACLK
            mov.b   #0x0D,&UCA0BR0          ; 2400 Baud
            mov.b   #0x00,&UCA0BR1 
            bis.b   #UCBRS_6 + UCBRF_0,&UCA0MCTL
                                            ; Modulation UCBRSx=6, UCBRFx=0
            bic.b   #UCSWRST,&UCA0CTL1      ; **Initialize USCI state machine**
            bis.b   #UCRXIE,&UCA0IE         ; Enable USCI_A1 RX interrupt
 
            bis.w   #LPM3 + GIE,SR          ; Enter LPM3, interrupts enabled
            nop                             ; For debugger
            
;-------------------------------------------------------------------------------
USCI_A0_ISR
;-------------------------------------------------------------------------------
            ; Echo back RXed character, confirm TX buffer is ready first
            add.w   &UCA0IV,PC      
            reti                            ; Vector 0 - no interrupt
            jmp     RXIFG_HND               ; Vector 2 - RXIFG
            reti                            ; Vector 4 - TXIFG

RXIFG_HND
wait_TX_rdy bit.b   #UCTXIFG,&UCA0IFG       ; USCI_A0 TX buffer ready? 
            jnc     wait_TX_rdy
            mov.b   &UCA0RXBUF,&UCA0TXBUF   ; RXBUF -> TXBUF
            reti                            ; Return from interrupt 

;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     USCI_A0_VECTOR
            DW      USCI_A0_ISR
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END
            