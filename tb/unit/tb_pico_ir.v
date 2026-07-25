`timescale 1ns/1ps

module tb_pico_ir;

    reg         clk;
    reg         reset_n;
    reg         write_en;
    reg  [15:0] instruction_in;
    wire [15:0] instruction_out;

    integer errors;

    pico_ir dut (
        .clk             (clk),
        .reset_n         (reset_n),
        .write_en        (write_en),
        .instruction_in  (instruction_in),
        .instruction_out (instruction_out)
    );

    always #5 clk = ~clk;

    task check_instruction;
        input [15:0] expected;
        input [8*32-1:0] test_name;
        begin
            #1;

            if (instruction_out !== expected) begin
                $display(
                    "FAIL: %0s expected=%04h actual=%04h",
                    test_name,
                    expected,
                    instruction_out
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: %0s instruction=%04h",
                    test_name,
                    instruction_out
                );
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/pico_ir.vcd");
        $dumpvars(0, tb_pico_ir);

        clk            = 1'b0;
        reset_n        = 1'b0;
        write_en       = 1'b0;
        instruction_in = 16'h0000;
        errors         = 0;

        #2;
        check_instruction(16'h0000, "reset value");

        @(negedge clk);
        reset_n        = 1'b1;
        write_en       = 1'b1;
        instruction_in = 16'h0405;

        @(posedge clk);
        check_instruction(16'h0405, "capture LOADI instruction");

        @(negedge clk);
        write_en       = 1'b0;
        instruction_in = 16'h1600;

        @(posedge clk);
        check_instruction(16'h0405, "hold previous instruction");

        @(negedge clk);
        write_en       = 1'b1;
        instruction_in = 16'h1600;

        @(posedge clk);
        check_instruction(16'h1600, "capture ADD instruction");

        reset_n = 1'b0;
        #1;
        check_instruction(16'h0000, "asynchronous reset");

        if (errors == 0)
            $display("INSTRUCTION REGISTER TEST: PASS");
        else
            $display(
                "INSTRUCTION REGISTER TEST: FAIL — %0d error(s)",
                errors
            );

        $finish;
    end

endmodule
