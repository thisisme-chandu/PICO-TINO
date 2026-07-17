PICO-TINO Instruction Set
1. Instruction Format

Every PICO-TINO instruction is 16 bits wide.

15          12 11        10 9          8 7                 0
+--------------+------------+------------+-------------------+
| Opcode [3:0] | Reg A [1:0]| Reg B [1:0]| Immediate/Address |
+--------------+------------+------------+-------------------+

Generic bit positions:

Field	Bits
Opcode	[15:12]
Register A	[11:10]
Register B	[9:8]
Immediate or address	[7:0]

The meaning of Register A and Register B depends on the instruction.

2. Register Encoding
Register	Encoding
R0	2'b00
R1	2'b01
R2	2'b10
R3	2'b11

All four registers are general-purpose registers.

R0 is not hardwired to zero.

3. Opcode Table
Opcode	Hex	Instruction
4'b0000	4'h0	LOADI
4'b0001	4'h1	ADD
4'b0010	4'h2	SUB
4'b0011	4'h3	AND
4'b0100	4'h4	OR
4'b0101	4'h5	LOAD
4'b0110	4'h6	STORE
4'b0111	4'h7	JMP
4'b1000	4'h8	HALT

Opcodes 4'h9 through 4'hF are illegal.

An illegal instruction causes the processor to enter HALT without writing a register or memory location.

4. LOADI
Assembly
LOADI Rdst, imm8
Operation
Rdst = imm8
Encoding
15       12 11      10 9       8 7                 0
+----------+----------+----------+-------------------+
|   0000   |   Rdst   |    00    |       imm8        |
+----------+----------+----------+-------------------+
States
FETCH → DECODE → WRITEBACK
Example
LOADI R1, 5

Machine code:

0000 01 00 00000101

Hexadecimal:

16'h0405
5. ADD
Assembly
ADD Rdst, Rsrc
Operation
Rdst = Rdst + Rsrc
Encoding
15       12 11      10 9        8 7                 0
+----------+----------+-----------+-------------------+
|   0001   |   Rdst   |   Rsrc    |      8'h00        |
+----------+----------+-----------+-------------------+
States
FETCH → DECODE → EXECUTE → WRITEBACK

Arithmetic wraps at eight bits.

6. SUB
Assembly
SUB Rdst, Rsrc
Operation
Rdst = Rdst - Rsrc
Encoding
15       12 11      10 9        8 7                 0
+----------+----------+-----------+-------------------+
|   0010   |   Rdst   |   Rsrc    |      8'h00        |
+----------+----------+-----------+-------------------+
States
FETCH → DECODE → EXECUTE → WRITEBACK

Arithmetic wraps at eight bits.

7. AND
Assembly
AND Rdst, Rsrc
Operation
Rdst = Rdst & Rsrc
Encoding
15       12 11      10 9        8 7                 0
+----------+----------+-----------+-------------------+
|   0011   |   Rdst   |   Rsrc    |      8'h00        |
+----------+----------+-----------+-------------------+
States
FETCH → DECODE → EXECUTE → WRITEBACK
8. OR
Assembly
OR Rdst, Rsrc
Operation
Rdst = Rdst | Rsrc
Encoding
15       12 11      10 9        8 7                 0
+----------+----------+-----------+-------------------+
|   0100   |   Rdst   |   Rsrc    |      8'h00        |
+----------+----------+-----------+-------------------+
States
FETCH → DECODE → EXECUTE → WRITEBACK
9. LOAD
Assembly
LOAD Rdst, [addr8]
Operation
Rdst = data_memory[addr8]
Encoding
15       12 11      10 9       8 7                 0
+----------+----------+----------+-------------------+
|   0101   |   Rdst   |    00    |       addr8       |
+----------+----------+----------+-------------------+
States
FETCH → DECODE → MEMORY → WRITEBACK

The address is absolute.

10. STORE
Assembly
STORE Rsrc, [addr8]
Operation
data_memory[addr8] = Rsrc
Encoding
15       12 11      10 9       8 7                 0
+----------+----------+----------+-------------------+
|   0110   |   Rsrc   |    00    |       addr8       |
+----------+----------+----------+-------------------+
States
FETCH → DECODE → MEMORY

The memory write occurs on the rising clock edge at the end of the MEMORY state.

11. JMP
Assembly
JMP addr8
Operation
PC = addr8
Encoding
15       12 11                   8 7                 0
+----------+----------------------+-------------------+
|   0111   |       4'b0000        |       addr8       |
+----------+----------------------+-------------------+
States
FETCH → DECODE → EXECUTE

JMP uses absolute instruction addressing.

12. HALT
Assembly
HALT
Operation
halted = 1
Encoding
15       12 11                                      0
+----------+------------------------------------------+
|   1000   |                 12'h000                  |
+----------+------------------------------------------+
States
FETCH → DECODE → HALT

The processor remains in HALT until reset.

13. Instruction Summary
Instruction	Destination	Source	Immediate/Address	Result
LOADI	Rdst	—	Immediate	Register
ADD	Rdst	Rsrc	—	Register
SUB	Rdst	Rsrc	—	Register
AND	Rdst	Rsrc	—	Register
OR	Rdst	Rsrc	—	Register
LOAD	Rdst	Memory	Address	Register
STORE	Memory	Rsrc	Address	Memory
JMP	PC	—	Address	PC
HALT	—	—	—	Halt state
14. First Test Program

Assembly:

Address  Instruction
0x00     LOADI R1, 5
0x01     LOADI R2, 3
0x02     ADD   R1, R2
0x03     STORE R1, [0x20]
0x04     HALT

Machine code:

Address	Assembly	Machine code
8'h00	LOADI R1, 5	16'h0405
8'h01	LOADI R2, 3	16'h0803
8'h02	ADD R1, R2	16'h1600
8'h03	STORE R1, [0x20]	16'h6420
8'h04	HALT	16'h8000

Expected final result:

R1 = 8
data_memory[8'h20] = 8
halted = 1
15. ISA Freeze Statement

The opcode values, register encoding, instruction formats and instruction semantics are frozen after Day 1.

Any future modification requires updating the decoder, FSM, testbench, machine-code programs and documentation together.
