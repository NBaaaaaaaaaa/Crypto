global _start

section .data
first dq 1547
second dq 560

section .text
_start:
	mov rax, [first]
	mov rdi, [second]

allzero:
	cmp rax, 0
	jnz comparison
	cmp rdi, 0
	jz exit

comparison:
	cmp rax, rdi
	jae algorithm
	mov rax, [second]
	mov rdi, [first]

algorithm:
	div rdi
	cmp rdx, 0
	jz exit

	mov rax, rdi
	mov rdi, rdx
	xor rdx, rdx
	jmp algorithm

;gcd находится в регисте rdi. 'echo $?' - посмотреть значение rdi
exit:
	mov rax, 60
	syscall

