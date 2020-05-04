*-----------------------------------------------------------
* Title      : OP-CODE routine
* Written by : Mohammed
* Date       : 11/25/2018
*-----------------------------------------------------------

OPCODE      DS.W        1                       
OP_SUCESS   DS.W        1

******************************
*       OP CODE 0XXX         *
*                            *
*BCLR, CMPI, ORI             *
******************************
OP0
            MOVEM.L     D0,-(SP)                
            

_OPBCLR1:   MOVE.W      OPCODE,D0              
            ANDI.W      #$0FC0,D0              
            CMP.W       #$0880,D0               
            BNE         _OPORI               
            JSR         OP_BCLR1                
            BRA         _DONEP0               

_OPBCLR2:   MOVE.W      OPCODE,D0              
            ANDI.W      #$01C0,D0               
            CMP.W       #$0188,D0               
            BNE         _BADP0                
            JSR         OP_BCLR2                
            BRA         _DONEP0 
                        
_OPORI:     MOVE.W      OPCODE,D0              
            ANDI.W      #$0F00,D0               
            CMP.W       #$0000,D0              
            BNE         _OPCMPI               
            JSR         OP_ORI                  
            BRA         _DONEP0
               
_OPCMPI:    MOVE.W      OPCODE,D0              
            ANDI.W      #$0F00,D0              
            CMP.W       #$0C00,D0              
            BNE         _OPBCLR2               
            JSR         OP_CMPI                 
            BRA         _DONEP0               

              
            
_BADP0:     CLR         OP_SUCESS               
_DONEP0:    MOVEM.L     (SP)+,D0                
            RTS                                 
    
            
               
******************************
*       OP CODE 4XXX         *
*                            *
*MOVEM, NEG, RTS, NOP, LEA   *
*JSR                         *
******************************
OP4
            MOVE.L D0, -(SP)

_OPMOVECCR: MOVE.W OPCODE,D0
            ANDI.W #$FFC0,D0
            CMP.W #$44C0, D0
            BNE _OPNEG
            BRA _BADP4 * not supported  

_OPNEG:     MOVE.W OPCODE,D0
            ANDI.W #$FF00,D0
            CMP.W #$4400, D0
            BNE _OPNOP
            JSR OP_NEG
            BRA _DONEP4            
            
_OPNOP:     MOVE.W  OPCODE,D0
			ANDI.W  #$0FFF,D0
			CMP.W   #$0E71,D0
			BNE		_OPRTS
			JSR		OP_NOP
			BRA     _DONEP4

_OPRTS:     MOVE.W  OPCODE,D0
            ANDI.W  #$0FFF,D0
            CMP.W   #$0E75,D0
            BNE     _OPLEA
            JSR     OP_RTS
            BRA     _DONEP4

_OPLEA:     MOVE.W  OPCODE,D0
            ANDI.W  #$01C0,D0
            CMP.W   #$01C0,D0
            BNE     _OPJSR
            JSR     OP_LEA
            BRA     _DONEP4

_OPJSR:     MOVE.W  OPCODE,D0
            ANDI.W  #$0E80,D0
            CMP.W   #$0E80,D0
            BNE     _OPMOVEM
            JSR     OP_JSR
            BRA     _DONEP4


_OPMOVEM:   MOVE.W      OPCODE,D0              
            ANDI.W      #$0B80,D0               
            CMP.W       #$0880,D0               
            BNE         _BADP4                
            JSR         OP_MOVEM                
            BRA         _DONEP4              


_BADP4:     CLR         OP_SUCESS               
_DONEP4:    MOVEM.L     (SP)+,D0               
            RTS

    
******************************
*       OP CODE 5XXX         *
*                            *
*SUBQ                        *
******************************
OP5
            MOVE.L D0, -(SP)

_OPSUBQ:    MOVE.W  OPCODE,D0
            ANDI.W  #$01C0,D0
            CMP.W   #$01C0,D0
            BEQ     _BADP5
            JSR     OP_SUBQ
            BRA     _DONEP5

_BADP5:     CLR         OP_SUCESS               
_DONEP5:    MOVEM.L     (SP)+,D0
            RTS
            
            
    
******************************
*       OP CODE 6XXX         *
*                            *
*Bcc(BCS,BGE,BLT,BVC), BRA                    *
******************************
OP6
            MOVE.L D0, -(SP)
            
_OPBRA:     MOVE.W  OPCODE,D0
            ANDI.W  #$0F00,D0
            CMP.W   #$0000,D0
            BNE     _OPBCS
            JSR     OP_BRA
            BRA     _DONEP6
            
