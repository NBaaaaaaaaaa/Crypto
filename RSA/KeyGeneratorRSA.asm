global generatorRSA

section .bss
p_RSA resq 1
q_RSA resq 1
;e_RSA, n_RSA - открытый ключ, d_RSA - секретный ключ.
n_RSA resq 2                    ;n_RSA = p_RSA * q_RSA
fi_RSA resq 2                   ;значение функции Эйлера fi(n) = (p_RSA-1) * (q_RSA-1)
e_RSA resq 1                    ;генерируется 1 <= e_RSA <= fi_RSA, gcd(e_RSA, fi_RSA) = 1; алг. Евклида
d_RSA resq 1                    ;d_RSA = e_RSA^-1 mod fi_RSA; расшир. алг. Евклида

section .text

%macro EuclAlg 2

	mov rax, %1
	mov rdi, %2

%%all_zero:
	cmp rax, 0
	jnz %%comparison
	cmp rdi, 0
	jz %%exit_EuclAlg

%%comparison:
	cmp rax, rdi
	jae %%algorithm
	mov rax, %2
	mov rdi, %1

%%algorithm:
	div rdi
	cmp rdx, 0
	jz %%exit_EuclAlg

	mov rax, rdi
	mov rdi, rdx
	xor rdx, rdx
	jmp %%algorithm

%%exit_EuclAlg:

%endmacro

%macro EctendEuclAlg 2
;расширенный алг эвклида. нахождение обр элемента. найдена закономерность. если ход нечетный, то отрицательное значение. если ход четный, то положительное значение. первые два хода идет заполнение коэффициентов rbx, rsi. при последущих идет rbx + rsi*rax (rax - целое число после деления) и знак зависит от четности хода.

    mov rax, %2
    mov rdi, %1
    mov rcx, 0                      ;счетчик итераций
    xor rbx, rbx                    ;хранится коэфициент предпредыдущий
    xor rsi, rsi                    ;хранится коэфициент предыдущий

%%algorithm:
    inc rcx

    div rdi

    push rdx                        ;сохраняем остаток, т.к. после умножения регистр изменит значение

    cmp rdx, 0                      ;проверка конец алгоритма Евклида
    jz %%exit_algorithm             ;выход из алгоритма

    cmp rcx, 1                      ;проверка на первую итерацию
    jnz %%not_one                   ;переход если не первая

    mov rbx, rax                    ;если первая, то сохраняем коэфициент
    jmp %%next_iter

%%not_one:

    cmp rcx, 2                      ;проверка на вторую итерацию
    jnz %%not_two                   ;переход если не вторая

    mul rbx                         ;если вторая, высчитываем второй коэфициент
    inc rax
    mov rsi, rax                    ;сохраняем второй коэфициент

    jmp %%next_iter

%%not_two:

    mul rsi                         ;высчитываем другой коэфициент
    add rax, rbx

    mov rbx, rsi                    ;сохраняем предпоследний коэфициент
    mov rsi, rax                    ;сохраняем последний коэфициент

%%next_iter:

    pop rdx                         ;достаем остаток от деления
    mov rax, rdi
	mov rdi, rdx
	xor rdx, rdx
	jmp %%algorithm

%%exit_algorithm:

    pop rdx                         ;удаляем из стека значение

    cmp rcx, 2                      ;проверка на количество итераций
    jnz %%n

    mov rax, [fi_RSA + 8]           ;если количество итераций равно 2
    sub rax, rbx
    mov rsi, rax
    jmp %%end

%%n:
    test rcx, 1                     ;проверка на четность счетчика
    jnz %%end                       ;переход если нечетное

    mov rax, [fi_RSA + 8]
    sub rax, rsi                    ;если чет, то обр элемент с - будет. тогда приводим под +. пока сделано, что можно вывести обр элемент в + единственным сложением. пример: обр = -10, модуль = 15, обр = 5
    mov rsi, rax

%%end:
    mov [d_RSA], rsi

%endmacro

;функция принимает 2 простых числа rax, rdx, rax!=rdx
;возвращает 3 значения: rax - e_RSA, rbx - n_RSA, rdx - d_RSA
generatorRSA:
    mov [p_RSA], rax
    mov [q_RSA],rdx

    ;формирование пар открытых/закрытых ключей для КС РША
    ;блок с известными p_RSA, q_RSA
    ;вычисление n_RSA = p_RSA * q_RSA
    mov rax, [p_RSA]
    mov rdx, [q_RSA]
    mul rdx                         ;старшая часть в rdx, младшая часть в rax
    mov [n_RSA], rdx
    mov [n_RSA + 8], rax            ;!!!пока будет считаться, что rdx = 0 всегда!!!

    ;вычисление значения функции Эйлера fi(n) = (p_RSA-1) * (q_RSA-1)
    mov rax, [p_RSA]
    mov rdx, [q_RSA]
    dec rax
    dec rdx
    mul rdx
    mov [fi_RSA], rdx
    mov [fi_RSA + 8], rax           ;!!!пока будет считаться, что rdx = 0 всегда!!!

    ;генерация 1 <= e_RSA <= fi_RSA, gcd(e_RSA, fi_RSA) = 1
    ;пока генерация ужасна. необходимо будет позже менять
    mov rcx, [fi_RSA + 8]
gen_e_RSA:
    dec rcx

    EuclAlg [fi_RSA + 8], rcx

    cmp rdi, 1
    jnz gen_e_RSA

    mov [e_RSA], rcx                ;сохранение значения e_RSA

    EctendEuclAlg [e_RSA], [fi_RSA + 8]
    mov rdi, [d_RSA]

    mov rax, [e_RSA]
    mov rbx, [n_RSA + 8]
    mov rdx, [d_RSA]
    ret
