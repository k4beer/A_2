`timescale 1ns/1ps
// -----------------------------------------------------------------------
// counter.v  (used as the Program Counter, PC)
// Converted from counter.sv.
//
// BUG FOUND & FIXED (report this in your "incorrect LLM/reference output"
// section):
//   The original counter.sv always incremented on every clock edge unless
//   `load` was asserted:
//       else count <= count + 1;
//   But control.sv drives a dedicated `inc_pc` signal that is only meant
//   to be high during specific T-states (OP_ADDR, and conditionally in
//   ALU_OP/STORE for SKZ/JMP). With the original counter, the PC would
//   increment on every one of the 8 T-states per instruction instead of
//   once per instruction, which breaks program flow entirely.
//   Fix: added an explicit `inc` input wired to control's inc_pc, and the
//   counter now only increments when `inc` is asserted.
// -----------------------------------------------------------------------
module counter #(
    parameter WIDTH = 5
)(
    output reg  [WIDTH-1:0] count,
    input  wire [WIDTH-1:0] data,
    input  wire             clk,
    input  wire             load,
    input  wire             inc,
    input  wire             rst_n
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= {WIDTH{1'b0}};
        else if (load)
            count <= data;
        else if (inc)
            count <= count + 1'b1;
    end

endmodule
