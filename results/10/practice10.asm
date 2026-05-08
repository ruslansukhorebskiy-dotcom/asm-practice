global _start

section .bss
    buf resb 32
    outbuf resb 16
    x resd 1
    bits_count resd 1

section .data
    zero db '0'
    one db '1'
    space db ' '
    nl db 10

section .text

_start:
    ; I/O
    mov eax, 3
    xor ebx, ebx
    mov ecx, buf
    mov edx, 32
    int 0x80

    ; parse
    mov esi, buf
    call atoi
    mov [x], eax

    call print_binary
    call print_nl

    call count_bits

    ; memory
    mov eax, [bits_count]
    call print_num
    call print_nl

    ; logic
    mov eax, [x]

    ; math
    mov ebx, 1
    shl ebx, 1
    or eax, ebx

    mov ebx, 1
    shl ebx, 3
    or eax, ebx

    mov ebx, 1
    shl ebx, 2
    not ebx
    and eax, ebx

    call print_num
    call print_nl

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_binary:
    ; memory
    mov eax, [x]
    mov ecx, 31

binary_loop:
    ; loops
    push eax
    push ecx

    ; logic
    mov ebx, eax
    shr ebx, cl
    and ebx, 1

    cmp ebx, 0
    je print_zero

    ; I/O
    mov ecx, one
    mov edx, 1
    call print
    jmp after_bit

print_zero:
    ; I/O
    mov ecx, zero
    mov edx, 1
    call print

after_bit:
    pop ecx
    pop eax

    ; logic
    cmp ecx, 0
    je binary_done

    ; math
    mov edx, ecx
    and edx, 3
    cmp edx, 0
    jne no_space

    ; I/O
    push eax
    push ecx
    call print_space
    pop ecx
    pop eax

no_space:
    dec ecx
    jmp binary_loop

binary_done:
    ret

count_bits:
    ; memory
    mov eax, [x]
    xor ecx, ecx

pop_loop:
    ; loops
    cmp eax, 0
    je pop_done

    ; logic
    mov ebx, eax
    and ebx, 1

    ; math
    add ecx, ebx
    shr eax, 1
    jmp pop_loop

pop_done:
    ; memory
    mov [bits_count], ecx
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