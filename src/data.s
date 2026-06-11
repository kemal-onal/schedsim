/* Shared Data Section
 * Defines all global variables used across the program modules.
 */

.section .bss

.global input_buf, output_buf
.global proc_id, proc_order, proc_burst, proc_arrival, proc_rem, proc_prio
.global proc_count, algo_type, rr_quantum, out_len, current_time, running_proc
.global rr_queue, rr_head, rr_tail, rr_quantum_left

/* Input And Output Buffers
 * Holds the raw input line and the generated output timeline.
 */
input_buf:      .space 4096
output_buf:     .space 4096

/* Process Attribute Arrays
 * Stores ID, input order, burst, arrival, remaining time, and priority per process.
 */
proc_id:        .space 16
proc_order:     .space 16
proc_burst:     .space 64
proc_arrival:   .space 64
proc_rem:       .space 64
proc_prio:      .space 64

/* Simulation State Variables
 * Tracks process count, algorithm type, output length, time, and running process.
 */
proc_count:     .space 4
algo_type:      .space 4
rr_quantum:     .space 4
out_len:        .space 4
current_time:   .space 4
running_proc:   .space 4

/* Round Robin Queue State
 * Linear queue buffer with head and tail indices and remaining quantum counter.
 */
rr_queue:       .space 4096
rr_head:        .space 4
rr_tail:        .space 4
rr_quantum_left:.space 4
