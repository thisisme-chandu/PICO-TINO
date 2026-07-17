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

    /*
     * PICO-TINO integration will be completed on Day 4.
     * This Day 0 declaration freezes the external interface.
     */

endmodule
