                                                    
.MODEL SMALL
.STACK 100H

.DATA



; Main Menu  

MENU DB 13,10,' NUMBER SYSTEM CONVERSION !!!',13,10
     DB '1. Decimal to Binary',13,10
     DB '2. Decimal to Hexadecimal',13,10
     DB '3. Binary to Decimal',13,10
     DB '4. Hexadecimal to Decimal',13,10
     DB '5. Exit',13,10
     DB 'Choose Option: $'

; Input Messages  

MSG_DEC DB 13,10,'Enter Decimal Number (Up to 255): $'
MSG_BIN DB 13,10,'Enter Binary Number (maximum 8 bits): $'
MSG_HEX DB 13,10,'Enter Hex Number (2 digits): $'

; Output Messages

RESULT DB 13,10,'Result = $'
NEWLINE DB 13,10,'$'

; Store decimal value 

NUM DB ?

.CODE

MAIN PROC

    
    MOV AX,@DATA

    
    MOV DS,AX



MENU_LOOP:

    ; Display menu 
    
    LEA DX,MENU
    MOV AH,09H
    INT 21H

    ; Take user choice  
    
    MOV AH,01H
    INT 21H

    
    CMP AL,'1'
    JE DEC_TO_BIN

    CMP AL,'2'
    JE DEC_TO_HEX

   
    CMP AL,'3'
    JE BIN_TO_DEC

    
    CMP AL,'4'
    JE HEX_TO_DEC

    
    CMP AL,'5'
    JE EXIT_PROGRAM

    
    JMP MENU_LOOP


; DECIMAL TO BINARY


DEC_TO_BIN:

    ; Read decimal number
    
    CALL READ_DECIMAL

    ; Show result message
    
    LEA DX,RESULT
    MOV AH,09H
    INT 21H

    ; Load decimal number into AL
    
    MOV AL,NUM

    
    CALL DECIMAL_TO_BINARY

    JMP MENU_LOOP


; DECIMAL TO HEXADECIMAL


DEC_TO_HEX:

    ; Read decimal number 
    
    CALL READ_DECIMAL

    ; Show result message
    
    LEA DX,RESULT
    MOV AH,09H
    INT 21H

    ; Load number into AL 
    
    MOV AL,NUM

    CALL DECIMAL_TO_HEX

    JMP MENU_LOOP


;  BINARY TO DECIMAL


BIN_TO_DEC:

    CALL READ_BINARY

    JMP MENU_LOOP


; OPTION 4 : HEX TO DECIMAL


HEX_TO_DEC:

    CALL READ_HEX

    JMP MENU_LOOP


; EXIT PROGRAM


EXIT_PROGRAM:

    ; DOS terminate program
    
    MOV AH,4CH
    INT 21H

MAIN ENDP


; READ DECIMAL NUMBER


READ_DECIMAL PROC

    ; Show decimal input message  
    
    LEA DX,MSG_DEC
    MOV AH,09H
    INT 21H

    ; BX = 0 
    
    XOR BX,BX

READ_DEC:

    ; Read one character  
    
    MOV AH,01H
    INT 21H

    ; If Enter pressed  
    
    CMP AL,13
    JE STORE_DEC

    ; ASCII -> Numeric value  
    
    SUB AL,'0'

    ; Clear AH 
    
    MOV AH,0

    ; Save current digit  
    
    MOV CX,AX

    ; Load previous value 
    
    MOV AX,BX

    ; Multiply previous value by 10 
    
    MOV DX,10
    MUL DX

    ; Add current digit  
    
    ADD AX,CX

    ; Save updated value 
    
    MOV BX,AX

    ; Read next digit 
    
    JMP READ_DEC

STORE_DEC:

    ; Store final number  
    
    MOV NUM,BL

    RET

READ_DECIMAL ENDP


; DECIMAL TO BINARY


DECIMAL_TO_BINARY PROC

    ; Digit counter 
    
    XOR CX,CX

BIN_LOOP:

    ; Clear AH before division  
    
    MOV AH,0

    ; Divisor = 2 
    
    MOV BL,2

    ; AX / 2 
    
    DIV BL

    ; Save quotient and remainder  
    
    PUSH AX

    ; Count binary digits 
    
    INC CX

    ; Continue until quotient = 0  
    
    CMP AL,0
    JNE BIN_LOOP

PRINT_BINARY:

    ; Get stored value 
    
    POP AX

    ; Remainder stored in AH 
    
    MOV DL,AH

    ; Convert to ASCII 
    
    ADD DL,'0'

    ; Print digit  
    
    MOV AH,02H
    INT 21H

    ; Repeat until CX = 0     
    
    LOOP PRINT_BINARY

    ; New line   
    
    LEA DX,NEWLINE
    MOV AH,09H
    INT 21H

    RET

