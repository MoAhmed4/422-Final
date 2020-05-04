*-----------------------------------------------------------
* Title      : I/O
* Written by : Fatih Ridha
* Date       : 11/28/2018
* Decription : Handles user input for start and end address,
*              and output for displaying instructions.
*-----------------------------------------------------------

**
* PromptAddress
**
* Prompts the user to enter a starting and ending address for the disassembler.
* This function does error handling and will loop until the user enters
* valid addresses.
*
**
* @return Ret_PromptAddress_StartAddr       Start address
* @return Ret_PromptAddress_EndAddr         Ending address
* @const Const_PromptAddress_StartAddrMsg   Prompt for start address
* @const Const_PromptAddress_EndAddrMsg     Prompt for end address
* @const Const_PromptAddress_InvalidMsg     Message for invalid input
* @branch _PromptAddress_Loop               I/O loop
* @branch _PromptAddress_LoopEnd            I/O loop end
* @branch _PromptAddress_End                Subroutine end
**
Ret_PromptAddress_StartAddr         DS.L    1
Ret_PromptAddress_EndAddr           DS.L    1
Const_PromptAddress_StartAddrMsg    DC.B    'Enter a starting address in hex: $', 0
Const_PromptAddress_EndAddrMsg      DC.B    'Enter an ending address in hex: $', 0
Const_PromptAddress_InvalidMsg      DC.B    'Invalid address. ', 0

PromptAddress:                      DS.W    0
    MOVEM.L     A0, -(SP)                   * Backup register to stack
    LEA         Const_PromptAddress_StartAddrMsg, A0
                                            * Load prompt for start address

_PromptAddress_Loop
    MOVE.L      A0, Arg_Print_Str           * Load current prompt
    JSR         Print                       * Execute print
    JSR         Input                       * Get input from user
    
    MOVE.L      #Ret_Input_Str, Arg_HexStrToNum_Str
                                            * Attempt to convert user input
    JSR         HexStrToNum                 * Execute conversion
    
    CMPI.B      #0, Ret_HexStrToNum_Success * If valid
    BEQ         _PromptAddress_LoopEnd      * End loop
    
                                            * Else
    MOVE.L      #Const_PromptAddress_InvalidMsg, Arg_Print_Str
                                            * Load invalid message
    JSR         Print                       * Print
    
    BRA         _PromptAddress_Loop         * Loop back

_PromptAddress_LoopEnd
    CMPA.L      #Const_PromptAddress_EndAddrMsg, A0
                                            * If current prompt asks for end address
    BEQ         _PromptAddress_End          * We have both addresses, finish subroutine

                                            * Else
    MOVE.L      Ret_HexStrToNum_Num, Ret_PromptAddress_StartAddr
                                            * Return start address
    LEA         Const_PromptAddress_EndAddrMsg, A0
                                            * Load prompt for end address
    BRA         _PromptAddress_Loop         * Loop back

_PromptAddress_End
    MOVE.L      Ret_HexStrToNum_Num, Ret_PromptAddress_EndAddr
                                            * Return end address
    MOVEM.L     (SP)+, A0                   * Restore register from stack
    RTS                                     * Exit subroutine


**
* Print
**
* Displays the given NULL-terminated string.
*
**
* PrintLn
**
* Displays the given NULL-terminated string followed by a new line (CRLF).
* 
**
* @param  Arg_Print_Str     Pointer to first value of string to print
* @branch _Print_Str        Branch for printing from either Print or PrintLn
**
Arg_Print_Str   DS.L    1

Print:          DS.W    0
    MOVEM.L     D0/A1, -(SP)        * Backup registers to stack
    MOVEQ       #14, D0             * Trap task to display string
    BRA         _Print_Str          * Branch to print

PrintLn:        DS.W    0
    MOVEM.L     D0/A1, -(SP)        * Backup registers to stack
    MOVEQ       #13, D0             * Trap task to display string with new line

_Print_Str
    MOVEA.L     Arg_Print_Str, A1   * Load string pointer
    TRAP        #15                 * Execute trap to print

    MOVEM.L     (SP)+, D0/A1        * Restore registers from stack
    RTS                             * Exit subroutine


**
* Input
**
* Read a string entered by the user and stores it in the return address.
*
**
* @return Ret_Input_Str      Location where user-input string is stored
**
Ret_Input_Str   DS.B    80

