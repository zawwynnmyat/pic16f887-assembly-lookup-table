#include <P16F887.inc>

 __CONFIG _CONFIG1, _FOSC_EXTRC_CLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_ON
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
RES_VECT  CODE    0x0000         ; processor reset vector
    GOTO START                   ; go to beginning of program

INT_VECT CODE      0x0004        ; interrupt vector
    GOTO ISR                     ; go to interrupt service routine

MAIN_PROG CODE                      ; let linker place main program

CBLOCK 0x20
    micros
    ones
    tens
    count
ENDC

START
    bsf STATUS,RP0
    movlw 0x00
    movwf TRISB
    movlw 0x00
    movwf TRISC
    movlw 0x07
    movwf OPTION_REG
    bcf STATUS,RP0
    bsf INTCON,GIE
    bsf INTCON,TMR0IE
    clrf ones
    clrf tens
    clrf micros

MAIN
    movlw 0x02
    movwf PORTC
    movf ones, W
    call TABLE
    movwf PORTB
    call DELAY
    movlw 0x01
    movwf PORTC
    movf tens, W
    call TABLE
    movwf PORTB
    call DELAY
    goto MAIN
   
ISR
    bcf INTCON,GIE
    bcf INTCON,TMR0IE
    incf micros,1
    movf micros,0
    sublw 0x0F
    btfsc STATUS,Z
    goto inc_ones
    goto ret
inc_ones
    clrf micros
    incf ones, 1
    movf ones, 0
    sublw 0x0A
    btfsc STATUS,Z
    goto inc_tens
    goto ret
inc_tens
    clrf ones
    incf tens, 1
    movf tens, 0
    sublw 0x0A
    btfsc STATUS,Z
    clrf tens
    goto ret
ret bcf INTCON,TMR0IF
    bsf INTCON,GIE
    bsf INTCON,TMR0IE
    retfie

DELAY
    LOOP DECFSZ count,F
    GOTO LOOP
    RETURN
  
TABLE   addwf PCL
        retlw b'00111111'    ;digit 0
        retlw b'00000110'    ;digit 1
        retlw b'01011011'    ;digit 2
        retlw b'01001111'    ;digit 3
        retlw b'01100110'    ;digit 4
        retlw b'01101101'    ;digit 5
        retlw b'01111101'    ;digit 6
        retlw b'00000111'    ;digit 7
        retlw b'01111111'    ;digit 8
        retlw b'01101111'    ;digit 9    

    END