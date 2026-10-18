`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_EX_FWD_tb
// Self-checking testbench for the EX-stage forwarding unit.
//
// Properties enforced:
//   - MEM priority over WB when both match the same source reg
//   - x0 guard: never forward when EX_RSx == 0
//   - REGwr gating: matching RD but REGwr=0 must not forward
//   - channel A and B resolve independently
//   - default: no match -> raw EX_R_A / EX_R_B
//////////////////////////////////////////////////////////////////////////////////
module RV32I_EX_FWD_tb;

    localparam WIDTH = 32;

    reg  [4:0] EX_RS1, EX_RS2, MEM_RD, WB_RD;
    reg        MEM_REGwr, WB_REGwr;
    reg  [WIDTH-1:0] MEM_WBdata, WB_WBdata, EX_R_A, EX_R_B;
    wire [WIDTH-1:0] A_FWD, B_FWD;

    integer pass, fail, t, i;

    RV32I_EX_FWD #(.WIDTH(WIDTH)) DUT (
        .EX_RS1(EX_RS1), .EX_RS2(EX_RS2), .MEM_RD(MEM_RD), .WB_RD(WB_RD),
        .MEM_REGwr(MEM_REGwr), .WB_REGwr(WB_REGwr),
        .MEM_WBdata(MEM_WBdata), .WB_WBdata(WB_WBdata),
        .EX_R_A(EX_R_A), .EX_R_B(EX_R_B),
        .A_FWD(A_FWD), .B_FWD(B_FWD)
    );

    // ---- reference model for one channel ----
    function [WIDTH-1:0] expfwd(
        input [4:0] rs, mem_rd, wb_rd,
        input mem_we, wb_we,
        input [WIDTH-1:0] mem_data, wb_data, raw
    );
        begin
            if ((rs != 0) && (rs == mem_rd) && mem_we)
                expfwd = mem_data;              // MEM priority
            else if ((rs != 0) && (rs == wb_rd) && wb_we)
                expfwd = wb_data;               // then WB
            else
                expfwd = raw;                   // else raw
        end
    endfunction

    task automatic check(input [8*10-1:0] name);
        reg [WIDTH-1:0] eA, eB;
        begin
            #5;
            eA = expfwd(EX_RS1, MEM_RD, WB_RD, MEM_REGwr, WB_REGwr, MEM_WBdata, WB_WBdata, EX_R_A);
            eB = expfwd(EX_RS2, MEM_RD, WB_RD, MEM_REGwr, WB_REGwr, MEM_WBdata, WB_WBdata, EX_R_B);
            if (A_FWD === eA && B_FWD === eB) begin
                $display("T%0d PASS: %0s", t, name);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL: %0s  A_FWD=%h(exp %h) B_FWD=%h(exp %h)",
                        t, name, A_FWD, eA, B_FWD, eB);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    // distinctive data so the source is identifiable
    localparam [WIDTH-1:0] DMEM = 32'hAAAAAAAA; // MEM data
    localparam [WIDTH-1:0] DWB  = 32'hBBBBBBBB;                          // WB data
    localparam [WIDTH-1:0] DRA  = 32'h11111111;                         // raw A
    localparam [WIDTH-1:0] DRB  = 32'h22222222;                         // raw B

    initial begin
        pass=0; fail=0; t=0;
        MEM_WBdata=32'hAAAAAAAA; WB_WBdata=DWB; EX_R_A=DRA; EX_R_B=DRB;

        // === default: no match, both channels raw ===
        EX_RS1=5'd10; EX_RS2=5'd11; MEM_RD=5'd20; WB_RD=5'd21;
        MEM_REGwr=1; WB_REGwr=1; check("default");

        // === A forwards from MEM, B raw ===
        EX_RS1=5'd5; EX_RS2=5'd11; MEM_RD=5'd5; WB_RD=5'd21;
        MEM_REGwr=1; WB_REGwr=1; check("A_MEM");

        // === A forwards from WB, B raw ===
        EX_RS1=5'd7; EX_RS2=5'd11; MEM_RD=5'd20; WB_RD=5'd7;
        MEM_REGwr=1; WB_REGwr=1; check("A_WB");

        // === MEM priority: both MEM and WB match A -> MEM wins ===
        EX_RS1=5'd9; EX_RS2=5'd11; MEM_RD=5'd9; WB_RD=5'd9;
        MEM_REGwr=1; WB_REGwr=1; check("A_MEM>WB");

        // === channel independence: A from MEM, B from WB same cycle ===
        EX_RS1=5'd5; EX_RS2=5'd7; MEM_RD=5'd5; WB_RD=5'd7;
        MEM_REGwr=1; WB_REGwr=1; check("A_MEM_B_WB");

        // === channel independence swapped: A from WB, B from MEM ===
        EX_RS1=5'd7; EX_RS2=5'd5; MEM_RD=5'd5; WB_RD=5'd7;
        MEM_REGwr=1; WB_REGwr=1; check("A_WB_B_MEM");

        // === x0 guard: RS1=0 matches MEM_RD=0, must NOT forward ===
        EX_RS1=5'd0; EX_RS2=5'd11; MEM_RD=5'd0; WB_RD=5'd21;
        MEM_REGwr=1; WB_REGwr=1; check("A_x0_guard_MEM");

        // === x0 guard on WB path: RS2=0 matches WB_RD=0 ===
        EX_RS1=5'd10; EX_RS2=5'd0; MEM_RD=5'd20; WB_RD=5'd0;
        MEM_REGwr=1; WB_REGwr=1; check("B_x0_guard_WB");

        // === REGwr gating: MEM_RD matches but MEM_REGwr=0 -> no MEM forward ===
        EX_RS1=5'd5; EX_RS2=5'd11; MEM_RD=5'd5; WB_RD=5'd21;
        MEM_REGwr=0; WB_REGwr=1; check("A_MEM_noWE");

        // === REGwr gating falls through to WB: MEM off, WB matches ===
        EX_RS1=5'd7; EX_RS2=5'd11; MEM_RD=5'd7; WB_RD=5'd7;
        MEM_REGwr=0; WB_REGwr=1; check("A_MEMoff_WBon");

        // === both channels forward from MEM simultaneously ===
        EX_RS1=5'd5; EX_RS2=5'd5; MEM_RD=5'd5; WB_RD=5'd21;
        MEM_REGwr=1; WB_REGwr=1; check("AB_both_MEM");

        // === random stress ===
        for (i=0;i<300;i=i+1) begin
            EX_RS1=$random; EX_RS2=$random; MEM_RD=$random; WB_RD=$random;
            MEM_REGwr=$random; WB_REGwr=$random;
            MEM_WBdata=$random; WB_WBdata=$random; EX_R_A=$random; EX_R_B=$random;
            check("RND");
        end

        $display("=== EX_FWD RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule