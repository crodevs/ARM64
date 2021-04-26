    # Carson Rohan
    # Recursively printing a shape
    # Nov 1, 2019
    # Dr. Matthews
    # CS 330

    # Set aside memory for the prompts and asterisk
    # in data segment

	  .data
prompt:   .asciiz "Enter lengths of first and last lines: "
asterisk: .asciiz "*"
newline:  .asciiz "\n"

      .align 2

      # Instructions
      .text

      # first is associated with $s0
      # last is associated with $s1
      # length is associated with $s2

main:
      # Save $ra to stack
      addi $sp, $sp, -4
      sw $ra, 0($sp)

      # Prompt for first and last and store them
      la $a0, prompt # $a0 = address associated with prompt
      li $v0, 4 # $v0 = 4 (print_string)
      syscall

      # Read first from console, store in $s0
      li $v0, 5 # $v0 = 5 (read_string)
      syscall
      move $s0, $v0 # $s0 = first

      # Read last from console, store in $s1
      li $v0, 5
      syscall
      move $s1, $v0 # $s1 = last

      # Store first and last in parameter registers $a0 and $a1
      move $a0, $s0 # $a0 = first
      move $a1, $s1 # $a1 = last

      # Call print_shape(int first, int last)
      jal print_shape

      # After we've let print_shape do its thing, we can restore $ra
      lw $ra, 0($sp)
      addi $sp, $sp, 4
      jr $ra

      # --------------------
      # print_shape
      # --------------------

print_shape:
      # adjust stack to save $ra and $s0 .. $s1
      addi $sp, $sp, -12
      sw $ra, 8($sp)
      sw $s0, 4($sp)
      sw $s1, 0($sp)

      # body of print_shape()

      # if (first == last)
      # branch on first != last
      bne $a0, $a1, if_done1

      # Base case, print a line with "*" determined by first
      # first is already located in $a0
      jal print_asterisks
      j print_shape_done

if_done1:
      # Recurse:

      # Print first *'s
      jal print_asterisks

      # Recursively print shape:
      # print_shape (first + 1, last);
      move $s0, $a0
      addi $a0, $a0, 1  # $a0 = first + 1

      move $s1, $a1 # saves last
      jal print_shape

      move $a1, $s1

      # Print first *'s again
      move $a0, $s0 # $a0 = first
      jal print_asterisks

print_shape_done:
      # Restore registers
      lw $ra, 8($sp)
      lw $s0, 4($sp)
      lw $s1, 0($sp)
      addi $sp, $sp, 12
      jr $ra

      # --------------------
      # print_asterisks
      # --------------------

print_asterisks:
      # adjust stack to save $a0
      addi $sp, $sp, -8
      sw $s2, 4($sp)
      sw $a0, 0($sp)

      # i is associated with $s2
      li $s2, 0

      # save $a0 in $t0
      move $t0, $a0

      # Begin for loop
for:
      # i < length
      # branch on i >= length
      bge $s2, $t0, for_exit


      # Print asterisk
      la $a0, asterisk  # $a0 = address associated with asterisk
      li $v0, 4 # $v0 = 4 (print_string)
      syscall

      addi $s2, $s2, 1

      j for

for_exit:
      # Print newline
      la $a0, newline  # $a2 = address associated with newline
      li $v0, 4 # $v0 = 4 (print_string)
      syscall

      # Load $a0 back in
      lw $a0, 0($sp)
      lw $s2, 4($sp)
      addi $sp, $sp 8

      jr $ra


