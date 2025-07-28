class alu_generator;

  alu_transaction blueprint;
  mailbox #(alu_transaction) mbx_gd;

  function new(mailbox #(alu_transaction) mbx_gd);
    this.mbx_gd = mbx_gd;
    blueprint = new();
  endfunction

  task start();
    for(int i=0;i<`no_of_trans;i++)begin
      blueprint.randomize();
      $display("");
      mbx_gd.put(blueprint.copy());
      $display("geneartor randomized transaction op_a = %0d,op_b = %0d,inp_valid = %0d, mode = %0d, cmd = %0d", blueprint.op_a, blueprint.op_b,blueprint.inp_valid,blueprint.mode,blueprint.cmd);
    end
  endtask
endclass
