class env #(parameter DATA_WIDTH = 8);
    generator  #(DATA_WIDTH) gen;
    driver     #(DATA_WIDTH) drv;
    monitor    #(DATA_WIDTH) mon;
    scoreboard #(DATA_WIDTH) scb;
    coverage   #(DATA_WIDTH) cov;

    mailbox gen2drv;
    mailbox mon2scb;
    mailbox mon2cov;
    event   drv_done;

    virtual fifo_if #(DATA_WIDTH) vif;

    function new(virtual fifo_if #(DATA_WIDTH) vif);
        this.vif = vif;
        gen2drv  = new();
        mon2scb  = new();
        mon2cov  = new();
        
        gen = new(gen2drv, drv_done);
        drv = new(vif, gen2drv, drv_done);
        mon = new(vif, mon2scb, mon2cov);
        scb = new(mon2scb);
        cov = new(mon2cov);
    endfunction

    task test();
        fork
            drv.main();
            mon.main();
            scb.main();
            cov.main();
        join_none
        
        drv.reset();
        gen.main(); // Blocks until simulation item loop completes
    endtask

    task post_test();
        // Give a couple of cycles for trailing reads/evaluation
        repeat(5) @(posedge vif.clk);
        $display("\n==================================================");
        $display("          VERIFICATION PERFORMANCE REPORT         ");
        $display("==================================================");
        $display(" Total Success Checked Matches : %0d", scb.match_count);
        $display(" Total Scoreboard Mismatches  : %0d", scb.error_count);
        $display(" Final System Coverage Metric  : %0.2f%%", cov.fifo_cg.get_inst_coverage());
        $display("==================================================");
    endtask
endclass
