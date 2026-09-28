`timescale 1ns/1ps
// -----------------------------------------------------------------------
// alu.v
// Converted from alu.sv (Cadence SV training example) to plain Verilog.
// Changes from original:
//   - logic -> reg/wire, always_ff/always_comb -> always @(...)
//   - unique case -> case; opcode_t enum (from `import typedefs::*`)
//     replaced with local 3-bit localparams (Verilog has no packages)
//   - removed timeunit/timeprecision (not needed, kept behaviour same)
//   - added WIDTH parameter for configurability (assignment requirement)
// -----------------------------------------------------------------------
module alu #(
    parameter WIDTH = 8
)(
    output reg  [WIDTH-1:0] out,
    output wire             zero,
    input  wire             clk,
    input  wire [WIDTH-1:0] accum,
    input  wire [WIDTH-1:0] data,
    input  wire [2:0]       opcode
);

    // Opcode encoding - must match instruction_decoder.v / control.v
    localparam OP_ADD = 3'b000;
    localparam OP_AND = 3'b001;
    localparam OP_XOR = 3'b010;
    localparam OP_LDA = 3'b011;
    localparam OP_STO = 3'b100;
    localparam OP_JMP = 3'b101;
    localparam OP_SKZ = 3'b110;
    localparam OP_HLT = 3'b111;

    always @(negedge clk) begin
        case (opcode)
            OP_ADD:                          out <= accum + data;
            OP_AND:                          out <= accum & data;
            OP_XOR:                          out <= accum ^ data;
            OP_LDA:                          out <= data;
            OP_HLT, OP_SKZ, OP_JMP, OP_STO:  out <= accum;
            default:                         out <= accum;
        endcase
    end

    assign zero = ~(|accum);

endmodule
