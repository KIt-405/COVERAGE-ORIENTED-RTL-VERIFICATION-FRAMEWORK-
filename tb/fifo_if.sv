interface fifo_if #(parameter DATA_WIDTH = 8) (input logic clk);
    logic                   rst_n;
    logic                   wr_en;
    logic                   rd_en;
    logic [DATA_WIDTH-1:0]  data_in;
    logic [DATA_WIDTH-1:0]  data_out;
    logic                   full;
    logic                   empty;
    logic [4:0]             room_avail; // Matched to depth 16

    //========================================================================
    // SystemVerilog Assertions (SVA)
    //========================================================================

    // 1. Prevent Overflow Hazard
    property p_no_overflow;
        @(posedge clk) disable iff (!rst_n)
        (full && wr_en) |-> ##1 (full);
    endproperty
    assert property (p_no_overflow) else $error("[SVA_ERROR] Overflow condition! Write attempted while FIFO is full.");

    // 2. Prevent Underflow Hazard
    property p_no_underflow;
        @(posedge clk) disable iff (!rst_n)
        (empty && rd_en) |-> ##1 (empty);
    endproperty
    assert property (p_no_underflow) else $error("[SVA_ERROR] Underflow condition! Read attempted while FIFO is empty.");

    // 3. Reset State Verification
    property p_reset_state;
        @(negedge rst_n) 1 |-> ##1 (empty && !full && (room_avail == 16));
    endproperty
    assert property (p_reset_state) else $error("[SVA_ERROR] Reset state failure. FIFO parameters did not clear.");

endinterface
