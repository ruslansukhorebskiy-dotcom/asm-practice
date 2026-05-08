global _start

section .bss
    input resb 16
    linebuf resb 64
    h resd 1

section .data
    star db '*'
    space db ' '
    nl db 10

section .text

_start:
    ; I/O
    mov eax, 3
    xor ebx, ebx
    mov ecx, input
    mov edx, 16
    int 0x80

    ; parse
    mov esi, input
    call atoi
    mov [h], eax

    ; loops
    xor ecx, ecx

row_loop:
    cmp ecx, [h]
    jge exit

    push ecx

    ; math
    mov eax, [h]
    sub eax, ecx
    dec eax
    mov ebx, eax

    ; math
    mov eax, ecx
    add eax, ecx
    inc eax
    mov edx, eax

    ; memory
    mov edi, linebuf

space_loop:
    ; loops
    cmp ebx, 0
    jle star_loop

    mov byte [edi], ' '
    inc edi
    dec ebx
    jmp space_loop

star_loop:
    ; loops
    cmp edx, 0
    jle line_done

    mov byte [edi], '*'
    inc edi
    dec edx
    jmp star_loop

line_done:
    ; memory
    mov byte [edi], 10
    inc edi

    ; math
    mov edx, edi
    sub edx, linebuf

    ; I/O
    mov ecx, linebuf
    call print_line

    pop ecx
    inc ecx
    jmp row_loop

exit:
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

print_line:
    ; I/O
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret