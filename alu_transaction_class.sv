class alu_transaction;
//PROPERTIES
//INPUTS declare as rand variables
  rand bit [7:0] op_a,op_b;
  rand bit cin,ce,mode;
  rand bit [3:0] cmd;
  rand bit [1:0] inp_valid;
 rand bit rst;
//OUTPUTS daclare as non-rand variables
  bit [7:0]res;
  bit err,oflow,cout,G,L,E;

//CONSTRAINTS for write_enb and read_enb

  constraint inp_valid_a {inp_valid!=2'b00;}
  constraint inp_valid_b {inp_valid inside {[0:3]};}
  constraint rst_a { rst == 0;}
  constraint ce_a { ce==1; }
  constraint mode_a {mode inside {0,1};}
  constraint cin_a {cin inside {0,1};}
  constraint cmd_a { (mode==1) -> (cmd inside {[0:10]}); }
  constraint cmd_b { (mode==0) -> (cmd inside {[0:13]}); }
  constraint op_a1 { op_a inside {[0:255]};}
  constraint op_b1 { op_b inside {[0:255]};}
  constraint inc_op_1 { ((cmd inside {4,5,6,7} ) && (mode==1)) -> (inp_valid inside {1,2});}
  constraint inc_op { ((cmd inside {6,7,8,9,10,11} ) && (mode==0)) -> (inp_valid inside {1,2});}
  constraint inc_op_not_1 { (!(cmd inside {4,5,6,7} ) && (mode==1)) -> (inp_valid inside {3});}
  constraint inc_op_not { (!(cmd inside {6,7,8,9,10,11,12} ) && (mode==0)) -> (inp_valid inside {3});}
  constraint rotate {(cmd inside {12,13})->((mode == 0) && ( op_b [7:4] == 0)); }



//METHODS
//Copying objects for blueprint This is a deep copy function
 virtual function alu_transaction copy();
  copy = new();
  copy.op_a=this.op_a;
  copy.op_b=this.op_b;
  copy.ce=this.ce;
  copy.rst=this.rst;
  copy.inp_valid=this.inp_valid;
  copy.mode=this.mode;
  copy.cmd=this.cmd;
  copy.cin=this.cin;
  return copy;
  endfunction
endclass

class alu_transaction1 extends alu_transaction;
//CONSTRAINTS OVERRIDING by extending the transaction class


//METHODS
//Copying objects for blueprint
 virtual function alu_transaction copy();
  alu_transaction1 copy1;
  copy1=new();
  copy1.op_a=this.op_a;
  copy1.op_b=this.op_b;
  copy1.ce=this.ce;
  copy1.rst=this.rst;
  copy1.inp_valid=this.inp_valid;
  copy1.mode=this.mode;
  copy1.cmd=this.cmd;
  copy1.cin=this.cin;
  return copy1;
  endfunction
endclass

class alu_transaction2 extends alu_transaction;
//CONSTRAINTS OVERRIDING by extending the transaction class

//METHODS
//Copying objects for blueprint
 virtual function alu_transaction copy();
 alu_transaction2 copy2;
  copy2=new();
  copy2.op_a=this.op_a;
  copy2.op_b=this.op_b;
  copy2.ce=this.ce;
  copy2.rst=this.rst;
  copy2.inp_valid=this.inp_valid;
  copy2.mode=this.mode;
  copy2.cmd=this.cmd;
  copy2.cin=this.cin;
  return copy2;
  endfunction
endclass

class alu_transaction3 extends alu_transaction;
//CONSTRAINTS OVERRIDING by extending the transaction class

//METHODS
//Copying objects for blueprint
 virtual function alu_transaction copy();
  alu_transaction3 copy3;
  copy3 = new();
  copy3.op_a=this.op_a;
  copy3.op_b=this.op_b;
  copy3.ce=this.ce;
  copy3.rst=this.rst;
  copy3.inp_valid=this.inp_valid;
  copy3.mode=this.mode;
  copy3.cmd=this.cmd;
  copy3.cin=this.cin;
  return copy3;
  endfunction
endclass

class alu_transaction4 extends alu_transaction;
//CONSTRAINTS OVERRIDING by extending the transaction class

//METHODS
//Copying objects for blueprint
 virtual function alu_transaction copy();
  alu_transaction4 copy4;
  copy4 = new();
  copy4.op_a=this.op_a;
  copy4.op_b=this.op_b;
  copy4.ce=this.ce;
  copy4.inp_valid=this.inp_valid;
  copy4.mode=this.mode;
  copy4.cmd=this.cmd;
  copy4.cin=this.cin;
  return copy4;
  endfunction
endclass
