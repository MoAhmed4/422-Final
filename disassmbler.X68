*-----------------------------------------------------------
* Title      : 68K Disassmbler 
* Written by : Abdelrahman, Fatih and Mohammad
* Date       : 11/22/2018
* Description:  Final project for CSS422
*-----------------------------------------------------------
    ORG    $1000

BUFFER DS.B 80
DATAOUT DS.B 80
TEMPBUFF DS.B 80
ADDRESS DS.L 1

START:
            JSR PromptAddress
            MOVE.L Ret_PromptAddress_StartAddr, A5
            MOVE.L Ret_PromptAddress_EndAddr, A6
    
            
    
lp          CMP A5, A6
    
            BEQ END
    
            *clear both buffers
            MOVE.L #BUFFER, Arg_ClearBuffer_Buffer
            JSR ClearBuffer     
            
            MOVE.L #DATAOUT, Arg_ClearBuffer_Buffer
            JSR ClearBuffer     
            
            *add $ sign to both buffers
            MOVE.L #S_HEXSIGN, Arg_AddStrToBuffer_String 
            MOVE.L #BUFFER, Arg_AddStrToBuffer_Buffer
            JSR AddStrToBuffer
            
            *ADD address to both buffers
            MOVE.L A5, Arg_NumToHexStr_Num
            MOVE.B #8, Arg_NumToHexStr_Length 
            JSR NumToHexStr 
            
            MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
            JSR AddStrToBuffer
            
            MOVE.L A5, ADDRESS
                      
            MOVE.W (A5)+, D0
            
          
                
    
    
********************    
*** Main routine ***
********************
    
con         MOVE.W D0, OPCODE
            
            MOVE.W #1, OP_SUCESS 
            
            
            MOVE.L D0, D1
            MOVE.W #12, D2
            LSR.L D2, D1   
        
            MOVE.W      D1,D2                   * Copy digit to D2
            AND.W       #$000C,D2               * Isolate highest digits
            
            CMP.B       #$00,D2                 * See if first two digits are 0
            BNE         _OP4                    * Skip to case 4
            CMP.B       #$00,D1                 * See if entire digit is 0
            BNE         _OPMMOVE                * Not 0? Jump to MOVE
            BEQ         _OP0                    * Jump to op primary 0
            
            
_OPMMOVE:   JSR         OP_MOVE                 * Jump to op MOVE
        
        
_OP0        CMP.W #$00, D1
            BNE _OP4
            JSR OP0
                
_OP4        CMP.W #$04, D1
            BNE _OP5
            JSR OP4
        
_OP5        CMP.W #$05, D1
            BNE _OP6
            JSR OP5

_OP6        CMP.W #$06, D1
            BNE _OP7
            JSR OP6

_OP7        CMP.W #$07, D1
            BNE _OP8
            JSR OP7

_OP8        CMP.W #$08, D1
            BNE _OP9
            JSR OP8
        
_OP9        CMP.W #$09, D1
            BNE _OPA
            JSR OP9        

_OPA        CMP.W #$0A, D1
            BNE _OPB
            JSR OPA
        
_OPB        CMP.W #$0B, D1
            BNE _OPC
            JSR OPB

_OPC        CMP.W #$0C, D1
            BNE _OPD
            JSR OPC

_OPD        CMP.W #$0D, D1
            BNE _OPE
            JSR OPD

_OPE        CMP.W #$0E, D1
            BNE _OPF
            JSR OPE        

_OPF        CMP.W #$0F, D1
            BNE printOUT
            JSR OPF        




printOUT    *print data
            CMP.W #1, OP_SUCESS 
            BNE printDATA
            BEQ printBUFF            
        

    
            BRA lp
    


printDATA   *add $ sign to both buffers
            MOVE.L #S_HEXSIGN, Arg_AddStrToBuffer_String 
            MOVE.L #DATAOUT, Arg_AddStrToBuffer_Buffer
            JSR AddStrToBuffer
            
            *ADD address to both buffers
            MOVE.L ADDRESS, Arg_NumToHexStr_Num 
            MOVE.B #8, Arg_NumToHexStr_Length
            JSR NumToHexStr 
            
            MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
            JSR AddStrToBuffer 
            
            MOVE.L #S_OCDATA, Arg_AddStrToBuffer_String 
            JSR AddStrToBuffer
            
            MOVE.W OPCODE, Arg_NumToHexStr_Num 
            MOVE.B #4, Arg_NumToHexStr_Length
            JSR NumToHexStr      
            
            MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
            JSR AddStrToBuffer 
            
            MOVE.L #DATAOUT, Arg_Print_Str 
            JSR PrintLn
            
            BRA lp           

printBUFF   MOVE.L #BUFFER, Arg_Print_Str 
            JSR PrintLn
            
            BRA lp



END



    SIMHALT             ; halt simulator
    
    INCLUDE "IO.x68"
    INCLUDE "EA.x68"
    INCLUDE "opcode.x68"
    *INCLUDE "Test-File.x68"

    INCLUDE "TESTOPCODES.x68"



    END    START        ; last line of source




















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
