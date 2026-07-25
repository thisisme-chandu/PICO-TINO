`timescale 1ns/1ps

module pico_core (
    input  wire        clk,
    input  wire        reset_n,

    // External instruction-memory interface
    output wire [7:0]  imem_addr,
    input  wire [15:0] imem_rdata,

    // External data-memory interface
    output wire [7:0]  dmem_addr,
    input  wire [7:0]  dmem_rdata,
    output wire [7:0]  dmem_wdata,
    output wire        dmem_we,

    output wire        halted
);

    // Decoder classification signals
    wire is_loadi;
    wire is_alu;
    wire is_load;
    wire is_store;
    wire is_jump;
    wire is_halt;
    wire is_illegal;

    wire [1:0] decoded_alu_op;

    // FSM control signals
    wire       pc_inc;
    wire       pc_load;
    wire       ir_write;
    wire       alu_out_write;
    wire       reg_write;
    wire [1:0] alu_op;
    wire [1:0] wb_sel;

    /*
     * FSM state is exposed for verification, but the core does not
     * otherwise use it.
     */
    /* verilator lint_off UNUSEDSIGNAL */
    wire [2:0] control_state_unused;
    /* verilator lint_on UNUSEDSIGNAL */

    // Datapath
    pico_datapath u_datapath (
        .clk            (clk),
        .reset_n        (reset_n),

        .pc_inc         (pc_inc),
        .pc_load        (pc_load),
        .ir_write       (ir_write),
        .alu_out_write  (alu_out_write),
        .reg_write      (reg_write),
        .alu_op         (alu_op),
        .wb_sel         (wb_sel),

        .is_loadi       (is_loadi),
        .is_alu         (is_alu),
        .is_load        (is_load),
        .is_store       (is_store),
        .is_jump        (is_jump),
        .is_halt        (is_halt),
        .is_illegal     (is_illegal),
        .decoded_alu_op (decoded_alu_op),

        .imem_addr      (imem_addr),
        .imem_rdata     (imem_rdata),

        .dmem_addr      (dmem_addr),
        .dmem_rdata     (dmem_rdata),
        .dmem_wdata     (dmem_wdata)
    );

    // Control FSM
    pico_control_fsm u_control (
        .clk            (clk),
        .reset_n        (reset_n),

        .is_loadi       (is_loadi),
        .is_alu         (is_alu),
        .is_load        (is_load),
        .is_store       (is_store),
        .is_jump        (is_jump),
        .is_halt        (is_halt),
        .is_illegal     (is_illegal),

        .decoded_alu_op (decoded_alu_op),

        .pc_inc         (pc_inc),
        .pc_load        (pc_load),
        .ir_write       (ir_write),
        .alu_out_write  (alu_out_write),
        .reg_write      (reg_write),
        .dmem_we        (dmem_we),
        .halted         (halted),

        .alu_op         (alu_op),
        .wb_sel         (wb_sel),
        .state          (control_state_unused)
    );

endmodule
