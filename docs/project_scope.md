# PICO-TINO Project Scope

## Frozen Architecture

| Parameter | Decision |
|---|---|
| Processor | PICO-TINO |
| Architecture | Multi-cycle FSM CPU |
| RTL language | Verilog-2001 |
| Data width | 8 bits |
| Instruction width | 16 bits |
| Address width | 8 bits |
| Registers | R0-R3, four 8-bit registers |
| Pipeline | None |
| Cache | None |
| Clock domains | One |
| Instruction memory | External |
| Data memory | External |
| Technology | Nangate45 |
| Reset | Active-low asynchronous |

## Instructions

LOADI, ADD, SUB, AND, OR, LOAD, STORE, JMP and HALT.

## FSM States

RESET, FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK and HALT.

## Memory Model

Instruction memory has 256 locations of 16 bits and uses combinational reads.

Data memory has 256 locations of 8 bits, combinational reads and synchronous writes.

Both memories remain outside the synthesizable processor.

## Excluded Features

- Pipeline
- Cache
- Conditional branches
- Flags
- Multiplication and division
- Interrupts
- Exceptions
- Memory handshaking
- Internal SRAM
- UART
- Debug interface
- RISC-V compatibility
