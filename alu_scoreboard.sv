class alu_scoreboard;
    // Properties
    alu_transaction ref_trans, mon_trans;

    // Mailboxes
    mailbox #(alu_transaction) mbx_rs;  // Reference model to scoreboard
    mailbox #(alu_transaction) mbx_ms;  // Monitor to scoreboard

    // Match/Mismatch counters
    int MATCH, MISMATCH;
    int TOTAL_TRANSACTIONS;

    // Error tracking
    int RESULT_MISMATCHES;
    int CARRY_MISMATCHES;
    int OVERFLOW_MISMATCHES;
    int COMPARE_MISMATCHES;
    int ERROR_MISMATCHES;

    // Constructor
    function new(mailbox #(alu_transaction) mbx_rs,
                 mailbox #(alu_transaction) mbx_ms);
        this.mbx_rs = mbx_rs;
        this.mbx_ms = mbx_ms;
        this.MATCH = 0;
        this.MISMATCH = 0;
        this.TOTAL_TRANSACTIONS = 0;
        this.RESULT_MISMATCHES = 0;
        this.CARRY_MISMATCHES = 0;
        this.OVERFLOW_MISMATCHES = 0;
        this.COMPARE_MISMATCHES = 0;
        this.ERROR_MISMATCHES = 0;
    endfunction

    // Main task
    task start();
        forever begin
            ref_trans = new();
            mon_trans = new();

            // Get transactions from both mailboxes
            fork
                mbx_rs.get(ref_trans);
                mbx_ms.get(mon_trans);
            join

            TOTAL_TRANSACTIONS++;
            compare_results();
        end
    endtask

    // Comparison task
    task compare_results();
        bit error_flag = 0;

        $display("\n============ SCOREBOARD COMPARISON ============");
        $display("Transaction #%0d at time %0t", TOTAL_TRANSACTIONS, $time);
        $display("Operation: Mode=%b, Cmd=%0d, A=%0d, B=%0d, rst=%0d, inp_valid = %0d",
                 ref_trans.mode, ref_trans.cmd,
                 ref_trans.op_a, ref_trans.op_b, ref_trans.rst, ref_trans.inp_valid);

        // Compare results
        if (ref_trans.res !== mon_trans.res) begin
            $display("RESULT MISMATCH: Expected=%0d, Actual=%0d",
                    ref_trans.res, mon_trans.res);
            RESULT_MISMATCHES++;
            error_flag = 1;
        end

        // Compare carry out
        if (ref_trans.cout !== mon_trans.cout) begin
            $display("CARRY MISMATCH: Expected=%b, Actual=%b",
                    ref_trans.cout, mon_trans.cout);
            CARRY_MISMATCHES++;
            error_flag = 1;
        end

        // Compare overflow
        if (ref_trans.oflow !== mon_trans.oflow) begin
            $display("OVERFLOW MISMATCH: Expected=%b, Actual=%b",
                    ref_trans.oflow, mon_trans.oflow);
            OVERFLOW_MISMATCHES++;
            error_flag = 1;
        end

        // Compare comparator outputs (if in compare mode)
        if (ref_trans.mode == `arith_mode && ref_trans.cmd == `cmp) begin
            if (ref_trans.G !== mon_trans.G ||
                ref_trans.E !== mon_trans.E ||
                ref_trans.L !== mon_trans.L) begin
                $display("COMPARE MISMATCH: Expected GEL=%b%b%b, Actual GEL=%b%b%b",
                        ref_trans.G, ref_trans.E, ref_trans.L,
                        mon_trans.G, mon_trans.E, mon_trans.L);
                COMPARE_MISMATCHES++;
                error_flag = 1;
            end
        end

        // Compare error flag
        if (ref_trans.err !== mon_trans.err) begin
            $display("ERROR FLAG MISMATCH: Expected=%b, Actual=%b",
                    ref_trans.err, mon_trans.err);
            ERROR_MISMATCHES++;
            error_flag = 1;
        end

        // Update match/mismatch counters
        if (error_flag) begin
            MISMATCH++;
            $display(">>>>>> MISMATCH #%0d <<<<<<", MISMATCH);
        end
        else begin
            MATCH++;
            $display(">>>>>> MATCH #%0d <<<<<<", MATCH);
        end

        // Periodic report
        if (TOTAL_TRANSACTIONS % 10 == 0) begin
            print_summary();
        end
    endtask : compare_results  // Added label for clarity

    // Summary report
    function void print_summary();
        $display("\n************ SCOREBOARD SUMMARY ************");
        $display("Total Transactions: %0d", TOTAL_TRANSACTIONS);
        $display("Matches: %0d (%.1f%%)", MATCH, (MATCH*100.0)/TOTAL_TRANSACTIONS);
        $display("Mismatches: %0d (%.1f%%)", MISMATCH, (MISMATCH*100.0)/TOTAL_TRANSACTIONS);
        $display("Detail Mismatches:");
        $display("  Results:    %0d", RESULT_MISMATCHES);
        $display("  Carry:      %0d", CARRY_MISMATCHES);
        $display("  Overflow:   %0d", OVERFLOW_MISMATCHES);
        $display("  Compare:    %0d", COMPARE_MISMATCHES);
        $display("  Error Flag: %0d", ERROR_MISMATCHES);
        $display("******************************************\n");
    endfunction 
endclass 
