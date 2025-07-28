class alu_monitor;

  alu_transaction mon_trans;

  mailbox #(alu_transaction) mbx_ms;

  virtual alu_if.MON vif;

  covergroup mon_cg;
    oflow_flag: coverpoint mon_trans.oflow { bins oflow_bins = {0,1};}
    result_flag: coverpoint mon_trans.res {bins res_high = {[128:255]};
                                           bins res_zero = {0};
                                           bins res_low = {[1:127]};
                                          }
    cout_flag : coverpoint mon_trans.cout {bins cout_bin = {0,1};}
    err_flag :coverpoint mon_trans.err {bins err_bins = {0,1};}
    G_flag : coverpoint mon_trans.G {bins G_bins = {0,1};}
    E_flag : coverpoint mon_trans.E {bins E_bins = {0,1};}
    L_flag : coverpoint mon_trans.L {bins L_bins = {0,1};}
    flags_cross: cross G_flag, E_flag, L_flag;
    error_cross: cross err_flag, oflow_flag, cout_flag;
  endgroup

  function new(virtual alu_if.MON vif, mailbox #(alu_transaction) mbx_ms);
    this.vif = vif;
    this.mbx_ms = mbx_ms;
    mon_cg = new();
  endfunction

  task start();
    repeat(3)@(vif.mon_cb);
      for(int i=0;i<`no_of_trans;i++)
         begin
          mon_trans = new();
           repeat(1)@(vif.mon_cb);
            begin
              mon_trans.res = vif.mon_cb.res;
              mon_trans.oflow = vif.mon_cb.oflow;
              mon_trans.cout = vif.mon_cb.cout;
              mon_trans.err = vif.mon_cb.err;
              mon_trans.G = vif.mon_cb.G;
              mon_trans.E = vif.mon_cb.E;
              mon_trans.L = vif.mon_cb.L;
               mbx_ms.put(mon_trans);

              mon_cg.sample();
            end


              $display("ALU Monitor: Result=0x%h, Flags: G=%b, E=%b, L=%b, Cout=%b, OF=%b, Err=%b @ %0t",
               mon_trans.res, mon_trans.G, mon_trans.E, mon_trans.L,
               mon_trans.cout, mon_trans.oflow, mon_trans.err, $time);
           $display("OUTPUT FUNCTIONAL COVERAGE = %.2f%%", mon_cg.get_coverage());
                repeat(1) @(vif.mon_cb);

            end
          endtask
          endclass
