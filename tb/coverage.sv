class coverage #(parameter DATA_WIDTH = 8);
    mailbox mon2cov;
    transaction #(DATA_WIDTH) trans;

    // Functional Coverage Definition
    covergroup fifo_cg;
        option.per_instance = 1;
        option.name = "FIFO_Functional_Coverage";

        // Cover points for Control signals
        cp_wr_en: coverpoint trans.wr_en {
            bins active   = {1};
            bins inactive = {0};
        }
        cp_rd_en: coverpoint trans.rd_en {
            bins active   = {1};
            bins inactive = {0};
        }

        // Cover points for Status Flags
        cp_full:  coverpoint trans.full;
        cp_empty: coverpoint trans.empty;

        // Cross coverage to verify simultaneous boundary operations
        cross_operational_modes: cross cp_wr_en, cp_rd_en, cp_full, cp_empty {
            illegal_bins full_and_empty = binsof(cp_full.true) && binsof(cp_empty.true);
        }
    endgroup

    function new(mailbox mon2cov);
        this.mon2cov = mon2cov;
        fifo_cg = new();
    endfunction

    task main();
        forever begin
            mon2cov.get(trans);
            fifo_cg.sample();
        end
    endtask
endclass
