/* Round Robin Scheduler
 * Executes processes in cyclic order with a fixed time quantum and idle padding.
 */

.section .text
.global do_rr

/* Run Current Process Or Dequeue
 * Continues the running process within its quantum, or dequeues the next one.
 */
do_rr:
    cmpl $-1, running_proc(%rip)
    je rr_dequeue
    
    decl rr_quantum_left(%rip)
    movl running_proc(%rip), %eax
    lea proc_rem(%rip), %rdi
    movl (%rdi, %rax, 4), %edx
    test %edx, %edx
    jle rr_pad

    lea proc_id(%rip), %rsi
    movb (%rsi, %rax, 1), %cl
    decl (%rdi, %rax, 4)
    jmp rr_write

/* Pad Remaining Quantum With Idle
 * Outputs idle marker when the process finishes before its quantum expires.
 */
rr_pad:
    movb $'X', %cl

/* Write Round Robin Output
 * Appends the current character to output and checks if the quantum has expired.
 */
rr_write:
    lea output_buf(%rip), %rdi
    movl out_len(%rip), %r8d
    movb %cl, (%rdi, %r8, 1)
    incl out_len(%rip)
    incl current_time(%rip)

    cmpl $0, rr_quantum_left(%rip)
    jg rr_loop_end

    movl running_proc(%rip), %eax
    lea proc_rem(%rip), %rdi
    cmpl $0, (%rdi, %rax, 4)
    jle rr_no_enq

/* Re-enqueue Unfinished Process
 * Adds the process back to the end of the ready queue if it still has remaining time.
 */
    movl rr_tail(%rip), %edx
    lea rr_queue(%rip), %rsi
    movb %al, (%rsi, %rdx, 1)
    incl rr_tail(%rip)

rr_no_enq:
    movl $-1, running_proc(%rip)
rr_loop_end:
    jmp sim_loop

/* Dequeue Next Process
 * Takes the front process from the ready queue or outputs idle if the queue is empty.
 */
rr_dequeue:
    movl rr_head(%rip), %eax
    cmpl rr_tail(%rip), %eax
    jne rr_do_deq
    movb $'X', %cl
    lea output_buf(%rip), %rdi
    movl out_len(%rip), %r8d
    movb %cl, (%rdi, %r8, 1)
    incl out_len(%rip)
    incl current_time(%rip)
    jmp sim_loop

/* Start Dequeued Process
 * Sets the dequeued process as running and initializes its quantum counter.
 */
rr_do_deq:
    lea rr_queue(%rip), %rsi
    movzb (%rsi, %rax, 1), %edx
    movl %edx, running_proc(%rip)
    incl rr_head(%rip)
    movl rr_quantum(%rip), %edx
    movl %edx, rr_quantum_left(%rip)
    jmp do_rr
