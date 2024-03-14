global MyPrintf


section .text


LEN_BUFFER              equ 32d                                                                         ; Buffer length


SIZE_ONE_CELL           equ 8d                                                                          ; The size of one cell is 8 bytes


BIN_SYSTEM              equ 2d                                                                          ; Binary number system


OCT_SYSTEM              equ 8d                                                                          ; Octal number system


DEC_SYSTEM              equ 10d                                                                         ; Decimal number system


HEX_SYSTEM              equ 16d                                                                         ; Hexadecimal number system


END_STRING              equ 0d                                                                          ; Terminating character of a line


INVALID_SPECIFIER       equ 1d                                                                          ; Error code indicating that an invalid specifier was entered


%macro putchar 1                                                                                        ; A macro that writes a character to a buffer and, if it overflows, prints it to the command line
                Call CheckBuffer                                                                        ; Calling the Buffer Check Function

                mov al, %1
                stosb                                                                                   ; Writing a character to a buffer
                inc rdx                                                                                 ; Increasing the number of characters written to the buffer
%endmacro


%macro print_on_cmd_line 0                                                                              ; Macro that prints a string
                mov rdi, 1                                                                              ; Output handle - console
                mov rax, 1                                                                              ; Line output function number
                syscall
%endmacro


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; A function that is a poor copy of Printf
; Entry:
;       RDI - Stores the start address of a string format
;       RSI, RDX, RCX, R8, R9 - Store arguments that will be output to the console
; Info:
;       RAX - Will store the output character or system function number (depending on the function being performed)
;       RDX - Will store the number of characters written to the buffer
;       RDI - Stores the beginning of the buffer
;       RSI - Stores the address at the beginning of the string format
;       R8  - This register stores the error code
;       R14 - Stores the address of the first argument on the stack
;       R15 - Stores the return address !!!Do not touch this register in this program!!!
; Destr:
;       RAX
;       RBX
;       RCX
;       RDX
;       RDI
;       RSI
;       R12
;       R13
;       R14
;       R15
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


MyPrintf:
                pop r15                                                                                 ; We save the return address
                push r9                                                                                 ; Pushing arguments written to registers
                push r8
                push rcx
                push rdx
                push rsi

;;---------------------------------Reset the register----------------------------------------------------

                xor rax, rax                                                                            ; Will store the output character or system function number (depending on the function being performed)
                xor rdx, rdx                                                                            ; Will store the number of characters written to the buffer
                xor r8, r8                                                                              ; Will store the error code

                mov r14, rsp                                                                            ; We save the address to the first argument on the stack

                mov rsi, rdi                                                                            ; Stores the address at the beginning of the string format
                lea rdi, buffer                                                                         ; Stores the beginning of the buffer

        .again:

                Call CheckSymbol                                                                        ; Call the function to check the character string format

                cmp byte [rsi], END_STRING                                                              ; We compare the symbol format of the string with the end of the string, if they are equal, then we exit
                jne .again

                Call PrintBuffer                                                                        ; Call the function to output the remaining part of the buffer

                add rsp, 40                                                                             ; Balancing the stack
                push r15                                                                                ; We push the return address

                mov rax, r8                                                                             ; Returning the error code

                ret


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; A function that checks a character for a specifier and writes it to a buffer
; Entry:
;       RDI - Stores the address of the buffer
;       RSI - Stores address format string
;       R14 - Stores the address on the stack for the output argument
; Info:
;       RAX - Stores a character in string format
;       R13 - Stores the address to which you want to jump in the program
;       BIN_SYSTEM - Binary number system
;       OCT_SYSTEM - Octal number system
;       DEC_SYSTEM - Decimal number system
;       HEX_SYSTEM - Hexadecimal number system
; Destr:
;       RAX
;       RSI
;       R13
;       R14
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


CheckSymbol:
                cmp byte [rsi], byte "%"                                                                ; We compare the string format symbol with %, if they are not equal, then we jump to the output of a regular symbol, otherwise we consider it a specifier
                jne .no_spec_symbol

                inc rsi                                                                                 ; Move to the next character

                xor rax, rax
                mov al, byte [rsi]                                                                      ; Write down the symbol
                mov r13, .jump_table[(rax - '%') * SIZE_ONE_CELL]                                       ; Write down the jump address

                jmp r13

        .jump_table:                                                                                    ; A table containing the addresses to which you need to jump
                dq .no_spec_symbol                                                                      ; Address of a label indicating the output of a regular symbol
                times ('b' - '%' - 1) dq .case_error                                                    ; Address of the label indicating the output of the error message
                dq .case_bin                                                                            ; Address of the label indicating the output of the number in the binary number system
                dq .case_char                                                                           ; Address of a label indicating the output of one character
                dq .case_dec                                                                            ; Address of the label indicating the output of the number in the decimal number system
                times ('o' - 'd' - 1) dq .case_error                                                    ; Address of the label indicating the output of the error message
                dq .case_oct                                                                            ; Address of the label indicating the output of the number in the octal number system
                times ('s' - 'o' - 1) dq .case_error                                                    ; Address of the label indicating the output of the error message
                dq .case_string                                                                         ; Address of the label indicating the output of the line
                times ('x' - 's' - 1) dq .case_error                                                    ; Address of the label indicating the output of the error message
                dq .case_hex                                                                            ; Address of the label indicating the output of the number in the hexadecimal number system

;;---------------------------------Output-of-one-character-----------------------------------------------

        .case_char:

                putchar byte [r14]                                                                      ; Symbol output

                jmp .end_switch

;;---------------------------------Line-output-----------------------------------------------------------

        .case_string:

                Call PrintString                                                                        ; Calling a function that writes a string to a buffer

                jmp .end_switch

;;---------------------------------Displaying-a-number-in-16-number-system-------------------------------
        .case_hex:

                mov r12, HEX_SYSTEM                                                                     ; We write the number of the number system into the register
                Call ConverNumberSystem                                                                 ; Calling a function to convert a number to the desired number system and output it

                jmp .end_switch

;;---------------------------------Displaying-a-number-in-the-10-system----------------------------------

        .case_dec:

                mov r12, DEC_SYSTEM                                                                     ; We write the number of the number system into the register
                Call ConverNumberSystem                                                                 ; Calling a function to convert a number to the desired number system and output it

                jmp .end_switch

;;---------------------------------Displaying-a-number-in-the-8-system-----------------------------------

        .case_oct:

                mov r12, OCT_SYSTEM                                                                     ; We write the number of the number system into the register
                Call ConverNumberSystem                                                                 ; Calling a function to convert a number to the desired number system and output it

                jmp .end_switch

;;---------------------------------Displaying-a-number-in-the-2-system-----------------------------------

        .case_bin:

                mov r12, BIN_SYSTEM                                                                     ; We write the number of the number system into the register
                Call ConverNumberSystem                                                                 ; Calling a function to convert a number to the desired number system and output it

                jmp .end_switch

;;---------------------------------Displaying-a-message-about-an-invalid-specifier-----------------------

        .case_error:

                mov r8, INVALID_SPECIFIER                                                               ; Write down the error code
                jmp .end_switch

;;---------------------------------Update-registers-after-фrgument-output--------------------------------

        .end_switch:

                inc rsi                                                                                 ; Move to next character
                add r14, SIZE_ONE_CELL                                                                  ; Move to the next argument on the stack

                jmp .ret_func

;;---------------------------------Outputting-a-default-character----------------------------------------

        .no_spec_symbol:

                putchar byte [rsi]                                                                      ; Outputting a default character
                inc rsi                                                                                 ; Move to next character

        .ret_func:
                ret


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Function that writes a string to a buffer
; Entry:
;       R14 - Stores the address to the next output argument of the function
; Info:
;       RBX - Stores the address of the output string
;       END_STRING - Terminating character of a line
; Destr:
;       RBX
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


PrintString:
                mov rbx, [r14]                                                                          ; Write the address of the beginning of the output line to the register

        .print_str:

                putchar byte [rbx]                                                                      ; We output the string character located at our address

                inc rbx                                                                                 ; Move to the next character

                cmp byte [rbx], END_STRING                                                              ; We compare the character with the end of the string, if they are not equal, then continue the output
                jne .print_str

                ret


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Function for converting a number to a specific number system
; Entry:
;       R12 - Number system number
;       R14 - Stores the address to the next output argument
; Info:
;       RBX - Temporarily stores the number of characters written to the buffer
;       RCX - Stores the length of the new number
;       RDX - This function will contain the remainder of the division (Its value is stored in the RBX register)
; Destr:
;       RAX
;       RBX
;       RCX
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


ConverNumberSystem:
                mov rax, [r14]                                                                          ; We write down the number that needs to be converted to another number system

                mov rbx, rdx                                                                            ; Saving the value of the RDX register
                xor rcx, rcx                                                                            ; Reset the register

        .again:
                xor rdx, rdx                                                                            ; Reset the register that stores the remainder of the division to zero
                inc rcx                                                                                 ; Increase the length of the resulting number by 1

                div r12                                                                                  ; We divide our number by the number of the number system

                push rdx                                                                                ; Push the rest onto the stack

                cmp rax, 0                                                                              ; Comparing the quotient of division with zero
                jne .again                                                                              ; If not equal, continue dividing

                mov rdx, rbx                                                                            ; Returning the old register value

                Call PrintNumber                                                                        ; Call the function, writing a number from the stack to the buffer

                ret


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; A function that writes a number in any number system to the buffer (this number must be on the stack in reverse order)
; Info:
;       RAX - Stores the output digit
;       RBX - Stores the address of a string with numbers
;       R12 - Stores the return address
; Destr:
;       RAX
;       RBX
;       R12
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


PrintNumber:
                pop r12                                                                                 ; We store the return address in a register in order to access the digits written to it on the stack
                lea rbx, hex_alphabet                                                                   ; Write the address on a line with numbers

        .print:

                pop rax                                                                                 ; Take the next number from the stack
                putchar byte [rbx + rax]                                                                ; Write it to the buffer

                loop .print

                push r12                                                                                ; Push the return address onto the stack

                ret


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; A function that checks the buffer for free space in it
; Entry:
;       RDX - stores the length of the buffer
; Info:
;       LEN_BUFFER
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


CheckBuffer:
                cmp rdx, LEN_BUFFER                                                                     ; Compare the length of the buffer and the number of characters written to the buffer
                jne .ret_func                                                                           ; If they are not equal, then we exit the function

                Call PrintBuffer                                                                        ; If equal, call the buffer output function

        .ret_func:
                ret


;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Function to output a buffer to the console
; Entry:
;       RDX - stores the length of the buffer, resets to zero at the end of the function
; Info:
;       RAX - Stores the system function number
;       RDI - stores the output descriptor - console, at the end of the function, the address of the beginning of the buffer is written to it
;       RSI - Stores the address of the output string
; Destr:
;       RDX
;;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


PrintBuffer:
                push rax                                                                                ; Saving register values ​​on the stack
                push rcx
                push rsi

                lea rsi, buffer                                                                         ; Write down the address of the beginning of the buffer

                print_on_cmd_line                                                                       ; Call the macro to output a line to the console

                mov rdx, 0                                                                              ; Reset the register storing the number of characters written to the buffer to zero
                lea rdi, buffer                                                                         ; Write down the address of the beginning of the buffer

                pop rsi                                                                                 ; Getting old register values
                pop rcx
                pop rax

                ret


section .data


buffer: times LEN_BUFFER db 0                                                                           ; A buffer that temporarily stores characters output to the console


hex_alphabet:   db "0123456789ABCDEF"                                                                   ; Text representations of hexadecimal symbols
