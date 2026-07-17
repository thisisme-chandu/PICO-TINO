PICO-TINO Architecture
1. Project Purpose

PICO-TINO is a tiny 8-bit multi-cycle processor designed to teach the complete open-source RTL-to-GDSII journey before developing TINO-MC45.

The processor intentionally uses a small custom instruction set, four registers, external memories and a finite-state-machine controller.

2. Frozen Architectural Specifications
Parameter	Decision
Processor name	PICO-TINO
CPU type	Multi-cycle FSM processor
RTL language	Verilog-2001
Data width	8 bits
Instruction width	16 bits
Address width	8 bits
Register count	Four
Registers	R0, R1, R2, R3
Pipeline	None
Cache	None
Clock domains	One
Instruction memory	External
Data memory	External
Memory handshake	None
Technology target	Nangate45
Reset	Active-low asynchronous reset
3. Processor Components

PICO-TINO contains the following architectural components:

Program Counter
Instruction Register
Instruction Decoder
Control FSM
Four-register Register File
8-bit ALU
ALU Result Register
Writeback Multiplexer
Data-memory Interface
Top-level External-memory Interface
4. Architectural State

The processor contains the following state-holding elements:

Element	Width	Purpose
Program Counter	8 bits	Holds the current instruction address
Instruction Register	16 bits	Holds the instruction being executed
Register File	4 × 8 bits	Holds architectural data values
ALU Result Register	8 bits	Holds ALU results between EXECUTE and WRITEBACK
FSM State Register	3 bits	Holds the current processor state

The external instruction and data memories are not part of the synthesizable processor.

5. Module Hierarchy
pico_top
└── pico_core
    ├── pico_control_fsm
    └── pico_datapath
        ├── pico_pc
        ├── pico_ir
        ├── pico_decoder
        ├── pico_regfile
        └── pico_alu

The ALU result register and writeback multiplexer may be implemented directly inside pico_datapath.

6. Datapath Overview
flowchart LR
    IMEM[External Instruction Memory]
    DMEM[External Data Memory]

    PC[Program Counter]
    IR[Instruction Register]
    DEC[Instruction Decoder]
    FSM[Control FSM]
    RF[Register File\nR0-R3]
    ALU[8-bit ALU]
    AOUT[ALU Result Register]
    WBMUX[Writeback MUX]

    PC -->|imem_addr| IMEM
    IMEM -->|imem_rdata| IR
    IR --> DEC
    DEC --> FSM
    DEC --> RF
    RF -->|Destination value| ALU
    RF -->|Source value| ALU
    ALU --> AOUT
    AOUT --> WBMUX
    DEC -->|Immediate| WBMUX
    DMEM -->|Read data| WBMUX
    WBMUX --> RF
    DEC -->|Address| DMEM
    RF -->|Store data| DMEM
    DEC -->|Jump address| PC

    FSM -. Control .-> PC
    FSM -. Control .-> IR
    FSM -. Control .-> RF
    FSM -. Control .-> ALU
    FSM -. Control .-> AOUT
    FSM -. Control .-> WBMUX
    FSM -. Control .-> DMEM
7. Instruction-fetch Behaviour

During the FETCH state:

The Program Counter drives imem_addr.
External instruction memory returns imem_rdata.
The Instruction Register captures imem_rdata.
The Program Counter increments by one.
The FSM moves to DECODE.

Each instruction-memory location contains one complete 16-bit instruction.

8. Register-file Behaviour

The Register File contains four independent 8-bit registers:

R0
R1
R2
R3

All four registers are readable and writable.

R0 is not hardwired to zero.

The Register File has:

Two combinational read ports
One synchronous write port
Active-low asynchronous reset
9. ALU Behaviour

The ALU supports:

Addition
Subtraction
Bitwise AND
Bitwise OR

Arithmetic wraps naturally at eight bits.

Examples:

8'hFF + 8'h01 = 8'h00
8'h00 - 8'h01 = 8'hFF

PICO-TINO does not implement carry, zero, negative or overflow flags.

10. Writeback Sources

The Writeback Multiplexer selects one of three sources:

Selection	Source
2'b00	Immediate value
2'b01	ALU Result Register
2'b10	Data-memory read data
2'b11	Reserved

The selected value is written into the destination register when reg_write is asserted.

11. External Instruction-memory Interface
output wire [7:0]  imem_addr;
input  wire [15:0] imem_rdata;

Assumptions:

256 instruction locations
One 16-bit instruction per location
Combinational read
No ready or valid handshake
Memory exists only in the testbench
12. External Data-memory Interface
output wire [7:0] dmem_addr;
input  wire [7:0] dmem_rdata;
output wire [7:0] dmem_wdata;
output wire       dmem_we;

Assumptions:

256 data locations
Eight bits per location
Combinational read
Synchronous write
Write occurs on the rising clock edge when dmem_we is high
Memory exists only in the testbench
13. Program-counter Behaviour

The Program Counter follows these rules:

Reset sets PC to 8'h00.
FETCH increments PC by one.
JMP loads an absolute 8-bit target address.
PC remains unchanged in other states.
PC overflow wraps naturally from 8'hFF to 8'h00.
14. Processor Execution Model

PICO-TINO executes one instruction across several clock cycles.

Example ADD execution:

FETCH
  Capture instruction and increment PC

DECODE
  Decode opcode and register addresses

EXECUTE
  Add the two register values
  Capture the result in the ALU Result Register

WRITEBACK
  Write the ALU result into the destination register

The processor is multi-cycle but not pipelined. Only one instruction is active at a time.

15. Top-level Interface
module pico_top (
    input  wire        clk,
    input  wire        reset_n,

    output wire [7:0]  imem_addr,
    input  wire [15:0] imem_rdata,

    output wire [7:0]  dmem_addr,
    input  wire [7:0]  dmem_rdata,
    output wire [7:0]  dmem_wdata,
    output wire        dmem_we,

    output wire        halted
);
16. Architecture Exclusions

The following features are intentionally excluded:

Pipeline
Conditional branches
Processor flags
Multiplication and division
Stack
Function calls
Interrupts
Exceptions
Internal memories
Memory stalls
Memory handshake
Cache
UART
Debug interface
RISC-V compatibility
17. Architecture Freeze Statement

The PICO-TINO architecture is frozen after Day 1.

Any feature not described in this document belongs to a later processor project and must not be introduced into the one-week PICO-TINO implementation.
