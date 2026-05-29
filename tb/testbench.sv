`timescale 1ns/1ps

module fifo_tb_top;

    localparam D_WIDTH = 8;
    localparam F_DEPTH = 8;

    reg                clk;
    reg                rst_n;
    reg                wr_en;
    reg                rd_en;
    reg  [D_WIDTH-1:0] data_in;
    wire [D_WIDTH-1:0] data_out;
    wire               full;
    wire               empty;

    initial clk = 0;
    always #10 clk = ~clk;


    fifo_rtl #(
        .DATA_WIDTH(D_WIDTH),
        .FIFO_DEPTH(F_DEPTH)
    ) dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .wr_en   (wr_en),
        .rd_en   (rd_en),
        .data_in (data_in),
        .data_out(data_out),
        .full    (full),
        .empty   (empty)
    );

    task reset_dut;
    begin
        rst_n   = 1'b0;
        wr_en   = 1'b0;
        rd_en   = 1'b0;
        data_in = 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        rst_n   = 1'b1;
    end
    endtask

    task drive_stimulus(input integer cycles);
        integer i;
        integer rand_wr, rand_rd;
    begin
        for (i = 0; i < cycles; i = i + 1) begin
            @(posedge clk);
            #1; 
            rand_wr = $unsigned($random) % 100;
            wr_en   = (rand_wr < 70) ? 1'b1 : 1'b0;

            rand_rd = $unsigned($random) % 100;
            rd_en   = (rand_rd < 40)
