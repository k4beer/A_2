`timescale 1ns/1ps
// -----------------------------------------------------------------------
// mem.v
// Converted from mem.sv (synchronous 8x32 memory).
// Changes:
//   - logic -> reg/wire, always_ff/iff -> plain always + if
//   - removed the `#1` inline delay on the write (non-synthesizable,
//     simulation-only artifact; the non-blocking assignment already
//     gives correct simulation ordering)
//   - parameterized ADDR_WIDTH / DATA_WIDTH instead of hard-coded 5/8
//   - added an optional INIT_FILE parameter ($readmemh) so a test
//     program can be preloaded without hierarchical pokes
// -----------------------------------------------------------------------
module mem #(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 8,
    parameter INIT_FILE  = ""
)(
    input  wire                  clk,
    input  wire                  read,
    input  wire                  write,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] data_in,
    output reg  [DATA_WIDTH-1:0] data_out
);

    reg [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];

    initial begin
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, memory);
    end

    // Write port
    always @(posedge clk) begin
        if (write && !read)
            memory[addr] <= data_in;
    end

    // Read port
    always @(posedge clk) begin
        if (read && !write)
            data_out <= memory[addr];
    end

endmodule
