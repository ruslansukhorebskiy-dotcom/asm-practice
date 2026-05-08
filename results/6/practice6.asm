global _start

section .bss
    buf resb 64
    outbuf resb 16
    a resd 1
    b resd 1

section .data
    sl db 'SIGNED: a < b',10
    slen equ $-sl
    se db 'SIGNED: a = b',10
    seen equ $-se
    sg db 'SIGNED: a > b',10
    sglen equ $-sg

    ul db 'UNSIGNED: a < b',10
    ulen equ $-ul
    ue db 'UNSIGNED: a = b',10
    ueen equ $-ue
    ug db 'UNSIGNED: a > b',10
    uglen equ $-ug

    nl db 10

section .text

_start:
    ; I/O
    mov eax, 3
    xor ebx, ebx
    mov ecx, buf
    mov edx, 64
    int 0x80

    ; parse
    mov esi, buf
    call atoi
    mov [a], eax
    call skip
    call atoi
    mov [b], eax

    call cmp_signed
    call cmp_unsigned

    ; logic
    mov eax, [a]
    cmp eax, [b]
    jg signed_a
    mov eax, [b]
signed_a:
    call print_num
    call print_nl

    ; logic
    mov eax, [a]
    cmp eax, [b]
    ja unsigned_a
    mov eax, [b]
unsigned_a:
    call print_num
    call print_nl

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

cmp_signed:
    ; logic
    mov eax, [a]
    cmp eax, [b]
    jl cs_less
    jg cs_greater
    je cs_equal

cs_less:
    ; I/O
    mov ecx, sl
    mov edx, slen
    call print
    ret

cs_equal:
    ; I/O
    mov ecx, se
    mov edx, seen
    call print
    ret

cs_greater:
    ; I/O
    mov ecx, sg
    mov edx, sglen
    call print
    ret

cmp_unsigned:
    ; logic
    mov eax, [a]
    cmp eax, [b]
    jb cu_less
    ja cu_greater
    je cu_equal

cu_less:
    ; I/O
    mov ecx, ul
    mov edx, ulen
    call print
    ret

cu_equal:
    ; I/O
    mov ecx, ue
    mov edx, ueen
    call print
    ret

cu_greater:
    ; I/O
    mov ecx, ug
    mov edx, uglen
    call print
    ret

atoi:
    ; memory
    xor eax, eax
    xor edi, edi

    ; logic
    cmp byte [esi], '-'
    jne atoi_loop
    mov edi, 1
    inc esi

atoi_loop:
    ; loops
    mov bl, [esi]
    cmp bl, '0'
    jl atoi_done
    cmp bl, '9'
    jg atoi_done

    ; math
    imul eax, eax, 10
    sub bl, '0'
    movzx ebx, bl
    add eax, ebx

    inc esi
    jmp atoi_loop

atoi_done:
    ; logic
    cmp edi, 0
    je atoi_ret
    neg eax

atoi_ret:
    ret

skip:
    ; loops
    cmp byte [esi], ' '
    je skip_next
    cmp byte [esi], 10
    je skip_next
    cmp byte [esi], 9
    je skip_next
    ret

skip_next:
    ; logic
    inc esi
    jmp skip

print_num:
    ; memory
    mov edi, outbuf + 16
    xor esi, esi

    ; logic
    cmp eax, 0
    jge num_loop
    neg eax
    mov esi, 1

num_loop:
    ; loops
    xor edx, edx
    mov ebx, 10
    div ebx

    ; math
    add dl, '0'
    dec edi
    mov [edi], dl

    ; logic
    test eax, eax
    jnz num_loop

    cmp esi, 0
    je num_write
    dec edi
    mov byte [edi], '-'

num_write:
    ; I/O
    mov ecx, edi
    mov edx, outbuf + 16
    sub edx, edi
    call print
    ret

print:
    ; I/O
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

print_nl:
    ; I/O
    mov ecx, nl
    mov edx, 1
    call print
    ret