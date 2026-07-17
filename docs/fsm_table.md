PICO-TINO FSM and Control Table
1. FSM States

PICO-TINO uses seven states:

State	Encoding	Purpose
RESET	3'b000	Initialize control flow
FETCH	3'b001	Fetch instruction and increment PC
DECODE	3'b010	Decode instruction
EXECUTE	3'b011	Perform ALU operation or jump
MEMORY	3'b100	Perform data-memory access
WRITEBACK	3'b101	Write result into Register File
HALT	3'b110	Stop processor execution

3'b111 is unused and must recover to RESET or HALT.

2. Control Signals
Signal	Width	Purpose
pc_inc	1	Increment Program Counter
pc_load	1	Load jump address into Program Counter
ir_write	1	Capture instruction-memory data
alu_out_write	1	Capture ALU result
alu_op	2	Select ADD, SUB, AND or OR
reg_write	1	Write Register File
wb_sel	2	Select writeback source
dmem_we	1	Write external data memory
halted	1	Indicate processor halt
3. ALU-operation Encoding
alu_op	Operation
2'b00	ADD
2'b01	SUB
2'b10	AND
2'b11	OR
4. Writeback-selection Encoding
wb_sel	Writeback source
2'b00	Immediate value
2'b01	ALU Result Register
2'b10	Data-memory read data
2'b11	Reserved
5. Default Control Values

At the beginning of the combinational control block, all controls must receive safe defaults:

pc_inc        = 0
pc_load       = 0
ir_write      = 0
alu_out_write = 0
alu_op        = ADD
reg_write     = 0
wb_sel        = IMMEDIATE
dmem_we       = 0
halted        = 0

This prevents inferred latches and accidental writes.

6. General State-transition Table
Current state	Condition	Active operation	Next state
RESET	Always	No architectural write	FETCH
FETCH	Always	Capture instruction and increment PC	DECODE
DECODE	LOADI	Decode destination and immediate	WRITEBACK
DECODE	ADD/SUB/AND/OR	Decode register operands	EXECUTE
DECODE	LOAD	Decode destination and address	MEMORY
DECODE	STORE	Decode source and address	MEMORY
DECODE	JMP	Decode jump address	EXECUTE
DECODE	HALT	No write	HALT
DECODE	Illegal opcode	No write	HALT
EXECUTE	ADD/SUB/AND/OR	Capture ALU result	WRITEBACK
EXECUTE	JMP	Load PC with target address	FETCH
EXECUTE	Any unexpected opcode	No write	HALT
MEMORY	LOAD	Present address and read memory	WRITEBACK
MEMORY	STORE	Write source register to memory	FETCH
MEMORY	Any unexpected opcode	No write	HALT
WRITEBACK	LOADI	Write immediate into Rdst	FETCH
WRITEBACK	ADD/SUB/AND/OR	Write ALU result into Rdst	FETCH
WRITEBACK	LOAD	Write memory data into Rdst	FETCH
WRITEBACK	Any unexpected opcode	No write	HALT
HALT	Always	Assert halted	HALT
7. State-output Table
State	pc_inc	pc_load	ir_write	alu_out_write	reg_write	dmem_we	halted
RESET	0	0	0	0	0	0	0
FETCH	1	0	1	0	0	0	0
DECODE	0	0	0	0	0	0	0
EXECUTE: ALU	0	0	0	1	0	0	0
EXECUTE: JMP	0	1	0	0	0	0	0
MEMORY: LOAD	0	0	0	0	0	0	0
MEMORY: STORE	0	0	0	0	0	1	0
WRITEBACK	0	0	0	0	1	0	0
HALT	0	0	0	0	0	0	1
8. Instruction State Sequences
Instruction	State sequence
LOADI	FETCH → DECODE → WRITEBACK → FETCH
ADD	FETCH → DECODE → EXECUTE → WRITEBACK → FETCH
SUB	FETCH → DECODE → EXECUTE → WRITEBACK → FETCH
AND	FETCH → DECODE → EXECUTE → WRITEBACK → FETCH
OR	FETCH → DECODE → EXECUTE → WRITEBACK → FETCH
LOAD	FETCH → DECODE → MEMORY → WRITEBACK → FETCH
STORE	FETCH → DECODE → MEMORY → FETCH
JMP	FETCH → DECODE → EXECUTE → FETCH
HALT	FETCH → DECODE → HALT
Illegal	FETCH → DECODE → HALT
9. Instruction Micro-operations
RESET
State register enters RESET after reset_n is asserted.
Next state becomes FETCH.

