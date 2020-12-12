# as --64 day11.s -o day11.o && ld -melf_x86_64 -s day11.o -o day11

    .set NR_read, 0
    .set NR_write, 1
    .set NR_open, 2
    .set NR_close, 3
    .set O_RDONLY,0
    .set STDIN,0
    .set STDOUT,1
    .set STDERR,3

    .set SEP, '\n
    .set FLOOR, '.
    .set EMPTY, 'L
    .set OCCUPIED, '#
    .set DIRS, 0xFF01FF0001FF0001
    .set P1N, 4
    .set P2N, 5

    .data
filename:
    .ascii "test.txt\0"

open_error_msg:
    .ascii "File open error"
open_error_len:

read_error_msg:
    .ascii "File read error"
read_error_len:

    .bss
    .align 64
seats1:
    .space 0x4000
seats2:
    .space 0x4000
seats3:
    .space 0x4000
buffer:
    .space 0x1000
buffer_end:

    .text
    .globl _start
_start:
    mov $filename, %rdi
    cmp $1, (%rsp)
    jbe 1f
    mov 16(%rsp), %rdi
1:  mov $NR_open, %rax
    mov $O_RDONLY, %rsi
    syscall

    cmp $0, %rax
    jl open_error

    mov %rax, %rdi
    mov $seats1, %rsi
    mov $(seats2 - seats1), %rdx
    mov $NR_read, %rax
    syscall

    cmp $0, %rax
    jl read_error

    mov %rax, %r12 # store file size

    mov $NR_close, %rax
    syscall

    mov %rsi, %rdi
    mov $SEP, %al
    mov %r12, %rcx
    repnz scasb
    sub %rsi, %rdi

    mov $DIRS, %rbx
    add %dil, %bl
    ror $8, %rbx
    add %dil, %bl
    ror $8, %rbx
    add %dil, %bl
    ror $8, %rbx
    sub %dil, %bl
    ror $8, %rbx
    sub %dil, %bl
    ror $8, %rbx
    sub %dil, %bl
    ror $8, %rbx

    mov $100, %rcx
1:  push %rcx

    call setup
    mov $part1, %rdx
    mov $P1N, %r8
    call steps
    call occupied
    call printInt

    call setup
    mov $part2, %rdx
    mov $P2N, %r8
    call steps
    call occupied
    call printInt

    pop %rcx
    loop 1b

exit:
    mov  $60, %rax
    syscall

setup:
    mov $seats2, %rdi
    mov $seats1, %rsi
    mov %r12, %rcx
    shr $3, %rcx
    rep movsq
    mov %r12, %rcx
    and $7, %rcx
    rep movsb
    ret

steps:
    mov $seats2, %rsi
    mov $seats3, %rdi
5:  mov %rsi, %rbp
    add %r12, %rbp
    xor %r9, %r9
1:  lodsb
#   | 0 1-N >N
# # | #  #   L
# L | #  L   L
    cmp $OCCUPIED, %al
    jz 2f
    cmp $EMPTY, %al
    jnz 3f
2:  mov %al, %r10b
    mov %rbp, %r11
    sub %r12, %r11
    dec %rsi
    xor %rax, %rax
    mov $8, %rcx
    jmp *%rdx  # neighbors
    .p2align 4
neigh:
    inc %rsi
    test %rax, %rax
    jz 6f
    cmp %r8, %rax
    jl 7f
    cmp $EMPTY, %r10b
    jz 7f
    mov $EMPTY, %r10b
    jmp 8f
6:  cmp $OCCUPIED, %r10b
    jz 7f
    mov $OCCUPIED, %r10b
8:  mov $1, %r9b
7:  mov %r10b, %al
3:  stosb
    cmp %rbp, %rsi
    jb 1b
    test %r9, %r9
    jz 4f
    sub %r12, %rsi
    neg %rsi
    add $seats2, %rsi
    add $seats3, %rsi
    sub %r12, %rdi
    neg %rdi
    add $seats2, %rdi
    add $seats3, %rdi
    jmp 5b
4:  ret

    .p2align 4
part1:
1:  movsx %bl, %r13
    ror $8, %rbx
    add %rsi, %r13
    cmp %r11, %r13
    jb 2f
    cmp %rbp, %r13
    jae 2f
    cmpb $SEP, (%r13)
    je 2f
    cmpb $OCCUPIED, (%r13)
    jne 2f
    inc %rax
2:  loop 1b
    jmp neigh

    .p2align 4
part2:
1:  movsx %bl, %r14
    ror $8, %rbx
    mov %rsi, %r13
3:  add %r14, %r13
    cmp %r11, %r13
    jb 2f
    cmp %rbp, %r13
    jae 2f
    cmpb $SEP, (%r13)
    je 2f
    cmpb $FLOOR, (%r13)
    je 3b
    cmpb $OCCUPIED, (%r13)
    jne 2f
    inc %rax
2:  loop 1b
    jmp neigh

occupied:
    mov %r12, %rcx
    mov $OCCUPIED, %al
    xor %rdx, %rdx
    dec %rdi
    std
1:  repnz scasb
    jnz 2f
    inc %rdx
    jmp 1b
2:  mov %rdx, %rax
    cld
    inc %rdi
    ret

read_error:
    push %rax
    mov $read_error_msg, %rsi
    mov $(read_error_len-read_error_msg), %rdx
    call printString
    pop %rdi
    jmp exit

open_error:
    push %rax
    mov $open_error_msg, %rsi
    mov $(open_error_len-open_error_msg), %rdx
    call printString
    pop %rdi


printInt:
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

printString:
    mov $NR_write, %rax
    mov $STDOUT, %rdi
    syscall
    ret
