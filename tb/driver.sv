class driver #(parameter DATA_WIDTH = 8);
    virtual fifo_if #(DATA_WIDTH) vif;
    mailbox gen2drv;
    event   drv_done;

    function new(virtual fifo_if #(DATA_WIDTH) vif, mailbox gen2drv, event drv_done);
        this.vif      = vif;
        this.gen2drv  = gen2drv;
        this.drv_done = drv_done;
    endfunction

    task reset();
        $display("[DRIVER] Initiating System Reset...");
        vif.rst_n   <= 0;
        vif.wr_en   <= 0;
        vif.rd_en   <= 0;
        vif.data_in <= 0;
        repeat(2) @(posedge vif.clk);
        vif.rst_n   <= 1;
        $display("[DRIVER] Reset Released.");
    endtask

    task main();
        forever begin
            transaction #(DATA_WIDTH) trans;
            gen2drv.get(trans);
            
            @(posedge vif.clk);
            vif.wr_en   <= trans.wr_en;
            vif.rd_en   <= trans.rd_en;
            vif.data_in <= trans.data_in;
            
            ->drv_done;
        end
    endtask
endclass
