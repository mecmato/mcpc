;******************************************************************************
;  MSP430F54x Demo - XT2 sources MCLK & SMCLK
;
;  Description: This program demonstrates using XT2 to source MCLK. XT1 is not
;  connected in this case.
;
;  By default, LFXT1 is requested by the following modules:
;     - FLL
;     - ACLK
;  If LFXT1 is NOT used and if the user does not change the source modules,
;  it causes the XT1xxOFIFG flag to be set because it is constantly looking
;  for LFXT1. OFIFG, global oscillator fault flag, will always be set if LFXT1
;  is set. Hence, it is important to ensure LFXT1 is no longer being sourced
;  if LFXT1 is NOT used.
;  MCLK = XT2
;
;               MSP430F5438
;             -----------------
;        /|\ |                 |
;         |  |                 |
;         ---|RST              |
;            |            XT2IN|-
;            |                 | HF XTAL (455kHz - 16MHz)
;            |           XT2OUT|-
;            |                 |
;            |            P11.1|--> MCLK = XT2
;            |                 |
;
;   W. Goh
;   Texas Instruments Inc.
;   February 2009
;   Built with CCE Version: 3.2.2 and IAR Embedded Workbench Version: 4.11B
;******************************************************************************

#include <msp430x54x.h>

#define     count   R4
;-------------------------------------------------------------------------------
            RSEG    CSTACK                  ; Define stack segment
;-------------------------------------------------------------------------------
            RSEG    CODE                    ; Assemble to Flash memory
;-------------------------------------------------------------------------------
RESET       mov.w   #SFE(CSTACK),SP         ; Initialize stackpointer
            mov.w   #WDTPW + WDTHOLD,&WDTCTL; Stop WDT
            mov.b   #BIT1 + BIT2,&P11DIR    ; P11.1-2 to output direction
            bis.b   #BIT1 + BIT2,&P11SEL    ; P11.1-2 to output SMCLK,MCLK
            bis.b   #0x0C,&P5SEL            ; Port select XT2

            bic.w   #XT2OFF,&UCSCTL6        ; Clear XT2OFF bit
            bis.w   #SELREF_2,&UCSCTL3      ; FLLref = REFO
                                            ; Since LFXT1 is not used,
                                            ; sourcing FLL with LFXT1 can cause
                                            ; XT1OFFG flag to set
            bis.w   #SELA_2,&UCSCTL4        ; ACLK=REFO,SMCLK=DCO,MCLK=DCO

            ; Loop until XT1,XT2 & DCO stabilizes
do_while    bic.w   #XT2OFFG + XT1LFOFFG + XT1HFOFFG + DCOFFG,&UCSCTL7
                                            ; Clear XT2,XT1,DCO fault flags
            bic.w   #OFIFG,&SFRIFG1         ; Clear fault flags
            bit.w   #OFIFG,&SFRIFG1         ; Test oscillator fault flag
            jc      do_while

            bic.w   #XT2DRIVE0,&UCSCTL6     ; Decrease XT2 Drive according to
                                            ; expected frequency
            bis.w  #SELS_5 + SELM_5,&UCSCTL4; SMCLK=MCLK=XT2

while_loop  jmp     while_loop

;-------------------------------------------------------------------------------
            COMMON  INTVEC                  ; Interrupt Vectors
;-------------------------------------------------------------------------------
            ORG     RESET_VECTOR            ; POR, ext. Reset
            DW      RESET
            END