.code

public __writecr2
public __read_ldtr
public __read_tr
public __read_cs
public __read_ss
public __read_ds
public __read_es
public __read_fs
public __read_gs
public write_tr
public write_cs
public write_ss
public write_ds
public write_es
public write_fs
public write_gs
public write_ldtr
public __sgdt
public __sidt
public __load_ar
public __vm_call
public __vm_call_ex
public __hyperv_vm_call
public __reload_gdtr
public __reload_idtr
public __invept
public __invvpid


__writecr2 proc
    mov cr2,rcx
    ret
__writecr2 endp

__read_ldtr proc
    sldt ax
    ret
__read_ldtr endp

__read_tr proc
    str ax
    ret
__read_tr endp

__read_cs proc
    mov ax, cs
    ret
__read_cs endp

__read_ss proc
    mov ax, ss
    ret
__read_ss endp

__read_ds proc
    mov ax, ds
    ret
__read_ds endp

__read_es proc
    mov ax, es              
    ret
__read_es endp

__read_fs proc
    mov ax, fs
    ret
__read_fs endp

__read_gs proc
    mov ax, gs
    ret
__read_gs endp

__sgdt proc
    sgdt qword ptr [rcx]
    ret
__sgdt endp

__sidt proc
    sidt qword ptr [rcx]
    ret
__sidt endp

__load_ar proc
    lar rax, rcx
    jz no_error
    xor rax, rax
no_error:
    ret
__load_ar endp

; R14 = TSC, R15 = vmcall_compute_token(CR3, TSC); RCX/RDX/R8/R9 (+R10–R13 for ex) = payload.
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

__hyperv_vm_call proc
    push r10
    xor r10, r10
    xor r10, r10
    lea r11, [r11+0]
    pop r10
    vmcall
    ret
__hyperv_vm_call endp

__reload_gdtr proc
	push rcx
	shl rdx, 48
	push rdx
	lgdt fword ptr [rsp+6]
	pop rax
	pop rax
	ret
__reload_gdtr endp


__reload_idtr proc
	push rcx
	shl	 rdx, 48
	push rdx
	lidt fword ptr [rsp+6]
	pop	rax
	pop	rax
	ret
__reload_idtr endp

__invept proc
    invept rcx,oword ptr[rdx]
    ret
__invept endp

__invvpid proc
    invvpid rcx,oword ptr[rdx]
    ret
__invvpid endp

write_tr proc
  ltr cx
  ret
write_tr endp

write_cs proc
  mov cs, cx
  ret
write_cs endp

write_ss proc
  mov ss, cx
  ret
write_ss endp

write_ds proc
  mov ds, cx
  ret
write_ds endp

write_es proc
  mov es, cx
  ret
write_es endp

write_fs proc
  mov fs, cx
  ret
write_fs endp

write_gs proc
  mov gs, cx
  ret
write_gs endp

write_ldtr proc
  lldt cx
  ret
write_ldtr endp

end
