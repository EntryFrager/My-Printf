global MyPrintf


section .bss


str: resb 1000


section .text


%macro str1_to_str2 0
                movsb
%endmacro


MyPrintf:
                lea rsi, str
                xchg rsi, rdi

                Call GetStr

                lea rsi, str
                mov rdi, 1

                mov rax, 1
                syscall

                ret


GetStr:
        .again:
                inc rdx

                Call CheckParam

                str1_to_str2

                cmp byte [rsi], byte 0
                jne .again

                ret


CheckParam:
                cmp byte [rsi], byte "%"
                jne .end_switch

                inc rsi

                cmp byte [rsi], byte "%"
                jne .case_c

                str1_to_str2

                jmp .end_switch

        .case_c:

                cmp byte [rsi], byte "c"
                jne .case_s

                jmp .end_switch

        .case_s:

                cmp byte [rsi], byte "s"
                jne .case_x

                jmp .end_switch

        .case_x:

                cmp byte [rsi], byte "x"
                jne .case_o

                jmp .end_switch

        .case_o:

                cmp byte [rsi], byte "o"
                jne .case_d

                jmp .end_switch

        .case_d:

                cmp byte [rsi], byte "d"
                jne .case_b

                jmp .end_switch

        .case_b:

                cmp byte [rsi], byte "b"
                jne .end_switch

                jmp .end_switch

        .end_switch:

                ret
