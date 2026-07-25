`timescale 1ns/1ps
`include "pico_defs.vh"

module tb_pico_decoder;

    reg  [15:0] instruction;

    wire [3:0] opcode;
    wire [1:0] reg_a;
    wire [1:0] reg_b;
    wire [7:0] imm_addr;
    wire [1:0] alu_op;

    wire is_loadi;
    wire is_alu;
    wire is_load;
    wire is_store;
    wire is_jump;
    wire is_halt;
    wire is_illegal;

    /*
     * Flag order:
     * [6] illegal
     * [5] halt
     * [4] jump
     * [3] store
     * [2] load
     * [1] ALU
     * [0] LOADI
     */
    wire [6:0] decoded_flags;

    integer errors;

    assign decoded_flags = {
        is_illegal,
        is_halt,
        is_jump,
        is_store,
        is_load,
        is_alu,
        is_loadi
    };

    pico_decoder dut (
        .instruction (instruction),
        .opcode      (opcode),
        .reg_a       (reg_a),
        .reg_b       (reg_b),
        .imm_addr    (imm_addr),
        .alu_op      (alu_op),
        .is_loadi    (is_loadi),
        .is_alu      (is_alu),
        .is_load     (is_load),
        .is_store    (is_store),
        .is_jump     (is_jump),
        .is_halt     (is_halt),
        .is_illegal  (is_illegal)
    );

    task check_decode;
        input [15:0] instruction_value;
        input [3:0]  expected_opcode;
        input [1:0]  expected_reg_a;
        input [1:0]  expected_reg_b;
        input [7:0]  expected_imm_addr;
        input [1:0]  expected_alu_op;
        input [6:0]  expected_flags;
        input [8*40-1:0] test_name;

        begin
            instruction = instruction_value;
            #1;

            if ((opcode        !== expected_opcode)   ||
                (reg_a         !== expected_reg_a)    ||
                (reg_b         !== expected_reg_b)    ||
                (imm_addr      !== expected_imm_addr) ||
                (alu_op        !== expected_alu_op)   ||
                (decoded_flags !== expected_flags)) begin

                $display("FAIL: %0s", test_name);
                $display(
                    "  opcode expected=%h actual=%h",
                    expected_opcode,
                    opcode
                );
                $display(
                    "  reg_a expected=%h actual=%h",
                    expected_reg_a,
                    reg_a
                );
                $display(
                    "  reg_b expected=%h actual=%h",
                    expected_reg_b,
                    reg_b
                );
                $display(
                    "  imm/address expected=%02h actual=%02h",
                    expected_imm_addr,
                    imm_addr
                );
                $display(
                    "  alu_op expected=%b actual=%b",
                    expected_alu_op,
                    alu_op
                );
                $display(
                    "  flags expected=%b actual=%b",
                    expected_flags,
                    decoded_flags
                );

                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: %-24s instruction=%04h",
                    test_name,
                    instruction_value
                );
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/pico_decoder.vcd");
        $dumpvars(0, tb_pico_decoder);

        instruction = 16'h0000;
        errors = 0;

        // LOADI R1, 5
        check_decode(
            16'h0405,
            `PICO_OP_LOADI,
            2'b01,
            2'b00,
            8'h05,
            `PICO_ALU_ADD,
            7'b0000001,
            "LOADI R1, 5"
        );

        // ADD R1, R2
        check_decode(
            16'h1600,
            `PICO_OP_ADD,
            2'b01,
            2'b10,
            8'h00,
            `PICO_ALU_ADD,
            7'b0000010,
            "ADD R1, R2"
        );

        // SUB R2, R3
        check_decode(
            16'h2B00,
            `PICO_OP_SUB,
            2'b10,
            2'b11,
            8'h00,
            `PICO_ALU_SUB,
            7'b0000010,
            "SUB R2, R3"
        );

        // AND R3, R0
        check_decode(
            16'h3C00,
            `PICO_OP_AND,
            2'b11,
            2'b00,
            8'h00,
            `PICO_ALU_AND,
            7'b0000010,
            "AND R3, R0"
        );

        // OR R0, R1
        check_decode(
            16'h4100,
            `PICO_OP_OR,
            2'b00,
            2'b01,
            8'h00,
            `PICO_ALU_OR,
            7'b0000010,
            "OR R0, R1"
        );

        // LOAD R2, [0x55]
        check_decode(
            16'h5855,
            `PICO_OP_LOAD,
            2'b10,
            2'b00,
            8'h55,
            `PICO_ALU_ADD,
            7'b0000100,
            "LOAD R2, [0x55]"
        );

        // STORE R3, [0xAA]
        check_decode(
            16'h6CAA,
            `PICO_OP_STORE,
            2'b11,
            2'b00,
            8'hAA,
            `PICO_ALU_ADD,
            7'b0001000,
            "STORE R3, [0xAA]"
        );

        // JMP 0x44
        check_decode(
            16'h7044,
            `PICO_OP_JMP,
            2'b00,
            2'b00,
            8'h44,
            `PICO_ALU_ADD,
            7'b0010000,
            "JMP 0x44"
        );

        // HALT
        check_decode(
            16'h8000,
            `PICO_OP_HALT,
            2'b00,
            2'b00,
            8'h00,
            `PICO_ALU_ADD,
            7'b0100000,
            "HALT"
        );

        // Undefined opcode
        check_decode(
            16'hF123,
            4'hF,
            2'b00,
            2'b01,
            8'h23,
            `PICO_ALU_ADD,
            7'b1000000,
            "Illegal opcode"
        );

        if (errors == 0)
            $display("DECODER TEST: PASS");
        else
            $display(
                "DECODER TEST: FAIL — %0d error(s)",
                errors
            );

        $finish;
    end

endmodule
