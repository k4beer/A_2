`timescale 1ns/1ps
// -----------------------------------------------------------------------
// clock_generator.v  (NEW - required by the assignment, not present in
// the original reference design)
//
// A free-running clock source for the CPU, parameterized by half-period
// so the whole design's clock rate is configurable from one place.
// Note: this is a simulation-time clock source (a `#delay` self-toggling
// oscillator), not a synthesizable PLL/clock-divider. That's fine for
// this assignment since the CPU is verified purely in simulation with
// your own testbench (Section 3) - flag this clearly as a simulation-only
// block if asked about synthesizability in the viva.
// -----------------------------------------------------------------------
module clock_generator #(
    parameter HALF_PERIOD = 5   // in simulation time units (see `timescale)
)(
    output reg clk
);

    initial clk = 1'b0;

    always #(HALF_PERIOD) clk = ~clk;

endmodule
