global asciiToDec
global decToAscii

section .text
;Функция перевода символа Ascii в цифру.
;Вход: 1 - символ для перевода, 2 - куда сохранять.
asciiToDec:

	mov al, %1
	sub al, '0'
	mov %2, al

    ret

;Функция перевода цифры в символ Ascii.
;Вход: al - цифра для перевода, 2 - куда сохранять.
decToAscii:

	mov al, %1
	add al, '0'
	mov %2, al

    ret
