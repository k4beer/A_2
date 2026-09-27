`timescale 1ns/1ps
// -----------------------------------------------------------------------
// register.v
// Converted from register.sv. Used twice in the CPU top level: once as
// the accumulator, once as the instruction register (IR).
// Changes: logic -> reg/wire, always_ff -> always, added WIDTH parameter.
// -----------------------------------------------------------------------
module register #(
    parameter WIDTH = 8
)(
    output reg  [WIDTH-1:0] out,
    input  wire [WIDTH-1:0] data,
    input  wire             clk,
    input  wire             enable,
    input  wire             rst_n
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            out <= {WIDTH{1'b0}};
        else if (enable)
            out <= data;
    end

endmodule
