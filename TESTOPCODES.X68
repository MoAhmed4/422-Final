*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $3000
    MOVEM.L D1-D2, -(A7)
    MOVEM.L (A7)+,D1-D2
    ORI.W #54, D6
    ASL.B D2, D3
    CMP.W $6545, D2
    BRA label53
    NOP
    ADD.W (A4)+, D2
    ADDA.L A5, A6
    BCS label53
    BGE label53
    BLT label53
    BVC label53
    BCLR #2, D2
    CMPI.L #5, D4
    DIVS.W D2, D1
    EOR.W D1, D2
    JSR label53
    LEA message, A2
    LSR.W $5000
    LSL.L D2, D3
    MOVE.B $5654, (A5)+
    MOVEA.W A5, A6
    MOVEM.L D1-D2, -(A7)
    MULS.W #1, D2
    NEG D4
    OR.W D4, D5    
    ROL.L #2, D2
    ROR.W $2000
    RTS
    SUB.W D2, D3
    SUBQ.L #8, D3
    ASR.W #2, D1
    
    
label53
message DC.B 'something',0

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
