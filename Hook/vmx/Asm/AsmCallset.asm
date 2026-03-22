.code

public __vm_call
public __vm_call_ex

; R14 = TSC, R15 = token (CR3,TSC); must match VT_Driver vmcall_token.h / vmcall_handler.

__vm_call proc
	push rbx
	push rsi
	push rdi
	mov rbx, rcx
	rdtsc
	shl rdx, 32
	or rax, rdx
	mov rsi, rax
	mov rdi, cr3
	mov rax, rsi
	mov rcx, rsi
	shr rcx, 32
	xor rax, rcx
	xor rax, rdi
	mov rcx, rsi
	shr rcx, 32
	add rax, rcx
	mov r14, rsi
	mov r15, rax
	mov rcx, rbx
	pop rdi
	pop rsi
	pop rbx
	push r10
	xor r10, r10
	xor r10, r10
	lea r11, [r11+0]
	pop r10
	vmcall
	ret
__vm_call endp

__vm_call_ex proc
	sub rsp, 30h
	mov qword ptr [rsp],       r10
	mov qword ptr [rsp + 8h],  r11
	mov qword ptr [rsp + 10h], r12
	mov qword ptr [rsp + 18h], r13
	mov qword ptr [rsp + 20h], r14
	mov qword ptr [rsp + 28h], r15

	mov r10, qword ptr [rsp + 58h]
	mov r11, qword ptr [rsp + 60h]
	mov r12, qword ptr [rsp + 68h]
	mov r13, qword ptr [rsp + 70h]

	push rbx
	push rsi
	push rdi
	mov rbx, rcx
	rdtsc
	shl rdx, 32
	or rax, rdx
	mov rsi, rax
	mov rdi, cr3
	mov rax, rsi
	mov rcx, rsi
	shr rcx, 32
	xor rax, rcx
	xor rax, rdi
	mov rcx, rsi
	shr rcx, 32
	add rax, rcx
	mov r14, rsi
	mov r15, rax
	mov rcx, rbx
	pop rdi
	pop rsi
	pop rbx
	xor rax, rax
	xor rax, rax
	lea r10, [r10+0]
	xchg r11, r11
	nop
	vmcall
	mov r10, qword ptr [rsp]
	mov r11, qword ptr [rsp + 8h]
	mov r12, qword ptr [rsp + 10h]
	mov r13, qword ptr [rsp + 18h]
	mov r14, qword ptr [rsp + 20h]
	mov r15, qword ptr [rsp + 28h]
	add rsp, 30h
	ret
__vm_call_ex endp

end
