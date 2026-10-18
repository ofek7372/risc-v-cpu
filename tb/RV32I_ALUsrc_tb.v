`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_ALUsrc_tb
// Self-checking testbench for the ALU operand-source mux.
//   000 REG   : A=R_A, B=R_B
//   001 IMM   : A=R_A, B=IMM
//   010 LUI   : A=0,   B=IMM
//   011 AUIPC : A=PC,  B=IMM
//   100 LINK  : A=PC,  B=4
//   default   : A=0,   B=0
//////////////////////////////////////////////////////////////////////////////////
module RV32I_ALUsrc_tb;

    localparam WIDTH = 32;
    localparam REGop=3'b000, IMMop=3'b001, LUI=3'b010, AUIPC=3'b011, LINKop=3'b100;

    reg  [2:0] EX_ALUsrc;
    reg  [WIDTH-1:0] EX_IMM, EX_PC, EX_R_B, EX_R_A;
    wire [WIDTH-1:0] A, B;

    integer pass, fail, t, i;

    RV32I_ALUsrc #(.WIDTH(WIDTH)) DUT (
        .EX_ALUsrc(EX_ALUsrc), .EX_IMM(EX_IMM), .EX_PC(EX_PC),
        .EX_R_B(EX_R_B), .EX_R_A(EX_R_A), .A(A), .B(B)
    );

    task automatic check(input [8*8-1:0] name, input [WIDTH-1:0] eA, eB);
        begin
            #5;
            if (A===eA && B===eB) begin
                $display("T%0d PASS: %0s", t, name);
                pass=pass+1;
            end else begin
                $error("T%0d FAIL: %0s  A=%h(exp %h) B=%h(exp %h)", t, name, A, eA, B, eB);
                fail=fail+1;
            end
            t=t+1;
        end
    endtask

    initial begin
        pass=0; fail=0; t=0;

        for (i=0;i<50;i=i+1) begin
            EX_R_A=$random; EX_R_B=$random; EX_IMM=$random; EX_PC=$random;

            EX_ALUsrc=REGop;  check("REG",   EX_R_A, EX_R_B);
            EX_ALUsrc=IMMop;  check("IMM",   EX_R_A, EX_IMM);
            EX_ALUsrc=LUI;    check("LUI",   32'b0,  EX_IMM);
            EX_ALUsrc=AUIPC;  check("AUIPC", EX_PC,  EX_IMM);
            EX_ALUsrc=LINKop; check("LINK",  EX_PC,  32'd4);
            EX_ALUsrc=3'b101; check("dflt5", 32'b0,  32'b0);
            EX_ALUsrc=3'b111; check("dflt7", 32'b0,  32'b0);
        end

        $display("=== ALUsrc RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule