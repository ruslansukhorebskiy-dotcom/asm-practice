global _start

section .bss
    buf resb 256
    text resb 201
    pattern resb 51
    outbuf resb 16
    text_len resd 1
    pat_len resd 1
    first_pos resd 1
    count resd 1

section .data
    nl db 10

section .text

_start:
    ; I/O
    mov eax, 3
    xor ebx, ebx
    mov ecx, buf
    mov edx, 256
    int 0x80

    ; parse
    mov esi, buf
    mov edi, text
    call copy_line

    mov edi, pattern
    call copy_line

    ; memory
    mov esi, text
    call strlen
    mov [text_len], eax

    mov esi, pattern
    call strlen
    mov [pat_len], eax

    ; logic
    cmp dword [pat_len], 0
    jne start_search

    mov dword [first_pos], -1
    mov dword [count], 0
    jmp print_result

start_search:
    ; memory
    mov dword [first_pos], -1
    mov dword [count], 0

    ; loops
    xor ecx, ecx

search_loop:
    ; logic
    mov eax, [text_len]
    sub eax, [pat_len]
    cmp ecx, eax
    jg print_result

    push ecx
    call check_match
    pop ecx

    cmp eax, 1
    jne next_pos

    ; logic
    cmp dword [count], 0
    jne inc_found
    mov [first_pos], ecx

inc_found:
    ; math
    inc dword [count]
    add ecx, [pat_len]
    jmp search_loop

next_pos:
    inc ecx
    jmp search_loop

check_match:
    ; memory
    mov esi, text
    add esi, ecx
    mov edi, pattern

    ; loops
    xor ebx, ebx

match_loop:
    cmp ebx, [pat_len]
    jge match_yes

    ; logic
    mov al, [esi + ebx]
    cmp al, [edi + ebx]
    jne match_no

    inc ebx
    jmp match_loop

match_yes:
    mov eax, 1
    ret

match_no:
    xor eax, eax
    ret

copy_line:
    ; loops
    mov al, [esi]
    cmp al, 10
    je copy_done
    cmp al, 0
    je copy_done

    ; memory
    mov [edi], al

    inc esi
    inc edi
    jmp copy_line

copy_done:
    ; memory
    mov byte [edi], 0

    ; logic
    cmp byte [esi], 10
    jne copy_ret
    inc esi

copy_ret:
    ret

strlen:
    ; memory
    xor eax, eax

strlen_loop:
    ; loops
    cmp byte [esi + eax], 0
    je strlen_done

    inc eax
    jmp strlen_loop

strlen_done:
    ret

print_result:
    ; I/O
    mov eax, [first_pos]
    call print_num
    call print_nl

    mov eax, [count]
    call print_num
    call print_nl

    mov eax, 1
    xor ebx, ebx
    int 0x80

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

print_nl:
    ; I/O
    mov ecx, nl
    mov edx, 1
    call print
    ret