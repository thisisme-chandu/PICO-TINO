`timescale 1ns/1ps

module pico_top (
    input  wire        clk,
    input  wire        reset_n,

    output wire [7:0]  imem_addr,
    input  wire [15:0] imem_rdata,

    output wire [7:0]  dmem_addr,
    input  wire [7:0]  dmem_rdata,
    output wire [7:0]  dmem_wdata,
    output wire        dmem_we,

    output wire        halted
);

    pico_core u_core (
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

endmodule
