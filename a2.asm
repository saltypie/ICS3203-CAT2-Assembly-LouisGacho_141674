section .data
    prompt_msg db "Enter 5 integers (press Enter after each):", 0xA
    prompt_len equ $ - prompt_msg
    output_fmt db "Reversed array: "
    output_len equ $ - output_fmt
    space db " "
    newline db 0xA
    array_size dq 5

section .bss
    array resq 5    ; Reserve space for 5 integers (8 bytes each)
    buffer resb 32  ; Buffer for input string

section .text
    global _start

_start:
    ; Print prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_msg
    mov rdx, prompt_len
    syscall

    ; Initialize array index
    xor r12, r12    ; Use r12 as persistent counter

input_loop:
    cmp r12, [array_size]
    jge reverse_array

    ; Read input
    mov rax, 0      ; sys_read
    mov rdi, 0      ; stdin
    mov rsi, buffer
    mov rdx, 32
    syscall

    ; Convert string to integer
    push r12        ; Save counter
    mov rsi, buffer ; Source string
    call string_to_int
    pop r12         ; Restore counter

    ; Store number in array
    mov [array + r12*8], rax  ; Store the converted number

    inc r12
    jmp input_loop

reverse_array:
    mov rsi, 0                ; the Front index
    mov rdi, [array_size]     
    dec rdi                   ; Back index

reverse_loop:
    cmp rsi, rdi
    jge print_result

    ; Calculate addresses and swap
    mov rax, [array + rsi*8]
    mov rbx, [array + rdi*8]
    mov [array + rsi*8], rbx
    mov [array + rdi*8], rax

    inc rsi
    dec rdi
    jmp reverse_loop

print_result:
    ; "Reversed array: "
    mov rax, 1
    mov rdi, 1
    mov rsi, output_fmt
    mov rdx, output_len
    syscall

    ; Initialize print counter
    xor r12, r12

print_loop:
    cmp r12, [array_size]
    jge exit_program

    ; converts current number to string
    mov rdi, [array + r12*8]
    push r12
    call int_to_string
    pop r12

    ; prints the number
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, buffer     ; string to print
    mov rdx, r13        ; length (set by int_to_string)
    syscall

    ; Prints space
    mov rax, r12
    inc rax
    cmp rax, [array_size]
    je skip_space

    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall

skip_space:
    inc r12
    jmp print_loop

exit_program:
    ; newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall

; Converts a string to integer Input: RSI points to string Output: RAX contains integer
string_to_int:
    push rbx
    push rcx
    push rdx
    push rsi    ; saves the original string pointer

    xor rax, rax    ; Initialize result
    xor rcx, rcx    ; Initialize current character
    xor rbx, rbx    ; Initialize digit

.next_char:
    mov cl, [rsi]   ; Get current character
    cmp cl, 0xA     ; Check for newline
    je .done
    cmp cl, 0x20    ; Check for space
    je .done
    cmp cl, 0       ; Check for null
    je .done

    sub cl, '0'     ; Convert ASCII to number
    imul rax, 10    ; Multiply current result by 10
    add rax, rcx    ; Add new digit

    inc rsi         ; Move to next character
    jmp .next_char

.done:
    pop rsi     ; Restore string pointer
    pop rdx
    pop rcx
    pop rbx
    ret

; Convert integer to string Input: RDI contains integer Output: Buffer contains string, R13 contains length
int_to_string:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi

    mov rax, rdi        ; number to convert
    mov rcx, 0          ; string length counter
    mov r13, 0          ; store final length
    add rcx, 31         ; points to end of buffer
    mov byte [buffer+rcx], 0  ; null termination

.divide_loop:
    dec rcx
    mov rbx, 10
    xor rdx, rdx
    div rbx
    add dl, '0'         ; convert remainder to ASCII
    mov [buffer+rcx], dl
    test rax, rax
    jnz .divide_loop

    ; calculate length
    mov r13, 31
    sub r13, rcx        ; Calculate length
    
    ; Move string to start of buffer
    mov rsi, buffer
    add rsi, rcx
    mov rdi, buffer
    mov rcx, r13
    cld
    rep movsb

    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret


; Once the input loop is completed the program enters the reverse_array label, the mov rsi, 0 instruction sets the front index to 0 and the back index is set to -1 (last element of the array) using the mov rdi, [array_size] instruction. The main loop in the reversal process is the reverse_loop label. Using the cmp rsi, rdi instruction the pogram checks whether the front index is greater than or equal to the back index, if it is greater than or equal to the back index the program jumps to the print_result label. In the loop the program calculates the address of the front and back elements using mov rax, [array+rsi*8] and mov rbx, [array + rdi*8]. A temporary register is used to swap the values. Once the swap is complete the program increments the front index using inc rsi and decrements the back index using dec rdi.

; Direct memory addressing is utilised in the program leading to challenges as memory addresses have to be carefully calculated in order to ensure the correct elements (in bound) are accessed. For example the following snippets are used to access the array elements using base plus indexing  [array + rsi*8] and  [array + rdi*8]. The array size also had to be hard-coded, making program dynamic such that it could work with different array sizes would lead to the program having to allocate memory dynamically for the array. The resb directive had to be used to ensure correct alignment. Assembly does not provide automatic bound checking so the program compares the indices with the array size. It was also necessary to make use of registers for temporary storage for swapping.