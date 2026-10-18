`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_IF_ID_tb
// Self-checking testbench for the IF/ID pipeline register.
// Same structure: reset, reset>all, load, hold, flush>EN, flush>hold.
//////////////////////////////////////////////////////////////////////////////////
module RV32I_IF_ID_tb;

    localparam WIDTH = 32;
    localparam clk_period = 10;

    reg clk, EN, nRST, FLUSH;

    // ---- DUT inputs ----
    reg [WIDTH-1:0] IF_PC, IF_inst;

    // ---- DUT outputs ----
    wire [WIDTH-1:0] ID_PC, ID_inst;

    integer pass, fail, t;

    RV32I_IF_ID #(.WIDTH(WIDTH)) DUT (
        .clk(clk), .EN(EN), .nRST(nRST), .FLUSH(FLUSH),
        .IF_PC(IF_PC), .IF_inst(IF_inst),
        .ID_PC(ID_PC), .ID_inst(ID_inst)
    );

    initial clk = 0;
    always #(clk_period/2) clk = ~clk;

    task automatic drive_inputs(input [WIDTH-1:0] pc, inst);
        begin
            IF_PC=pc; IF_inst=inst;
        end
    endtask

    task automatic check_all_zero(input [127:0] label);
        begin
            if ( {ID_PC,ID_inst} === 'b0 ) begin
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
            if ( ID_PC===IF_PC && ID_inst===IF_inst ) begin
                $display("T%0d PASS (%0s): outputs match inputs", t, label);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL (%0s): outputs do not match driven inputs", t, label);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    reg [WIDTH-1:0] h_PC, h_inst;

    task automatic snapshot;
        begin
            h_PC=ID_PC; h_inst=ID_inst;
        end
    endtask

    task automatic check_held(input [127:0] label);
        begin
            if ( ID_PC===h_PC && ID_inst===h_inst ) begin
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

        drive_inputs(32'h00000040, 32'hDEADBEEF);

        nRST=0; EN=1; FLUSH=0; @(posedge clk); #1; check_all_zero("reset");
        nRST=0; EN=1; FLUSH=1; @(posedge clk); #1; check_all_zero("reset>all");
        nRST=1; EN=1; FLUSH=0; @(posedge clk); #1; check_loaded("load");

        snapshot;
        drive_inputs(32'h000000F0, 32'h12345678);
        nRST=1; EN=0; FLUSH=0; @(posedge clk); #1; check_held("hold");

        nRST=1; EN=1; FLUSH=1; @(posedge clk); #1; check_all_zero("flush>EN");

        drive_inputs(32'h00000080, 32'hCAFEF00D);
        nRST=1; EN=1; FLUSH=0; @(posedge clk); #1; check_loaded("reload");
        nRST=1; EN=0; FLUSH=1; @(posedge clk); #1; check_all_zero("flush>hold");

        $display("=== RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule