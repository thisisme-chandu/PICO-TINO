`ifndef PICO_DEFS_VH
`define PICO_DEFS_VH

// ------------------------------------------------------------
// PICO-TINO instruction opcodes
// ------------------------------------------------------------
`define PICO_OP_LOADI  4'h0
`define PICO_OP_ADD    4'h1
`define PICO_OP_SUB    4'h2
`define PICO_OP_AND    4'h3
`define PICO_OP_OR     4'h4
`define PICO_OP_LOAD   4'h5
`define PICO_OP_STORE  4'h6
`define PICO_OP_JMP    4'h7
`define PICO_OP_HALT   4'h8

// ------------------------------------------------------------
// ALU operation encoding
// ------------------------------------------------------------
`define PICO_ALU_ADD   2'b00
`define PICO_ALU_SUB   2'b01
`define PICO_ALU_AND   2'b10
`define PICO_ALU_OR    2'b11

// ------------------------------------------------------------
// Control FSM state encoding
// ------------------------------------------------------------
`define PICO_STATE_RESET      3'b000
`define PICO_STATE_FETCH      3'b001
`define PICO_STATE_DECODE     3'b010
`define PICO_STATE_EXECUTE    3'b011
`define PICO_STATE_MEMORY     3'b100
`define PICO_STATE_WRITEBACK  3'b101
`define PICO_STATE_HALT       3'b110

// ------------------------------------------------------------
// Writeback multiplexer encoding
// ------------------------------------------------------------
`define PICO_WB_IMMEDIATE     2'b00
`define PICO_WB_ALU_RESULT    2'b01
`define PICO_WB_MEMORY        2'b10

`endif
