; Nothing of value to see here,
; just me trying to learn about the stack.
; As far as I've understood the Windows calling convention:
; For integers/pointers/objects:
; 1 arg  = RCX
; 2 arg  = RDX
; 3 arg  = R8
; 4 arg  = R9
; 5+ arg = Stack
; floats/reals follow the same, but in xmm0-xmm3 + stack.
; Returned value goes into RAX.
; For multiple returns, I _think_ you use the stack?


[bits 64]

section .data

section .text
	global _start

; Here I just set RAX to some "random" value.
init_rax:
	; Not saving rbp, no arguments passed to this function.
	; afaik, you should/can still do it, helps debuggers in some cases.
	sub rsp, 4
	mov dword [rsp], eax
	and dword [rsp], 0xA
	xor rax, rax
	add eax, dword [rsp]
	add rsp, 4
	ret


add_proc:
	push rbp
	mov rbp, rsp
	call init_rax
	; BP contains previous BP, due to our push to stack.
	; We also need to account for the return address RIP,
	; So, to access the first argument by callee,
	; skip the first 2 qwords.
	add eax, dword [rbp + 16] ; First  argument.
	add eax, dword [rbp + 24] ; Second argument.
	pop rbp
	ret


_start:
	push dword 5  ; Pushing is ALWAYS register sized, so qword.
	push dword 10 ; the 'dword' here notates a dword sized immediate.
	call add_proc
	add rsp, 16 ; pop 2 qwords
.l:	jmp .l
	ret
