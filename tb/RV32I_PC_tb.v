`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_PC_tb
// Self-checking testbench for the PC register.
// No FLUSH: PC redirect happens via the D input, not a flush.
// Covers: reset, reset>EN priority, load (EN=1), hold (EN=0).
//////////////////////////////////////////////////////////////////////////////////
module RV32I_PC_tb;

    localparam WIDTH = 32;
    localparam clk_period = 10;

    reg clk, EN, nRST;
    reg  [WIDTH-1:0] D;
    wire [WIDTH-1:0] Q;

    integer pass, fail, t;

    // NOTE: match this port list to your actual PC module.
    // Your PC ports were: EN, nRST, clk, D, Q  (parameter WIDTH).
    PC #(.WIDTH(WIDTH)) DUT (
        .clk(clk), .EN(EN), .nRST(nRST), .D(D), .Q(Q)
    );

    initial clk = 0;
    always #(clk_period/2) clk = ~clk;

    task automatic check_zero(input [127:0] label);
        begin
            if ( Q === 'b0 ) begin
                $display("T%0d PASS (%0s): Q is zero", t, label);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL (%0s): expected Q=0, got %0h", t, label, Q);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    task automatic check_loaded(input [127:0] label);
        begin
            if ( Q === D ) begin
                $display("T%0d PASS (%0s): Q matches D (%0h)", t, label, Q);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL (%0s): expected Q=%0h, got %0h", t, label, D, Q);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    reg [WIDTH-1:0] h_Q;
    task automatic snapshot; begin h_Q = Q; end endtask

    task automatic check_held(input [127:0] label);
        begin
            if ( Q === h_Q ) begin
                $display("T%0d PASS (%0s): Q held previous value (%0h)", t, label, Q);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL (%0s): Q changed when it should have held (was %0h, now %0h)", t, label, h_Q, Q);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    initial begin
        pass=0; fail=0; t=0;

        // === TEST 1: reset (nRST=0) forces Q=0, EN irrelevant ===
        D = 32'hDEADBEEF;
        nRST=0; EN=1; @(posedge clk); #1; check_zero("reset");

        // === TEST 2: reset priority over EN (nRST=0, EN=1, valid D) ===
        D = 32'h12345678;
        nRST=0; EN=1; @(posedge clk); #1; check_zero("reset>EN");

        // === TEST 3: load (EN=1) ===
        D = 32'h00000004;
        nRST=1; EN=1; @(posedge clk); #1; check_loaded("load");

        // === TEST 4: load a second value (sequential advance) ===
        D = 32'h00000008;
        nRST=1; EN=1; @(posedge clk); #1; check_loaded("load2");

        // === TEST 5: hold (EN=0) keeps value, D changes must be ignored ===
        snapshot;
        D = 32'hFFFFFFFF;
        nRST=1; EN=0; @(posedge clk); #1; check_held("hold");

        // === TEST 6: hold again to confirm it stays put across multiple edges ===
        D = 32'hAAAAAAAA;
        nRST=1; EN=0; @(posedge clk); #1; check_held("hold2");

        // === TEST 7: resume loading after hold ===
        D = 32'h0000000C;
        nRST=1; EN=1; @(posedge clk); #1; check_loaded("resume");

        $display("=== RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule