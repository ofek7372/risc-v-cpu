`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RV32I_ID_EX_tb
// Description: Self-checking testbench for the ID/EX pipeline register.
//              Verifies: reset, flush, load (EN=1), hold (EN=0),
//              and the priority ordering nRST > FLUSH > EN.
//
// TEMPLATE NOTE: The other pipeline registers (EX/MEM, MEM/WB, IF/ID) are
// the same structure. To reuse: swap the DUT port list, the tb signal
// declarations, and the drive/expected values inside the tasks. The clock
// gen, counters, priority logic, and summary stay identical.
//////////////////////////////////////////////////////////////////////////////////
module RV32I_ID_EX_tb;

    localparam WIDTH = 32;
    localparam clk_period = 10;

    // ---- controls ----
    reg clk, EN, nRST, FLUSH;

    // ---- DUT inputs (drive side) ----
    reg [WIDTH-1:0] ID_R_B, ID_R_A, ID_IMM, ID_PC;
    reg [2:0]  ID_ALUsrc;
    reg [3:0]  ID_ALUctrl;
    reg [1:0]  ID_jop;
    reg        ID_bop;
    reg [4:0]  ID_RS1, ID_RS2;
    reg [2:0]  ID_funct3;
    reg        ID_MEMrd, ID_MEMwr, ID_MEMtoREG;
    reg [4:0]  ID_RD;
    reg        ID_REGwr;

    // ---- DUT outputs (monitor side) ----
    wire [WIDTH-1:0] EX_R_B, EX_R_A, EX_IMM, EX_PC;
    wire [2:0]  EX_ALUsrc;
    wire [3:0]  EX_ALUctrl;
    wire [1:0]  EX_jop;
    wire        EX_bop;
    wire [4:0]  EX_RS1, EX_RS2;
    wire [2:0]  EX_funct3;
    wire        EX_MEMrd, EX_MEMwr, EX_MEMtoREG;
    wire [4:0]  EX_RD;
    wire        EX_REGwr;

    integer pass, fail, t;

    // ---- DUT ----
    RV32I_ID_EX #(.WIDTH(WIDTH)) DUT (
        .clk(clk), .EN(EN), .nRST(nRST), .FLUSH(FLUSH),
        .ID_R_B(ID_R_B), .ID_R_A(ID_R_A), .ID_IMM(ID_IMM), .ID_PC(ID_PC),
        .ID_ALUsrc(ID_ALUsrc), .ID_ALUctrl(ID_ALUctrl), .ID_jop(ID_jop),
        .ID_bop(ID_bop), .ID_RS1(ID_RS1), .ID_RS2(ID_RS2), .ID_funct3(ID_funct3),
        .ID_MEMrd(ID_MEMrd), .ID_MEMwr(ID_MEMwr), .ID_MEMtoREG(ID_MEMtoREG),
        .ID_RD(ID_RD), .ID_REGwr(ID_REGwr),
        .EX_R_B(EX_R_B), .EX_R_A(EX_R_A), .EX_IMM(EX_IMM), .EX_PC(EX_PC),
        .EX_ALUsrc(EX_ALUsrc), .EX_ALUctrl(EX_ALUctrl), .EX_jop(EX_jop),
        .EX_bop(EX_bop), .EX_RS1(EX_RS1), .EX_RS2(EX_RS2), .EX_funct3(EX_funct3),
        .EX_MEMrd(EX_MEMrd), .EX_MEMwr(EX_MEMwr), .EX_MEMtoREG(EX_MEMtoREG),
        .EX_RD(EX_RD), .EX_REGwr(EX_REGwr)
    );

    // ---- clock ----
    initial clk = 0;
    always #(clk_period/2) clk = ~clk;

    // ---- helper: pack all inputs at once (keeps tests readable) ----
    task automatic drive_inputs(
        input [WIDTH-1:0] r_b, r_a, imm, pc,
        input [2:0] alusrc, input [3:0] aluctrl, input [1:0] jop_i,
        input bop_i, input [4:0] rs1, rs2, input [2:0] f3,
        input memrd, memwr, memtoreg, input [4:0] rd, input regwr
    );
        begin
            ID_R_B=r_b; ID_R_A=r_a; ID_IMM=imm; ID_PC=pc;
            ID_ALUsrc=alusrc; ID_ALUctrl=aluctrl; ID_jop=jop_i;
            ID_bop=bop_i; ID_RS1=rs1; ID_RS2=rs2; ID_funct3=f3;
            ID_MEMrd=memrd; ID_MEMwr=memwr; ID_MEMtoREG=memtoreg;
            ID_RD=rd; ID_REGwr=regwr;
        end
    endtask

    // ---- check: are ALL outputs zero? (reset/flush expectation) ----
    task automatic check_all_zero(input [127:0] label);
        begin
            if ( {EX_R_B,EX_R_A,EX_IMM,EX_PC} === 'b0 &&
                 {EX_ALUsrc,EX_ALUctrl,EX_jop,EX_bop,EX_RS1,EX_RS2,EX_funct3,
                  EX_MEMrd,EX_MEMwr,EX_MEMtoREG,EX_RD,EX_REGwr} === 'b0 ) begin
                $display("T%0d PASS (%0s): all outputs zero", t, label);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL (%0s): expected all-zero outputs", t, label);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    // ---- check: do outputs equal the last driven inputs? (load expectation) ----
    task automatic check_loaded(input [127:0] label);
        begin
            if ( EX_R_B===ID_R_B && EX_R_A===ID_R_A && EX_IMM===ID_IMM && EX_PC===ID_PC &&
                 EX_ALUsrc===ID_ALUsrc && EX_ALUctrl===ID_ALUctrl && EX_jop===ID_jop &&
                 EX_bop===ID_bop && EX_RS1===ID_RS1 && EX_RS2===ID_RS2 && EX_funct3===ID_funct3 &&
                 EX_MEMrd===ID_MEMrd && EX_MEMwr===ID_MEMwr && EX_MEMtoREG===ID_MEMtoREG &&
                 EX_RD===ID_RD && EX_REGwr===ID_REGwr ) begin
                $display("T%0d PASS (%0s): outputs match inputs", t, label);
                pass = pass + 1;
            end else begin
                $error("T%0d FAIL (%0s): outputs do not match driven inputs", t, label);
                fail = fail + 1;
            end
            t = t + 1;
        end
    endtask

    // ---- check: do outputs equal a captured snapshot? (hold expectation) ----
    // We compare against EX_* captured before the edge, using a saved copy.
    reg [WIDTH-1:0] h_R_B, h_R_A, h_IMM, h_PC;
    reg [2:0] h_ALUsrc; reg [3:0] h_ALUctrl; reg [1:0] h_jop; reg h_bop;
    reg [4:0] h_RS1, h_RS2; reg [2:0] h_funct3;
    reg h_MEMrd, h_MEMwr, h_MEMtoREG; reg [4:0] h_RD; reg h_REGwr;

    task automatic snapshot; // capture current outputs as the "previous value"
        begin
            h_R_B=EX_R_B; h_R_A=EX_R_A; h_IMM=EX_IMM; h_PC=EX_PC;
            h_ALUsrc=EX_ALUsrc; h_ALUctrl=EX_ALUctrl; h_jop=EX_jop; h_bop=EX_bop;
            h_RS1=EX_RS1; h_RS2=EX_RS2; h_funct3=EX_funct3;
            h_MEMrd=EX_MEMrd; h_MEMwr=EX_MEMwr; h_MEMtoREG=EX_MEMtoREG;
            h_RD=EX_RD; h_REGwr=EX_REGwr;
        end
    endtask

    task automatic check_held(input [127:0] label);
        begin
            if ( EX_R_B===h_R_B && EX_R_A===h_R_A && EX_IMM===h_IMM && EX_PC===h_PC &&
                 EX_ALUsrc===h_ALUsrc && EX_ALUctrl===h_ALUctrl && EX_jop===h_jop &&
                 EX_bop===h_bop && EX_RS1===h_RS1 && EX_RS2===h_RS2 && EX_funct3===h_funct3 &&
                 EX_MEMrd===h_MEMrd && EX_MEMwr===h_MEMwr && EX_MEMtoREG===h_MEMtoREG &&
                 EX_RD===h_RD && EX_REGwr===h_REGwr ) begin
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

        // ---- distinctive input pattern used across load/hold tests ----
        // (values chosen so every field is non-zero and distinguishable)
        drive_inputs(
            32'hAAAA5555, 32'h12345678, 32'hDEADBEEF, 32'h00000040, // R_B,R_A,IMM,PC
            3'b101, 4'b1001, 2'b10, 1'b1,                            // ALUsrc,ALUctrl,jop,bop
            5'b10101, 5'b01010, 3'b110,                              // RS1,RS2,funct3
            1'b1, 1'b1, 1'b1, 5'b11011, 1'b1                         // MEMrd,MEMwr,MEMtoREG,RD,REGwr
        );

        // === TEST 1: reset (nRST=0) forces zero, EN irrelevant ===
        nRST=0; EN=1; FLUSH=0;
        @(posedge clk); #1;
        check_all_zero("reset");

        // === TEST 2: reset priority over EN and FLUSH (all asserted) ===
        nRST=0; EN=1; FLUSH=1;
        @(posedge clk); #1;
        check_all_zero("reset>all");

        // === TEST 3: load (EN=1, no reset/flush) ===
        nRST=1; EN=1; FLUSH=0;
        @(posedge clk); #1;
        check_loaded("load");

        // === TEST 4: hold (EN=0) keeps loaded value ===
        // snapshot the just-loaded outputs, change inputs, confirm no change
        snapshot;
        drive_inputs(  // change every input to prove hold ignores them
            32'h00000000, 32'hFFFFFFFF, 32'h0F0F0F0F, 32'h000000F0,
            3'b010, 4'b0011, 2'b01, 1'b0,
            5'b00001, 5'b11111, 3'b001,
            1'b0, 1'b0, 1'b0, 5'b00100, 1'b0
        );
        nRST=1; EN=0; FLUSH=0;
        @(posedge clk); #1;
        check_held("hold");

        // === TEST 5: flush (FLUSH=1, EN=1) zeros outputs, flush beats load ===
        nRST=1; EN=1; FLUSH=1;
        @(posedge clk); #1;
        check_all_zero("flush>EN");

        // === TEST 6: reload after flush, then flush-with-hold (FLUSH=1, EN=0) ===
        drive_inputs(
            32'h11112222, 32'h33334444, 32'h55556666, 32'h00000080,
            3'b001, 4'b0101, 2'b01, 1'b1,
            5'b00011, 5'b00101, 3'b010,
            1'b1, 1'b0, 1'b1, 5'b01001, 1'b1
        );
        nRST=1; EN=1; FLUSH=0;  @(posedge clk); #1;  // load a known value
        check_loaded("reload");
        nRST=1; EN=0; FLUSH=1;  @(posedge clk); #1;  // flush should win over hold
        check_all_zero("flush>hold");

        $display("=== RESULTS: %0d passed, %0d failed ===", pass, fail);
        $finish;
    end
endmodule