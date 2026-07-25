`timescale 1ns/1ps

module pico_regfile (
    input  wire       clk,
    input  wire       reset_n,

    input  wire [1:0] read_addr_a,
    input  wire [1:0] read_addr_b,
    output wire [7:0] read_data_a,
    output wire [7:0] read_data_b,

    input  wire       write_en,
    input  wire [1:0] write_addr,
    input  wire [7:0] write_data
);

    reg [7:0] registers [0:3];
    integer index;

    assign read_data_a = registers[read_addr_a];
    assign read_data_b = registers[read_addr_b];

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (index = 0; index < 4; index = index + 1)
                registers[index] <= 8'h00;
        end
        else if (write_en) begin
            registers[write_addr] <= write_data;
        end
    end

endmodule
