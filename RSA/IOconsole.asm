global readConsole
global writeConsole

section .text
;Функция чтения с консоли.
;Вход: rsi - адрес, куда записать, rdx - размер вводимой последовательности.
readConsole:

	mov rax, 0
	mov rdi, 0
	syscall

	ret

;Функция вывода на консоль.
;Вход: rsi - адрес, откуда брать, rdx - длина выводимой последовательности.
writeConsole:

	mov rax, 1
	mov rdi, 1
	syscall

	ret
