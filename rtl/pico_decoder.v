`timescale 1ns/1ps
`include "pico_defs.vh"

module pico_decoder (
    input  wire [15:0] instruction,

    output wire [3:0]  opcode,
    output wire [1:0]  reg_a,
    output wire [1:0]  reg_b,
    output wire [7:0]  imm_addr,

    output reg  [1:0]  alu_op,

    output reg          is_loadi,
    output reg          is_alu,
    output reg          is_load,
    output reg          is_store,
    output reg          is_jump,
    output reg          is_halt,
    output reg          is_illegal
);

    assign opcode   = instruction[15:12];
    assign reg_a    = instruction[11:10];
    assign reg_b    = instruction[9:8];
    assign imm_addr = instruction[7:0];

    always @(*) begin
        // Safe defaults
        alu_op     = `PICO_ALU_ADD;

        is_loadi   = 1'b0;
        is_alu     = 1'b0;
        is_load    = 1'b0;
        is_store   = 1'b0;
        is_jump    = 1'b0;
        is_halt    = 1'b0;
        is_illegal = 1'b0;

        case (opcode)
            `PICO_OP_LOADI: begin
                is_loadi = 1'b1;
            end

            `PICO_OP_ADD: begin
                is_alu = 1'b1;
                alu_op = `PICO_ALU_ADD;
            end

            `PICO_OP_SUB: begin
                is_alu = 1'b1;
                alu_op = `PICO_ALU_SUB;
            end

            `PICO_OP_AND: begin
                is_alu = 1'b1;
                alu_op = `PICO_ALU_AND;
            end

            `PICO_OP_OR: begin
                is_alu = 1'b1;
                alu_op = `PICO_ALU_OR;
            end

            `PICO_OP_LOAD: begin
                is_load = 1'b1;
            end

            `PICO_OP_STORE: begin
                is_store = 1'b1;
            end

            `PICO_OP_JMP: begin
                is_jump = 1'b1;
            end

            `PICO_OP_HALT: begin
                is_halt = 1'b1;
            end

            default: begin
                is_illegal = 1'b1;
            end
        endcase
    end

endmodule
