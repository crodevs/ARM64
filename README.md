# An In-Depth Look at the ARM ISA

Carson Rohan

April 15, 2021

## 1 Usage

Download recurShape.S and the Makefile for the ARM64 version of the source code.
1. Enter 'make recurShape' in the terminal
2. Run the program with './recurShape <first_number> <second_number>'
3. This must be done on an ARM64 machine or a VM running an ARM64 machine

## 2 Introduction

With over 180 billion chips produced, ARM (Advanced RISC Machine) is the most widely used ISA in the world. ARM chips run inside many different kinds of machines, from light and portable devices like smartphones, tablets, and laptops, to high-powered desktop computers and servers. The ARM architecture even resides in the currently-leading supercomputer in teraflops per second (Cutress, 2020). Even the US tech giant Apple has recently dived head-first into adopting ARM and now presents some of its most popular products as containing their newest ARM-based M1 chip. Seeing as this RISC architecture has taken the world by storm, it is worthwhile to see how it holds up against another architecture and delve into what makes it so special. 
The MIPS ISA is another RISC architecture that is often studied in computer architecture university courses. It is relatively easy to understand and provides a good introductory language with which to begin learning assembly. It is not nearly as popular as ARM, but it does hold some similarities to ARM. 
Aspects of each architecture’s assembly language that will be compared include instructions, arithmetic and logical operations, branch implementations,  immediate value restrictions, procedure calls, stack usage, and strengths and weaknesses. A section of this dive into ARM includes implementations of the same program in MIPS and in ARM in order to compare how they operate on an assembly language level.
This experience was done by one developer with the help of a TSU CS faculty member over the course of a semester. The initial project idea, bug fixes, and general help can be attributed to Dr. Matthews. If ever I ran into issues, Matthews was there to
keep the project moving forward. Microsoft's Visual Studio Code was used as the primary development environment for this experience.

## 3 Hardware & Software
The development of this project was done on a Windows machine. Compilation was done using the Gnu Assembler. The program was compiled and executed on a 
Raspberry Pi 4B with a 1.5GHz quad-core ARM Cortex-A72 chip running a Debian-based 64-bit OS on the AArch64 Linux kernel. Code was transferred onto the Pi 
using VSCode's remote window extension. This utilizes the SSH protocol in order to edit a file in one environment, but be able to compile and execute that 
code in another.

## 4 ARM & MIPS

### 4.1 Registers
ARM has 32 64-bit registers. This means that there are  memory addresses reachable by data transfer instructions. Each register can be accessed in 64-bit mode 
or 32-bit mode depending on the name of the register. X registers utilize all 64 bits available in the architecture. W registers only have access to the first 
32 bits. For example, if register x0 contained the value 0xFFFFFFFFFFFFFFFF, the corresponding register, w0, would contain the value 0xFFFFFFFF. When a W 
register is written to, the upper 32 bits are cleared. In MIPS, there are 32 32-bit registers, which comes out to only  memory addresses reachable by data 
transfer instructions. A small but notable difference in register syntax is that in MIPS, registers must be preceded by a ‘$’ symbol. For example, for saved 
register 1, in MIPS it would look like $s1.

### 4.2 Data Transfer
ARMv8 uses byte addresses, so sequential doubleword addresses differ by 8. This means that if the programmer wished, for example, to access the next element 
of an array stored on the stack, the programmer would have to offset the register by 8. ARMv8 is considered to not have any alignment restrictions, meaning 
that the programmer does not have to align memory locations by a multiple of 8. However, while using stack accesses and instruction fetches, memory accesses 
must be aligned. MIPS also uses byte addresses, but sequential doubleword addresses differ by 4. MIPS does have an alignment restriction and requires that all 
words must start at addresses that are multiples of 4. Both languages contain different options for loading and storing values such as load and store word, load 
and store half, load and store byte. However, when it comes to storing 16-bit constants, ARMv8 has another option to store the 16-bits and leave the rest of the 
bits unchanged. Both MIPS and ARMv8 have the move psuedoinstruction, but MIPS only allows the programmer to use this instruction with registers, not constants. 

### 4.3 Arithmetic Operations
ARMv8 has many arithmetic operations including add, subtract, add immediate, subtract immediate, and add and subtract while setting certain flags. This allows 
the programmer to set condition codes which can come in handy when branching conditionally. MIPS has three arithmetic operations: add, subtract, and add 
immediate. There is no subtract immediate due to the fact that the programmer can simply place a negative constant in the arguments and get the same results 
as a subtract immediate instruction.

### 4.4 Logical Operations
MIPS has the basic logical operations including and, or, nor, and or immediate, and the left and right logical bit shifts. ARMv8 has all of the basic logical 
operations while boasting a few extra, including exclusive and inclusive or, and exclusive and inclusive or immediate. 

### 4.5 Branch Implementations
In ARMv8 assembly, a conditional branch can be performed using the pair of instructions cmp, b.condition. For example, if the programmer wanted to see if a 
register contained a value greater than another, she would call cmp followed by the two registers being compared. Then, b.gt or b.lt should be called. If gt 
is used, it will branch if the first register is greater than the second. If lt is used, it will branch if the first register is less than the first. For 
branching unconditionally, the programmer can branch to a PC-relative address, a register (procedure return), or branch with link to a PC-relative address 
(see section 3.6 Procedures). Internally, when the cmp instruction is called, flag bits are set in a flag register that describes whether the 

### 4.6 Procedure Calls
Both MIPS and ARMv8 assembly have similar procedure call instructions. In ARMv8, if the programmer wishes to call a procedure, he would load parameters into 
the argument registers x0-x7. Then he would save the return address in the link register and call bl (branch and link) then the name of the procedure he wants 
to branch to. To return from the procedure, the programmer should load any return values into registers x0-x7 then call ret (return). The ret instruction 
branches to register lr or the return address which is the instruction after the instruction that called the procedure. In MIPS, this is done similarly but 
with different instruction and register names. There is also no pseudoinstruction ret in MIPS which does the branch to return address automatically.

### 4.7 Stack Usage
In ARMv8, the stack pointer must be 16-byte aligned. In MIPS, the stack pointer must be 4-byte aligned. While MIPS requires the programmer to do arithmetic on 
the stack pointer before storing or loading then using offsets, ARMv8 allows storing or loading and arithmetic on the stack pointer in the same instruction. 
Instead of forcing the programmer to do the math beforehand, the stack pointer can be moved on the same line as the load or store. 

### 4.8 Syscalls
ARMv8, like MIPS assembly, uses syscalls to accomplish kernel-level tasks, such as writing and printing. However, MIPS has abstracted out the syscall process, 
only requiring the programmer to pass in arguments and a syscall number, without needing to worry about the size of the arguments passed in or buffers. In ARMv8,\
when the programmer wants to invoke a syscall, the entire sycall procedure must be considered. For example, if the programmer wishes to read input from the 
terminal, the read syscall must be invoked with a parameter specifying the file descriptor, a buffer of characters that will contain what will be read, and the 
length of that buffer. Finally, the syscall number must be passed into a certain register and a command to invoke the syscall must be written. Then, since the 
buffer contains ASCII characters, if the programmer wishes to read an integer, the ASCII value of 0 (or 48) must be subtracted from the character to convert it to 
an integer. All of this is done for you in MIPS, resulting in a much easier time reading values from the terminal. 

### 4.9 Strengths and Weaknesses
ARMv8 is a powerful assembly language. With 64-bit registers and many instructions, it can prove to be very useful on a chip running on a mobile device or 
even a supercomputer. ARMv8 has more support for uninitialized variables in the form of a segment separate from the text and data segments called the bss 
(block starting symbol) segment. While ARMv8 seems to be the superior language, MIPS also brings benefits to the table. MIPS tends to have easier-to-read 
instructions and less involved syntax. For example, reading an integer from the terminal in MIPS is as easy as putting the syscall number in a register then 
invoking the syscall, while in ARMv8 there are many more steps to be taken. This means MIPS is a better language for learning assembly language and other low-
level programming topics. 
MIPS does not seem to have much of a place in today’s hardware, but it is a powerful learning tool for beginners and experts alike. 

### 4.10 Program Implementations
See source code.


## 5 Experience
### 5.1 Communication
Being able to describe bugs and other issues through email should be considered an art, and reading said descriptions just the same. Every so often an issue 
would arise and I would try my best to memorize ARM assembly jargon in order to better explain my obstacles. It is important to keep descriptions of problems 
succinct and separate from other issues, so as to avoid confusion. This is something that I have had to remind myself of during the lifetime of development of 
this project.

