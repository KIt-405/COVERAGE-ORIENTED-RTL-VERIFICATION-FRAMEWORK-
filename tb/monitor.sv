class monitor #(parameter DATA_WIDTH = 8);
    virtual fifo_if #(DATA_WIDTH) vif;
    mailbox mon2scb;
    mailbox mon2cov;

    function new(virtual fifo_if #(DATA_WIDTH) vif, mailbox mon2scb, mailbox mon2cov);
        this.vif     = vif;
        this.mon2scb = mon2scb;
        this.mon2cov = mon2cov;
    endfunction

    task main();
        forever begin
            transaction #(DATA_WIDTH) trans;
            trans = new();
            
            @(posedge vif.clk);
            // Capture data after active edge propagation delay
            #1;
            trans.wr_en    = vif.wr_en;
            trans.rd_en    = vif.rd_en;
            trans.data_in  = vif.data_in;
            trans.data_out = vif.data_out;
            trans.full     = vif.full;
            trans.empty    = vif.empty;

            mon2scb.put(trans);
            mon2cov.put(trans);
        end
    endtask
endclass
