class alu_environment;
//properties

virtual alu_if drv_vif, mon_vif, ref_vif;
mailbox #(alu_transaction) mbx_gd, mbx_dr, mbx_rs, mbx_ms;

alu_generator        gen;
alu_driver           drv;
alu_monitor          mon;
alu_reference       ref_sb;
alu_scoreboard       scb;

//methods
//explicitly overriding the constructor to connect the virtual interfaces to test

function new( virtual alu_if drv_vif, virtual alu_if mon_vif, virtual alu_if ref_vif);
this.drv_vif = drv_vif;
this.mon_vif = mon_vif;
this.ref_vif = ref_vif;
endfunction

// task that creates objects for mailbox and components

task build();
begin

mbx_gd = new();
mbx_dr = new();
mbx_rs = new();
mbx_ms = new();

// creating objects and passing arguments in function new() in constructor

        gen = new(mbx_gd);
        drv = new(mbx_gd, mbx_dr,drv_vif);  // Interface first, then mailboxes
        mon = new(mon_vif, mbx_ms);
        ref_sb = new(mbx_dr, mbx_rs, ref_vif);
        scb = new(mbx_rs, mbx_ms);



end
endtask

task start();
fork
gen.start();
drv.start();
mon.start();
scb.start();
ref_sb.start();
join
scb.compare_results();
endtask

endclass
