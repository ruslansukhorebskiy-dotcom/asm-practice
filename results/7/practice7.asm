global _start

section .bss
    buf resb 16
    arr resd 50
    outbuf resb 16
    n resd 1
    minv resd 1
    maxv resd 1
    mini resd 1
    maxi resd 1

section .data
    space db ' '
    nl db 10
    min_txt db 'min '
    min_len equ $ - min_txt
    max_txt db 'max '
    max_len equ $ - max_txt
    idx_txt db ' index '
    idx_len equ $ - idx_txt

section .text

_start:
    ; I/O
    mov eax, 3
    xor ebx, ebx
    mov ecx, buf
    mov edx, 16
    int 0x80

    ; parse
    mov esi, buf
    call atoi
    mov [n], eax

    ; loops
    xor ecx, ecx

fill_loop:
    cmp ecx, [n]
    jge find_minmax

    ; math
    mov eax, ecx
    imul eax, eax
    add eax, 3
    sub eax, ecx

    ; memory
    mov [arr + ecx * 4], eax

    inc ecx
    jmp fill_loop

find_minmax:
    ; memory
    mov eax, [arr]
    mov [minv], eax
    mov [maxv], eax
    mov dword [mini], 0
    mov dword [maxi], 0

    ; loops
    xor ecx, ecx

check_loop:
    cmp ecx, [n]
    jge print_array

    ; memory
    mov eax, [arr + ecx * 4]

    ; logic
    cmp eax, [minv]
    jge check_max
    mov [minv], eax
    mov [mini], ecx

check_max:
    ; logic
    cmp eax, [maxv]
    jle next_check
    mov [maxv], eax
    mov [maxi], ecx

next_check:
    inc ecx
    jmp check_loop

print_array:
    ; loops
    xor ecx, ecx

print_loop:
    cmp ecx, [n]
    jge print_min

    ; memory
    mov eax, [arr + ecx * 4]
    push ecx
    call print_num
    call print_space
    pop ecx

    inc ecx
    jmp print_loop

print_min:
    call print_nl

    ; I/O
    mov ecx, min_txt
    mov edx, min_len
    call print

    mov eax, [minv]
    call print_num

    mov ecx, idx_txt
    mov edx, idx_len
    call print

    mov eax, [mini]
    call print_num
    call print_nl

print_max:
    ; I/O
    mov ecx, max_txt
    mov edx, max_len
    call print

    mov eax, [maxv]
    call print_num

    mov ecx, idx_txt
    mov edx, idx_len
    call print

    mov eax, [maxi]
    call print_num
    call print_nl

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    ; memory
    xor eax, eax

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

    ; logic
    inc esi
    jmp atoi_loop

atoi_done:
    ret

print_num:
    ; memory
    mov edi, outbuf + 16

    ; logic
    cmp eax, 0
    jne num_loop

    dec edi
    mov byte [edi], '0'
    jmp num_write

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