`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_data_mem_tb
// Self-checking testbench for the byte-enable data memory.
// KEY property: a partial (byte-enabled) write updates ONLY enabled lanes and
// preserves the others. Also: read gated by MEMrd, write gated by MEMwr.
//////////////////////////////////////////////////////////////////////////////////
module RV32I_data_mem_tb;

    localparam WIDTH = 32;
    localparam AW = 10;
    localparam clk_period = 10;

    reg clk, MEMwr, MEMrd;
    reg  [3:0] byte_enable;
    reg  [AW-1:0] addr;
    reg  [WIDTH-1:0] data_in;
    wire [WIDTH-1:0] data_out;

    integer pass, fail, t;

    RV32I_data_mem #(.WIDTH(WIDTH), .data_addr_width(AW)) DUT (
        .clk(clk), .MEMwr(MEMwr), .MEMrd(MEMrd),
        .byte_enable(byte_enable), .addr(addr),
        .data_in(data_in), .data_out(data_out)
    );

    initial clk=0;
    always #(clk_period/2) clk=~clk;

    // do a write on the clock edge
    task automatic do_write(input [AW-1:0] a, input [3:0] be, input [WIDTH-1:0] d);
        begin
            addr=a; byte_enable=be; data_in=d; MEMwr=1; MEMrd=0;
            @(posedge clk); #1;
            MEMwr=0;
        end
    endtask

    // read (combinational, gated by MEMrd) and check
    task automatic check_read(input [8*12-1:0] name, input [AW-1:0] a, input [WIDTH-1:0] expected);
        begin
            addr=a; MEMrd=1; #2;
            if (data_out === expected) begin
                $display("T%0d PASS: %0s [%0d]=%h", t, name, a, data_out);
                pass=pass+1;
            end else begin
                $error("T%0d FAIL: %0s [%0d] got=%h exp=%h", t, name, a, data_out, expected);
                fail=fail+1;
            end
            MEMrd=0;
            t=t+1;
        end
    endtask

    initial begin
        pass=0; fail=0; t=0;
        MEMwr=0; MEMrd=0; byte_enable=0; addr=0; data_in=0;

        // ===== full-word write then read =====
        do_write(10'd5, 4'b1111, 32'hDEADBEEF);
        check_read("SW_full", 10'd5, 32'hDEADBEEF);

        // ===== byte write preserves other lanes =====
        // preload word 6 with AAAAAAAA, then SB 0xBB to lane 2 -> expect AABBAAAA... wait lane2 = [23:16]
        do_write(10'd6, 4'b1111, 32'hAAAAAAAA);
        do_write(10'd6, 4'b0100, 32'h00BB0000);   // enable lane2 only, data in [23:16]
        check_read("SB_lane2", 10'd6, 32'hAABBAAAA);

        // ===== byte write lane0 preserves upper 3 =====
        do_write(10'd7, 4'b1111, 32'h11223344);
        do_write(10'd7, 4'b0001, 32'h000000FF);   // lane0 only
        check_read("SB_lane0", 10'd7, 32'h112233FF);

        // ===== byte write lane3 preserves lower 3 =====
        do_write(10'd8, 4'b1111, 32'h11223344);
        do_write(10'd8, 4'b1000, 32'hFF000000);   // lane3 only
        check_read("SB_lane3", 10'd8, 32'hFF223344);

        // ===== halfword write low preserves upper half =====
        do_write(10'd9, 4'b1111, 32'h11223344);
        do_write(10'd9, 4'b0011, 32'h0000EEEE);   // low half
        check_read("SH_low", 10'd9, 32'h1122EEEE);

        // ===== halfword write high preserves lower half =====
        do_write(10'd10, 4'b1111, 32'h11223344);
        do_write(10'd10, 4'b1100, 32'hEEEE0000);  // high half
        check_read("SH_high", 10'd10, 32'hEEEE3344);

        // ===== write with MEMwr=0 must NOT change memory =====
        do_write(10'd11, 4'b1111, 32'hCAFEBABE);
        addr=10'd11; byte_enable=4'b1111; data_in=32'hFFFFFFFF; MEMwr=0; MEMrd=0;
        @(posedge clk); #1;
        check_read("no_write", 10'd11, 32'hCAFEBABE);   // unchanged

        // ===== read with MEMrd=0 -> output 0 =====
        addr=10'd5; MEMrd=0; #2;
        if (data_out === 32'b0) begin
            $display("T%0d PASS: MEMrd=0 -> data_out=0", t); pass=pass+1;
        end else begin
            $error("T%0d FAIL: MEMrd=0 expected 0 got %h", t, data_out); fail=fail+1;
        end
        t=t+1;

        $display("=== DATA_MEM RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule