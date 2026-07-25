`timescale 1ns/1ps

module tb_pico_regfile;

    reg        clk;
    reg        reset_n;
    reg  [1:0] read_addr_a;
    reg  [1:0] read_addr_b;
    wire [7:0] read_data_a;
    wire [7:0] read_data_b;
    reg        write_en;
    reg  [1:0] write_addr;
    reg  [7:0] write_data;

    integer errors;

    pico_regfile dut (
        .clk         (clk),
        .reset_n     (reset_n),
        .read_addr_a (read_addr_a),
        .read_addr_b (read_addr_b),
        .read_data_a (read_data_a),
        .read_data_b (read_data_b),
        .write_en    (write_en),
        .write_addr  (write_addr),
        .write_data  (write_data)
    );

    always #5 clk = ~clk;

    task write_register;
        input [1:0] address;
        input [7:0] data;
        begin
            @(negedge clk);
            write_en   = 1'b1;
            write_addr = address;
            write_data = data;

            @(posedge clk);
            #1;

            @(negedge clk);
            write_en = 1'b0;
        end
    endtask

    task check_reads;
        input [1:0] address_a;
        input [1:0] address_b;
        input [7:0] expected_a;
        input [7:0] expected_b;
        input [8*32-1:0] test_name;
        begin
            read_addr_a = address_a;
            read_addr_b = address_b;
            #1;

            if ((read_data_a !== expected_a) ||
                (read_data_b !== expected_b)) begin
                $display(
                    "FAIL: %0s A=%02h/%02h B=%02h/%02h",
                    test_name,
                    read_data_a,
                    expected_a,
                    read_data_b,
                    expected_b
                );
                errors = errors + 1;
            end
            else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/pico_regfile.vcd");
        $dumpvars(0, tb_pico_regfile);

        clk         = 1'b0;
        reset_n     = 1'b0;
        read_addr_a = 2'b00;
        read_addr_b = 2'b01;
        write_en    = 1'b0;
        write_addr  = 2'b00;
        write_data  = 8'h00;
        errors      = 0;

        #2;
        check_reads(2'b00, 2'b01, 8'h00, 8'h00, "reset clears R0 and R1");
        check_reads(2'b10, 2'b11, 8'h00, 8'h00, "reset clears R2 and R3");

        @(negedge clk);
        reset_n = 1'b1;

        write_register(2'b00, 8'h11);
        write_register(2'b01, 8'h22);
        write_register(2'b10, 8'h33);
        write_register(2'b11, 8'h44);

        check_reads(2'b00, 2'b01, 8'h11, 8'h22, "read R0 and R1");
        check_reads(2'b10, 2'b11, 8'h33, 8'h44, "read R2 and R3");
        check_reads(2'b01, 2'b10, 8'h22, 8'h33, "dual read ports");

        reset_n = 1'b0;
        #1;

        check_reads(2'b00, 2'b11, 8'h00, 8'h00, "asynchronous reset");

        if (errors == 0)
            $display("REGISTER FILE TEST: PASS");
        else
            $display("REGISTER FILE TEST: FAIL — %0d error(s)", errors);

        $finish;
    end

endmodule
