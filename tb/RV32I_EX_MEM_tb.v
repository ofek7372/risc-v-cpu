`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_EX_MEM_tb
// Self-checking testbench for the EX/MEM pipeline register.
// Same structure as RV32I_ID_EX_tb: reset, reset>all, load, hold, flush>EN, flush>hold.
//////////////////////////////////////////////////////////////////////////////////
module RV32I_EX_MEM_tb;

    localparam WIDTH = 32;
    localparam clk_period = 10;

    reg clk, EN, nRST, FLUSH;

    // ---- DUT inputs ----
    reg [WIDTH-1:0] EX_B_FWD, EX_ALUresult;
    reg [2:0]  EX_funct3;
    reg        EX_MEMrd, EX_MEMwr, EX_MEMtoREG;
    reg [4:0]  EX_RD;
    reg        EX_REGwr;

    // ---- DUT outputs ----
    wire [WIDTH-1:0] MEM_B_FWD, MEM_ALUresult;
    wire [2:0]  MEM_funct3;
    wire        MEM_MEMrd, MEM_MEMwr, MEM_MEMtoREG;
    wire [4:0]  MEM_RD;
    wire        MEM_REGwr;

    integer pass, fail, t;

    RV32I_EX_MEM #(.WIDTH(WIDTH)) DUT (
        .clk(clk), .nRST(nRST), .EN(EN), .FLUSH(FLUSH),
        .EX_B_FWD(EX_B_FWD), .EX_ALUresult(EX_ALUresult), .EX_funct3(EX_funct3),
        .EX_MEMrd(EX_MEMrd), .EX_MEMwr(EX_MEMwr), .EX_MEMtoREG(EX_MEMtoREG),
        .EX_RD(EX_RD), .EX_REGwr(EX_REGwr),
        .MEM_B_FWD(MEM_B_FWD), .MEM_ALUresult(MEM_ALUresult), .MEM_funct3(MEM_funct3),
        .MEM_MEMrd(MEM_MEMrd), .MEM_MEMwr(MEM_MEMwr), .MEM_MEMtoREG(MEM_MEMtoREG),
        .MEM_RD(MEM_RD), .MEM_REGwr(MEM_REGwr)
    );

    initial clk = 0;
    always #(clk_period/2) clk = ~clk;

    task automatic drive_inputs(
        input [WIDTH-1:0] b_fwd, aluresult, input [2:0] f3,
        input memrd, memwr, memtoreg, input [4:0] rd, input regwr
    );
        begin
            EX_B_FWD=b_fwd; EX_ALUresult=aluresult; EX_funct3=f3;
            EX_MEMrd=memrd; EX_MEMwr=memwr; EX_MEMtoREG=memtoreg;
            EX_RD=rd; EX_REGwr=regwr;
        end
    endtask

    task automatic check_all_zero(input [127:0] label);
        begin
            if ( {MEM_B_FWD,MEM_ALUresult} === 'b0 &&
                 {MEM_funct3,MEM_MEMrd,MEM_MEMwr,MEM_MEMtoREG,MEM_RD,MEM_REGwr} === 'b0 ) begin
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
            if ( MEM_B_FWD===EX_B_FWD && MEM_ALUresult===EX_ALUresult && MEM_funct3===EX_funct3 &&
                 MEM_MEMrd===EX_MEMrd && MEM_MEMwr===EX_MEMwr && MEM_MEMtoREG===EX_MEMtoREG &&
                 MEM_RD===EX_RD && MEM_REGwr===EX_REGwr ) begin
                $display("T%0d PASS (%0s): outputs match inputs", t, label);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL (%0s): outputs do not match driven inputs", t, label);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    reg [WIDTH-1:0] h_B_FWD, h_ALUresult; reg [2:0] h_funct3;
    reg h_MEMrd, h_MEMwr, h_MEMtoREG; reg [4:0] h_RD; reg h_REGwr;

    task automatic snapshot;
        begin
            h_B_FWD=MEM_B_FWD; h_ALUresult=MEM_ALUresult; h_funct3=MEM_funct3;
            h_MEMrd=MEM_MEMrd; h_MEMwr=MEM_MEMwr; h_MEMtoREG=MEM_MEMtoREG;
            h_RD=MEM_RD; h_REGwr=MEM_REGwr;
        end
    endtask

    task automatic check_held(input [127:0] label);
        begin
            if ( MEM_B_FWD===h_B_FWD && MEM_ALUresult===h_ALUresult && MEM_funct3===h_funct3 &&
                 MEM_MEMrd===h_MEMrd && MEM_MEMwr===h_MEMwr && MEM_MEMtoREG===h_MEMtoREG &&
                 MEM_RD===h_RD && MEM_REGwr===h_REGwr ) begin
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

        drive_inputs(32'hAAAA5555, 32'h12345678, 3'b101, 1'b1, 1'b1, 1'b1, 5'b11011, 1'b1);

        nRST=0; EN=1; FLUSH=0; @(posedge clk); #1; check_all_zero("reset");
        nRST=0; EN=1; FLUSH=1; @(posedge clk); #1; check_all_zero("reset>all");
        nRST=1; EN=1; FLUSH=0; @(posedge clk); #1; check_loaded("load");

        snapshot;
        drive_inputs(32'h00000000, 32'hFFFFFFFF, 3'b010, 1'b0, 1'b0, 1'b0, 5'b00100, 1'b0);
        nRST=1; EN=0; FLUSH=0; @(posedge clk); #1; check_held("hold");

        nRST=1; EN=1; FLUSH=1; @(posedge clk); #1; check_all_zero("flush>EN");

        drive_inputs(32'h11112222, 32'h33334444, 3'b010, 1'b1, 1'b0, 1'b1, 5'b01001, 1'b1);
        nRST=1; EN=1; FLUSH=0; @(posedge clk); #1; check_loaded("reload");
        nRST=1; EN=0; FLUSH=1; @(posedge clk); #1; check_all_zero("flush>hold");

        $display("=== RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule