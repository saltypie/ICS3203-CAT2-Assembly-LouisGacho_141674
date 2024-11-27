section .data
    ; system status messages
    prompt_msg db "Water Control System Simulation", 10
               db "Enter water level (0-100): "
    prompt_len equ $ - prompt_msg
    
    motor_on_msg db "STATUS: Motor running - Tank filling", 10
    motor_on_len equ $ - motor_on_msg
    
    motor_off_msg db "STATUS: Motor stopped - Level OK", 10
    motor_off_len equ $ - motor_off_msg
    
    alarm_msg db "WARNING: Water level critical! Alarm activated!", 10
    alarm_len equ $ - alarm_msg
    
    ; Parameters
    LOW_THRESHOLD equ 20     ; motor starts if level is below this
    HIGH_THRESHOLD equ 80    ; Alarm is on when the level is above this

section .bss
    water_level resq 1       ; simulated sensor input
    control_register resq 1  ; Bit 0: Motor, Bit 1: Alarm
    input_buffer resb 16     ; buffer for input

section .text
    global _start

_start:
    ; Initialize the control register with 0 (all are off)
    mov qword [control_register], 0

control_loop:
    ; display prompt
    mov rax, 1              
    mov rdi, 1              ; stdout
    mov rsi, prompt_msg
    mov rdx, prompt_len
    syscall
    
    ; input sys_read
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    mov rsi, input_buffer
    mov rdx, 16
    syscall
    
    ; converts an ASCII input to number
    call ascii_to_int
    mov [water_level], rax
    
    ; load water level into register so that we can use it for comparison
    mov rax, [water_level]
    
    ; checks incase of critical levels
    cmp rax, HIGH_THRESHOLD
    jg high_level_alarm
    
    ; check for low level
    cmp rax, LOW_THRESHOLD
    jl low_level_motor
    
    ; normal range
    call normal_level
    jmp control_loop

high_level_alarm:
    ; Set alarm bit (bit 1) and clear motor bit (bit 0)
    mov rax, [control_register]
    or rax, 2               ; alarm bit set
    and rax, ~1            ; clear motor bit
    mov [control_register], rax
    
    ; alarm message
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, alarm_msg
    mov rdx, alarm_len
    syscall
    jmp control_loop

low_level_motor:
    ; Set motor bit (bit 0) and clear alarm bit (1)
    mov rax, [control_register]
    or rax, 1               ; Set motor bit
    and rax, ~2            ; Clear alarm bit
    mov [control_register], rax
    
    ; when motor is running
    mov rax, 1              
    mov rdi, 1              
    mov rsi, motor_on_msg
    mov rdx, motor_on_len
    syscall
    jmp control_loop

normal_level:

    mov rax, [control_register]
    and rax, ~3            ; clears both motor and alarm bits
    mov [control_register], rax
    
    ; displays normal operation message
    mov rax, 1              
    mov rdi, 1              
    mov rsi, motor_off_msg
    mov rdx, motor_off_len
    syscall
    ret

ascii_to_int:
    ; Convert ASCII string in input_buffer to integer in RAX
    xor rax, rax            ; Clear RAX
    mov rcx, 10             ; multiplier for decimal
    mov rsi, input_buffer   ; source 
    
.next_digit:
    movzx rdx, byte [rsi]   ; get the next character
    cmp dl, 10              ; check for newline
    je .done
    cmp dl, '0'             ; check if it is a digit
    jl .done
    cmp dl, '9'
    jg .done
    
    sub dl, '0'             ; converts  ASCII to number
    imul rax, rcx           ; multiply value by 10
    add rax, rdx            ; add digit
    
    inc rsi                 ; move to next character
    jmp .next_digit
    
.done:
    ret

exit:
    mov rax, 60             ; sys_exit
    xor rdi, rdi            ; status = 0
    syscall



; The sensor input is loaded into the rax register. The value in rax is compared with the upper threshold if the level is greater then the program jumps to the high_level_alarm label under which the alarm is set off. The program compares the low threshold with the value in rax if the value in rax is lower than the minimum threshold of 20 the prigram jumps to the low_level_motor where the motor is switched on. Otherwise the program calls the normal_level function.

; The control register is used in the program. When the least significant bit is 0 the motor is off and when it is 1 the motor is on. Bit 1 on the control register is manipulated such that it is set to 1 when the water level is high in turn switching the alarm on, it is also set to 0 when the water level is low. Bit manipulation is carried out on the registers to clear the motor bits in the case of high water levels whereas the alarm bit is cleared out when water levels are low. rax, ~2 clears the alarm bit whereas rax, ~1 clears the motor bit.
