;******************************************************************************
;   MSP430x54x Demo - Enters LPM3 (ACLK = VLO)
;
;   Description: Enters LPM3 with ACLK = VLO.
;   ACLK = MCLK = SMCLK = VLO = 12kHz
;   Note: SVS(H,L) & SVM(H,L) not disabled
;
;                 MSP430x5438
;             -----------------
;         /|\|                 |
;          | |                 |
;          --|RST              |
;            |                 |
;
;   W. Goh
;   Texas Instruments Inc.
;   April 2009
;   Built with IAR Embedded Workbench Version: 4.11B
;******************************************************************************
#include  "msp430x54x.h"

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT

            mov.w   #SELM_1+SELS_1+SELA_1,&UCSCTL4
                                            ; Set MCLK = SMCLK = ACLK = VLO

            mov.b   #0xFF,&P1DIR
            mov.b   #0xFF,&P2DIR
            mov.b   #0xFF,&P3DIR
            mov.b   #0xFF,&P4DIR
            mov.b   #0xFF,&P5DIR
            mov.b   #0xFF,&P6DIR
            mov.b   #0xFF,&P7DIR
            mov.b   #0xFF,&P8DIR
            mov.b   #0xFF,&P9DIR
            mov.b   #0xFF,&P10DIR
            mov.b   #0xFF,&P11DIR
            mov.w   #0xFF,&PJDIR
            clr.b   P1OUT
            clr.b   P2OUT
            clr.b   P3OUT
            clr.b   P4OUT
            clr.b   P5OUT
            clr.b   P6OUT
            clr.b   P7OUT
            clr.b   P8OUT
            clr.b   P9OUT
            clr.b   P10OUT
            clr.b   P11OUT
            clr.w   PJOUT

            bis.w   #LPM3,SR                ; Enter LPM3
            nop                             ; For debugger

;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END
