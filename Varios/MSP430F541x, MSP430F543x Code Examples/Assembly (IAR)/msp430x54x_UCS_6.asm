;******************************************************************************
;  MSP430F54x Demo - XT1 sources ACLK
;
;  Description: This program demonstrates using XT1 to source ACLK
;  ACLK = LFXT1 = 32,768Hz	
;  ;* An external watch crystal between XIN & XOUT is required for ACLK *;	
;
;               MSP430F5438
;             -----------------
;        /|\ |              XIN|-
;         |  |                 | 32kHz
;         ---|RST          XOUT|-
;            |                 |
;            |            P11.0|--> ACLK = ~32kHz
;            |                 |
;
;   W. Goh
;   Texas Instruments Inc.
;   April 2009
;   Built with IAR Embedded Workbench Version: 4.11B
;******************************************************************************

#include <msp430x54x.h>

;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDT_ADLY_1000,&WDTCTL  ; WDT ~1000ms, ACLK, interval timer
            bis.w   #WDTIE,&SFRIE1          ; Enable WDT interrupt
            bis.w   #SELA_0,&UCSCTL4        ; LFXT1 Sources ACLK

            bis.b   #BIT0,&P1DIR;           ; P1.0 to output direction
            bis.b   #BIT0,&P11DIR           ; P11.0 to output direction
            bis.b   #BIT0,&P11SEL           ; P11.0 to output ACLK

            bis.b   #0x03,&P7SEL            ; Select XT1
            bic.w   #XT1OFF,&UCSCTL6        ; XT1 On
            bis.w   #XCAP_3,&UCSCTL6        ; Internal load cap

            ; Loop until XT1,XT2 & DCO stabilizes
do_while    bic.w   #XT2OFFG + XT1LFOFFG + XT1HFOFFG + DCOFFG,&UCSCTL7
                                            ; Clear XT2,XT1,DCO fault flags
            bic.w   #OFIFG,&SFRIFG1         ; Clear fault flags
            bit.w   #OFIFG,&SFRIFG1         ; Test oscillator fault flag
            jc      do_while

            bic.w   #XT1DRIVE_3,&UCSCTL6    ; XT1 stable, reduce drive strength

            bis.w   #LPM3 + GIE,SR          ; Enter LPM3 w/ interrupts
            nop                             ; For debugger

;-------------------------------------------------------------------------------
WDT_ISR;    Watchdog Timer interrupt service routine
;-------------------------------------------------------------------------------
            xor.b   #0x01,&P1OUT            ; Toggle P1.0 using exclusive-OR
            reti
;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     WDT_VECTOR              ; WDT Vector
            DW      WDT_ISR
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END