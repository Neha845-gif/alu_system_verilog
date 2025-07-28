import alu_pkg::*;
`include "defines.sv"
`include "alu.v"
`include "alu_pkg.sv"
`include "alu_if.sv"

module top();

  // Importing the ALU package


  // Declaring variables for clock and reset
  bit clk;
  bit rst;  // Changed from reset to rst

  // Generating the clock (100MHz)
  initial begin
    forever #5 clk = ~clk;  // 10ns period = 100MHz
  end

  // Reset sequence
  initial begin
    rst = 1;  // Active high reset (now using rst)
    repeat(2) @(posedge clk);
    rst = 0;
  end

  // Instantiating the ALU interface (update reset to rst in interface too)
  alu_if intf(clk, rst);  // Changed reset to rst

  // Instantiating the ALU DUV
  // Instantiating the ALU DUV
 alu DUV(
    .INP_VALID(intf.inp_valid),
    .OPA(intf.op_a),
    .OPB(intf.op_b),
    .CIN(intf.cin),
    .CLK(clk),
    .RST(rst),
    .CMD(intf.cmd),
    .CE(intf.ce),
    .MODE(intf.mode),
    .COUT(intf.cout),
    .OFLOW(intf.oflow),
    .RES(intf.res),
    .G(intf.G),
    .E(intf.E),
    .L(intf.L),
    .ERR(intf.err)
);

  // Instantiating the Test
  alu_test test = new(intf.DRV, intf.MON, intf.REF);

  // Running the test
  initial begin
    $display("ALU Testbench Started at %0t", $time);
    test.run();
    $display("ALU Testbench Completed at %0t", $time);
    $finish();
  end

  // Waveform dumping
  initial begin
    $dumpfile("alu_waves.vcd");
    $dumpvars(0, top);
  end

endmodule