Architectural registers are cleared directly by their reset logic.

FETCH
IR ← imem_rdata
PC ← PC + 1

Control:

ir_write = 1
pc_inc   = 1
DECODE
opcode ← IR[15:12]
reg_a  ← IR[11:10]
reg_b  ← IR[9:8]
imm8   ← IR[7:0]

No architectural register is modified.

EXECUTE — Arithmetic or Logic
ALU_OUT ← R[reg_a] operation R[reg_b]

Control:

alu_out_write = 1
alu_op         = decoded ALU operation
EXECUTE — JMP
PC ← IR[7:0]

Control:

pc_load = 1
MEMORY — LOAD
dmem_addr ← IR[7:0]

The memory read is combinational.

No internal register is modified during this state.

MEMORY — STORE
dmem_addr  ← IR[7:0]
dmem_wdata ← R[IR[11:10]]
dmem_we    ← 1

The testbench data memory performs the write on the rising clock edge.

WRITEBACK — LOADI
R[IR[11:10]] ← IR[7:0]

Control:

reg_write = 1
wb_sel    = IMMEDIATE
WRITEBACK — ALU Instructions
R[IR[11:10]] ← ALU_OUT

Control:

reg_write = 1
wb_sel    = ALU_RESULT
WRITEBACK — LOAD
R[IR[11:10]] ← dmem_rdata

Control:

reg_write = 1
wb_sel    = MEMORY_DATA
HALT
halted = 1
next_state = HALT

The processor remains halted until reset.

10. First Program Cycle Trace

Program:

0x00  LOADI R1, 5
0x01  LOADI R2, 3
0x02  ADD R1, R2
0x03  STORE R1, [0x20]
0x04  HALT

Expected processor activity:

Cycle	State	Instruction	Major operation
1	RESET	—	Move to FETCH
2	FETCH	LOADI R1, 5	IR captures instruction; PC becomes 1
3	DECODE	LOADI R1, 5	Decode destination and immediate
4	WRITEBACK	LOADI R1, 5	R1 becomes 5
5	FETCH	LOADI R2, 3	IR captures instruction; PC becomes 2
6	DECODE	LOADI R2, 3	Decode destination and immediate
7	WRITEBACK	LOADI R2, 3	R2 becomes 3
8	FETCH	ADD R1, R2	IR captures instruction; PC becomes 3
9	DECODE	ADD R1, R2	Read R1 and R2
10	EXECUTE	ADD R1, R2	ALU_OUT becomes 8
11	WRITEBACK	ADD R1, R2	R1 becomes 8
12	FETCH	STORE R1, [0x20]	IR captures instruction; PC becomes 4
13	DECODE	STORE R1, [0x20]	Decode source and address
14	MEMORY	STORE R1, [0x20]	Memory location 0x20 becomes 8
15	FETCH	HALT	IR captures instruction; PC becomes 5
16	DECODE	HALT	Decode halt instruction
17	HALT	HALT	halted becomes 1
11. Safety Rules
reg_write is active only in WRITEBACK.
dmem_we is active only during STORE in MEMORY.
ir_write is active only in FETCH.
pc_inc is active only in FETCH.
pc_load is active only during JMP in EXECUTE.
alu_out_write is active only for ALU instructions in EXECUTE.
Illegal instructions produce no register or memory writes.
HALT cannot be exited without reset.
12. FSM Freeze Statement

The state list, instruction state sequences, control signals and micro-operations are frozen after Day 1.

The RTL control FSM must implement this document directly without introducing additional states.
