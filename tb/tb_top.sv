module tb_top;
    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;

    bit clk;
    always #5 clk = ~clk; // 100MHz clock execution simulation

    // Interface Instantiation
    fifo_if #(DATA_WIDTH) inf(clk);

    // DUT Instantiation
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(inf.clk),
        .rst_n(inf.rst_n),
        .wr_en(inf.wr_en),
        .rd_en(inf.rd_en),
        .data_in(inf.data_in),
        .data_out(inf.data_out),
        .full(inf.full),
        .empty(inf.empty),
        .room_avail(inf.room_avail)
    );

    // Test execution block
    initial begin
        env #(DATA_WIDTH) environment;
        environment = new(inf);
        environment.gen.loop_count = 1000; // Injection parameter
        
        environment.test();
        environment.post_test();
        $finish;
    end

    // Waveform generation setup
    initial begin
        $dumpfile("sim_dump.vcd");
        $dumpvars(0, tb_top);
    end
endmodule
