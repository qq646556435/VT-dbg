.code

; bool __vm_launch();
vm_launch proc
  push r10
  xor r10, r10
  xor r10, r10
  lea r11, [r11+0]
  pop r10
  ; set VMCS_GUEST_RSP to the current value of RSP
  mov rax, 681Ch
  vmwrite rax, rsp

  ; set VMCS_GUEST_RIP to the address of <successful_launch>
  mov rax, 681Eh
  mov rdx, successful_launch  ;成功启动
  vmwrite rax, rdx

  push r10
  xor r10, r10
  xor r10, r10
  lea r11, [r11+0]
  pop r10
  vmlaunch

  ; if we reached here, then we failed to launch
  xor al, al
  ret

successful_launch:
  mov al, 1
  ret
vm_launch endp

end

