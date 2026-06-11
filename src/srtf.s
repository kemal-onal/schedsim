/* Shortest Remaining Time First Scheduler
 * Preemptively selects the arrived process with the shortest remaining time each cycle.
 */

.section .text
.global do_srtf

/* Find Shortest Remaining Process
 * Iterates all arrived processes and picks the one with the least remaining time.
 */
do_srtf:
    movl $-1, %r9d
    movl $0x7FFFFFFF, %r10d
    movl $0xFF, %r11d
    movl proc_count(%rip), %ecx
    movl $0, %eax
srtf_loop:
    cmp %ecx, %eax
    jge srtf_end
    lea proc_rem(%rip), %rdi
    movl (%rdi, %rax, 4), %edx
    test %edx, %edx
    jle srtf_next
    lea proc_arrival(%rip), %rdi
    movl (%rdi, %rax, 4), %esi
    cmpl current_time(%rip), %esi
    jg srtf_next

    cmp %r10d, %edx
    jl srtf_set
    jg srtf_next
    lea proc_order(%rip), %rsi
    movzb (%rsi, %rax, 1), %r8d
    cmp %r11d, %r8d
    jge srtf_next
srtf_set:
    movl %eax, %r9d
    movl %edx, %r10d
    lea proc_order(%rip), %rsi
    movzb (%rsi, %rax, 1), %r11d
srtf_next:
    inc %eax
    jmp srtf_loop
srtf_end:
    movl %r9d, running_proc(%rip)
    jmp exec_proc
