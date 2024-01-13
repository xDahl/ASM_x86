 ; Just me trying to learn x64 assembly.
 ; Wrote some basic functions, for fun!
 ; Todo: Learn calling conventions.

[bits 64]

SECTION .DATA
	string db "123", 0
	woah db "This is nice!", 0
	nah db 0
	arr dq 11, 21, 31, 41, 51, 61, 71
	arr_len dq 7

SECTION .TEXT
	GLOBAL _start

 ; My second function!
 ; rcx = amount of elements / length.
 ; r8  = qword Number to find
 ; rsi = address
 ; Returns index in rbx
qword_binary_search:
	; l = rax, m = rbx, r = rcx
	dec rcx
	xor rax, rax ; l = 0
.loop:	cmp rax, rcx ; if l > r, quit!
	jg .failed
	mov rbx, rcx ; RBX (m) = l + (r - l) / 2
	sub rbx, rax
	shr rbx, 1
	add rbx, rax 
	cmp [rsi + rbx * 8], r8 ; cmp rsi[m]
	je .found
	jl .less
	mov rcx, rbx
	dec rcx
	jmp .loop
.less:	mov rax, rbx
	inc rax
	jmp .loop
.failed: xor rbx, rbx
	dec rbx ; rbx = -1
.found:	ret
	

 ; My first function!
 ; rsi = string to scan.
 ; length returned in rax.
 ; This function could be better, but works.
string_length:
	xor rax, rax
	jmp .cmp
.loop:	inc rax
.cmp	cmp [rsi + rax], byte 0
	jnz .loop
	ret

_start:
	; Just to make the register values easier to see change.
	mov r8, -1
	mov r9, -1
	mov r10, -1
	mov r11, -1
	mov r12, -1

	lea rsi, arr
	mov rcx, [arr_len]
	mov r8, 51
	call qword_binary_search
	mov r8, rbx

	lea rsi, string
	call string_length
	mov r9, rax

	lea rsi, woah
	call string_length
	mov r10, rax

	lea rsi, nah
	call string_length
	mov r11, rax
done:
	jmp done
	ret
