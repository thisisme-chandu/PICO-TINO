`timescale 1ns/1ps

module tb_pico_pc;

    reg        clk;
    reg        reset_n;
    reg        increment_en;
    reg        load_en;
    reg  [7:0] load_data;
    wire [7:0] pc_value;

    integer errors;

    pico_pc dut (
        .clk          (clk),
        .reset_n      (reset_n),
        .increment_en (increment_en),
        .load_en      (load_en),
        .load_data    (load_data),
        .pc_value     (pc_value)
    );

    always #5 clk = ~clk;

    task check_pc;
        input [7:0] expected;
        input [8*32-1:0] test_name;
        begin
            #1;

            if (pc_value !== expected) begin
                $display(
                    "FAIL: %0s expected=%02h actual=%02h",
                    test_name,
                    expected,
                    pc_value
                );
                errors = errors + 1;
            end
            else begin
                $display("PASS: %0s PC=%02h", test_name, pc_value);
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/pico_pc.vcd");
        $dumpvars(0, tb_pico_pc);

        clk          = 1'b0;
        reset_n      = 1'b0;
        increment_en = 1'b0;
        load_en      = 1'b0;
        load_data    = 8'h00;
        errors       = 0;

        #2;
        check_pc(8'h00, "reset value");

        @(negedge clk);
        reset_n      = 1'b1;
        increment_en = 1'b1;

        @(posedge clk);
        check_pc(8'h01, "first increment");

        @(posedge clk);
        check_pc(8'h02, "second increment");

        @(negedge clk);
        increment_en = 1'b0;

        @(posedge clk);
        check_pc(8'h02, "hold");

        @(negedge clk);
        load_en   = 1'b1;
        load_data = 8'hA5;

        @(posedge clk);
        check_pc(8'hA5, "jump load");

        @(negedge clk);
        increment_en = 1'b1;
        load_en      = 1'b1;
        load_data    = 8'h55;

        @(posedge clk);
        check_pc(8'h55, "load priority over increment");

        reset_n = 1'b0;
        #1;
        check_pc(8'h00, "asynchronous reset");

        if (errors == 0)
            $display("PROGRAM COUNTER TEST: PASS");
        else
            $display("PROGRAM COUNTER TEST: FAIL — %0d error(s)", errors);

        $finish;
    end

endmodule
