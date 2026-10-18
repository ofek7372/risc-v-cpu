`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_Target_adder_tb
// Self-checking testbench for the branch/jump target adder.
//   jop != 10 (branch/JAL): target = PC + IMM
//   jop == 10 (JALR)      : target = (A_FWD + IMM) & ~1   (bit 0 cleared)
//////////////////////////////////////////////////////////////////////////////////
module RV32I_Target_adder_tb;

    localparam WIDTH = 32;
    localparam JALR = 2'b10;

    reg  [1:0] EX_jop;
    reg  [WIDTH-1:0] EX_PC, EX_IMM, A_FWD;
    wire [WIDTH-1:0] target;

    integer pass, fail, t, i;

    RV32I_Target_adder #(.WIDTH(WIDTH)) DUT (
        .EX_jop(EX_jop), .EX_PC(EX_PC), .EX_IMM(EX_IMM), .A_FWD(A_FWD),
        .target(target)
    );

    function [WIDTH-1:0] exptarget(input [1:0] jop, input [WIDTH-1:0] pc, imm, a);
        begin
            if (jop == JALR) exptarget = (a + imm) & ~32'b1;
            else             exptarget = pc + imm;
        end
    endfunction

    task automatic check(input [8*10-1:0] name);
        reg [WIDTH-1:0] e;
        begin
            #5;
            e = exptarget(EX_jop, EX_PC, EX_IMM, A_FWD);
            if (target === e) begin
                $display("T%0d PASS: %0s target=%h", t, name, target);
                pass=pass+1;
            end else begin
                $error("T%0d FAIL: %0s jop=%b PC=%h IMM=%h A=%h target=%h exp=%h",
                        t, name, EX_jop, EX_PC, EX_IMM, A_FWD, target, e);
                fail=fail+1;
            end
            t=t+1;
        end
    endtask

    initial begin
        pass=0; fail=0; t=0;

        // ===== branch/JAL path: PC + IMM =====
        EX_jop=2'b00; EX_PC=32'h00001000; EX_IMM=32'h00000010; A_FWD=32'hDEAD;
        check("BR_fwd");                                  // 0x1010
        EX_jop=2'b01; EX_PC=32'h00001000; EX_IMM=32'hFFFFFFF0; A_FWD=32'hDEAD;
        check("JAL_back");                                // backward: 0x0FF0
        EX_jop=2'b00; EX_PC=32'h00002000; EX_IMM=32'h00000000; A_FWD=32'hDEAD;
        check("BR_zero");                                 // 0x2000

        // ===== JALR: (A_FWD + IMM) & ~1, uses A_FWD not PC =====
        EX_jop=JALR; EX_PC=32'hFFFFFFFF; EX_IMM=32'h00000004; A_FWD=32'h00003000;
        check("JALR_even");                               // 0x3004, PC ignored
        EX_jop=JALR; EX_PC=32'h0; EX_IMM=32'h00000003; A_FWD=32'h00003000;
        check("JALR_odd");                                // 0x3003 -> &~1 -> 0x3002
        EX_jop=JALR; EX_PC=32'h0; EX_IMM=32'h00000001; A_FWD=32'h00003000;
        check("JALR_lsb");                                // 0x3001 -> 0x3000
        EX_jop=JALR; EX_PC=32'h0; EX_IMM=32'hFFFFFFFF; A_FWD=32'h00003000;
        check("JALR_negI");                               // 0x2FFF -> &~1 -> 0x2FFE

        // ===== confirm JALR ignores PC entirely =====
        EX_jop=JALR; EX_PC=32'hAAAAAAAA; EX_IMM=32'h0; A_FWD=32'h00000010;
        check("JALR_noPC");                               // 0x10, not PC-derived

        // ===== random =====
        for (i=0;i<300;i=i+1) begin
            EX_jop=$random; EX_PC=$random; EX_IMM=$random; A_FWD=$random;
            check("RND");
        end

        $display("=== TARGET RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule