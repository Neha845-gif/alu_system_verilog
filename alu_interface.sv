import alu_pkg::*;
interface alu_if(input bit clk,input bit rst);

  logic [7:0] op_a,op_b;
  logic cin, mode, ce;
  logic [3:0] cmd;
  logic [1:0] inp_valid;

  logic [8:0] res;
  logic cout,err,G,E,L,oflow;

  clocking drv_cb@(posedge clk);
    default input #1 output #1;
    output op_a,op_b,ce,mode,cmd,inp_valid,cin;
    input rst;
  endclocking

  clocking mon_cb@(posedge clk);
    default input #0 output #0;
    input res,oflow,cout,G,E,L,err;
  endclocking

  clocking ref_cb@(posedge clk);
    default input #0 output #0;
    endclocking
 // OPA validity check
assert property (@(posedge clk) !$isunknown(op_a))
else $error("OPA has unknown value at time %0t", $time);

// OPB validity check
assert property (@(posedge clk) !$isunknown(op_b))
else $error("OPB has unknown value at time %0t", $time);

// CIN validity check
assert property (@(posedge clk) !$isunknown(cin))
else $error("CIN has unknown value at time %0t", $time);

// CE validity check
assert property (@(posedge clk) !$isunknown(ce))
else $error("CE has unknown value at time %0t", $time);

// MODE validity check
assert property (@(posedge clk) !$isunknown(mode))
else $error("MODE has unknown value at time %0t", $time);

// INP_VALID validity check
assert property (@(posedge clk) !$isunknown(inp_valid))
else $error("INP_VALID has unknown value at time %0t", $time);

// CMD validity check
assert property (@(posedge clk) !$isunknown(cmd))
else $error("CMD has unknown value at time %0t", $time);

  modport DRV(clocking drv_cb,input rst);
    modport MON(clocking mon_cb,input rst);
      modport REF(clocking ref_cb,input rst);
endinterface