_OPBCS:     MOVE.W  OPCODE,D0
            ANDI.W  #$0F00,D0
            CMP.W   #$0500,D0
            BNE     _OPBGE
            JSR     OP_BCS
            BRA     _DONEP6
            
_OPBGE:     CMP.W   #$0C00,D0
            BNE     _OPBLT
            JSR     OP_BGE
            BRA     _DONEP6

_OPBLT:     CMP.W   #$0D00,D0
            BNE     _OPBVC
            JSR     OP_BLT
            BRA     _DONEP6
            
_OPBVC:     CMP.W   #$0800,D0
            BNE     _BADP6
            JSR     _OPBVC
            BRA     _DONEP6
            
            
_BADP6:     CLR         OP_SUCESS               
_DONEP6:    MOVEM.L     (SP)+,D0        

            RTS

    
******************************
*       OP CODE 7XXX         *
*                            *
*not supported               *
******************************
OP7
_BADP7:     CLR         OP_SUCESS               
            RTS

    
******************************
*       OP CODE 8XXX         *
*                            *
*DIVS, OR                    *
******************************
OP8
            MOVE.L D0, -(SP)
            
_OPDIVS:    MOVE.W  OPCODE,D0
            ANDI.W  #$01C0,D0
            CMP.W   #$01C0,D0
            BNE     _OPOR
            JSR     OP_DIVS
            BRA     _DONEP8
            
_OPOR:      MOVE.W  OPCODE,D0
            ANDI.W  #$00C0,D0
            CMP.W   #$00C0,D0
            BEQ     _BADP8
            JSR     OP_OR
            BRA     _DONEP8

_BADP8:     CLR         OP_SUCESS            
_DONEP8:    MOVEM.L     (SP)+,D0
            RTS

    
******************************
*       OP CODE 9XXX         *
*                            *
*SUB                         *
****************************** 
OP9
            MOVE.L D0, -(SP)

_OPSUBA:    MOVE.W  OPCODE,D0
            ANDI.W  #$00C0,D0
            CMP.W   #$00C0,D0
            BNE     _OPSUB  
            BRA     _BADP9 * not supported

_OPSUB:     JSR     OP_SUB
            BRA     _DONEP9    
            
_BADP9:     CLR         OP_SUCESS            
_DONEP9:    MOVEM.L     (SP)+,D0            
            RTS

    
******************************
*       OP CODE AXXX         *
*                            *
*not supported               *
******************************
OPA
_BADPA:     CLR         OP_SUCESS                   
            RTS

    
******************************
*       OP CODE BXXX         *
*                            *
*CMP, EOR                    *
******************************
OPB
            MOVEM.L D0,-(SP)
            
_OPCMP:     MOVE.W  OPCODE,D0
            ANDI.W  #$0100,D0
            CMP.W   #$0000,D0
            BNE     _OPCMPA
            MOVE.W  OPCODE,D0
            ANDI.W  #$00C0,D0
            CMP.W   #$00C0,D0
            BEQ     _BADPB
            JSR     OP_CMP
            BRA     _DONEPB

_OPCMPA:    MOVE.W  OPCODE,D0
            ANDI.W  #$01C0,D0
            CMP.W   #$01C0,D0
            BEQ     _BADPB
                        
_OPCMPM:    MOVE.W  OPCODE,D0
            ANDI.W  #$0138,D0
            CMP.W   #$0108,D0
            BEQ     _BADPB
            
_OPEOR:     MOVE.W  OPCODE,D0
            ANDI.W  #$0100,D0
            CMP.W   #$0100,D0
            BNE     _BADPB
            JSR     OP_EOR
            BRA     _DONEPB
            
_BADPB:     CLR     OP_SUCESS
_DONEPB     MOVEM.L (SP)+,D0
            
            
            RTS

    
******************************
*       OP CODE CXXX         *
*                            *
*MULS                        *
******************************
OPC
            MOVE.L D0, -(SP)

_OPMULS:    MOVE.W  OPCODE,D0
            ANDI.W  #$01C0,D0
            CMP.W   #$01C0,D0
            BNE     _BADPC  
            JSR     OP_MULS
            BRA     _DONEPC    
            
_BADPC:     CLR         OP_SUCESS            
_DONEPC:    MOVEM.L     (SP)+,D0        
            RTS


******************************
*       OP CODE DXXX         *
*                            *
*ADD, ADDA                   *
******************************    
OPD
            MOVE.L D0, -(SP)

_OPADDA:    MOVE.W  OPCODE,D0
            ANDI.W  #$00C0,D0
            CMP.W   #$00C0,D0
            BNE     _OPADD  
            JSR     OP_ADDA
            BRA     _DONEPD    

