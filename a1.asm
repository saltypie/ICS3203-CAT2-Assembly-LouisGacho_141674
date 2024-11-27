section .data
    prompt db "Enter a number: "
    prompt_len equ $ - prompt
    pos_msg db "POSITIVE", 0xa
    pos_len equ $ - pos_msg
    neg_msg db "NEGATIVE", 0xa
    neg_len equ $ - neg_msg
    zero_msg db "ZERO", 0xa
    zero_len equ $ - zero_msg

section .bss
    number resb 16    ; Buffer for input string
    number_len equ 16

section .text
    global _start

_start:
    ; Print prompt
    mov rax, 1        ; sys_write
    mov rdi, 1        ; file descriptor: stdout
    mov rsi, prompt   ; message to write
    mov rdx, prompt_len ; message length
    syscall

    ; Read input sys_read
    mov rax, 0        
    mov rdi, 0        ; file descriptor: stdin
    mov rsi, number   ; buffer to store input
    mov rdx, number_len ; buffer length
    syscall

    ; Convert ASCII to integer
    mov rcx, rax      ; save length of input
    mov rsi, number   ; point to start of buffer
    xor rax, rax      ; clear rax for result
    xor rbx, rbx      ; clear rbx for current
    mov r9, 1         ; sign flag (1 for positive)

    ; Check for minus sign
    cmp byte [rsi], '-'
    jne .convert_loop ;The JNE instruction is used to compare whether the first character is equal to ‘-’ or not. If the first character is not equal the control of the flow is moved to the convert loop. If the first character is - then the register r9 is set to -1.
    mov r9, -1        ; set negative flag
    inc rsi           ; move past minus sign
    dec rcx           ; decrease length

.convert_loop:
    mov bl, [rsi]     ; get current character
    cmp bl, 0xa       ; check for newline
    je .done_convert  ; The jump on equal instruction is used to shift the flow to the done_convert label when comparing with the newline character 0xa.
    sub bl, '0'       ; convert ASCII to number
    imul rax, 10      ; multiply current result by 10
    add rax, rbx      ; add new digit
    inc rsi           ; move to next digit
    dec rcx           ; decrease counter
    jnz .convert_loop ; The jump on not zero instruction is used to maintain the loop on condition that the counter has not reached zero jumps to the start of the loop.

.done_convert:
    imul rax, r9      ; apply sign

    ; Compare with zero
    cmp rax, 0
    je zero_case
    jl negative_case ; The jump on less than command shifts the control of the flow to the negative_case label, this occurs if the number is less than 0.

    ; Positive case
    mov rsi, pos_msg
    mov rdx, pos_len
    jmp print_result ; The jump statement JMP is used to shift the flow of the program to the print_result label, this is an unconditional jump and is always executed so as to display the result.

negative_case:
    mov rsi, neg_msg
    mov rdx, neg_len
    jmp print_result

zero_case:
    mov rsi, zero_msg
    mov rdx, zero_len

print_result:
    mov rax, 1        ; syscall: sys_write
    mov rdi, 1        ; file descriptor: stdout
    syscall

    ; Exit program
    mov rax, 60       ; syscall: sys_exit
    xor rdi, rdi      ; status: 0
    syscall


; The JNE instruction is used to compare whether the first character is equal to ‘-’ or not. If the first character is not equal the control of the flow is moved to the convert loop. If the first character is - then the register r9 is set to -1.

; The jump on equal instruction is used to shift the flow to the done_convert label when comparing with the newline character 0xa.

; The jump on less than command shifts the control of the flow to the negative_case label, this occurs if the number is less than 0.

; The jump statement JMP is used to shift the flow of the program to the print_result label, this is an unconditional jump and is always executed so as to display the result.
