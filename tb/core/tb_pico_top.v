`timescale 1ns/1ps

module tb_pico_top;

    reg clk;
    reg reset_n;

    wire [7:0]  imem_addr;
    wire [15:0] imem_rdata;

    wire [7:0] dmem_addr;
    wire [7:0] dmem_rdata;
    wire [7:0] dmem_wdata;
    wire       dmem_we;

    wire halted;

    reg [15:0] imem [0:255];
    reg [7:0]  dmem [0:255];

    integer index;
    integer cycles;
    integer errors;

    pico_top dut (
        .clk        (clk),
        .reset_n    (reset_n),

        .imem_addr  (imem_addr),
        .imem_rdata (imem_rdata),

        .dmem_addr  (dmem_addr),
        .dmem_rdata (dmem_rdata),
        .dmem_wdata (dmem_wdata),
        .dmem_we    (dmem_we),

        .halted     (halted)
    );

    // External combinational-read memories
    assign imem_rdata = imem[imem_addr];
    assign dmem_rdata = dmem[dmem_addr];

    // External synchronous-write data memory
    always @(posedge clk) begin
        if (dmem_we) begin
            dmem[dmem_addr] <= dmem_wdata;

            $display(
                "DMEM WRITE: address=%02h data=%02h",
                dmem_addr,
                dmem_wdata
            );
        end
    end

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveforms/pico_top_basic.vcd");
        $dumpvars(0, tb_pico_top);

        clk     = 1'b0;
        reset_n = 1'b0;
        cycles  = 0;
        errors  = 0;

        // Default all instruction locations to HALT.
        for (index = 0; index < 256; index = index + 1)
            imem[index] = 16'h8000;

        // Clear data memory.
        for (index = 0; index < 256; index = index + 1)
            dmem[index] = 8'h00;

        // Load the Day 4 program.
        $readmemh("tb/programs/program_basic.hex", imem);

        $display("========================================");
        $display("PICO-TINO CORE INTEGRATION TEST");
        $display("========================================");

        // Hold reset for two rising edges.
        repeat (2)
            @(posedge clk);

        @(negedge clk);
        reset_n = 1'b1;

        // Run until HALT or timeout.
        while ((halted !== 1'b1) && (cycles < 50)) begin
            @(posedge clk);
            #1;

            cycles = cycles + 1;

            $display(
                "Cycle=%0d PC=%02h Instruction=%04h DMEM_WE=%b",
                cycles,
                imem_addr,
                imem_rdata,
                dmem_we
            );
        end

        #1;

        if (halted !== 1'b1) begin
            $display("FAIL: Processor did not reach HALT.");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Processor reached HALT.");
        end

        if (dmem[8'h20] !== 8'h08) begin
            $display(
                "FAIL: dmem[0x20] expected=08 actual=%02h",
                dmem[8'h20]
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: dmem[0x20] = 08");
        end

        if (errors == 0) begin
            $display("========================================");
            $display("PICO-TINO CORE TEST: PASS");
            $display("========================================");
        end
        else begin
            $display("========================================");
            $display(
                "PICO-TINO CORE TEST: FAIL — %0d error(s)",
                errors
            );
            $display("========================================");
        end

        $finish;
    end

endmodule
