global _start

section .bss
    buf resb 1024
    arr resd 100
    outbuf resb 16
    n resd 1

section .data
    space db ' '
    nl db 10

section .text

_start:
    ; I/O
    mov eax, 3
    xor ebx, ebx
    mov ecx, buf
    mov edx, 1024
    int 0x80

    ; parse
    mov esi, buf
    call atoi
    mov [n], eax

    ; loops
    xor ecx, ecx

read_loop:
    cmp ecx, [n]
    jge print_before

    call skip
    call atoi

    ; memory
    mov [arr + ecx * 4], eax

    inc ecx
    jmp read_loop

print_before:
    ; loops
    xor ecx, ecx

print_before_loop:
    cmp ecx, [n]
    jge sort_start

    ; memory
    mov eax, [arr + ecx * 4]

    push ecx
    call print_num
    call print_space
    pop ecx

    inc ecx
    jmp print_before_loop

sort_start:
    call print_nl

    ; loops
    xor ecx, ecx

outer_loop:
    mov eax, [n]
    dec eax
    cmp ecx, eax
    jge print_after

    ; memory
    mov edi, ecx
    mov edx, ecx
    inc edx

inner_loop:
    cmp edx, [n]
    jge swap_items

    ; logic
    mov eax, [arr + edx * 4]
    cmp eax, [arr + edi * 4]
    jge no_new_min

    mov edi, edx

no_new_min:
    inc edx
    jmp inner_loop

swap_items:
    ; logic
    cmp edi, ecx
    je next_outer

    ; memory
    mov eax, [arr + ecx * 4]
    mov ebx, [arr + edi * 4]
    mov [arr + ecx * 4], ebx
    mov [arr + edi * 4], eax

next_outer:
    inc ecx
    jmp outer_loop

print_after:
    ; loops
    xor ecx, ecx

print_after_loop:
    cmp ecx, [n]
    jge print_median

    ; memory
    mov eax, [arr + ecx * 4]

    push ecx
    call print_num
    call print_space
    pop ecx

    inc ecx
    jmp print_after_loop

print_median:
    call print_nl

    ; math
    mov eax, [n]
    dec eax
    shr eax, 1

    ; memory
    mov eax, [arr + eax * 4]
    call print_num
    call print_nl

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

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
    mov bl, [esi]
    cmp bl, ' '
    je skip_next
    cmp bl, 10
    je skip_next
    cmp bl, 13
    je skip_next
    cmp bl, 9
    je skip_next
    ret

skip_next:
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

    ; math
    div ebx
    add dl, '0'

    ; memory
    dec edi
    mov [edi], dl

    ; logic
    cmp eax, 0
    jne num_loop

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

print_space:
    ; I/O
    mov ecx, space
    mov edx, 1
    call print
    ret

print_nl:
    ; I/O
    mov ecx, nl
    mov edx, 1
    call print
    ret