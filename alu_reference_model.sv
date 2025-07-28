// Mode definitions
`define arith_mode 1
`define logic_mode 0

// Arithmetic commands
`define add     4'd0
`define sub     4'd1
`define add_cin 4'd2
`define sub_cin 4'd3
`define inc_a   4'd4
`define dec_a   4'd5
`define inc_b   4'd6
`define dec_b   4'd7
`define cmp     4'd8

// Logical commands
`define and     4'd0
`define nand    4'd1
`define or      4'd2
`define nor     4'd3
`define xor     4'd4
`define xnor    4'd5
`define not_a   4'd6
`define not_b   4'd7
`define shr1_a  4'd8
`define shl1_a  4'd9
`define shr1_b  4'd10
`define shl1_b  4'd11
`define rol_a_b 4'd12
`define ror_a_b 4'd13

class alu_reference;
    // Properties
    alu_transaction ref_trans;

    // Mailbox to scoreboard and from driver
    mailbox #(alu_transaction) mbx_dr;
    mailbox #(alu_transaction) mbx_rs;
    virtual alu_if.REF vif;

    // Methods
    function new(mailbox #(alu_transaction) mbx_dr,
                 mailbox #(alu_transaction) mbx_rs,
                 virtual alu_if.REF vif);
        this.mbx_dr = mbx_dr;
        this.mbx_rs = mbx_rs;
        this.vif = vif;
    endfunction


    task start();
        forever begin
            ref_trans = new();
            mbx_dr.get(ref_trans);
            @(vif.ref_cb) begin
                case(ref_trans.inp_valid)
                    2'b11: begin
                        case(ref_trans.mode)
                            `arith_mode: process_arith();
                            `logic_mode: process_logic();
                        endcase
                    end
                    2'b01: begin
                        case(ref_trans.mode)
                            `arith_mode: process_arith_valid_a();
                            `logic_mode: process_logic_valid_a();
                            default: ref_trans.res = 1'b0;
                        endcase
                    end
                    2'b10: begin
                        case(ref_trans.mode)
                            `arith_mode: process_arith_valid_b();
                            `logic_mode: process_logic_valid_b();
                            default: ref_trans.res = 1'b0;
                        endcase
                    end
                    default: begin
                        ref_trans.res = 8'b0;
                        ref_trans.cout = 1'b0;
                        ref_trans.err = 1'b0;
                        ref_trans.G = 1'b0;
                        ref_trans.E = 1'b0;
                        ref_trans.L = 1'b0;
                    end
                endcase
                mbx_rs.put(ref_trans);
            end
        end
    endtask

    task process_arith();
        bit cin = 0; // Define carry-in if needed
        case(ref_trans.cmd)
            `add: begin
                {ref_trans.cout, ref_trans.res} = ref_trans.op_a + ref_trans.op_b;

            end
            `sub: begin
                {ref_trans.cout, ref_trans.res} = ref_trans.op_a - ref_trans.op_b;
                ref_trans.oflow = (ref_trans.op_a[7] != ref_trans.op_b[7]) &&
                                 (ref_trans.res[7] != ref_trans.op_a[7]);
            end
            `add_cin: begin
                {ref_trans.cout, ref_trans.res} = ref_trans.op_a + ref_trans.op_b + cin;
            end
            `sub_cin: begin
                {ref_trans.cout, ref_trans.res} = ref_trans.op_a - ref_trans.op_b - cin;
                ref_trans.oflow = (ref_trans.op_a[7] != ref_trans.op_b[7]) &&
                                 (ref_trans.res[7] != ref_trans.op_a[7]);
            end
            `cmp: begin
                ref_trans.G = (ref_trans.op_a > ref_trans.op_b);
                ref_trans.E = (ref_trans.op_a == ref_trans.op_b);
                ref_trans.L = (ref_trans.op_a < ref_trans.op_b);
            end

            default: begin
                ref_trans.res = 1'b0;
                ref_trans.cout = 1'b0;
                ref_trans.oflow = 1'b0;
            end
        endcase
    endtask

    task process_logic();
        case(ref_trans.cmd)
            `and: ref_trans.res = {1'b0,ref_trans.op_a & ref_trans.op_b};
            `nand: ref_trans.res ={1'b0, ~(ref_trans.op_a & ref_trans.op_b)};
            `or: ref_trans.res = {1'b0,ref_trans.op_a | ref_trans.op_b};
            `nor: ref_trans.res = {1'b0,~(ref_trans.op_a | ref_trans.op_b)};
            `xor: ref_trans.res = {1'b0,ref_trans.op_a ^ ref_trans.op_b};
            `xnor: ref_trans.res = {1'b0,~(ref_trans.op_a ^ ref_trans.op_b)};
            `not_a: ref_trans.res = {1'b0,~ref_trans.op_a};
            `not_b: ref_trans.res = {1'b0,~ref_trans.op_b};
            `shr1_a: ref_trans.res = {1'b0, ref_trans.op_a[7:1]};
            `shl1_a: ref_trans.res = {ref_trans.op_a[6:0], 1'b0};
            `shr1_b: ref_trans.res = {1'b0, ref_trans.op_b[7:1]};
            `shl1_b: ref_trans.res = {ref_trans.op_b[6:0], 1'b0};
            `rol_a_b: begin
                if(ref_trans.op_b[7:4] == 4'b0000) begin
                    case(ref_trans.op_b[3:0])
                        4'd0: ref_trans.res = ref_trans.op_a;
                        4'd1: ref_trans.res = { ref_trans.op_a[6:0], ref_trans.op_a[7]};
                        4'd2: ref_trans.res = { ref_trans.op_a [5:0], ref_trans.op_a [7:6] };
                        4'd3: ref_trans.res = { ref_trans.op_a [4:0], ref_trans.op_a [7:5] };
                        4'd4: ref_trans.res = { ref_trans.op_a [3:0], ref_trans.op_a [7:6] };
                        4'd5: ref_trans.res = { ref_trans.op_a [2:0], ref_trans.op_a [7:5] };
                        4'd6: ref_trans.res = { ref_trans.op_a [1:0], ref_trans.op_a [7:6] };
                        4'd7: ref_trans.res = { ref_trans.op_a [0],   ref_trans.op_a [7:1] };
                       default : ref_trans.res = 1'b0;
                    endcase
                end
            end
            `ror_a_b: begin
                if(ref_trans.op_b[7:4] == 4'b0000) begin
                    case(ref_trans.op_b[3:0])
                        4'd0: ref_trans.res = ref_trans.op_a;
                        4'd1: ref_trans.res = { ref_trans.op_a [0], ref_trans.op_a [7:1]   };
                        4'd2: ref_trans.res = { ref_trans.op_a [1:0], ref_trans.op_a [7:2] };
                        4'd3: ref_trans.res = { ref_trans.op_a [2:0], ref_trans.op_a [7:3] };
                        4'd4: ref_trans.res = { ref_trans.op_a [3:0], ref_trans.op_a [7:4] };
                        4'd5: ref_trans.res = { ref_trans.op_a [4:0], ref_trans.op_a [7:5] };
                        4'd6: ref_trans.res = { ref_trans.op_a [5:0], ref_trans.op_a [7:6] };
                        4'd7: ref_trans.res = { ref_trans.op_a [6:0], ref_trans.op_a [7]   };
                       default : ref_trans.res = 1'b0;
                    endcase
                end
            end
            default: begin
                ref_trans.res = 1'b0;
                ref_trans.cout = 1'b0;
                ref_trans.oflow = 1'b0;
            end
        endcase
    endtask

    task process_arith_valid_a();
        case(ref_trans.cmd)
            `inc_a: ref_trans.res = ref_trans.op_a + 1;
            `dec_a: ref_trans.res = ref_trans.op_a - 1;
            default: ref_trans.res = 1'bz;
        endcase
    endtask

    task process_logic_valid_a();
        case(ref_trans.cmd)
            `not_a: ref_trans.res = ~ref_trans.op_a;
            `shr1_a: ref_trans.res = {1'b0, ref_trans.op_a[7:1]};
            `shl1_a: ref_trans.res = {ref_trans.op_a[6:0], 1'b0};
            default: ref_trans.res = 1'bz;
        endcase
    endtask

    task process_arith_valid_b();
        case(ref_trans.cmd)
            `inc_b: ref_trans.res = ref_trans.op_b + 1;
            `dec_b: ref_trans.res = ref_trans.op_b - 1;
            default: ref_trans.res = 1'bz;
        endcase
    endtask

    task process_logic_valid_b();
        case(ref_trans.cmd)
            `not_b: ref_trans.res = ~ref_trans.op_b;
            `shr1_b: ref_trans.res = {2'b0, ref_trans.op_b[7:1]};
            `shl1_b: ref_trans.res = {1'b0, ref_trans.op_b[6:0], 1'b0};
            default: ref_trans.res = 1'bz;
        endcase
    endtask
endclass
