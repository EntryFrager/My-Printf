global convert


section .text


convert:
                mov rbx, rsi

                mov rax, rdi

                mov rcx, 1

        .again:
                inc rcx

                xor rdx, rdx

                div rbx

                push rdx

                cmp rax, rbx
                jae .again

                push rax

                lea rbx, buffer

                lea rdi, hex_alphabet

        .loop:
                pop rax

                mov al, byte [rdi + rax]

                mov byte [rbx], al

                inc rbx

                loop .loop

                lea rax, buffer

                ret


section .data

buffer: times 1000 db 0

hex_alphabet: db "0123456789ABCDEF"
