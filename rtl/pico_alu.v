`timescale 1ns/1ps
`include "pico_defs.vh"

module pico_alu (
    input  wire [7:0] operand_a,
    input  wire [7:0] operand_b,
    input  wire [1:0] alu_op,
    output reg  [7:0] result
);

    always @(*) begin
        case (alu_op)
            `PICO_ALU_ADD: result = operand_a + operand_b;
            `PICO_ALU_SUB: result = operand_a - operand_b;
            `PICO_ALU_AND: result = operand_a & operand_b;
            `PICO_ALU_OR : result = operand_a | operand_b;
            default      : result = 8'h00;
        endcase
    end

endmodule
