[bits 64]

section .data
	amount dq 9
	string db 0x81, "12", 0xE2, 0x82, 0xAC, 0xC3, 0x86
	_1string db 0xF0, 0x9F, 0x98, 0x8A, 0xc0, 0x86
	_2string db 0xF4, 0x90, 0x80, 0x80, 0
	str_len dq 18
	codepoints dd -1, 0x31, 0x32, 0x20ac, 0xc6, 0x1f60a, -1, -1, -1, 0
	_utf8_decode_mask db 0, 0, 0x1f, 0x0f, 0x07


section .text
	global _start


 ; My third hand written assembly function.
 ; This decodes a UTF-8 encoding,
 ; and returns it's codepoint and length.
 ; This function will check for overlong encodings,
 ; and it does check that all header bits are valid.
 ; -----------------------------------------
 ; Notice:  This returns encoding length in BX,
 ; this isn't valid in the Windows C Calling Convention.
 ; -----------------------------------------
 ; rcx = string to decode.
 ; rdx = string length.
 ; eax = returned codepoint (-1 on invalid encoding).
 ;  bl = returned encoding length (1 on invalid encoding).
utf8_decode:
	cmp rdx, 0 ; String length must be non zero.
	jle .inv
	xor rax, rax
	xor rbx, rbx
	mov al, byte [rcx]
	jmp .hcmp
.hinc:	inc bl
	shl al, 1
.hcmp:	test al, byte 0x80
	jnz .hinc
	cmp bl, 1 ; Only one high bit set, not start of encoding.
	je .inv
	jl .ascii
	cmp bl, dl ; Header length larger than string.
	jg .inv

	; Multi byte decode time!
	; Fetch lower bits of header.
	mov al, byte [_utf8_decode_mask + rbx]
	and al, byte [rcx]
	push rcx
	push bx

	; Decode rest in loop!
.loop:	shl eax, 6
	inc rcx
	mov bh, byte [rcx] ; Check for valid header.
	and bh, byte 0xc0
	cmp bh, byte 0x80
	jne .inv_p
	mov bh, byte [rcx]
	and bh, byte 0x3f
	add al, bh
	dec bl
	cmp bl, 1
	jnz .loop
	pop bx

	; Before we restore the string pointer argument,
	; we'll check for an overlong encoding.
	mov rcx, rax
	call utf8_encoding_length
	cmp al, bl
	jne .ol
	mov rax, rcx
	pop rcx
	ret
.inv_p:	pop bx
.ol:	pop rcx
.inv:	xor eax, eax
	xor bx, bx
	dec eax
.ascii:	inc bl
	ret

 ; Returns the UTF-8 encoding length of a codepoint.
 ; ecx = codepoint.
 ;  al = returned byte length (0 on invalid).
utf8_encoding_length:
	xor rax, rax
	cmp ecx, 0
	jl .l0
	cmp ecx, 0x80
	jl .l1
	cmp ecx, 0x800
	jl .l2
	cmp ecx, 0x10000
	jl .l3
	cmp ecx, 0x110000
	jl .l4
	jmp .l0
.l4:	inc al
.l3:	inc al
.l2:	inc al
.l1:	inc al
.l0:	ret


_start:
	; Decode the string and check expected codepoints.
	xor r8, r8 ; counter
	xor r9, r9 ; string index
.loop:	lea rcx, [string + r9]
	mov rdx, [str_len]
	sub rdx, r9
	call utf8_decode
	cmp [codepoints + r8 * 4], eax
	jne .failed
	add r9, rbx
	inc r8
	cmp [amount], r8
	jne .loop
	mov rax, 0
	mov rbx, 0
	mov rcx, 0
	mov rdx, 0
	jmp .done
.failed:	mov rax, -1
	mov rbx, -1
	mov rcx, -1
	mov rdx, -1
.done:	jmp .done
	ret
