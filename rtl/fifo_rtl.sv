// ==============================================================================
// Module Name: fifo_rtl.sv
// Description: Parameterized Synchronous FIFO Memory Buffer.
// ==============================================================================

module fifo_rtl #(
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 8
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    wr_en,
    input  logic                    rd_en,
    input  logic [DATA_WIDTH-1:0]   data_in,
    output logic [DATA_WIDTH-1:0]   data_out,
    output logic                    full,
    output logic                    empty
);

    localparam int ADDR_WIDTH = $clog2(FIFO_DEPTH);
    
    logic [DATA_WIDTH-1:0] mem [FIFO_DEPTH];
    logic [ADDR_WIDTH:0]   wr_ptr, rd_ptr; // Extra bit to differentiate full/empty

    // Status Flags Logic
    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]) && 
                   (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]);

    // Sequential Pointer Tracking and Memory Write
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr   <= '0;
            rd_ptr   <= '0;
            data_out <= '0;
        end else begin
            // Write Operation
            if (wr_en && !full) begin
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
                wr_ptr                      <= wr_ptr + 1'b1;
            end
            // Read Operation
            if (rd_en && !empty) begin
                data_out <= mem[rd_ptr[ADDR_WIDTH-1:0]];
                rd_ptr   <= rd_ptr + 1'b1;
            end
        end
    end

endmodule
