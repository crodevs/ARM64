/**
 * @author Carson Rohan
 * @version 4-14-2021
 *
 * File: recurShape.S
 * Recursively prints a shape based on two integer inputs 1-9 from the user
 */

 /**
  * Data segment:
  * Set aside memory for the prompt, newline, and asterisk
  * in data segment and determine their lengths
  */
.data
        prompt: .ascii "Enter lengths of the first and last lines separated by a space (1-9): "
        pLen = . - prompt
        asterisk: .ascii "*"
        aLen = . - asterisk
        newline: .ascii "\n"
        nLen = . - newline

/**
 * Block Starting Symbol segment:
 * Storage for uninitialized statically allocated variables
 */
.bss
        first: .space 16
        last: .space 16

/**
 * Text segment:
 * Instructions
 */
.text
.globl _start

_start:
        /**
         * Save lr (link register/return address) to stack.  
         * Stack pointer must be 16-byte aligned (multiple of 16 bytes).
         * Subtract 16 bytes from stack pointer, save lr
         */
        str lr, [sp, -16]!

        /**
         * Prompt for first and last and store them.
         * syscall: write(int fd, const void *buf, size_t count) 
         */
        mov x0, 1               /* fd = STDOUT_FILENO */
        ldr x1, =prompt         /* buf = prompt */
        ldr x2, =pLen           /* count = len */
        mov x8, 64              /* write is syscall 64 */
        svc 0                   /* invoke syscall */

        /* read first num from console */
        mov x0, 1               /* STDIN */
        ldr x1, =first          /* first = memory location of our input */
        mov x2, 2               /* read in 2 bytes (number and space char) */
        mov x8, 63              /* read is syscall 63 */
        svc 0

        /* convert ascii digit to number */
        ldr x6, =first
        ldr x4, [x6]
        and x4, x4, 0xff        /* mask higher byte */
        sub x4, x4, 48          /* subtract 48 (ascii 0) */
        mov x19, x4

        /* read last num from console */
        mov x0, 1
        ldr x1, =last
        mov x2, 2
        mov x8, 63
        svc 0

        /* convert ascii digit to number */
        ldr x6, =last
        ldr x4, [x6]
        and x4, x4, 0xff
        sub x4, x4, 48
        mov x20, x4

        /* save first and last in x0 and x1 */
        mov x0, x19
        mov x1, x20

        /* call print_shape(int first, int last) */
        bl print_shape

        /* pop link register, add 16 to stack pointer */
        ldr lr, [sp], 16

        /* syscall exit(int status) */
        mov x8, 93              /* exit is syscall 1 */
        svc 0                   

        /* Gracefully Exit */
    

        /*--------------------- 
         * print_shape
         *---------------------
         */

print_shape:
        /* save link register and x19, x20 */
        str lr, [sp, -16]!      /* push lr */
        str x19, [sp, -16]!     /* push x19 */
        str x20, [sp, -16]!     /* push x20 */

        /* if(first == last) */
        /* branch on first != last */
        cmp x0, x1
        bne else

        /* base case, print a line with "*" determined by first */
        /* first is already located in x0 */
        bl print_asterisks
        b done

else:
        /* recurse */
        /* print first *'s */
        bl print_asterisks

        /* recursively print shape: */
        /* print_shape (first + 1, last); */
        mov x19, x0
        add x0, x0, 1           /* x0 = first + 1 */

        mov x20, x1             /* saves last */
        bl print_shape

        mov x1, x20             /* x1 = last */

        /* print first *'s again */
        mov x0, x19             /* x0 = first */
        bl print_asterisks

done:
        /* restore registers */
        ldr x20, [sp], 16       /* pop x20 */
        ldr x19, [sp], 16       /* pop x19 */
        ldr lr, [sp], 16        /* pop lr */
        ret

        /*--------------------- 
         * print_asterisks
         *---------------------
         */

print_asterisks:
        /* adjust stack to save x21, x0, and x1 */
        str x21, [sp, -16]!
        str x0, [sp, -16]!
        str x1, [sp, -16]!

        /* i is associated with x21 */
        mov x21, xzr

        /* save x0 in x9 */
        mov x9, x0

        /* begin for loop */
for:
        /* i < length */
        /* branch on i >= length */
        cmp x21, x9
        bge for_break

        /* print asterisk */
        mov x0, 1
        ldr x1, =asterisk
        ldr x2, =aLen
        mov x8, 64
        svc 0

        add x21, x21, 1
        b for

for_break:
        /* print newline */
        mov x0, 1
        ldr x1, =newline
        ldr x2, =nLen
        mov x8, 64
        svc 0

        ldr x1, [sp], 16        /* pop x1 */
        ldr x0, [sp], 16        /* pop x0 */
        ldr x21, [sp], 16       /* pop x21 */
        ret                      
