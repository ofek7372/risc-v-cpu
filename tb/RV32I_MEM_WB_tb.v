`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_MEM_WB_tb
// Self-checking testbench for the MEM/WB pipeline register.
// Same structure: reset, reset>all, load, hold, flush>EN, flush>hold.
//////////////////////////////////////////////////////////////////////////////////
module RV32I_MEM_WB_tb;

    localparam WIDTH = 32;
    localparam clk_period = 10;

    reg clk, EN, nRST, FLUSH;

    // ---- DUT inputs ----
    reg [WIDTH-1:0] MEM_WBdata;
    reg [4:0]  MEM_RD;
    reg        MEM_REGwr;

    // ---- DUT outputs ----
    wire [WIDTH-1:0] WB_WBdata;
    wire [4:0]  WB_RD;
    wire        WB_REGwr;

    integer pass, fail, t;

    RV32I_MEM_WB #(.WIDTH(WIDTH)) DUT (
        .clk(clk), .EN(EN), .nRST(nRST), .FLUSH(FLUSH),
        .MEM_WBdata(MEM_WBdata), .MEM_RD(MEM_RD), .MEM_REGwr(MEM_REGwr),
        .WB_WBdata(WB_WBdata), .WB_RD(WB_RD), .WB_REGwr(WB_REGwr)
    );

    initial clk = 0;
    always #(clk_period/2) clk = ~clk;

    task automatic drive_inputs(
        input [WIDTH-1:0] wbdata, input [4:0] rd, input regwr
    );
        begin
            MEM_WBdata=wbdata; MEM_RD=rd; MEM_REGwr=regwr;
        end
    endtask

    task automatic check_all_zero(input [127:0] label);
        begin
            if ( WB_WBdata === 'b0 && {WB_RD,WB_REGwr} === 'b0 ) begin
                $display("T%0d PASS (%0s): all outputs zero", t, label);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL (%0s): expected all-zero outputs", t, label);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    task automatic check_loaded(input [127:0] label);
        begin
            if ( WB_WBdata===MEM_WBdata && WB_RD===MEM_RD && WB_REGwr===MEM_REGwr ) begin
                $display("T%0d PASS (%0s): outputs match inputs", t, label);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL (%0s): outputs do not match driven inputs", t, label);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    reg [WIDTH-1:0] h_WBdata; reg [4:0] h_RD; reg h_REGwr;

    task automatic snapshot;
        begin
            h_WBdata=WB_WBdata; h_RD=WB_RD; h_REGwr=WB_REGwr;
        end
    endtask

    task automatic check_held(input [127:0] label);
        begin
            if ( WB_WBdata===h_WBdata && WB_RD===h_RD && WB_REGwr===h_REGwr ) begin
                $display("T%0d PASS (%0s): outputs held previous value", t, label);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL (%0s): outputs changed when they should have held", t, label);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    initial begin
        pass=0; fail=0; t=0;

        drive_inputs(32'hAAAA5555, 5'b11011, 1'b1);

        nRST=0; EN=1; FLUSH=0; @(posedge clk); #1; check_all_zero("reset");
        nRST=0; EN=1; FLUSH=1; @(posedge clk); #1; check_all_zero("reset>all");
        nRST=1; EN=1; FLUSH=0; @(posedge clk); #1; check_loaded("load");

        snapshot;
        drive_inputs(32'hFFFFFFFF, 5'b00100, 1'b0);
        nRST=1; EN=0; FLUSH=0; @(posedge clk); #1; check_held("hold");

        nRST=1; EN=1; FLUSH=1; @(posedge clk); #1; check_all_zero("flush>EN");

        drive_inputs(32'h11112222, 5'b01001, 1'b1);
        nRST=1; EN=1; FLUSH=0; @(posedge clk); #1; check_loaded("reload");
        nRST=1; EN=0; FLUSH=1; @(posedge clk); #1; check_all_zero("flush>hold");

        $display("=== RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule