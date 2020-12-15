# as --64 day15.s -o day15.o && ld -melf_x86_64 -s day15.o -o day15
    .set N, 30000000
    #.set N, 2020
    .set SIZE, 4
    .set NR_write, 1
    .set STDOUT,1
    .data
input:
    .byte 15,5,1,4,7,0
    .set CNT, .-input

    .bss
    .align 64
lookup: .fill N, SIZE
buffer:
    .space 0x1000
buffer_end:

    .text

    .globl _start
_start:
    mov $input, %rsi
    mov $lookup, %r10
    mov $(CNT-1), %cx
1:  inc %edx
    lodsb
    mov %edx, (%r10,%rax,SIZE)
    loop 1b

    mov $(N-CNT), %ecx
    lodsb
    inc %edx

    .p2align 4
1:  mov (%r10,%rax,SIZE), %ebx
    mov %edx, (%r10,%rax,SIZE)
    mov %edx, %edi
    sub %ebx, %edi
    test %ebx, %ebx
    cmovnz %edi, %ebx
    inc %edx
    mov %ebx, %eax
    loop 1b

    mov $buffer_end, %rsi
    movb $'\n, -1(%rsi)
    dec %rsi
    mov $10, %rcx
1:
    xor %rdx, %rdx
    div %rcx
    add $'0, %dl
    mov %dl, -1(%rsi)
    dec %rsi
    test %rax, %rax
    jnz 1b

    mov $buffer_end, %rdx
    sub %rsi, %rdx

    mov $NR_write, %rax
    mov $STDOUT, %rdi
    syscall

exit:
    mov  $60, %rax
    syscall
