*-----------------------------------------------------------
* Title      : I/O Test File
* Written by : Fatih Ridha
* Date       : 11/28/2018
* Description: Test file for io.X68
*-----------------------------------------------------------

Test_IO_Start:
    JSR         PromptAddress
    
    MOVE.B      #4, Arg_NumToHexStr_Length
    
    MOVEA.L     Ret_PromptAddress_StartAddr, A0
    MOVEA.L     Ret_PromptAddress_EndAddr, A1
    
    * Clear buffer
    MOVE.L      #Buffer, Arg_ClearBuffer_Buffer
    JSR         ClearBuffer
    
    * Add start addr msg to buffer
    MOVE.L      #Const_StartAddrMsg, Arg_AddStrToBuffer_String
    MOVE.L      #Buffer, Arg_AddStrToBuffer_Buffer
    JSR         AddStrToBuffer
    
    * Convert start addr to hex
    MOVE.L      A0, Arg_NumToHexStr_Num
    JSR         NumToHexStr
    * then add to buffer
    MOVE.L      #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
    MOVE.L      #Buffer, Arg_AddStrToBuffer_Buffer
    JSR         AddStrToBuffer
    
    * Print buffer
    MOVE.L      #Buffer, Arg_Print_Str
    JSR         PrintLn
    
    * Clear buffer
    MOVE.L      #Buffer, Arg_ClearBuffer_Buffer
    JSR         ClearBuffer
    
    * Add end addr msg to buffer
    MOVE.L      #Const_EndAddrMsg, Arg_AddStrToBuffer_String
    MOVE.L      #Buffer, Arg_AddStrToBuffer_Buffer
    JSR         AddStrToBuffer
    
    * Convert end addr to hex
    MOVE.L      A1, Arg_NumToHexStr_Num
    JSR         NumToHexStr
    * then add to buffer
    MOVE.L      #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
    JSR         AddStrToBuffer
    
    * Clear buffer
    MOVE.L      #Buffer, Arg_Print_Str
    JSR         PrintLn
    

    SIMHALT

Buffer              DS.B    80
Const_StartAddrMsg  DC.B    'Start address: $', 0
Const_EndAddrMsg    DC.B    'End address: $', 0
StartAddr           DS.B    9
EndAddr             DS.B    9

    INCLUDE "io.X68"


    END    Test_IO_Start


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
