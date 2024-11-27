# Assembly Project
This project is licensed under the MIT license
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Introduction

This is an x86_64 assembly project, it consists of four different programs(tasks) labelled a1 through to a4.
The instructions provided below were carried out on a linux system.

## Getting Started

### Environment and Repository Setup
To set up the repository on your device navigate to the directory in which you would like to clone your project, For example:
     
     C::\Users\user1\Projects

Clone the project into the directory.
     
     git clone https://github.com/saltypie/ICS3203-CAT2-Assembly-LouisGacho_141674.git

Move to the project directory.

      cd ICS3203-CAT2-Assembly-LouisGacho_141674 


## Question and Task Naming
There are four tasks in the projects, the questions and their corresponding tasks and assembly files were named as shown in the table below.

| **Question** | **Task Name** | **Assembly File** |
|--------------|---------------|-------------------|
| Question 1   | a1            | a1.asm            |
| Question 2   | a2            | a2.asm            |
| Question 3   | a3            | a3.asm            |
| Question 4   | a4            | a4.asm            |

## Running the Programs
Ensure you have gdb and nasm installed. 

      nasm -v
      gdb --version

To compile a program use the following command. Replace <task_name> with the name of the task (See the table attached above on the questions and corresponding task name) 
      
      nasm -f elf64 -o <task_name>.o <task_name>.asm  
      ld -o <task_name> <task_name>.o -lc --dynamic-linker=/lib64/ld-linux-x86-64.so.2

To run a program use the command.

      ./<program-name>

Change program-name to a1, a2, a3 or a4 depending on the desired task.


## Task Documentation

### 1. Control Flow and Conditional Logic


The jump on not zero instruction is used to maintain the loop on condition that the counter has not reached zero it affects the flow by changing control of flow to the start of the loop while the loop is in range.

The jump on equal case was used because the comparison of rax and 0 causes the zero flag to be set to 1 when rax stores a zero. It shifts control of the flow to the zero_case label only when the value in rax is zero.

The jump on equal instruction is also used to shift the flow to the done_convert label when comparing with the newline character 0xa.

The JNE instruction is used to compare whether the first character is equal to ‘-’ or not. If the first character is not equal the control of the flow is moved to the convert loop. If the first character is - then the register r9 is set to -1.

The jump on equal instruction was used in order to check for the newline it shifts the flow to the done_convert label after comparing with the newline character 0xa.

The jump on less than was chosen because after comparing with zero as it would set the status register such that the status flag is not equal to the overflow flag when the value in rax is negative. The jump on less than command shifts the control of the flow to the negative_case label, this occurs if the number is less than 0.

An unconditional jump was used so that the result is always printed immediately after the negative case. It shifts control of the program flow to the print_result label responsible for printing the results. 

### 2. Array Manipulation with Looping and Reversal 

Once the input loop is completed the program enters the reverse_array label, the mov rsi, 0 instruction sets the front index to 0 and the back index is set to -1 (last element of the array) using the mov rdi, [array_size] instruction. The main loop in the reversal process is the reverse_loop label. Using the cmp rsi, rdi instruction the pogram checks whether the front index is greater than or equal to the back index, if it is greater than or equal to the back index the program jumps to the print_result label. In the loop the program calculates the address of the front and back elements using mov rax, [array+rsi*8] and mov rbx, [array + rdi*8]. A temporary register is used to swap the values. Once the swap is complete the program increments the front index using inc rsi and decrements the back index using dec rdi.

Direct memory addressing is utilised in the program leading to challenges as memory addresses have to be carefully calculated in order to ensure the correct elements (in bound) are accessed. For example the following snippets are used to access the array elements using base plus indexing  [array + rsi*8] and  [array + rdi*8]. The array size also had to be hard-coded, making program dynamic such that it could work with different array sizes would lead to the program having to allocate memory dynamically for the array. The resb directive had to be used to ensure correct alignment. Assembly does not provide automatic bound checking so the program compares the indices with the array size. It was also necessary to make use of registers for temporary storage for swapping.

### 3. Modular Program with Subroutines for Factorial Calculation 

rbx, rcx, rdx, and rsi are the preserved registers in the string to int function. These registers are modified during string parsing so setting them as preserved allows for the caller’s values to be maintained. The program makes use of rax, rcx and rsi as the working registers. RAX is used for accumulating results, rcx for holding the current character and rsi for the input string pointer. 

In the int_to_string function rcx, rdx, rdi, rsi and rbx are preserved as they are used in number-to-string conversion. The working registers include rax, rbx, rcx, rdx, rdi and rsi. Rax is used in division operations and returning the final length. Rbx holds the divisor, rcx is used as the character counter, rdc as the division remainder while rsi and rdi are used for string pointer manipulation.

In the factorial function rb and rcx are preserved whereas rax and rcx are used as the working registers with rax being used for accumulation of the factorial result and rcx being used as the loop counter.

The stack is mainly used for short-term value preservation allowing for critical values to be preserved across system calls. The value preservation pattern used is push rax and pop rdi, it is especially used to preserve across system calls. During output printing the pattern is used to preserve the factorial result. The stack is also used for multiple register preservation where registers are pushed in order at function start then popped in reverse order at function end.


### 4. Data Monitoring and Control Using Port-Based Simulation 

The sensor input is loaded into the rax register. The value in rax is compared with the upper threshold if the level is greater then the program jumps to the high_level_alarm label under which the alarm is set off. The program compares the low threshold with the value in rax if the value in rax is lower than the minimum threshold of 20 the program jumps to the low_level_motor where the motor is switched on. Otherwise the program calls the normal_level function.

The control register is used in the program. When the least significant bit is 0 the motor is off and when it is 1 the motor is on. Bit 1 on the control register is manipulated such that it is set to 1 when the water level is high in turn switching the alarm on, it is also set to 0 when the water level is low. Bit manipulation is carried out on the registers to clear the motor bits in the case of high water levels whereas the alarm bit is cleared out when water levels are low. rax, ~2 clears the alarm bit whereas rax, ~1 clears the motor bit.

 