_OPADDX     MOVE.W  OPCODE,D0
            ANDI.W  #$0130,D0
            CMP.W   #$0100,D0
            BNE     _OPADD  
            BRA     _BADPD    

             
_OPADD      JSR OP_ADD    
            BRA _DONEPD

    
_BADPD:     CLR         OP_SUCESS            
_DONEPD:    MOVEM.L     (SP)+,D0      
            RTS

******************************
*       OP CODE EXXX         *
*                            * 
*ASR, ASL, LSR, LSL, ROL, ROR*
******************************    
OPE
            MOVE.L D0, -(SP)
            
_ASd        MOVE.W OPCODE, D0
            ANDI.W #$0EC0, D0
            CMP.W  #$00C0, D0
            BNE _LSd         
            JSR OP_ASd
            BRA _DONEPE
 
_LSd        CMP.W  #$02C0, D0
            BNE _ROd         
            JSR OP_LSd
            BRA _DONEPE
 
_ROd        CMP.W  #$06C0, D0
            BNE _ASd2         
            JSR OP_ROd
            BRA _DONEPE

_ASd2       MOVE.W OPCODE, D0
            ANDI.W #$0018, D0
            CMP.W  #$0000, D0
            BNE _LSd2         
            JSR OP_ASd2
            BRA _DONEPE

_LSd2       CMP.W  #$0080, D0
            BNE _ROd2         
            JSR OP_LSd2
            BRA _DONEPE
 
_ROd2       CMP.W  #$0180, D0
            BNE _BADPE         
            JSR OP_ROd2
            BRA _DONEPE
                     
_BADPE:     CLR         OP_SUCESS            
_DONEPE:    MOVEM.L     (SP)+,D0  
            RTS

    
    
******************************
*       OP CODE FXXX         *
*                            *
*NOT SUPPORTED               *
******************************    
OPF
_BADPF:     CLR         OP_SUCESS                               
            RTS
    
******************************
*           ADD              *
******************************        
OP_ADD:     LEA S_ADD, A1
            MOVE.B #13, D0
            TRAP #15
            RTS
            
******************************
*           ADDA             *
******************************        
OP_ADDA:    LEA S_ADDA, A1
            MOVE.B #13, D0
            TRAP #15
            RTS
    
******************************
*           BCLR1            *
******************************        
OP_BCLR1:   LEA S_BCLR, A1
            MOVE.B #13, D0
            TRAP #15
            RTS

******************************
*           BCLR2            *
******************************        
OP_BCLR2:   LEA S_BCLR, A1
            MOVE.B #13, D0
            TRAP #15
            RTS  
                        
******************************
*            BRA             *
******************************    
OP_BRA      LEA S_BRA, A1
            MOVE.B #13, D0
            TRAP #15
            RTS

******************************
*            CMPI            *
******************************    
OP_CMPI     LEA S_CMPI, A1
            MOVE.B #13, D0
            TRAP #15
            RTS

******************************
*            ORI             *
******************************    
OP_ORI      LEA S_ORI, A1
            MOVE.B #13, D0
            TRAP #15
            
            JSR OPCODE_SIZE
            JSR EA_IMM
            JSR EA_PRIMARY
            
            RTS

******************************
*            MOVEM           *
******************************    
OP_MOVEM    LEA S_MOVEM, A1
            MOVE.B #13, D0
            TRAP #15
            RTS
   
******************************
*            NOP             *
******************************    
OP_NOP      LEA S_NOP, A1
            MOVE.B #13, D0
            TRAP #15
            RTS

******************************
*            NEG             *
******************************    
OP_NEG      LEA S_NEG, A1
            MOVE.B #13, D0
            TRAP #15
            RTS

******************************
*            RTS             *
******************************    
OP_RTS      LEA S_RTS, A1
            MOVE.B #13, D0
            TRAP #15
            RTS
            
******************************
*            SUB             *
******************************    
OP_SUB     LEA S_SUB,A1
            MOVE.B #13, D0
            TRAP #15
            RTS
            
******************************
*            SUBQ            *
******************************    
OP_SUBQ     LEA S_SUBQ,A1
            MOVE.B #13, D0
            TRAP #15
            RTS
           
******************************
*            EOR             *
******************************        
OP_EOR      LEA S_EOR,A1
            MOVE.B #13,D0
            TRAP #15
            RTS
            
******************************
*            OR              *
******************************        
OP_OR       LEA S_OR,A1
            MOVE.B #13,D0
            TRAP #15
            RTS
                        
