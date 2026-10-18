`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_branch_tb
// Self-checking testbench for the branch evaluation unit.
//   bop=0 -> taken=0 always.
//   BEQ(000): taken=zero      BNE(001): taken=~zero
//   BLT(100): taken=ALUres[0] BGE(101): taken=~ALUres[0]
//   BLTU(110):taken=ALUres[0] BGEU(111):taken=~ALUres[0]
// (signed/unsigned is the ALU's job; this unit only applies polarity by funct3)
//////////////////////////////////////////////////////////////////////////////////
module RV32I_branch_tb;

    localparam WIDTH = 32;
    localparam BEQ=3'b000, BNE=3'b001, BLT=3'b100, BGE=3'b101, BLTU=3'b110, BGEU=3'b111;

    reg  bop, zero;
    reg  [2:0] EX_funct3;
    reg  [WIDTH-1:0] EX_ALUresult;
    wire taken;

    integer pass, fail, t;

    RV32I_branch #(.WIDTH(WIDTH)) DUT (
        .bop(bop), .zero(zero), .EX_funct3(EX_funct3),
        .EX_ALUresult(EX_ALUresult), .taken(taken)
    );

    function exptaken(input b, input z, input [2:0] f3, input [WIDTH-1:0] alu);
        begin
            if (!b) exptaken = 1'b0;
            else case (f3)
                BEQ:  exptaken = z;
                BNE:  exptaken = ~z;
                BLT:  exptaken = alu[0];
                BGE:  exptaken = ~alu[0];
                BLTU: exptaken = alu[0];
                BGEU: exptaken = ~alu[0];
                default: exptaken = 1'b0;
            endcase
        end
    endfunction

    task automatic check(input [8*10-1:0] name);
        reg e;
        begin
            #5;
            e = exptaken(bop, zero, EX_funct3, EX_ALUresult);
            if (taken === e) begin
                $display("T%0d PASS: %0s taken=%b", t, name, taken);
                pass=pass+1;
            end else begin
                $error("T%0d FAIL: %0s bop=%b zero=%b f3=%b alu0=%b taken=%b exp=%b",
                        t, name, bop, zero, EX_funct3, EX_ALUresult[0], taken, e);
                fail=fail+1;
            end
            t=t+1;
        end
    endtask

    integer fi, zz, aa;
    initial begin
        pass=0; fail=0; t=0;

        // ===== bop=0 gate: taken must be 0 for every funct3 =====
        bop=0; zero=1; EX_ALUresult=32'h1;
        EX_funct3=BEQ;  check("gate_BEQ");
        EX_funct3=BNE;  check("gate_BNE");
        EX_funct3=BLT;  check("gate_BLT");
        EX_funct3=BGEU; check("gate_BGEU");

        // ===== exhaustive: bop=1, each funct3, both zero values, both alu[0] values =====
        bop=1;
        for (fi=0; fi<6; fi=fi+1) begin
            case(fi)
                0: EX_funct3=BEQ; 1: EX_funct3=BNE;  2: EX_funct3=BLT;
                3: EX_funct3=BGE; 4: EX_funct3=BLTU; 5: EX_funct3=BGEU;
            endcase
            for (zz=0; zz<2; zz=zz+1) begin
                zero = zz[0];
                for (aa=0; aa<2; aa=aa+1) begin
                    EX_ALUresult = aa;            // exercises bit 0 = 0 and 1
                    check("exhaustive");
                end
            end
        end

        // ===== confirm upper ALU bits are ignored (only bit 0 matters) =====
        bop=1; EX_funct3=BLT; zero=0;
        EX_ALUresult=32'hFFFFFFFE; check("BLT_hi_ignored");  // bit0=0 -> not taken
        EX_ALUresult=32'hFFFFFFFF; check("BLT_hi_taken");    // bit0=1 -> taken

        // ===== invalid funct3 with bop=1 -> default not taken =====
        bop=1; EX_funct3=3'b010; zero=1; EX_ALUresult=32'h1;
        check("invalid_f3");

        $display("=== BRANCH RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule