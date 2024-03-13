global MyPrintf


section .text


LEN_BUFFER              equ 64d

SIZE_ONE_STACK_CELL     equ 8d

BIN_SYSTEM              equ 2d

OCT_SYSTEM              equ 8d

DEC_SYSTEM              equ 10d

HEX_SYSTEM              equ 16d

END_STRING              equ 0d

%macro putchar 1
                Call CheckBuffer

                mov al, %1
                stosb
                inc rdx
%endmacro


MyPrintf:
                pop r15
                push r9
                push r8
                push rcx
                push rdx
                push rsi

                xor rax, rax
                xor rdx, rdx
                xor r8, r8
                xor r9, r9

                mov r14, rsp

                mov rsi, rdi
                lea rdi, buffer

        .again:

                Call CheckSymbol

                cmp byte [rsi], END_STRING
                jne .again

                Call PrintBuffer

                add rsp, 40
                push r15

                ret


CheckSymbol:
                cmp byte [rsi], byte "%"
                jne .no_spec_symbol

                inc rsi

                cmp byte [rsi], byte "%"
                je .no_spec_symbol

        .case_c:

                cmp byte [rsi], byte "c"
                jne .case_s

                putchar byte [r14]

                jmp .end_switch

        .case_s:

                cmp byte [rsi], byte "s"
                jne .case_x

                Call PrintString

                jmp .end_switch

        .case_x:

                cmp byte [rsi], byte "x"
                jne .case_d

                mov r9, HEX_SYSTEM
                Call ConverNumberSystem

                jmp .end_switch

        .case_d:

                cmp byte [rsi], byte "d"
                jne .case_o

                mov r9, DEC_SYSTEM
                Call ConverNumberSystem

                jmp .end_switch

        .case_o:

                cmp byte [rsi], byte "o"
                jne .case_b

                mov r9, OCT_SYSTEM
                Call ConverNumberSystem

                jmp .end_switch

        .case_b:

                mov r9, BIN_SYSTEM
                Call ConverNumberSystem

                jmp .end_switch

        .end_switch:

                inc r8
                inc rsi

                add r14, SIZE_ONE_STACK_CELL

                jmp .ret_func

        .no_spec_symbol:

                putchar byte [rsi]
                inc rsi

        .ret_func:
                ret



PrintString:
                mov rbx, [r14]

        .print_str:

                putchar byte [rbx]

                inc rbx

                cmp byte [rbx], END_STRING
                jne .print_str

                ret


ConverNumberSystem:
                mov rax, [r14]

                mov rbx, rdx
                mov rcx, 0

        .again:
                xor rdx, rdx
                inc rcx

                div r9

                push rdx

                cmp rax, 0
                jne .again

        .no_conver:

                mov rdx, rbx

                Call PrintNumber

                ret


PrintNumber:
                pop r9
                lea rbx, hex_alphabet

        .print:

                pop rax
                putchar byte [rbx + rax]

                loop .print

                push r9

                ret


CheckBuffer:
                cmp rdx, LEN_BUFFER
                jne .ret_func

                Call PrintBuffer

        .ret_func:
                ret


PrintBuffer:
                push rsi

                lea rsi, buffer
                mov rdi, 1
                mov rax, 1
                syscall

                mov rdx, 0
                lea rdi, buffer

                pop rsi

                ret


section .data


buffer: times LEN_BUFFER db 0


hex_alphabet: db "0123456789ABCDEF"
