global _start

;что необходимо сделать:
;- решето Эратосфена
;- генерирование чисел
;- проверка на простоту МРабина
;- алг Евклида
;- расшир алг Евклида

section .rodata
topBorder_Eratos dq 100      ;Верхняя граница диапазона поиска простых чисел

section .data
p_RSA dq 3                   ;генерируется простое число
q_RSA dq 5                   ;генерируется простое число p != q


section .bss
slieve_Eratos times topBorder_Eratos - 1 dq 1;массив хранения решета Эратосфена

;e_RSA, n_RSA - открытый ключ, a_RSA, d_RSA - секретный ключ.
n_RSA resq 2                 ;n_RSA = p_RSA * q_RSA
f_iRSA resq 2                ;значение функции Эйлера fi(n) = (p_RSA-1) * (q_RSA-1)
e_RSA resq 1                 ;генерируется 1 <= e_RSA <= fi, gcd(e_RSA, fi_RSA) = 1; алг. Евклида
d_RSA resq 1                 ;d_RSA = e_RSA^-1 mod fi_RSA; расшир. алг. Евклида


section .text
_start:
%macro Eratos 0

    mov rcx, 2          ;начальное значение решета
    mov rsi, 0          ;флаг 0 - ОК, 1 - переход к следующему значению, 2 - решето готово
    mov rdx, 0          ;смещение по массиву slieve_Eratos

    push rsi            ;[rsp + 16]
    push rcx            ;[rsp + 8]

%%while:                необходимо сделать вложенный цикл счетчики в стек
    sub rcx, 2
    mov rdi, [slieve_Eratos + rcx]

    cmp rdi, 1
    jnz %%nextIter

    mov rsi, [rsp + 8]
    mov [slieve_Eratos + rcx], rsi


%%nextIter:
    inc rcx
    jmp %%while

%endmacro
;формирование пар открытых/закрытых ключей для КС РША
;блок с известными p_RSA, q_RSA
;вычисление n_RSA = p_RSA * q_RSA
    mov rax, [p_RSA]
    mov rdx, [q_RSA]
    mul rdx                 ;старшая часть в rdx, младшая часть в rax
    mov [n_RSA], rdx
    mov [n_RSA + 8], rax     ;!!!пока будет считаться, что rdx = 0 всегда!!!

;вычисление значения функции Эйлера fi(n) = (p_RSA-1) * (q_RSA-1)
    mov rax, [p_RSA]
    mov rdx, [q_RSA]
    dec rax
    dec rdx
    mul rdx
    mov [fi_RSA], rdx
    mov [fi_RSA + 8], rax    ;!!!пока будет считаться, что rdx = 0 всегда!!!

exit:
    mov rax, 60
    syscall
