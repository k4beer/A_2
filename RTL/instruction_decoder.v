`timescale 1ns/1ps
// -----------------------------------------------------------------------
// instruction_decoder.v  (NEW - required by the assignment, not present
// in the original reference design)
//
// The reference design's control.sv consumed an already-decoded opcode_t
// enum handed to it by the (SV-only) `typedefs` package. Plain Verilog
// has no such mechanism, and the assignment separately requires a
// standalone "instruction decoder" IP block. This module splits the
// 8-bit instruction word fetched from memory into:
//   - a 3-bit opcode  (top bits)
//   - an N-bit address/operand field (bottom bits)
// which feed the controller and the address mux respectively.
// -----------------------------------------------------------------------
module instruction_decoder #(
    parameter INSTR_WIDTH = 8,
    parameter OPC_WIDTH   = 3,
    parameter ADDR_WIDTH  = 5
)(
    input  wire [INSTR_WIDTH-1:0] instruction,
    output wire [OPC_WIDTH-1:0]   opcode,
    output wire [ADDR_WIDTH-1:0]  address
);

    assign opcode  = instruction[INSTR_WIDTH-1 -: OPC_WIDTH];
    assign address = instruction[ADDR_WIDTH-1:0];

endmodule
