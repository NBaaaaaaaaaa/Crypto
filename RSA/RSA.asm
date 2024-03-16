global _start

extern generatorRSA

section .data
;p_RSA != q_RSA
p_RSA dq 7                     ;пока решил не генерить значения самостоятельно
q_RSA dq 11                    ;пока решил не генерить значения самостоятельно

section .bss
buffer resb 50


section .text
_start:
    mov rax, [p_RSA]
    mov rdx, [q_RSA]
    call generatorRSA

    mov rdi, rbx

exit:
    mov rax, 60
    syscall