DECIMAL_TO_BINARY ENDP


; DECIMAL TO HEXADECIMAL


DECIMAL_TO_HEX PROC

    ; Counter for hex digits  
    
    XOR CX,CX

HEX_LOOP:

    ; Clear AH
    
    MOV AH,0

    ; Divisor = 16 
    
    MOV BL,16

    ; AX / 16  
    
    DIV BL

    ; Save remainder  
    
    PUSH AX

    ; Count digits 
    
    INC CX

    ; Continue until quotient = 0     
    
    CMP AL,0
    JNE HEX_LOOP

PRINT_HEX:

    ; Retrieve remainder   
    
    POP AX

    MOV DL,AH

    ; If digit <= 9    
    
    CMP DL,9
    JBE HEX_DIGIT

    ; Convert 10-15 to A-F   
    
    ADD DL,7

HEX_DIGIT:

    ; Convert to ASCII   
    
    ADD DL,'0'

    ; Print character  
    
    MOV AH,02H
    INT 21H

    LOOP PRINT_HEX

    ; New line  
    
    LEA DX,NEWLINE
    MOV AH,09H
    INT 21H

    RET

DECIMAL_TO_HEX ENDP


; BINARY TO DECIMAL


READ_BINARY PROC

    ; Show binary input message 
    
    LEA DX,MSG_BIN
    MOV AH,09H
    INT 21H

    ; BX = 0 
    
    XOR BX,BX

NEXT_BIT:

    ; Read binary digit  
    
    MOV AH,01H
    INT 21H

    ; Enter key pressed  
    
    CMP AL,13
    JE SHOW_DECIMAL

    ; Multiply current value by 2   
    
    SHL BX,1

    ; If bit is not 1 
    
    CMP AL,'1'
    JNE NEXT_BIT

    ; Add 1 
    
    INC BX

    JMP NEXT_BIT

SHOW_DECIMAL:

    ; Print result label  
    
    LEA DX,RESULT
    MOV AH,09H
    INT 21H

    ; Move result into AX   
    
    MOV AX,BX

    ; Print decimal value  
    
    CALL PRINT_DECIMAL

    RET

READ_BINARY ENDP


; HEXADECIMAL TO DECIMAL


READ_HEX PROC

    ; Show hex input message 
    
    LEA DX,MSG_HEX
    MOV AH,09H
    INT 21H

    ; BX = 0   
    
    XOR BX,BX

    ; Read 2 digits
    
    MOV CX,2

HEX_INPUT:

    ; Read character 
    
    MOV AH,01H
    INT 21H

    ; Convert lowercase to uppercase  
    
    CMP AL,'a'
    JB CHECK_UPPER

    CMP AL,'f'
    JA CHECK_UPPER

    SUB AL,20H

CHECK_UPPER:

    ; Check numeric digit   
    
    CMP AL,'9'
    JBE NUMERIC_VALUE

    ; Convert A-F  
    
    SUB AL,7

NUMERIC_VALUE:

    ; ASCII -> Number 
    
    SUB AL,'0'

    ; Multiply current value by 16    
    
    SHL BX,4

    ; Add new digit 
    
    ADD BL,AL

    LOOP HEX_INPUT

    ; Print result label    
    
    LEA DX,RESULT
    MOV AH,09H
    INT 21H

    ; Result to AX   
    
    MOV AX,BX

    ; Print decimal value      
    
    CALL PRINT_DECIMAL

    RET

READ_HEX ENDP


; PRINT DECIMAL NUMBER


PRINT_DECIMAL PROC

    ; Digit counter 
    
    XOR CX,CX

DIVIDE_LOOP:

    ; Clear DX before division  
    
    MOV DX,0

    ; Divisor = 10   
    
    MOV BX,10

    ; AX / 10
    DIV BX

    ; Save remainder 
    
    PUSH DX

    ; Count digits  
    
    INC CX

    ; Continue until quotient = 0    
    
    CMP AX,0
    JNE DIVIDE_LOOP

PRINT_LOOP:

    ; Get digit from stack   
    
    POP DX

    ; Convert to ASCII    
    
    ADD DL,'0'

    ; Print digit     
    
    MOV AH,02H
    INT 21H

    LOOP PRINT_LOOP

    ; New line  
    
    LEA DX,NEWLINE
    MOV AH,09H
    INT 21H

    RET

PRINT_DECIMAL ENDP

END MAIN
```