Input:          DS.W    0
    MOVEM.L     D0-D1/A1, -(SP)     * Backup register to stack

    LEA         Ret_Input_Str, A1   * Load return address to register
    MOVEQ       #2, D0              * Trap task to read user input
    TRAP        #15                 * Execute trap

    MOVEM.L     (SP)+, D0-D1/A1     * Restore registers from stack
    RTS                             * Exit subroutine

    
**
* HexStrToNum
**
* Converts a NULL-terminated string of hexadecimal to its numeric equivalent.
* If the string is more than 8 characters, only the first 8 are converted.
* If the string is a valid hexadecimal, 0 is returned; otherwise, 1 is returned.
* 
* @param Arg_HexStrToNum_Str            Pointer to hexadecimal string
* @return Ret_HexStrToNum_Num           Value returned from conversion, NULL if invalid
* @return Ret_HexStrToNum_Success       0 if successfully converted, 1 otherwise
* @branch _HexStrToNum_Loop             Main loop through the string
* @branch _HexStrToNum_CheckHex         Check that hex digit is between 10 and 15
* @branch _HexStrToNum_Valid            Branch when hex char is valid; add to number
* @branch _HexStrToNum_Invalid          Branch when hex char is invalid; return 1
**
Arg_HexStrToNum_Str         DS.L    1
Ret_HexStrToNum_Num         DS.L    1
Ret_HexStrToNum_Success     DS.B    1

HexStrToNum:                DS.W    0
    MOVEM.L     D0-D2/A0, -(SP)             * Backup registers to stack
    
    MOVEA.L     Arg_HexStrToNum_Str, A0     * Load string pointer
    CLR.B       Ret_HexStrToNum_Success     * Clear success bit
    CLR.L       D0                          * Clear D0 for final value
    CLR.L       D1                          * Clear D1 for checking each char
    CLR.L       D2                          * Clear D2 for loop counter
    
_HexStrToNum_Loop
    MOVE.B      (A0)+, D1                   * Move next character to D1
    CMPI.B      #0, D1                      * If char == NULL
    BEQ         _HexStrToNum_End            * Finish subroutine

    LSL.L       #4, D0                      * Make room in final value for new digit

    CMPI.B      #'0', D1                    * If char < ASCII value for '0'
    BLT         _HexStrToNum_Invalid        * It's invalid

                                            * Else
    CMPI.B      #'9', D1                    * If char <= ASCII value for '9'
    BLE         _HexStrToNum_Number         * It's valid (0-9)
    
                                            * Else
    CMPI.B      #'A', D1                    * If char < ASCII value for 'A'
    BLT         _HexStrToNum_Invalid        * It's invalid

                                            * Else
    CMPI.B      #'F', D1                    * If char <= ASCII value for 'F'
    BLE         _HexStrToNum_UpperCase      * It's valid (A-F)

                                            * Else
    CMPI.B      #'a', D1                    * If char < ASCII value for 'a'
    BLT         _HexStrToNum_Invalid        * It's invalid

                                            * Else
    CMPI.B      #'f', D1                    * If char <= ASCII value for 'f'
    BLE         _HexStrToNum_LowerCase      * It's valid (a-f)

                                            * Else
    BRA         _HexStrToNum_Invalid        * It's invalid
    
_HexStrToNum_Number
    SUBI.B      #'0', D1                    * For 0-9, subtract ACCII value for '0'
    BRA         _HexStrToNum_Valid          * Valid char, go convert

_HexStrToNum_UpperCase
    SUBI.B      #'A', D1                    * For A-F, subtract ASCII value for 'A'
    BRA         _HexStrToNum_Add10          * For letters, add 10 for correct value

_HexStrToNum_LowerCase
    SUBI.B      #'a', D1                    * For a-f, subtract ASCII value for 'a'

_HexStrToNum_Add10
    ADDI.B      #10, D1                     * Add 10 for correct value for a-fA-f

_HexStrToNum_Valid
    OR          D1, D0                      * Add char bits to final value
    ADDQ        #1, D2                      * Increment counter
    CMPI.B      #7, D2                      * If counter > 7
    BGT         _HexStrToNum_End            * Finish subroutine

    BRA         _HexStrToNum_Loop           * Loop back

_HexStrToNum_Invalid
    CLR.L       D0                          * Invalid num, so clear value
    MOVE.B      #1, Ret_HexStrToNum_Success * Return 1 for invalid

