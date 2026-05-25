// ==============================================================================
// Description: Object-Oriented Framework capturing CRV, SVA, and Covergroups.
// ==============================================================================

`timescale 1ns/1ps

// ---------------------------------------------------------
// A. PHYSICAL INTERFACE CAPTURING PIN BUSES
// ---------------------------------------------------------
interface fifo_if #(parameter int D_WIDTH = 8) (input logic clk);
    logic               rst_n;
    logic               wr_en;
    logic               rd_en;
    logic [D_WIDTH-1:0] data_in;
    logic [D_WIDTH-1:0] data_out;
    logic               full;
    logic               empty;

    // Clocking block to eliminate simulation runtime race hazards
    clocking drv_cb @(posedge clk);
        default input #1ns output #1ns;
        output rst_n, wr_en, rd_en, data_in;
        input  data_out, full, empty;
    endclocking
endinterface


// ---------------------------------------------------------
// B. RANDOMIZABLE TRANSACTION PACKET (CRV Stimulus)
// ---------------------------------------------------------
class fifo_transaction #(parameter int D_WIDTH = 8);
    rand bit               wr_en;
    rand bit               rd_en;
    rand bit [D_WIDTH-1:0] data_in;

    // Constraint sets 70% Write, 40% Read mix to intentionally force a full state quickly
    constraint op_dist {
        wr_en dist {1'b1 := 70, 1'b0 := 30};
        rd_en dist {1'b1 := 40, 1'b0 := 60};
    }
endclass


// ---------------------------------------------------------
// C. OBJECT-ORIENTED INPUT STIMULUS DRIVER COMPONENT
// ---------------------------------------------------------
class fifo_driver #(parameter int D_WIDTH = 8);
    virtual fifo_if #(D_WIDTH) vif;

    function new(virtual fifo_if #(D_WIDTH) vif_in);
        this.vif = vif_in;
    endfunction

    task reset_dut();
        vif.drv_cb.rst_n   <= 1'b0;
        vif.drv_cb.wr_en   <= 1'b0;
        vif.drv_cb.rd_en   <= 1'b0;
        vif.drv_cb.data_in <= '0;
        repeat(3) @(vif.drv_cb);
        vif.drv_cb.rst_n   <= 1'b1;
    endtask

    task drive_stimulus(input int cycles);
        fifo_transaction #(D_WIDTH) tx;
        repeat(cycles) begin
            tx = new();
            void'(tx.randomize());
            @(vif.drv_cb);
            vif.drv_cb.wr_en   <= tx.wr_en;
            vif.drv_cb.rd_en   <= tx.rd_en;
            vif.drv_cb.data_in <= tx.data_in;
        end
    endtask
endclass


// ---------------------------------------------------------
// D. TOP-LEVEL SIMULATION RUNNER MODULE
// ---------------------------------------------------------
module fifo_tb_top;

    localparam int D_WIDTH = 8;
    localparam int F_DEPTH = 8;
    bit clk;

    always #10 clk = ~clk; // Generation of 50MHz Clock Tree

    fifo_if #(D_WIDTH) intf(clk);

    // Instantiation of actual hardware target
    fifo_rtl #(
        .DATA_WIDTH(D_WIDTH),
        .FIFO_DEPTH(F_DEPTH)
    ) dut (
        .clk     (intf.clk),
        .rst_n   (intf.rst_n),
        .wr_en   (intf.wr_en),
        .rd_en   (intf.rd_en),
        .data_in (intf.data_in),
        .data_out(intf.data_out),
        .full    (intf.full),
        .empty   (intf.empty)
    );

    // ---------------------------------------------------------
    // E. FUNCTIONAL COVERAGE ANALYSIS MATRIX (Bullet Point 3)
    // ---------------------------------------------------------
    covergroup fifo_coverage_cg @(posedge clk);
        option.per_instance = 1;

        // Cover group tracking critical protocol handshake combinations
        cross_op: cross intf.wr_en, intf.rd_en;

        // Functional boundary tracking: Did we hit absolute empty and absolute full?
        boundary_states: coverpoint {intf.full, intf.empty} {
            bins empty_state = {2'b01};
            bins full_state  = {2'b10};
            bins active_mix  = {2'b00};
        }
    endgroup

    // ---------------------------------------------------------
    // F. SYSTEMVERILOG ASSERTIONS (SVA) RUNTIME CHECKS (Bullet Point 2)
    // ---------------------------------------------------------
    // Property 1: If full is flagged, write operations must be blocked (No overflow)
    assert_overflow_protection: assert property (
        @(posedge clk) disable iff (!intf.rst_n)
        (intf.full && intf.wr_en) |=>> (dut.wr_ptr == $past(dut.wr_ptr))
    ) else $error("[ASSERTION ERROR] Memory Write Pointer advanced during FIFO Full condition!");

    // Property 2: If empty is flagged, read operations must be blocked (No underflow)
    assert_underflow_protection: assert property (
        @(posedge clk) disable iff (!intf.rst_n)
        (intf.empty && intf.rd_en) |=>> (dut.rd_ptr == $past(dut.rd_ptr))
    ) else $error("[ASSERTION ERROR] Memory Read Pointer advanced during FIFO Empty condition!");


    // ---------------------------------------------------------
    // G. EXECUTABLE SEQUENCER & STRUCTURAL MISMATCH MONITOR
    // ---------------------------------------------------------
    // Automated Scoreboard Check: Simulates a gold reference queue model
    logic [D_WIDTH-1:0] scoreboard_queue[$];
    logic [D_WIDTH-1:0] expected_data;

    initial begin : scoreboard_verification
        @(posedge intf.rst_n);
        forever begin
            @(posedge clk);
            #1ns; // Step into safe sampling zone
            if (intf.wr_en && !intf.full) begin
                scoreboard_queue.push_back(intf.data_in);
            end
            if (intf.rd_en && !intf.empty) begin
                // Give the memory array one cycle to propagate data out to the pins
                @(posedge clk); #1ns;
                expected_data = scoreboard_queue.pop_front();
                if (intf.data_out !== expected_data) begin
                    $display("[MISMATCH ERROR] Hardware Output: %h | Reference Model Output: %h", 
                             intf.data_out, expected_data);
                end else begin
                    $display("[MATCH DATA] Checked Transferred Data Payload Successfully: %h", intf.data_out);
                end
            end
        end
    end

    initial begin : execution_flow
        fifo_driver #(D_WIDTH) drv;
        fifo_coverage_cg cov_inst = new();
        
        // Enable log capture file for Python automation post-processing script
        int log_file;
        log_file = $fopen("simulation_transcript.log", "w");
        
        drv = new(intf);
        drv.reset_dut();
        
        $fdisplay(log_file, "[LOG_STAMP] Verification Session Initialized Successfully.");
        $display("Launching Advanced FIFO Verification Infrastructure Loop...");
        
        drv.drive_stimulus(100); // Stress test across 100 random permutations
        
        #10ns;
        $fdisplay(log_file, "[LOG_STAMP] Session Finished. Total Functional Coverage Metric Achieved: %0.2f%%", 
                  cov_inst.get_inst_coverage());
        $fclose(log_file);
        
        $display("Simulation Completed. Coverage: %0.2f%%", cov_inst.get_inst_coverage());
        $finish;
    end

endmodule
