/* Priority First Scheduler
 * Preemptively selects the arrived process with the lowest priority number each cycle.
 */

.section .text
.global do_pf

/* Find Highest Priority Process
 * Compares priority first, then remaining time, then input order to break ties.
 */
do_pf:
    movl $-1, %r9d
    movl $0x7FFFFFFF, %r10d
    movl $0x7FFFFFFF, %r12d
    movl $0xFF, %r11d
    movl proc_count(%rip), %ecx
    movl $0, %eax
pf_loop:
    cmp %ecx, %eax
    jge pf_end
    lea proc_rem(%rip), %rdi
    movl (%rdi, %rax, 4), %r13d
    test %r13d, %r13d
    jle pf_next
    lea proc_arrival(%rip), %rdi
    movl (%rdi, %rax, 4), %esi
    cmpl current_time(%rip), %esi
    jg pf_next

    lea proc_prio(%rip), %rdi
    movl (%rdi, %rax, 4), %edx

    cmp %r10d, %edx
    jl pf_set
    jg pf_next
    
    cmp %r12d, %r13d
    jl pf_set
    jg pf_next

    lea proc_order(%rip), %rsi
    movzb (%rsi, %rax, 1), %r8d
    cmp %r11d, %r8d
    jge pf_next
pf_set:
    movl %eax, %r9d
    movl %edx, %r10d
    movl %r13d, %r12d
    lea proc_order(%rip), %rsi
    movzb (%rsi, %rax, 1), %r11d
pf_next:
    inc %eax
    jmp pf_loop
pf_end:
    movl %r9d, running_proc(%rip)
    jmp exec_proc
