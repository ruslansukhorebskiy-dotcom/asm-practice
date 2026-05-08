global _start

section .bss
    inbuf resb 32
    outbuf resb 16

section .data
    nl db 10

section .text

_start:
    ; I/O
    mov eax, 3
    xor ebx, ebx
    mov ecx, inbuf
    mov edx, 32
    int 0x80

    ; parse
    mov esi, inbuf
    xor eax, eax

parse_loop:
    ; loops
    mov bl, [esi]
    cmp bl, 10
    je parse_done
    cmp bl, '0'
    jl parse_done
    cmp bl, '9'
    jg parse_done

    ; math
    imul eax, eax, 10
    sub bl, '0'
    movzx ebx, bl
    add eax, ebx

    ; logic
    inc esi
    jmp parse_loop

parse_done:
    ; memory
    movzx eax, ax

    call print_number
    call print_nl

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_number:
    ; memory
    mov edi, outbuf + 16

    ; logic
    cmp eax, 0
    jne convert_loop

    dec edi
    mov byte [edi], '0'
    jmp print_result

convert_loop:
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
    jne convert_loop

print_result:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, outbuf + 16
    sub edx, edi
    int 0x80
    ret

print_nl:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, nl
    mov edx, 1
    int 0x80
    ret