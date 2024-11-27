section .data
    prompt_msg db "Enter a number (0-12) to calculate factorial: "
    prompt_len equ $ - prompt_msg
    result_msg db "Factorial = "
    result_len equ $ - result_msg
    error_msg db "Error: Input must be between 0 and 12", 0xA
    error_len equ $ - error_msg
    newline db 0xA

section .bss
    input_buffer resb 32    ; buffer for string input
    number resq 1           ; 64-bit number storage
    output_buffer resb 32   ; buffer for string output

section .text
    global _start

_start:
    ; prompt
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, prompt_msg
    mov rdx, prompt_len
    syscall

    ; input
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    mov rsi, input_buffer
    mov rdx, 32
    syscall

    ; convert the string into a number
    mov rsi, input_buffer
    call string_to_int      ; Result in rax

    ; Validation of input
    cmp rax, 0
    jl input_error
    cmp rax, 12
    jg input_error

    ; Calculate factorial
    mov rdi, rax            ; save input number
    call factorial          ; result will be in rax

    ; Print "Factorial = "
    push rax                ; saves a factorial result
    mov rax, 1
    mov rdi, 1
    mov rsi, result_msg
    mov rdx, result_len
    syscall

    ; Convert result to string and print
    pop rdi                 ; Restores factorial result
    call int_to_string      ; converts number to string. Result in output_buffer
    mov rdx, rax            ; length is in rax
    mov rax, 1              
    mov rdi, 1              ; stdout
    mov rsi, output_buffer
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    jmp exit_program

input_error:
    mov rax, 1              
    mov rdi, 1              ; stdout
    mov rsi, error_msg
    mov rdx, error_len
    syscall

exit_program:
    mov rax, 60             ; sys_exit
    xor rdi, rdi            ; status = 0
    syscall

; Convert string to integer Input: RSI points to string Output: RAX contains integer
string_to_int:
    push rbx
    push rcx
    push rdx
    push rsi

    xor rax, rax            ; initializes the result
    xor rcx, rcx            ; current character

.next_char:
    mov cl, [rsi]           ; get current char
    cmp cl, 0xA             ; checks for newline
    je .done
    cmp cl, 0x20            ; check for space
    je .done
    cmp cl, 0               
    je .done

    sub cl, '0'             ; convert the ASCII to a number
    imul rax, 10            ; Multiply current result by 10
    add rax, rcx            ; add new digit

    inc rsi                 ; move to the next character
    jmp .next_char

.done:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    ret

; Convert integer to string Input: RDI contains integer  Output: RAX contains length, output_buffer contains string
int_to_string:
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi

    mov rax, rdi            ; Number to be convert
    mov rsi, output_buffer
    add rsi, 31             ; Points to end of buffer
    mov byte [rsi], 0       ; null termination

    mov rcx, 0              ; counter for characters
    mov rbx, 10             ; to be used as divisor

.divide_loop:
    xor rdx, rdx            ; Clear for division
    div rbx                 ; divides by 10
    add dl, '0'             ; This converts it to ASCII
    dec rsi                 ; move back through buffer
    mov [rsi], dl           ; store digit
    inc rcx                 ; counting the characters
    test rax, rax           ; tests if done
    jnz .divide_loop

    ; Move string to the start of buffer
    mov rdi, output_buffer
    push rcx                ; save length
    cld
    rep movsb

    pop rax                 ; Return length in RAX

    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

; Calculate factorial Input: RDI = number Output: RAX = factorial result
factorial:
    push rbx
    push rcx

    mov rax, 1              ; Initialize result to 1
    mov rcx, rdi            ; Counter = input number

.factorial_loop:
    cmp rcx, 1              ; check if we're done
    jle .factorial_done     ; If counter <= 1 finishes

    mul rcx                 ; RAX = RAX * RCX
    dec rcx                 ; decrement the counter
    jmp .factorial_loop

.factorial_done:
    pop rcx
    pop rbx
    ret

; rbx, rcx, rdx, and rsi are the preserved registers in the string to int function. These registers are modified during string parsing so setting them as preserved allows for the caller’s values to be maintained. The program makes use of rax, rcx and rsi as the working registers. RAX is used for accumulating results, rcx for holding the current character and rsi for the input string pointer. 

; In the int_to_string function rcx, rdx, rdi, rsi and rbx are preserved as they are used in number-to-string conversion. The working registers include rax, rbx, rcx, rdx, rdi and rsi. Rax is used in division operations and returning the final length. Rbx holds the divisor, rcx is used as the character counter, rdc as the division remainder while rsi and rdi are used for string pointer manipulation.

; In the factorial function rb and rcx are preserved whereas rax and rcx are used as the working registers with rax being used for accumulation of the factorial result and rcx being used as the loop counter.

; The stack is mainly used for short-term value preservation allowing for critical values to be preserved across system calls. The value preservation pattern used is push rax and pop rdi, it is especially used to preserve across system calls. During output printing the pattern is used to preserve the factorial result. The stack is also used for multiple register preservation where registers are pushed in order at function start then popped in reverse order at function end.