### 5.2 Computer Science Coursework
Systems programming, computer architecture and organization, and embedded systems are all computer science courses at Truman that have helped me to complete 
this experience. In systems programming, I was introduced to hex, binary, and decimal conversions, low-level C programming, and the heap and stack structures 
within a program. Computer arch and org taught me how to program in assembly language, use registers, create space on the stack and store registers there, the 
difference between the .text and .data segments, and addressing. Embedded systems reinforced some of the previous learning points and strengthened my ability 
to understand and code assembly language. All of these experiences aided me in this project. For example, across all RISC architectures, the knowledge of 
registers and how they are used is imperative. If a procedure is called in assembly language, the correct registers must be saved, stored, or used as 
arguments, then, if stored, must be restored later. If the register is not restored, the programmer risks tearing out hairs trying to locate a bug that 
involves a register with a garbage value. Strong knowledge of how the stack and stack pointer work is a must. For example, a mis-aligned stack pointer can 
cause all sorts of mayhem when trying to store multiple registers or load a register from the stack. Bitwise, logical, and arithmetic operations all proved to 
be useful when it came to bit masking registers, comparing the values of registers, and adding to or subtracting from registers. Somewhere along the way, the 
idea of a Makefile was introduced and since then Makefiles have saved countless minutes of compiling, linking, and executing separately.
Two non-computer science courses I took which were useful for this project were logic and foundations of mathematics. Both taught me how to think critically 
regarding mathematical concepts and taught me how to perform the dreaded proof. In logic, the focus was on proving the equality or inequality of logical 
sentences using propositional logic and rules of inferences such as modus ponens, modus tollens, contraposition, biconditional, and more. Foundations forced 
me to prove basic mathematical truths, such as how two odd integers added together will always result in an even integer. The instructors of these courses 
provided me with the skills and knowledge to create accurate programs, and to think more critically about what sort of mathematical ideas are behind my code.

### 5.3 Takeaways
Throughout the development of this project, I had to search for and read through references that would assist me in learning how ARM works and what nuances 
are involved in its assembly language syntax. Some of these references were not necessarily an easy read and required some extra thought to decipher useful 
information out of them. Slogging through them has helped me to better interpret resources like man pages, GitHub pages, and other documentation. 
Because of the difference in syscall procedures in MIPS and ARMv8, I became familiar with how the Linux kernel handles syscalls and which syscalls are useful 
from a programmer’s standpoint. 
In the program, the stack had to be manipulated in order to save and restore registers. In doing this, I was able to have a better understanding of the stack 
while programs are executing and how minor mistakes can derail the stack pointer and produce garbage values. 
In the beginning of this project, my Pi machine was running a Debian-based operating system called Raspbian. This is the OS that was built for use with the 
Pi, with pre-installed tools and games to help foster familiarity with the machine. This standard OS runs with 32-bit operations. In the early stages of this 
project, I was having trouble compiling the ARMv8 language which supports 64-bit registers. Compiling resulted in many errors, most of them containing the 
verbiage “unknown instruction on line [line number]”. While this seems obvious now, what I did not know at the time was that the 32-bit version of Raspbian 
was limiting the Cortex-A72 chip, which supports 64-bit operations, to running in 32-bit mode instead. Thus, ARMv8 assembly could not be compiled and run. The 
way I solved this problem was to find an experimental, 64-bit version of Rasbpian and load that OS onto my Pi which allowed me to compile and run ARMv8 
assembly programs. Another minor issue involved restored registers not containing the values they were expected to have. This ended up being an issue with the 
stack pointer and its need to be 16-byte aligned. If the stack pointer is not 16-byte aligned, whatever values stored on the stack may not be restored in the 
same order or at all. To ensure the stack is 16-byte aligned, the programmer must subtract 16 from the stack pointer before storing a register and must add 16 
to the stack pointer after loading a value to a register from the stack.  
This capstone experience required the knowledge of many computer architecture topics. One such topic that I would have benefitted from being more familiar 
with includes binary arithmetic. While I understand the basics, being able to quickly calculate what values registers might hold would have cut down on 
development and debugging time. 
This capstone experience provided knowledge in computer architecture, assembly language, and more specifically, the ARM ISA. Developing the program did not go 
without a few hiccups, but overall the amount of work and the final product was as expected. These learning outcomes will be useful in future endeavors and 
have made me a more well-rounded programmer. 

## 6 References
References
(n.d.). Retrieved from https://developer.arm.com/documentation/ddi0596/2020-12/SIMD-FP-Instructions/STR--immediate--SIMD-FP---Store-SIMD-FP-register--immediate-offset--?lang=en

'Hello World' in ARM64 Assembly. (n.d.). Retrieved from https://peterdn.com/post/2020/08/22/hello-world-in-arm64-assembly/

Cutress, D. I. (2020, June 22). New #1 Supercomputer: Fugaku in Japan, with A64FX, take Arm to the Top with 415 PetaFLOPs. Retrieved from https://www.anandtech.com/show/15869/new-1-supercomputer-fujitsus-fugaku-and-a64fx-take-arm-to-the-top-with-415-petaflops

Ibáñez, R. F. (2013, January 09). ARM assembler in Raspberry Pi – Chapter 1. Retrieved from https://thinkingeek.com/2013/01/09/arm-assembler-raspberry-pi-chapter-1/

Patterson, D. A., & Hennessy, J. L. (2018). Computer organization and design: The hardware/software interface. Morgan Kaufmann , an imprint of Elsevier.

Torvalds. (2018, March 09). Torvalds/linux. Retrieved from https://github.com/torvalds/linux/blob/v4.17/include/uapi/asm-generic/unistd.h
