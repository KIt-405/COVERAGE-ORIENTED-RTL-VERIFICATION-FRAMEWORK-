class transaction #(parameter DATA_WIDTH = 8);
    // Rand variables for Constrained Random Verification (CRV)
    rand bit                  wr_en;
    rand bit                  rd_en;
    rand bit [DATA_WIDTH-1:0] data_in;
         bit [DATA_WIDTH-1:0] data_out;
         bit                  full;
         bit                  empty;

    // Distribution constraint to bias stimulus towards high-density activity
    constraint rw_dist {
        wr_en dist {1 := 50, 0 := 50};
        rd_en dist {1 := 40, 0 := 60};
    }

    // Copy function for reference model operations
    function transaction copy();
        copy = new();
        copy.wr_en    = this.wr_en;
        copy.rd_en    = this.rd_en;
        copy.data_in  = this.data_in;
        copy.data_out = this.data_out;
        copy.full     = this.full;
        copy.empty    = this.empty;
    endfunction

    function void display(string name);
        $display("[%s] WR:%b RD:%b | DataIn:0x%0h | DataOut:0x%0h | Full:%b Empty:%b", 
                 name, wr_en, rd_en, data_in, data_out, full, empty);
    endfunction
endclass
