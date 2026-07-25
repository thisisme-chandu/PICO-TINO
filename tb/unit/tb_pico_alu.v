`timescale 1ns/1ps
`include "pico_defs.vh"

module tb_pico_alu;

    reg  [7:0] operand_a;
    reg  [7:0] operand_b;
    reg  [1:0] alu_op;
    wire [7:0] result;

    integer errors;

    pico_alu dut (
        .operand_a (operand_a),
        .operand_b (operand_b),
        .alu_op    (alu_op),
        .result    (result)
    );

    task check_result;
        input [7:0] expected;
        input [8*32-1:0] test_name;
        begin
            #1;

            if (result !== expected) begin
                $display(
                    "FAIL: %0s expected=%02h actual=%02h",
                    test_name,
                    expected,
                    result
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: %0s result=%02h",
                    test_name,
                    result
                );
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/pico_alu.vcd");
        $dumpvars(0, tb_pico_alu);

        errors = 0;

        operand_a = 8'h05;
        operand_b = 8'h03;
        alu_op = `PICO_ALU_ADD;
        check_result(8'h08, "5 + 3");

        operand_a = 8'hFF;
        operand_b = 8'h01;
        alu_op = `PICO_ALU_ADD;
        check_result(8'h00, "addition wraparound");

        operand_a = 8'h08;
        operand_b = 8'h03;
        alu_op = `PICO_ALU_SUB;
        check_result(8'h05, "8 - 3");

        operand_a = 8'h00;
        operand_b = 8'h01;
        alu_op = `PICO_ALU_SUB;
        check_result(8'hFF, "subtraction wraparound");

        operand_a = 8'hA5;
        operand_b = 8'h3C;
        alu_op = `PICO_ALU_AND;
        check_result(8'h24, "bitwise AND");

        operand_a = 8'hA5;
        operand_b = 8'h3C;
        alu_op = `PICO_ALU_OR;
        check_result(8'hBD, "bitwise OR");

        if (errors == 0)
            $display("ALU TEST: PASS");
        else
            $display("ALU TEST: FAIL — %0d error(s)", errors);

        $finish;
    end

endmodule