_HexStrToNum_End
    MOVE.L      D0, Ret_HexStrToNum_Num     * Return final valu
    MOVEM.L     (SP)+, D0-D2/A0             * Restore registers from stack
    RTS                                     * Exit subroutine


**
* NumToHexStr
**
* Converts the given number to a NULL-terminated hexadecimal character string
* with the specified length.
*
* By default, the number is converted to an 8-character string, but this can be
* changed in the length argument, which can be between 1 and 8 characters
* inclusive.
*
* Additionally, the conversion starts from the rightmost bit of the number, so
* keep this in mind when converting numbers with lengths < 8. For example,
* converting the number 0x0642FFFF with length = 4 results in the string 'FFFF'.
*
* The converted string will remain until the subroutine is called again, so
* make sure to store it elsewhere before calling this again.
*
**
* @param Arg_NumToHexStr_Num        Number to convert
* @param Arg_NumToHexStr_Length     Number of characters to convert, between 0-8
* @return Ret_NumToHexStr_Str       Converted hexadecimal character string
* @branch _NumToHexStr_PosLength    Branch for checking positive length
* @branch _NumToHexStr_ValidLength  Branch for checking valid length
* @branch _NumToHexStr_Loop         Loop through each digit
* @branch _NumToHexStr_Letter       Branch for converting to hex letter
* @branch _NumToHexStr_AddChar      Add character to string
**
Arg_NumToHexStr_Num     DS.L    1
Arg_NumToHexStr_Length  DC.B    8
Ret_NumToHexStr_Str     DS.B    9

NumToHexStr:            DS.W    0
    MOVEM.L     D0-D3/A0-A1, -(SP)          * Backup registers to stack
    CLR.L       D1
    CLR.L       D0
    MOVE.L      Arg_NumToHexStr_Num, D0     * Load number
    MOVE.B      Arg_NumToHexStr_Length, D1  * Load length
    MOVEA.L     #Ret_NumToHexStr_Str, A0    * Load string address
    
    CMPI.B      #1, D1
    BGE         _NumToHexStr_PosLength
    MOVEQ       #1, D1
    
_NumToHexStr_PosLength
    CMPI.B      #8, D1
    BLE         _NumToHexStr_ValidLength
    MOVEQ       #8, D1
    
_NumToHexStr_ValidLength
    MOVEA.L     A0, A1                      * A0 contains start, A1 contains current
    ADDA.W      D1, A1                      * Move to last digit
    CLR.B       (A1)                        * NULL last digit
    MOVEQ       #$0F, D2                    * Bitmask for rightmost nibble, which is last hex
    
_NumToHexStr_Loop
    MOVE.B      D0, D3                      * Get byte (2 hex chars) from number
    AND.B       D2, D3                      * Mask to get last hex char
    
    CMPI.B      #9, D3                      * If the value > 9
    BGT         _NumToHexStr_Letter         * It's a letter, so branch to letter
    
    ADDI.B      #'0', D3                    * Get to ASCII value for 0-9
    BRA         _NumToHexStr_AddChar        * Branch to add char to string

_NumToHexStr_Letter
    SUBI.B      #10, D3                     * Subtract 10 first to get correct ASCII
    ADDI.B      #'A', D3                    * Get to ASCII value for A-F

_NumToHexStr_AddChar
    MOVE.B      D3, -(A1)                   * Add char to string and decrement pointer
    LSR.L       #4, D0                      * Shift the number a nibble (hex char) to the right
    CMPA.L      A0, A1                      * If current pointer is > string start address
    BGT         _NumToHexStr_Loop           * Loop back
    
    MOVEM.L     (SP)+, D0-D3/A0-A1          * Restore registers from stack
    RTS                                     * Exit subroutine