******************************
*            CMP             *
******************************       
OP_CMP:     LEA S_CMP,A1
            MOVE.B #13,D0
            TRAP #15
            RTS
            
******************************
*    Bcc(BCS,BGE,BLT,BVC)    *
******************************    
OP_BCS      LEA S_BCS,A1
            MOVE.B #13,D0
            TRAP #15
            RTS
            
OP_BGE      LEA S_BGE,A1
            MOVE.B #13,D0
            TRAP #15
            RTS
            
OP_BLT      LEA S_BLT,A1
            MOVE.B #13,D0
            TRAP #15
            RTS
            
OP_BVC      LEA S_BVC,A1
            MOVE.B #13,D0
            TRAP #15
            RTS
            
******************************
*            DIVS            *
******************************    
OP_DIVS     LEA S_DIVS,A1
            MOVE.B #13,D0
            TRAP  #15
            RTS

******************************
*            LEA             *
******************************    
OP_LEA      LEA S_LEA,A1
            MOVE.B #13,D0
            TRAP  #15
            RTS

******************************
*            MOVE            *
******************************    
OP_MOVE     MOVEM.L     D0-D2,-(SP)             
            
            *MOVEA case
            MOVE.W      OPCODE,D0              
            MOVE.W      D0,D1                   
            AND.W       #$01C0,D1 
            CMP.W       #$0040,D1 
            BNE         _OPMCONT                
            
            JSR         OP_MOVEA                
            BRA         _OPMDONE                
            
            
_OPMCONT:
            *LOAD MOVE INTO STRING            
            *MOVE.L      #S_OCMOVE,ARG_PREG      * Print MOVE
            *MOVE.L      #GOOD_BUFF,ARG_PBUFF    * Print to good buffer
            *JSR         PRINTB
            
            LEA S_MOVE,A1
            MOVE.B #13,D0
            TRAP #15
            
            
            *JSR MOVE_SIZE *GET MOVE SIZE
            

            *MOVE.W OPCODE, EA_CODE
            *JSR EA_PRIMARY  * get the source EA
             
             
_OPMDONE    MOVEM.L     (SP)+, D0-D2    
            RTS


******************************
*           MOVEEA           *
******************************            
OP_MOVEA    MOVEM.L     D0,-(SP)
           
            LEA S_MOVEA, A1
            MOVE.B #13, D0
            TRAP #15
    
            MOVEM.L    (SP)+,D0
            RTS

******************************
*           MULS             *
******************************            
OP_MULS     MOVEM.L     D0,-(SP)
           
            LEA S_MULS, A1
            MOVE.B #13, D0
            TRAP #15
    
            MOVEM.L    (SP)+,D0
            RTS
    
    
******************************
*           JSR              *
******************************            
OP_JSR      MOVEM.L     D0,-(SP)
           
            LEA S_JSR, A1
            MOVE.B #13, D0
            TRAP #15
    
            MOVEM.L    (SP)+,D0
            RTS
    


******************************
*           ASd              *
******************************            
OP_ASd      MOVEM.L     D0,-(SP)
           
            LEA S_ASR, A1
            MOVE.B #13, D0
            TRAP #15
    
            MOVEM.L    (SP)+,D0
            RTS
    
******************************
*           ASd2             *
******************************            
OP_ASd2     MOVEM.L     D0,-(SP)
           
            LEA S_ASR, A1
            MOVE.B #13, D0
            TRAP #15
    
            MOVEM.L    (SP)+,D0
            RTS

******************************
*           LSd              *
******************************            
OP_LSd      MOVEM.L     D0,-(SP)
           
            LEA S_LSR, A1
            MOVE.B #13, D0
            TRAP #15
    
            MOVEM.L    (SP)+,D0
            RTS
    
******************************
*           LSd2             *
******************************            
OP_LSd2     MOVEM.L     D0,-(SP)
           
            LEA S_LSR, A1
            MOVE.B #13, D0
            TRAP #15
    
            MOVEM.L    (SP)+,D0
            RTS

******************************
*           ROd              *
******************************            
OP_ROd      MOVEM.L     D0,-(SP)
           
            LEA S_ROR, A1
            MOVE.B #13, D0
            TRAP #15
    
            MOVEM.L    (SP)+,D0
            RTS
    
******************************
*           ROd2             *
******************************            
OP_ROd2     MOVEM.L     D0,-(SP)
           
            LEA S_ROR, A1
            MOVE.B #13, D0
            TRAP #15
    
            MOVEM.L    (SP)+,D0
            RTS
    
    
******************************
*         MOVE_SIZE          *
******************************    
MOVE_SIZE   MOVEM.L     D0,-(SP)
    
            MOVE.W OPCODE,D0
            ANDI.W #$3000, D0 * isolate the size bits
    
