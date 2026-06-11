/* Shortest Job First Scheduler
 * Selects the process with the shortest burst time and runs it to completion.
 */

.section .text
.global do_sjf

/* Continue Or Find Next Process
 * Keeps running the current process if it has remaining time, otherwise searches for a new one.
 */
do_sjf:
    cmpl $-1, running_proc(%rip)
    je sjf_find
    movl running_proc(%rip), %eax
    lea proc_rem(%rip), %rdi
    cmpl $0, (%rdi, %rax, 4)
    jg exec_proc
    movl $-1, running_proc(%rip)

/* Find Next SJF Process
 * Picks the process with the shortest burst time, breaking ties by input order.
 */
sjf_find:
    movl $-1, %r9d
    movl $0x7FFFFFFF, %r10d
    movl $0xFF, %r11d
    movl proc_count(%rip), %ecx
    movl $0, %eax
sjf_loop:
    cmp %ecx, %eax
    jge sjf_end
    lea proc_rem(%rip), %rdi
    cmpl $0, (%rdi, %rax, 4)
    jle sjf_next
    lea proc_burst(%rip), %rdi
    movl (%rdi, %rax, 4), %edx
    
    cmp %r10d, %edx
    jl sjf_set
    jg sjf_next
    lea proc_order(%rip), %rsi
    movzb (%rsi, %rax, 1), %r8d
    cmp %r11d, %r8d
    jge sjf_next
sjf_set:
    movl %eax, %r9d
    movl %edx, %r10d
    lea proc_order(%rip), %rsi
    movzb (%rsi, %rax, 1), %r11d
sjf_next:
    inc %eax
    jmp sjf_loop
sjf_end:
    movl %r9d, running_proc(%rip)
    jmp exec_proc
