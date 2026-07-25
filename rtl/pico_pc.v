`timescale 1ns/1ps

module pico_pc (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       increment_en,
    input  wire       load_en,
    input  wire [7:0] load_data,
    output wire [7:0] pc_value
);

    reg [7:0] pc_reg;

    assign pc_value = pc_reg;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            pc_reg <= 8'h00;
        else if (load_en)
            pc_reg <= load_data;
        else if (increment_en)
            pc_reg <= pc_reg + 8'h01;
    end

endmodule
