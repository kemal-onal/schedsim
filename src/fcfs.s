/* First Come First Serve Scheduler
 * Selects the earliest arrived process and runs it to completion without preemption.
 */

.section .text
.global do_fcfs

/* Continue Or Find Next Process
 * Keeps running the current process if it has remaining time, otherwise searches for a new one.
 */
do_fcfs:
    cmpl $-1, running_proc(%rip)
    je fcfs_find
    movl running_proc(%rip), %eax
    lea proc_rem(%rip), %rdi
    cmpl $0, (%rdi, %rax, 4)
    jg exec_proc
    movl $-1, running_proc(%rip)

/* Find Next FCFS Process
 * Picks the arrived process with the earliest arrival time, breaking ties by input order.
 */
fcfs_find:
    movl $-1, %r9d
    movl $0x7FFFFFFF, %r10d
    movl $0xFF, %r11d
    movl proc_count(%rip), %ecx
    movl $0, %eax
fcfs_loop:
    cmp %ecx, %eax
    jge fcfs_end
    lea proc_rem(%rip), %rdi
    cmpl $0, (%rdi, %rax, 4)
    jle fcfs_next
    lea proc_arrival(%rip), %rdi
    movl (%rdi, %rax, 4), %edx
    cmpl current_time(%rip), %edx
    jg fcfs_next
    
    cmp %r10d, %edx
    jl fcfs_set
    jg fcfs_next
    lea proc_order(%rip), %rsi
    movzb (%rsi, %rax, 1), %r8d
    cmp %r11d, %r8d
    jge fcfs_next
fcfs_set:
    movl %eax, %r9d
    movl %edx, %r10d
    lea proc_order(%rip), %rsi
    movzb (%rsi, %rax, 1), %r11d
fcfs_next:
    inc %eax
    jmp fcfs_loop
fcfs_end:
    movl %r9d, running_proc(%rip)
    jmp exec_proc
