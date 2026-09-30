`timescale 1ns/1ps
// -----------------------------------------------------------------------
// scale_mux.v
// Converted from scale_mux.sv. Used at the top level to select the
// memory address bus source (PC vs. instruction address field).
// Changes: logic -> reg/wire, always_comb/unique case -> always @(*) + if,
// dropped the `'x` default (no X-propagation needed in plain Verilog sim).
// -----------------------------------------------------------------------
module scale_mux #(
    parameter WIDTH = 1
)(
    output reg  [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] in_a,
    input  wire [WIDTH-1:0] in_b,
    input  wire             sel_a
);

    always @(*) begin
        if (sel_a)
            out = in_a;
        else
            out = in_b;
    end

endmodule
