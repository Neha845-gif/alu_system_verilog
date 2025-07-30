class alu_driver;
    // Transaction and communication handles
    alu_transaction drv_trans;
    mailbox #(alu_transaction) mbx_gd;  // Generator to driver
    mailbox #(alu_transaction) mbx_dr;  // Driver to reference model
    virtual alu_if.DRV vif;

    // Fixed values storage for special operations
    bit [3:0] cmd_fixed;
    bit ce_fixed;
    bit mode_fixed;

    // Functional coverage
    covergroup drv_cg;

        inp_valid_x: coverpoint drv_trans.inp_valid {
                        bins no_valid   = {2'b00};
                        bins only_a     = {2'b01};
                        bins only_b     = {2'b10};
                        bins both_valid = {2'b11};
        }
        mode_x: coverpoint drv_trans.mode {
            bins mode = {0,1};
        }
        rst_x: coverpoint drv_trans.rst{
             bins rst_a = {1};
        }
        cmd_x: coverpoint drv_trans.cmd {
            bins command[] = {[0:13]};
        }
        ce_x: coverpoint drv_trans.ce {
            bins ce_a = {0,1};
        }
        op_a_x: coverpoint drv_trans.op_a {
            bins zero = {0};
            bins low[] = {[1:50]};
            bins high[] = {[51:100]};
        }
        op_b_x: coverpoint drv_trans.op_b {
            bins zero = {0};
            bins low[] = {[1:50]};
            bins high[] = {[51:100]};
        }
        cin_x: coverpoint drv_trans.cin {
            bins cin_a = {0,1};
        }

        mode_x_cmd: cross mode_x, cmd_x;
        inp_valid_x_cmd: cross inp_valid_x, cmd_x;
        inp_valid_x_mode: cross inp_valid_x, mode_x;
        inp_valid_x_op_b: cross inp_valid_x, op_b_x;
        inp_valid_x_op_a: cross inp_valid_x, op_a_x;
        op_a_x_op_b: cross op_a_x, op_b_x;
        op_a_x_cmd_x: cross op_a_x, cmd_x;
    endgroup

    // Constructor
    function new(mailbox #(alu_transaction) mbx_gd,
                 mailbox #(alu_transaction) mbx_dr,
                 virtual alu_if.DRV vif);
        this.mbx_gd = mbx_gd;
        this.mbx_dr = mbx_dr;
        this.vif = vif;
        drv_cg = new();

    endfunction

    // Main driver task
    task start();
        repeat(2) @(vif.drv_cb);  // Initial synchronization

        for(int i=0; i<`no_of_trans; i++) begin
          drv_trans = new();
            mbx_gd.get(drv_trans);  // Get transaction from generator

            if(vif.drv_cb.rst == 1) begin
               // Reset condition
                vif.drv_cb.inp_valid <= 2'b0;
                vif.drv_cb.mode <= 1'b0;
                vif.drv_cb.cmd <= 4'b0;
                vif.drv_cb.ce <= 0;
                vif.drv_cb.op_a <= 8'b0;
                vif.drv_cb.op_b <= 8'b0;
                vif.drv_cb.cin <= 0;
                repeat(1)@(vif.drv_cb);
                mbx_dr.put(drv_trans);

                $display("DRIVER: Reset values driven at time %0t", $time);
            end
            else begin
                  // Check for special 16-cycle case
                if (drv_trans.randomize() with { cmd == cmd_fixed; mode == mode_fixed; ce == ce_fixed; }) begin

                    // Store fixed values
                    @(vif.drv_cb);
                    mbx_dr.put(drv_trans);
                    cmd_fixed = drv_trans.cmd;
                    ce_fixed = drv_trans.ce;
                    mode_fixed = drv_trans.mode;

                    // Drive for 16 cycles or until both operands are valid
                    for (int j = 0; j < 16; j++) begin
                       @(vif.drv_cb);

                        // Drive all signals with fixed values for cmd, ce, mode
                        vif.drv_cb.inp_valid <= drv_trans.inp_valid;
                        vif.drv_cb.op_a <= drv_trans.op_a;
                        vif.drv_cb.op_b <= drv_trans.op_b;
                        vif.drv_cb.cin <= drv_trans.cin;
                        vif.drv_cb.cmd <= cmd_fixed;
                        vif.drv_cb.ce <= ce_fixed;
                        vif.drv_cb.mode <= mode_fixed;
                        repeat(1)@(vif.drv_cb);
                        mbx_dr.put(drv_trans);

                        // Break if both operands become valid
                        if (drv_trans.inp_valid == 2'b11) begin
                            break;
                        end
                    end
                end
                else begin
                    // Normal operation
                    vif.drv_cb.inp_valid <= drv_trans.inp_valid;
                    vif.drv_cb.mode <= drv_trans.mode;
                    vif.drv_cb.cmd <= drv_trans.cmd;
                    vif.drv_cb.ce <= drv_trans.ce;
                    vif.drv_cb.op_a <= drv_trans.op_a;
                    vif.drv_cb.op_b <= drv_trans.op_b;
                    vif.drv_cb.cin <= drv_trans.cin;

                    repeat(1)@(vif.drv_cb);
                     mbx_dr.put(drv_trans);

                    $display("DRIVER: Normal operation at time %0t \t", $time);
                end

                // Display and coverage

                $display("DRIVER: INP_VALID=%0d, MODE=%b, CMD=%0d, CE=%b, OPA=%0d, OPB=%0d, CIN=%0b at time %0t",
                        vif.drv_cb.inp_valid, vif.drv_cb.mode, vif.drv_cb.cmd,
                        vif.drv_cb.ce, vif.drv_cb.op_a, vif.drv_cb.op_b,
                        vif.drv_cb.cin, $time);
                drv_cg.sample();
                $display("DRIVER: Input coverage = %.2f%% \t", drv_cg.get_coverage());

            end
        end
    endtask
endclass
