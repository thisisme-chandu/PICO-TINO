`timescale 1ns/1ps
`include "pico_defs.vh"

module pico_control_fsm (
    input  wire       clk,
    input  wire       reset_n,

    input  wire       is_loadi,
    input  wire       is_alu,
    input  wire       is_load,
    input  wire       is_store,
    input  wire       is_jump,
    input  wire       is_halt,
    input  wire       is_illegal,

    input  wire [1:0] decoded_alu_op,

    output reg        pc_inc,
    output reg        pc_load,
    output reg        ir_write,
    output reg        alu_out_write,
    output reg        reg_write,
    output reg        dmem_we,
    output reg        halted,

    output reg  [1:0] alu_op,
    output reg  [1:0] wb_sel,

    output wire [2:0] state
);

    reg [2:0] state_reg;
    reg [2:0] next_state;

    assign state = state_reg;

    // State register
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state_reg <= `PICO_STATE_RESET;
        else
            state_reg <= next_state;
    end

    // Next-state and output logic
    always @(*) begin
        // Safe defaults
        next_state    = state_reg;

        pc_inc        = 1'b0;
        pc_load       = 1'b0;
        ir_write      = 1'b0;
        alu_out_write = 1'b0;
        reg_write     = 1'b0;
        dmem_we       = 1'b0;
        halted        = 1'b0;

        alu_op         = `PICO_ALU_ADD;
        wb_sel         = `PICO_WB_IMMEDIATE;

        case (state_reg)
            `PICO_STATE_RESET: begin
                next_state = `PICO_STATE_FETCH;
            end

            `PICO_STATE_FETCH: begin
                ir_write   = 1'b1;
                pc_inc     = 1'b1;
                next_state = `PICO_STATE_DECODE;
            end

            `PICO_STATE_DECODE: begin
                if (is_illegal || is_halt)
                    next_state = `PICO_STATE_HALT;
                else if (is_loadi)
                    next_state = `PICO_STATE_WRITEBACK;
                else if (is_alu)
                    next_state = `PICO_STATE_EXECUTE;
                else if (is_load || is_store)
                    next_state = `PICO_STATE_MEMORY;
                else if (is_jump)
                    next_state = `PICO_STATE_EXECUTE;
                else
                    next_state = `PICO_STATE_HALT;
            end

            `PICO_STATE_EXECUTE: begin
                if (is_alu) begin
                    alu_op         = decoded_alu_op;
                    alu_out_write  = 1'b1;
                    next_state     = `PICO_STATE_WRITEBACK;
                end
                else if (is_jump) begin
                    pc_load    = 1'b1;
                    next_state = `PICO_STATE_FETCH;
                end
                else begin
                    next_state = `PICO_STATE_HALT;
                end
            end

            `PICO_STATE_MEMORY: begin
                if (is_load) begin
                    next_state = `PICO_STATE_WRITEBACK;
                end
                else if (is_store) begin
                    dmem_we    = 1'b1;
                    next_state = `PICO_STATE_FETCH;
                end
                else begin
                    next_state = `PICO_STATE_HALT;
                end
            end

            `PICO_STATE_WRITEBACK: begin
                if (is_loadi) begin
                    reg_write  = 1'b1;
                    wb_sel     = `PICO_WB_IMMEDIATE;
                    next_state = `PICO_STATE_FETCH;
                end
                else if (is_alu) begin
                    reg_write  = 1'b1;
                    wb_sel     = `PICO_WB_ALU_RESULT;
                    next_state = `PICO_STATE_FETCH;
                end
                else if (is_load) begin
                    reg_write  = 1'b1;
                    wb_sel     = `PICO_WB_MEMORY;
                    next_state = `PICO_STATE_FETCH;
                end
                else begin
                    next_state = `PICO_STATE_HALT;
                end
            end

            `PICO_STATE_HALT: begin
                halted     = 1'b1;
                next_state = `PICO_STATE_HALT;
            end

            default: begin
                next_state = `PICO_STATE_RESET;
            end
        endcase
    end

endmodule