**
* AddStrToBuffer
**
* Adds the given NULL-terminated string to the specified buffer.
*
* Default buffer length is 80 characters, but can be modified in the argument
* variables.
*
* If the buffer length is exceeded, either due to lack of a NULL character or
* an incorrectly specified length, 1 is returned. Otherwise, 0 is returned to
* indicate success.
*
**
* @param Arg_AddStrToBuffer_String              Pointer to string
* @param Arg_AddStrToBuffer_Buffer              Pointer to buffer
* @param Arg_AddStrToBuffer_BufferLength        Length of buffer (default 80 chars)
* @return Ret_AddStrToBuffer_Success            0 if successful, 1 otherwise.
* @branch _AddStrToBuffer_FindBufferNullLoop    Loop to find NULL in buffer
* @branch _AddStrToBuffer_AddLoop               Loop to add string to buffer
* @branch _AddStrToBuffer_Success               Branch when string successfully added
* @branch _AddStrToBuffer_StringLengthExceeded  Branch when length exceeded (either string or buffer)
* @branch _AddStrToBuffer_End                   End of subroutine
**
Arg_AddStrToBuffer_String           DS.L    1
Arg_AddStrToBuffer_Buffer           DS.L    1
Arg_AddStrToBuffer_BufferLength     DC.L    80
Ret_AddStrToBuffer_Success          DS.B    1

AddStrToBuffer:                     DS.W    0
    MOVEM.L     D0-D1/A0-A1, -(SP)                  * Backup registers to stack

    MOVE.L      Arg_AddStrToBuffer_String, A0       * Load string pointer
    MOVE.L      Arg_AddStrToBuffer_Buffer, A1       * Load buffer pointer
    MOVE.L      Arg_AddStrToBuffer_BufferLength, D0 * Load buffer length
    CLR.W       Ret_AddStrToBuffer_Success          * Clear success bit
    CLR.L       D1                                  * Clear loop counter

_AddStrToBuffer_BufferLoop
    CMPI.B      #0, (A1)                            * If buffer char is NULL
    BEQ         _AddStrToBuffer_AddLoop             * Start adding string to bufer
    
    CMP.L       D0, D1                              * If counter >= max length
    BGE         _AddStrToBuffer_LengthExceeded      * Error, return
    
    ADDQ.L      #1, A1                              * Go to next character
    ADDQ.B      #1, D1                              * Increment counter
    BRA         _AddStrToBuffer_BufferLoop          * Loop back
    
_AddStrToBuffer_AddLoop
    CMPI.B      #0, (A0)                            * If string char is NULL
    BEQ         _AddStrToBuffer_Success             * String successfully added
    
    CMP.B       D0, D1                              * If counter >= max length
    BGE         _AddStrToBuffer_LengthExceeded      * Error, return
    
    MOVE.B      (A0)+, (A1)+                        * Move string char to buffer char
    ADDQ.B      #1, D1                              * Increment counter
    BRA         _AddStrToBuffer_AddLoop             * Loop back

_AddStrToBuffer_Success
    MOVE.B      #0, (A1)                            * Add NULL to end of string
    BRA         _AddStrToBuffer_End                 * Finish subroutine

_AddStrToBuffer_LengthExceeded
    MOVE.W      #1, Ret_AddStrToBuffer_Success      * Invalidate success bit

_AddStrToBuffer_End
    MOVEM.L     (SP)+, D0-D1/A0-A1                  * Restore registers from stack
    RTS                                             * Exit subroutine


**
* ClearBuffer
**
* Clears the given buffer by filling it with NULL. By default it will fill 80
* bytes from the buffer pointer with NULL, so make sure the buffer reserves
* that many bytes. The default can be changed.
*
**
* @param Arg_ClearBuffer_Buffer     Pointer to buffer
* @param Arg_ClearBuffer_Length     Byte length of buffer, default 80
* @branch _ClearBuffer_Loop         Buffer loop
* @branch _ClearBuffer_End          Subroutine end
**
Arg_ClearBuffer_Buffer  DS.L    1
Arg_ClearBuffer_Length  DC.L    80

ClearBuffer:            DS.W    0
    MOVEM.L     D0-D1/A0, -(SP)             * Backup registers to stack
    MOVEA.L     Arg_ClearBuffer_Buffer, A0  * Load buffer address
    MOVE.L      Arg_ClearBuffer_Length, D0  * Load buffer length
    CLR.L       D1                          * Clear counter
    
_ClearBuffer_Loop
    CMP.L       D0, D1                      * If counter >= length
    BGE         _ClearBuffer_End            * Finish subroutine
    
    CLR.B       (A0)+                       * Clear current character in buffer
    ADDQ        #1, D1                      * Increment counter
    BRA         _ClearBuffer_Loop           * Loop back
    
_ClearBuffer_End
    MOVEM.L     (SP)+, D0-D1/A0             * Restore registers from stack
    RTS                                     * Exit subroutine





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