mbt         CMP.W #$1,D0      *byte
            BNE mwd
            *add byte to string
            BRA MOVSZ_DONE
    
mwd         CMP.W #$3,D0      *word
            BNE mlg
            *add word to string
            BRA MOVSZ_DONE
    
mlg         CMP.W #$2,D0      *long
            BNE MOVSZ_ERR
            *add long to string*  
            BRA MOVSZ_DONE
    
MOVSZ_ERR   CLR OP_SUCESS
MOVSZ_DONE  MOVEM.L (SP)+, D0        
            RTS


******************************
*         ADDA_SIZE          *
******************************    
ADDA_SIZE   MOVEM.L     D0,-(SP)
    
            MOVE.W OPCODE,D0
            ANDI.W #$0100, D0 * isolate the size bits
        
awd         CMP.W #$0000,D0      *word
            BNE alg
            *add word to string
            BRA ADDSZ_DONE
    
alg         CMP.W #$0100,D0      *long
            BNE ADDSZ_ERR
            *add long to string*  
            BRA ADDSZ_DONE
    
ADDSZ_ERR   CLR OP_SUCESS
ADDSZ_DONE  MOVEM.L (SP)+, D0        
            RTS



******************************
*         OPCODE_SIZE        *
******************************    
OPCODE_SIZE MOVEM.L     D0,-(SP)
    
            MOVE.W OPCODE,D0
            ANDI.W #$00C0, D0 * isolate the size bits
    
bt          CMP.W #$0,D0      *byte
            BNE wd
            *add byte to string
            BRA SZ_DONE
    
wd          CMP.W #$0040,D0      *word
            BNE lg
            *add word to string
            BRA SZ_DONE
    
lg          CMP.W #$0080,D0      *long
            BNE SZ_ERR
            *add long to string*  
            BRA SZ_DONE
    
SZ_ERR      CLR OP_SUCESS
SZ_DONE     MOVEM.L (SP)+, D0        
            RTS
    


***********************    
*      Op-codes       *
***********************

S_ADD     DC.B        '  ADD',$0
S_ADDA    DC.B        '  ADDA',$0
S_ASL     DC.B        '  ASL',$0
S_ASR     DC.B        '  ASR',$0
S_BCS     DC.B        '  BCS',$0
S_BGE     DC.B        '  BGE',$0
S_BLT     DC.B        '  BLT',$0
S_BVC     DC.B        '  BVC',$0
S_BCLR    DC.B        '  BCLR',$0
S_BRA     DC.B        '  BRA',$0
S_CMP     DC.B        '  CMP',$0
S_CMPI    DC.B        '  CMPI',$0
S_OCDATA  DC.B        '  DATA     $',$0
S_DIVS    DC.B        '  DIVS',$0
S_EOR     DC.B        '  EOR',$0
S_JSR     DC.B        '  JSR',$0
S_LEA     DC.B        '  LEA',$0
S_LSL     DC.B        '  LSL',$0
S_LSR     DC.B        '  LSR',$0
S_MOVE    DC.B        '  MOVE',$0
S_MOVEA   DC.B        '  MOVEA',$0
S_MOVEM   DC.B        '  MOVEM',$0
S_MULS    DC.B        '  MULS',$0
S_NEG     DC.B        '  NEG',$0
S_NOP     DC.B        '  NOP',$0
S_OR      DC.B        '  OR',$0
S_ORI     DC.B        '  ORI',$0
S_ROL     DC.B        '  ROL',$0
S_ROR     DC.B        '  ROR',$0
S_RTS     DC.B        '  RTS',$0
S_SUB     DC.B        '  SUB',$0
S_SUBQ    DC.B        '  SUBQ',$0

* Special codes
S_BYTE      DC.B        '.B ',$0
S_WORD      DC.B        '.W ',$0
S_LONG      DC.B        '.L ',$0
S_BYTEL     DC.B        '.B',$0
S_WORDL     DC.B        '.W',$0
S_LONGL     DC.B        '.L',$0
S_COMMA     DC.B        ',',$0
S_ADDRESS   DC.B        'A',$0
S_DATA      DC.B        'D',$0
S_OPEN      DC.B        '(',$0
S_CLOSE     DC.B        ')',$0
S_PLUS      DC.B        '+',$0
S_MINUS     DC.B        '-',$0
S_IMMED     DC.B        '#',$0
S_HEXSIGN   DC.B        '$',$0
S_SLASH     DC.B        '/',$0
S_SPACE     DC.B        ' ',$0







 














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
