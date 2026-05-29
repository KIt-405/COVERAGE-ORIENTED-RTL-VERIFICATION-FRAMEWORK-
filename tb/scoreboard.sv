class scoreboard #(parameter DATA_WIDTH = 8, parameter DEPTH = 16);
    mailbox mon2scb;
    
    // Golden reference model queue
    bit [DATA_WIDTH-1:0] ref_fifo[$]; 
    int match_count = 0;
    int error_count = 0;

    function new(mailbox mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    task main();
        transaction #(DATA_WIDTH) trans;
        forever begin
            mon2scb.get(trans);
            
            // Reference Model Read Emulation
            if (trans.rd_en && ! (ref_fifo.size() == 0)) begin
                bit [DATA_WIDTH-1:0] expected_data;
                expected_data = ref_fifo.pop_front();
                
                if (trans.data_out === expected_data) begin
                    match_count++;
                end else begin
                    $display("[SCB_ERROR] Mismatch! Expected: 0x%0h, Got: 0x%0h", expected_data, trans.data_out);
                    error_count++;
                end
            end

            // Reference Model Write Emulation
            if (trans.wr_en && ! (ref_fifo.size() == DEPTH)) begin
                ref_fifo.push_back(trans.data_in);
            end
        end
    endtask
endclass
