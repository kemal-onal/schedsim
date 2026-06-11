/* Program Entry Point And Simulation Loop
 * Reads input, initializes state, runs the scheduling simulation, and writes output.
 */

.section .text
.global _start
.global parse_done, sim_loop, exec_proc

/* Read Input From Stdin
 * Reads up to 4096 bytes from standard input and hands off to the parser.
 */
_start:
    mov $0, %rax
    mov $0, %rdi
    lea input_buf(%rip), %rsi
    mov $4096, %rdx
    syscall

    lea input_buf(%rip), %rsi
    jmp skip_spc

/* Initialize Simulation State
 * Resets time and output counters, then sets up the round robin queue if needed.
 */
parse_done:
    movl $0, current_time(%rip)
    movl $0, out_len(%rip)
    movl $-1, running_proc(%rip)

    cmpl $4, algo_type(%rip)
    jne sim_loop
    movl proc_count(%rip), %ecx
    movl $0, %eax
init_rr_q:
    cmp %ecx, %eax
    jge rr_q_done
    lea rr_queue(%rip), %rdi
    movb %al, (%rdi, %rax, 1)
    inc %eax
    jmp init_rr_q
rr_q_done:
    movl $0, rr_head(%rip)
    movl %ecx, rr_tail(%rip)

/* Check If All Processes Are Done
 * Scans remaining times and exits when every process has completed.
 */
sim_loop:
    movl proc_count(%rip), %ecx
    movl $0, %eax
    movl $1, %r8d
check_all_loop:
    cmp %ecx, %eax
    jge check_all_done
    lea proc_rem(%rip), %rdi
    movl (%rdi, %rax, 4), %edx
    test %edx, %edx
    jz check_next
    movl $0, %r8d
check_next:
    inc %eax
    jmp check_all_loop
check_all_done:
    test %r8d, %r8d
    jz sim_continue
    
    cmpl $4, algo_type(%rip)
    jne sim_exit
    cmpl $-1, running_proc(%rip)
    jne sim_continue

/* Write Output And Exit
 * Appends a newline to the output buffer, writes to stdout, and terminates.
 */
sim_exit:
    mov $1, %rax
    mov $1, %rdi
    lea output_buf(%rip), %rsi
    mov out_len(%rip), %edx
    movb $10, (%rsi, %rdx, 1)
    inc %edx
    syscall

    mov $60, %rax
    xor %rdi, %rdi
    syscall

/* Dispatch To Scheduling Algorithm
 * Jumps to the handler matching the parsed algorithm type.
 */
sim_continue:
    movl algo_type(%rip), %eax
    cmp $0, %eax
    je do_fcfs
    cmp $1, %eax
    je do_sjf
    cmp $2, %eax
    je do_srtf
    cmp $3, %eax
    je do_pf
    cmp $4, %eax
    je do_rr
    jmp sim_exit

/* Execute Selected Process For One Cycle
 * Writes the process ID or idle marker to output and advances the clock.
 */
exec_proc:
    movl running_proc(%rip), %eax
    cmpl $-1, %eax
    jne exec_valid
    movb $'X', %cl
    jmp exec_write
exec_valid:
    lea proc_id(%rip), %rdi
    movb (%rdi, %rax, 1), %cl
    lea proc_rem(%rip), %rdi
    decl (%rdi, %rax, 4)
exec_write:
    lea output_buf(%rip), %rdi
    movl out_len(%rip), %edx
    movb %cl, (%rdi, %rdx, 1)
    incl out_len(%rip)
    incl current_time(%rip)
    jmp sim_loop
