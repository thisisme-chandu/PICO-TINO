`timescale 1ns/1ps
`include "pico_defs.vh"

module pico_datapath (
    input  wire        clk,
    input  wire        reset_n,

    // Control signals from the FSM
    input  wire        pc_inc,
    input  wire        pc_load,
    input  wire        ir_write,
    input  wire        alu_out_write,
    input  wire        reg_write,
    input  wire [1:0]  alu_op,
    input  wire [1:0]  wb_sel,

    // Instruction classification to the FSM
    output wire        is_loadi,
    output wire        is_alu,
    output wire        is_load,
    output wire        is_store,
    output wire        is_jump,
    output wire        is_halt,
    output wire        is_illegal,
    output wire [1:0]  decoded_alu_op,

    // External instruction-memory interface
    output wire [7:0]  imem_addr,
    input  wire [15:0] imem_rdata,

    // External data-memory interface
    output wire [7:0]  dmem_addr,
    input  wire [7:0]  dmem_rdata,
    output wire [7:0]  dmem_wdata
);

    // --------------------------------------------------------
    // Program Counter and Instruction Register
    // --------------------------------------------------------

    wire [7:0]  pc_value;
    wire [15:0] instruction;

    // --------------------------------------------------------
    // Decoded instruction fields
    // --------------------------------------------------------

    wire [1:0] reg_a;
    wire [1:0] reg_b;
    wire [7:0] imm_addr;

    /*
     * The decoder exposes the opcode for unit-level verification.
     * The integrated datapath uses instruction-class signals instead.
     */
    /* verilator lint_off UNUSEDSIGNAL */
    wire [3:0] decoded_opcode_unused;
    /* verilator lint_on UNUSEDSIGNAL */

    // --------------------------------------------------------
    // Register-file data
    // --------------------------------------------------------

    wire [7:0] read_data_a;
    wire [7:0] read_data_b;

    // --------------------------------------------------------
    // ALU and writeback data
    // --------------------------------------------------------

    wire [7:0] alu_result;
    reg  [7:0] alu_result_reg;
    reg  [7:0] writeback_data;

    // --------------------------------------------------------
    // External interface assignments
    // --------------------------------------------------------

    assign imem_addr = pc_value;

    /*
     * LOAD and STORE use the instruction's lower eight bits
     * as an absolute data-memory address.
     */
    assign dmem_addr = imm_addr;

    /*
     * For STORE, reg_a contains the source-register address.
     */
    assign dmem_wdata = read_data_a;

    // --------------------------------------------------------
    // Program Counter
    // --------------------------------------------------------

    pico_pc u_pc (
        .clk          (clk),
        .reset_n      (reset_n),
        .increment_en (pc_inc),
        .load_en      (pc_load),
        .load_data    (imm_addr),
        .pc_value     (pc_value)
    );

    // --------------------------------------------------------
    // Instruction Register
    // --------------------------------------------------------

    pico_ir u_ir (
        .clk             (clk),
        .reset_n         (reset_n),
        .write_en        (ir_write),
        .instruction_in  (imem_rdata),
        .instruction_out (instruction)
    );

    // --------------------------------------------------------
    // Instruction Decoder
    // --------------------------------------------------------

    pico_decoder u_decoder (
        .instruction    (instruction),

        .opcode         (decoded_opcode_unused),
        .reg_a          (reg_a),
        .reg_b          (reg_b),
        .imm_addr       (imm_addr),

        .alu_op         (decoded_alu_op),

        .is_loadi       (is_loadi),
        .is_alu         (is_alu),
        .is_load        (is_load),
        .is_store       (is_store),
        .is_jump        (is_jump),
        .is_halt        (is_halt),
        .is_illegal     (is_illegal)
    );

    // --------------------------------------------------------
    // Register File
    // --------------------------------------------------------

    pico_regfile u_regfile (
        .clk         (clk),
        .reset_n     (reset_n),

        .read_addr_a (reg_a),
        .read_addr_b (reg_b),
        .read_data_a (read_data_a),
        .read_data_b (read_data_b),

        .write_en    (reg_write),
        .write_addr  (reg_a),
        .write_data  (writeback_data)
    );

    // --------------------------------------------------------
    // Arithmetic Logic Unit
    // --------------------------------------------------------

    pico_alu u_alu (
        .operand_a (read_data_a),
        .operand_b (read_data_b),
        .alu_op    (alu_op),
        .result    (alu_result)
    );

    // --------------------------------------------------------
    // ALU Result Register
    // --------------------------------------------------------

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            alu_result_reg <= 8'h00;
        else if (alu_out_write)
            alu_result_reg <= alu_result;
    end

    // --------------------------------------------------------
    // Writeback Multiplexer
    // --------------------------------------------------------

    always @(*) begin
        case (wb_sel)
            `PICO_WB_IMMEDIATE:
                writeback_data = imm_addr;

            `PICO_WB_ALU_RESULT:
                writeback_data = alu_result_reg;

            `PICO_WB_MEMORY:
                writeback_data = dmem_rdata;

            default:
                writeback_data = 8'h00;
        endcase
    end

endmodule
