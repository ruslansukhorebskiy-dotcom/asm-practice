global _start

section .bss
    buf resb 1024
    arr resd 200
    rev resd 200
    outbuf resb 16
    n resd 1
    is_pal resd 1

section .data
    space db ' '
    nl db 10
    yes_msg db 'PALINDROME: YES', 10
    yes_len equ $ - yes_msg
    no_msg db 'PALINDROME: NO', 10
    no_len equ $ - no_msg

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
    jge make_reverse

    call skip
    call atoi

    ; memory
    mov [arr + ecx * 4], eax

    inc ecx
    jmp read_loop

make_reverse:
    ; loops
    xor ecx, ecx

rev_loop:
    cmp ecx, [n]
    jge check_pal

    ; math
    mov edx, [n]
    dec edx
    sub edx, ecx

    ; memory
    mov eax, [arr + edx * 4]
    mov [rev + ecx * 4], eax

    inc ecx
    jmp rev_loop

check_pal:
    ; memory
    mov dword [is_pal], 1

    ; loops
    xor ecx, ecx

pal_loop:
    mov eax, [n]
    shr eax, 1
    cmp ecx, eax
    jge print_original

    ; math
    mov edx, [n]
    dec edx
    sub edx, ecx

    ; memory
    mov eax, [arr + ecx * 4]
    mov ebx, [arr + edx * 4]

    ; logic
    cmp eax, ebx
    je pal_next

    mov dword [is_pal], 0
    jmp print_original

pal_next:
    inc ecx
    jmp pal_loop

print_original:
    ; loops
    xor ecx, ecx

print_arr_loop:
    cmp ecx, [n]
    jge print_rev

    ; memory
    mov eax, [arr + ecx * 4]

    push ecx
    call print_num
    call print_space
    pop ecx

    inc ecx
    jmp print_arr_loop

print_rev:
    call print_nl

    ; loops
    xor ecx, ecx

print_rev_loop:
    cmp ecx, [n]
    jge print_answer

    ; memory
    mov eax, [rev + ecx * 4]

    push ecx
    call print_num
    call print_space
    pop ecx

    inc ecx
    jmp print_rev_loop

print_answer:
    call print_nl

    ; logic
    cmp dword [is_pal], 1
    jne print_no

    ; I/O
    mov ecx, yes_msg
    mov edx, yes_len
    call print
    jmp exit

print_no:
    ; I/O
    mov ecx, no_msg
    mov edx, no_len
    call print

exit:
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