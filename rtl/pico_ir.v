`timescale 1ns/1ps

module pico_ir (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        write_en,
    input  wire [15:0] instruction_in,
    output wire [15:0] instruction_out
);

    reg [15:0] instruction_reg;

    assign instruction_out = instruction_reg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            instruction_reg <= 16'h0000;
        else if (write_en)
            instruction_reg <= instruction_in;
    end

endmodule
