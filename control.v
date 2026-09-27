`timescale 1ns/1ps
// -----------------------------------------------------------------------
// control.v  (the controller)
// Converted from control.sv.
// Changes:
//   - logic -> reg/wire, always_ff/always_comb -> plain always blocks
//   - `import typedefs::*` (opcode_t/state_t enums + state.next() method)
//     replaced with local 3-bit localparams; state.next() was simply a
//     free-running increment through 8 states, reproduced directly with
//     `state <= state + 1'b1` on a 3-bit register (0..7 wraps naturally)
//   - `inside {...}` operator replaced with explicit OR'd comparisons
//   - added an `op_phase` output (= state[2]) so the top level can use
//     scale_mux to select the memory address source (PC vs instruction
//     address field) without duplicating state-decoding logic elsewhere
// -----------------------------------------------------------------------
module control (
    output reg  load_ac,
    output reg  mem_rd,
    output reg  mem_wr,
    output reg  inc_pc,
    output reg  load_pc,
    output reg  load_ir,
    output reg  halt,
    output wire op_phase,
    input  wire [2:0] opcode,
    input  wire       zero,
    input  wire       clk,
    input  wire       rst_n
);

    // Opcode encoding - must match alu.v / instruction_decoder.v
    localparam OP_ADD = 3'b000;
    localparam OP_AND = 3'b001;
    localparam OP_XOR = 3'b010;
    localparam OP_LDA = 3'b011;
    localparam OP_STO = 3'b100;
    localparam OP_JMP = 3'b101;
    localparam OP_SKZ = 3'b110;
    localparam OP_HLT = 3'b111;

    // T-states of the instruction cycle (free-running, wraps 0..7)
    localparam S_INST_ADDR  = 3'd0;
    localparam S_INST_FETCH = 3'd1;
    localparam S_INST_LOAD  = 3'd2;
    localparam S_IDLE       = 3'd3;
    localparam S_OP_ADDR    = 3'd4;
    localparam S_OP_FETCH   = 3'd5;
    localparam S_ALU_OP     = 3'd6;
    localparam S_STORE      = 3'd7;

    reg [2:0] state;
    wire      aluop;

    assign aluop   = (opcode == OP_ADD) || (opcode == OP_AND) ||
                      (opcode == OP_XOR) || (opcode == OP_LDA);
    assign op_phase = state[2]; // 1 during OP_ADDR..STORE, 0 during INST_ADDR..IDLE

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_INST_ADDR;
        else
            state <= state + 1'b1;
    end

    always @(*) begin
        {mem_rd, load_ir, halt, inc_pc, load_ac, load_pc, mem_wr} = 7'b0;
        case (state)
            S_INST_ADDR : ; // address setup only, no control lines asserted
            S_INST_FETCH: mem_rd = 1'b1;
            S_INST_LOAD : begin
                mem_rd  = 1'b1;
                load_ir = 1'b1;
            end
            S_IDLE      : begin
                mem_rd  = 1'b1;
                load_ir = 1'b1;
            end
            S_OP_ADDR   : begin
                inc_pc = 1'b1;
                halt   = (opcode == OP_HLT);
            end
            S_OP_FETCH  : mem_rd = aluop;
            S_ALU_OP    : begin
                load_ac = aluop;
                mem_rd  = aluop;
                inc_pc  = (opcode == OP_SKZ) && zero;
                load_pc = (opcode == OP_JMP);
            end
            S_STORE     : begin
                // NOTE: load_ac is intentionally NOT re-asserted here.
                // The accumulator is already loaded during S_ALU_OP; since
                // the ALU (alu.v) recomputes combinationally on every
                // negedge clk from whatever `accum` currently holds,
                // asserting load_ac again here would re-run the ALU on the
                // *already-updated* accumulator (e.g. ADD would compute
                // (acc+data)+data instead of acc+data). This was a real bug
                // in the reference design, masked only for LDA (whose result
                // doesn't depend on accum, so re-latching is harmless).
                mem_rd  = aluop;
                inc_pc  = (opcode == OP_JMP) || ((opcode == OP_SKZ) && zero);
                load_pc = (opcode == OP_JMP);
                mem_wr  = (opcode == OP_STO);
            end
            default     : ; // unreachable - all 8 values of a 3-bit state covered above
        endcase
    end

endmodule
