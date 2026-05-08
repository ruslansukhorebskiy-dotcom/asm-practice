global _start

section .bss
    buf resb 16
    outbuf resb 16
    calls resd 1
    result resd 1

section .data
    nl db 10

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

    ; memory
    mov dword [calls], 0

    call fact

    ; memory
    mov [result], eax

    ; I/O
    mov eax, [result]
    call print_num
    call print_nl

    mov eax, [calls]
    call print_num
    call print_nl

    mov eax, 1
    xor ebx, ebx
    int 0x80

fact:
    ; memory
    push ebp
    mov ebp, esp
    push ebx

    ; math
    inc dword [calls]

    ; logic
    cmp eax, 1
    jg fact_rec

    mov eax, 1
    jmp fact_end

fact_rec:
    ; memory
    mov ebx, eax
    dec eax

    call fact

    ; math
    imul eax, ebx

fact_end:
    ; memory
    pop ebx
    mov esp, ebp
    pop ebp
    ret

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

print_nl:
    ; I/O
    mov ecx, nl
    mov edx, 1
    call print
    ret