/* Input Parser
 * Parses the algorithm name, process descriptors, and round robin quantum from input.
 */

.section .text
.global skip_spc, atoi

/* Skip Leading Whitespace
 * Advances past any spaces or tabs before the algorithm name.
 */
skip_spc:
    movzb (%rsi), %eax
    test %eax, %eax
    jz parse_done
    cmp $32, %eax
    je inc_spc
    cmp $9, %eax
    je inc_spc
    jmp check_algo
inc_spc:
    inc %rsi
    jmp skip_spc

/* Identify Scheduling Algorithm
 * Checks the first characters of the token to determine the algorithm type.
 */
check_algo:
    cmpb $'F', (%rsi)
    jne chk_S
    cmpb $'C', 1(%rsi)
    jne chk_S
    movl $0, algo_type(%rip)
    add $4, %rsi
    jmp parse_tokens
chk_S:
    cmpb $'S', (%rsi)
    jne chk_P
    cmpb $'J', 1(%rsi)
    jne chk_SRTF
    movl $1, algo_type(%rip)
    add $3, %rsi
    jmp parse_tokens
chk_SRTF:
    movl $2, algo_type(%rip)
    add $4, %rsi
    jmp parse_tokens
chk_P:
    cmpb $'P', (%rsi)
    jne chk_R
    movl $3, algo_type(%rip)
    add $2, %rsi
    jmp parse_tokens
chk_R:
    movl $4, algo_type(%rip)
    add $2, %rsi
    jmp parse_tokens

/* Parse Process Tokens
 * Iterates over remaining input tokens, parsing process descriptors or the quantum.
 */
parse_tokens:
    movl $0, proc_count(%rip)
token_loop:
    movzb (%rsi), %eax
    test %eax, %eax
    jz parse_done
    cmp $10, %eax
    je parse_done
    cmp $13, %eax
    je parse_done
    cmp $32, %eax
    je skip_t_spc
    cmp $9, %eax
    je skip_t_spc

    cmpl $4, algo_type(%rip)
    jne parse_proc
    cmp $'0', %eax
    jl parse_proc
    cmp $'9', %eax
    jg parse_proc

    call atoi
    movl %eax, rr_quantum(%rip)
    jmp parse_done

skip_t_spc:
    inc %rsi
    jmp token_loop

/* Parse Single Process Descriptor
 * Reads ID, burst time, and optional arrival time and priority fields.
 */
parse_proc:
    movl proc_count(%rip), %ecx
    movzb (%rsi), %eax
    lea proc_id(%rip), %rdi
    movb %al, (%rdi, %rcx, 1)

    lea proc_order(%rip), %rdi
    movb %cl, (%rdi, %rcx, 1)
    
    inc %rsi
    inc %rsi

    push %rcx
    call atoi
    pop %rcx

    lea proc_burst(%rip), %rdi
    movl %eax, (%rdi, %rcx, 4)
    lea proc_rem(%rip), %rdi
    movl %eax, (%rdi, %rcx, 4)

    lea proc_arrival(%rip), %rdi
    movl $0, (%rdi, %rcx, 4)
    lea proc_prio(%rip), %rdi
    movl $0, (%rdi, %rcx, 4)

    movl algo_type(%rip), %edx
    cmp $1, %edx
    je proc_done
    cmp $4, %edx
    je proc_done

    inc %rsi
    push %rcx
    call atoi
    pop %rcx
    lea proc_arrival(%rip), %rdi
    movl %eax, (%rdi, %rcx, 4)

    cmpl $3, algo_type(%rip)
    jne proc_done

    inc %rsi
    push %rcx
    call atoi
    pop %rcx
    lea proc_prio(%rip), %rdi
    movl %eax, (%rdi, %rcx, 4)

/* Finalize Process Entry
 * Increments the process count if the burst time is nonzero.
 */
proc_done:
    lea proc_burst(%rip), %rdi
    movl (%rdi, %rcx, 4), %eax
    test %eax, %eax
    jz skip_inc

    incl proc_count(%rip)
skip_inc:
    jmp token_loop

/* Convert ASCII String To Integer
 * Reads consecutive digit characters from rsi and returns the value in eax.
 */
atoi:
    xor %eax, %eax
atoi_loop:
    movzb (%rsi), %ecx
    cmp $'0', %ecx
    jl atoi_end
    cmp $'9', %ecx
    jg atoi_end
    sub $'0', %ecx
    imul $10, %eax
    add %ecx, %eax
    inc %rsi
    jmp atoi_loop
atoi_end:
    ret
