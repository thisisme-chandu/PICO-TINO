`timescale 1ns/1ps
`include "pico_defs.vh"

module tb_pico_control_fsm;

    reg clk;
    reg reset_n;

    reg is_loadi;
    reg is_alu;
    reg is_load;
    reg is_store;
    reg is_jump;
    reg is_halt;
    reg is_illegal;

    reg [1:0] decoded_alu_op;

    wire pc_inc;
    wire pc_load;
    wire ir_write;
    wire alu_out_write;
    wire reg_write;
    wire dmem_we;
    wire halted;

    wire [1:0] alu_op;
    wire [1:0] wb_sel;
    wire [2:0] state;

    wire [10:0] control_bus;

    integer errors;

    /*
     * Control-bus order:
     *
     * [10]   pc_inc
     * [9]    pc_load
     * [8]    ir_write
     * [7]    alu_out_write
     * [6]    reg_write
     * [5]    dmem_we
     * [4]    halted
     * [3:2]  wb_sel
     * [1:0]  alu_op
     */
    assign control_bus = {
        pc_inc,
        pc_load,
        ir_write,
        alu_out_write,
        reg_write,
        dmem_we,
        halted,
        wb_sel,
        alu_op
    };

    localparam [10:0] CTRL_SAFE = {
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        `PICO_WB_IMMEDIATE,
        `PICO_ALU_ADD
    };

    localparam [10:0] CTRL_FETCH = {
        1'b1,
        1'b0,
        1'b1,
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        `PICO_WB_IMMEDIATE,
        `PICO_ALU_ADD
    };

    localparam [10:0] CTRL_EXECUTE_ADD = {
        1'b0,
        1'b0,
        1'b0,
        1'b1,
        1'b0,
        1'b0,
        1'b0,
        `PICO_WB_IMMEDIATE,
        `PICO_ALU_ADD
    };

    localparam [10:0] CTRL_WRITEBACK_IMM = {
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        1'b1,
        1'b0,
        1'b0,
        `PICO_WB_IMMEDIATE,
        `PICO_ALU_ADD
    };

    localparam [10:0] CTRL_WRITEBACK_ALU = {
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        1'b1,
        1'b0,
        1'b0,
        `PICO_WB_ALU_RESULT,
        `PICO_ALU_ADD
    };

    localparam [10:0] CTRL_WRITEBACK_MEMORY = {
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        1'b1,
        1'b0,
        1'b0,
        `PICO_WB_MEMORY,
        `PICO_ALU_ADD
    };

    localparam [10:0] CTRL_STORE = {
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        1'b1,
        1'b0,
        `PICO_WB_IMMEDIATE,
        `PICO_ALU_ADD
    };

    localparam [10:0] CTRL_JUMP = {
        1'b0,
        1'b1,
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        `PICO_WB_IMMEDIATE,
        `PICO_ALU_ADD
    };

    localparam [10:0] CTRL_HALT = {
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        1'b0,
        1'b1,
        `PICO_WB_IMMEDIATE,
        `PICO_ALU_ADD
    };

    pico_control_fsm dut (
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
        .state          (state)
    );

    always #5 clk = ~clk;

    task clear_decode_inputs;
        begin
            is_loadi       = 1'b0;
            is_alu         = 1'b0;
            is_load        = 1'b0;
            is_store       = 1'b0;
            is_jump        = 1'b0;
            is_halt        = 1'b0;
            is_illegal     = 1'b0;
            decoded_alu_op = `PICO_ALU_ADD;
        end
    endtask

    task drive_opcode;
        input [3:0] instruction_opcode;

        begin
            clear_decode_inputs;

            case (instruction_opcode)
                `PICO_OP_LOADI:
                    is_loadi = 1'b1;

                `PICO_OP_ADD: begin
                    is_alu = 1'b1;
                    decoded_alu_op = `PICO_ALU_ADD;
                end

                `PICO_OP_SUB: begin
                    is_alu = 1'b1;
                    decoded_alu_op = `PICO_ALU_SUB;
                end

                `PICO_OP_AND: begin
                    is_alu = 1'b1;
                    decoded_alu_op = `PICO_ALU_AND;
                end

                `PICO_OP_OR: begin
                    is_alu = 1'b1;
                    decoded_alu_op = `PICO_ALU_OR;
                end

                `PICO_OP_LOAD:
                    is_load = 1'b1;

                `PICO_OP_STORE:
                    is_store = 1'b1;

                `PICO_OP_JMP:
                    is_jump = 1'b1;

                `PICO_OP_HALT:
                    is_halt = 1'b1;

                default:
                    is_illegal = 1'b1;
            endcase
        end
    endtask

    task check_fsm;
        input [2:0] expected_state;
        input [10:0] expected_controls;
        input [8*40-1:0] test_name;

        begin
            #1;

            if ((state !== expected_state) ||
                (control_bus !== expected_controls)) begin

                $display("FAIL: %0s", test_name);
                $display(
                    "  state expected=%b actual=%b",
                    expected_state,
                    state
                );
                $display(
                    "  controls expected=%b actual=%b",
                    expected_controls,
                    control_bus
                );

                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: %-30s state=%b controls=%b",
                    test_name,
                    state,
                    control_bus
                );
            end
        end
    endtask

    task advance_and_check;
        input [2:0] expected_state;
        input [10:0] expected_controls;
        input [8*40-1:0] test_name;

        begin
            @(posedge clk);
            check_fsm(
                expected_state,
                expected_controls,
                test_name
            );
        end
    endtask

    task reset_to_fetch;
        begin
            reset_n = 1'b0;
            clear_decode_inputs;

            #1;
            check_fsm(
                `PICO_STATE_RESET,
                CTRL_SAFE,
                "asynchronous RESET state"
            );

            @(negedge clk);
            reset_n = 1'b1;

            advance_and_check(
                `PICO_STATE_FETCH,
                CTRL_FETCH,
                "RESET to FETCH"
            );
        end
    endtask

    initial begin
        $dumpfile("waveforms/pico_control_fsm.vcd");
        $dumpvars(0, tb_pico_control_fsm);

        clk     = 1'b0;
        reset_n = 1'b1;
        errors  = 0;

        clear_decode_inputs;

        // ----------------------------------------------------
        // LOADI sequence
        // FETCH -> DECODE -> WRITEBACK -> FETCH
        // ----------------------------------------------------
        reset_to_fetch;

        @(negedge clk);
        drive_opcode(`PICO_OP_LOADI);

        advance_and_check(
            `PICO_STATE_DECODE,
            CTRL_SAFE,
            "LOADI DECODE"
        );

        advance_and_check(
            `PICO_STATE_WRITEBACK,
            CTRL_WRITEBACK_IMM,
            "LOADI WRITEBACK"
        );

        advance_and_check(
            `PICO_STATE_FETCH,
            CTRL_FETCH,
            "LOADI return to FETCH"
        );

        // ----------------------------------------------------
        // ADD sequence
        // FETCH -> DECODE -> EXECUTE -> WRITEBACK -> FETCH
        // ----------------------------------------------------
        reset_to_fetch;

        @(negedge clk);
        drive_opcode(`PICO_OP_ADD);

        advance_and_check(
            `PICO_STATE_DECODE,
            CTRL_SAFE,
            "ADD DECODE"
        );

        advance_and_check(
            `PICO_STATE_EXECUTE,
            CTRL_EXECUTE_ADD,
            "ADD EXECUTE"
        );

        advance_and_check(
            `PICO_STATE_WRITEBACK,
            CTRL_WRITEBACK_ALU,
            "ADD WRITEBACK"
        );

        advance_and_check(
            `PICO_STATE_FETCH,
            CTRL_FETCH,
            "ADD return to FETCH"
        );

        // ----------------------------------------------------
        // LOAD sequence
        // FETCH -> DECODE -> MEMORY -> WRITEBACK -> FETCH
        // ----------------------------------------------------
        reset_to_fetch;

        @(negedge clk);
        drive_opcode(`PICO_OP_LOAD);

        advance_and_check(
            `PICO_STATE_DECODE,
            CTRL_SAFE,
            "LOAD DECODE"
        );

        advance_and_check(
            `PICO_STATE_MEMORY,
            CTRL_SAFE,
            "LOAD MEMORY"
        );

        advance_and_check(
            `PICO_STATE_WRITEBACK,
            CTRL_WRITEBACK_MEMORY,
            "LOAD WRITEBACK"
        );

        advance_and_check(
            `PICO_STATE_FETCH,
            CTRL_FETCH,
            "LOAD return to FETCH"
        );

        // ----------------------------------------------------
        // STORE sequence
        // FETCH -> DECODE -> MEMORY -> FETCH
        // ----------------------------------------------------
        reset_to_fetch;

        @(negedge clk);
        drive_opcode(`PICO_OP_STORE);

        advance_and_check(
            `PICO_STATE_DECODE,
            CTRL_SAFE,
            "STORE DECODE"
        );

        advance_and_check(
            `PICO_STATE_MEMORY,
            CTRL_STORE,
            "STORE MEMORY"
        );

        advance_and_check(
            `PICO_STATE_FETCH,
            CTRL_FETCH,
            "STORE return to FETCH"
        );

        // ----------------------------------------------------
        // JMP sequence
        // FETCH -> DECODE -> EXECUTE -> FETCH
        // ----------------------------------------------------
        reset_to_fetch;

        @(negedge clk);
        drive_opcode(`PICO_OP_JMP);

        advance_and_check(
            `PICO_STATE_DECODE,
            CTRL_SAFE,
            "JMP DECODE"
        );

        advance_and_check(
            `PICO_STATE_EXECUTE,
            CTRL_JUMP,
            "JMP EXECUTE"
        );

        advance_and_check(
            `PICO_STATE_FETCH,
            CTRL_FETCH,
            "JMP return to FETCH"
        );

        // ----------------------------------------------------
        // HALT sequence
        // FETCH -> DECODE -> HALT -> HALT
        // ----------------------------------------------------
        reset_to_fetch;

        @(negedge clk);
        drive_opcode(`PICO_OP_HALT);

        advance_and_check(
            `PICO_STATE_DECODE,
            CTRL_SAFE,
            "HALT DECODE"
        );

        advance_and_check(
            `PICO_STATE_HALT,
            CTRL_HALT,
            "HALT state"
        );

        advance_and_check(
            `PICO_STATE_HALT,
            CTRL_HALT,
            "HALT remains HALT"
        );

        // ----------------------------------------------------
        // Illegal instruction
        // FETCH -> DECODE -> HALT
        // ----------------------------------------------------
        reset_to_fetch;

        @(negedge clk);
        drive_opcode(4'hF);

        advance_and_check(
            `PICO_STATE_DECODE,
            CTRL_SAFE,
            "ILLEGAL DECODE"
        );

        advance_and_check(
            `PICO_STATE_HALT,
            CTRL_HALT,
            "ILLEGAL enters HALT"
        );

        // Verify asynchronous reset can exit HALT
        reset_n = 1'b0;

        check_fsm(
            `PICO_STATE_RESET,
            CTRL_SAFE,
            "reset exits HALT"
        );

        if (errors == 0)
            $display("CONTROL FSM TEST: PASS");
        else
            $display(
                "CONTROL FSM TEST: FAIL — %0d error(s)",
                errors
            );

        $finish;
    end

endmodule
