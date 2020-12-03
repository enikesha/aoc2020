# as --64 day1_1.s -o day1_1.o && ld -melf_x86_64 -s day1_1.o -o day1_1
# ./day1_1 < day1_input.txt

.set need_sum, 2020

.data
msg_bad_input:
    .ascii "Bad input\n"
    .set len_bad_input, . - msg_bad_input
msg_large_input:
    .ascii "Input too large\n"
    .set len_large_input, . - msg_large_input
msg_not_found:
    .ascii "Year not found\n"
    .set len_not_found, . - msg_not_found

.bss
    .align 64
buf:
    .space 4096
    .set buf_len, . - buf

    .align 64
    inp_size = 1024
input:
    .fill inp_size, 8
inp_end:

.text
.globl _start
_start:
    mov $input, %r13
read:
    xor %rax, %rax
    xor %rdi, %rdi
    mov $buf, %rsi
    mov $buf_len, %rdx
    syscall
    mov %rax, %rcx
    jrcxz solve
next:
    movzbl (%rsi), %rax
    inc %rsi
    cmp $'\n, %al
    jz store
    cmp $'\ , %al
    jz store
    sub $'0, %al
    cmp $9, %al
    ja bad_input
    imul $10, %r12, %r12
    add %rax, %r12
    loop next
    jmp read
store:
    mov %r12, (%r13)
    add $8, %r13
    cmp $inp_end, %r13
    ja large_input
    xor %r12, %r12
    loop next
    jmp read

    mov $buf, %rsi
    mov %rax, %rdx
    jmp output

solve:
    mov $input, %r12 # end of array at %r13
    sub $8, %r13
    call qs

    mov %r12, %r15

sum_3:
    cmp %r13, %r15
    jg exit
    mov $need_sum, %rbx
    sub (%r15), %rbx
    call sum_2
    add $8, %r15
    jmp sum_3

sum_2:
    push %r12
    push %r13
search:
    cmp %r13, %r12
    jl cont
    pop %r13
    pop %r12
    ret
cont:
    cmp %r15, %r12
    jne 1f
    add $8, %r12
    jmp search
1:  cmp %r15, %r12
    jne 2f
    sub $8, %r13
    jmp search
2:  mov (%r12), %rax
    add (%r13), %rax
    cmp %rbx, %rax
    jz found
    ja dec
    add $8, %r12
    jmp search
dec:
    sub $8, %r13
    jmp search
found:
    mov (%r12), %rax
    call print
    mov (%r13), %rax
    call print
    mov (%r15), %rax
    call print
    mov (%r12), %rax
    mov (%r13), %rcx
    mul %rcx
    mov (%r15), %rcx
    mul %rcx
    call print
    jmp exit

print:
    mov $input, %rsi
    movb $'\n, -1(%rsi)
    dec %rsi
    mov $10, %rcx
div:
    xor %rdx, %rdx
    div %rcx
    add $'0, %dl
    mov %dl, -1(%rsi)
    dec %rsi
    test %rax, %rax
    jnz div

    mov $input, %rdx
    sub %rsi, %rdx
    call output
    ret

large_input:  mov $msg_large_input, %rsi
    mov $len_large_input, %rdx
    call output
    jmp exit

bad_input:  mov $msg_bad_input, %rsi
    mov $len_bad_input, %rdx
    call output
    jmp exit

not_found:  mov $msg_not_found, %rsi
    mov $len_not_found, %rdx
    call output
    jmp exit

output:
    mov  $1,   %rax
    mov  $1,   %rdi
    syscall
    ret

exit:
    mov  $60, %rax
    xor  %rdi, %rdi
    syscall

qs:
    # start: %r12, end: %r13
    cmp %r13, %r12
    jl 1f
    ret
1:
    push %r12
    push %r13
    mov %r12, %rax
    add %r13, %rax
    shr $4, %rax
    shl $3, %rax
    mov (%rax), %rdx
left:
    cmp %rdx, (%r12)
    jae right
    add $8, %r12
    jmp left
right:
    cmp %rdx, (%r13)
    jbe swap
    sub $8, %r13
    jmp right
swap:
    cmp %r13, %r12
    jge rec
    mov (%r13), %rax
    xchg (%r12), %rax
    mov %rax, (%r13)
    jmp left
rec:
    mov 8(%rsp), %r12
    call qs

    lea 8(%r13), %r12
    mov (%rsp), %r13
    call qs

    pop %r13
    pop %r12
    ret
