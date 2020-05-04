*-----------------------------------------------------------
* Title      : EA routine
* Written by : Abdelrahman Alajrami
* Date       : 11/29/2018
*-----------------------------------------------------------

EA_CODE     DS.W        1 
PREDEC      DS.B        1
*D2 = mode
*D3 = REG

EA_PRIMARY      MOVEM.L    D2-D3,-(SP)
                MOVE.W     EA_CODE, D2
                ANDI.W     #$003F, D2
                MOVE.W     D2, D3
                ANDI.W     #$0007, D3
                LSR.W      #3, D2   
                BRA EA_M0
                
SHORTCUT_MOVE   MOVEM.L    D2-D3,-(SP)
                
         
EA_M0           CMP.W #$0, D2 *data register
                BNE EA_M1
                JSR EA_DN
                BRA EA_DONE
        
EA_M1           CMP.W #$1, D2 *Adress register
                BNE EA_M2
                JSR EA_AN
                BRA EA_DONE
        
EA_M2           CMP.W #$2, D2 *Adress register indirect
                BNE EA_M3
                JSR EA_A_IND
                BRA EA_DONE
        
EA_M3           CMP.W #$3, D2 *Adress register indirect with post
                BNE EA_M4
                JSR EA_A_IND_POS 
                BRA EA_DONE
        
EA_M4           CMP.W #$4, D2 *Adress register indirect with dect
                BNE EA_M7
                MOVE.B #1, PREDEC
                JSR EA_A_IND_DEC 
                BRA EA_DONE
        
EA_M7           CMP.W #$7, D2 *NEED TO CHECK REG
                BNE EA_ERR
                JSR EA_M7_CS
                BRA EA_DONE

EA_ERR
EA_DONE         MOVEM.L    (SP)+,D2-D3
                RTS   



EA_DN           MOVE.L #S_DATA, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L D3, Arg_NumToHexStr_Num
                MOVE.B #1, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer
                
                RTS
        
EA_AN
                MOVE.L #S_ADDRESS, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                
                MOVE.L D3, Arg_NumToHexStr_Num
                MOVE.B #1, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer
                
                RTS
   
EA_A_IND        MOVE.L #S_OPEN, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L #S_ADDRESS, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L D3, Arg_NumToHexStr_Num
                MOVE.B #1, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer    
                
                MOVE.L #S_CLOSE, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                
                RTS

EA_A_IND_POS    
                MOVE.L #S_OPEN, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L #S_ADDRESS, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L D3, Arg_NumToHexStr_Num
                MOVE.B #1, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer
                
                MOVE.L #S_CLOSE, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L #S_PLUS, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                
                RTS

EA_A_IND_DEC    MOVE.L #S_MINUS, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                

                MOVE.L #S_OPEN, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                    
                MOVE.L #S_ADDRESS, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L D3, Arg_NumToHexStr_Num
                MOVE.B #1, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer
                
                MOVE.L #S_CLOSE, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                
                RTS

EA_M7_CS
                MOVEM.L    D0-D1,-(SP)
 
ab_w            CMP.W #0,D3
                BNE ab_l
                MOVE.W (A5)+,D1 *get the next word
                    
                MOVE.L #S_HEXSIGN, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L D1, Arg_NumToHexStr_Num
                MOVE.B #4, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer
                
                BRA EA_M7_END
     
ab_l            CMP.W #1,D3
                BNE imd
                MOVE.L (A5)+,D1 *get the next word 
                
                MOVE.L #S_HEXSIGN, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L D1, Arg_NumToHexStr_Num
                MOVE.B #8, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer
                
                BRA EA_M7_END
     
imd             CMP.W #4,D3
                
                MOVE.L #S_IMMED, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L #S_HEXSIGN, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                                
                CMP.B #2, OPSIZE
                BNE imdWORD                
                MOVE.L (A5)+,D1
                
                MOVE.L D1, Arg_NumToHexStr_Num
                MOVE.B #8, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer
                
                BRA EA_M7_END
     
          
imdWORD         MOVE.W (A5)+,D1
                                    
                MOVE.L D1, Arg_NumToHexStr_Num
                MOVE.B #4, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer
        
                BRA EA_M7_END
     
EA_M7_END       MOVEM.L    (SP)+,D0-D1
                RTS 





EA_IMM          MOVEM.L    D0-D1,-(SP)        
                
                CLR D0
                
                MOVE.L #S_IMMED, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L #S_HEXSIGN, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer                
                
                CMP.B #2, OPSIZE
                BEQ imdLONG                
                MOVE.W (A5)+,D1
                
                MOVE.L D1, Arg_NumToHexStr_Num
                MOVE.B #4, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer
                    
                BRA EA_IMM_END
     
          
imdLONG         MOVE.L (A5)+,D1
                                
                MOVE.L D1, Arg_NumToHexStr_Num
                MOVE.B #8, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer    
        
                BRA EA_IMM_END
                    
                
EA_IMM_END      
                MOVEM.L    (SP)+,D0-D1
                RTS 
             

EA_XN_MODE DS.B 1
EA_XN_NUM DS.W 1
                
EA_XN           MOVE.L    D0,-(SP)        
                
                CLR.L D0               
                MOVE.W EA_XN_NUM, D0
                
DN              CMP.B #0,EA_XN_MODE *DN
                BNE AN
                
                MOVE.L #S_DATA, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L D0, Arg_NumToHexStr_Num
                MOVE.B #1, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer
                
                BRA EA_XN_END
                
AN              
                MOVE.L #S_ADDRESS, Arg_AddStrToBuffer_String 
                
                JSR AddStrToBuffer
                
                MOVE.L D0, Arg_NumToHexStr_Num
                MOVE.B #1, Arg_NumToHexStr_Length
                JSR NumToHexStr 
            
                MOVE.L #Ret_NumToHexStr_Str, Arg_AddStrToBuffer_String
                
                JSR AddStrToBuffer
                             

   
                         
EA_XN_END       MOVE.L    (SP)+,D0         
                RTS



*send EA REG in the bits from 9 to 11
EA_XN_9_11      
                MOVEM.L    D0-D1,-(SP)        
                
                MOVE.W EA_CODE,D0         
                ANDI.W #$0E00, D0
                MOVE.B #9,D1
                LSR.W  D1, D0
                MOVE.W D0, EA_XN_NUM 
                JSR EA_XN
                
EA_XN_9_11_END  MOVEM.L    (SP)+,D0-D1         
                RTS




EA_MOVE_DS      MOVEM.L    D2-D3,-(SP)


                MOVE.W EA_CODE, D3
                ANDI.W #$0FC0, D3
                LSR.W  #6, D3
                MOVE.W D3, D2    
                LSR.W  #3, D3
                ANDI.W #$0007, D2
                
                JSR SHORTCUT_MOVE 
                *D2 = mode
                *D3 = REG

                MOVEM.L    (SP)+,D2-D3         
                RTS

























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
