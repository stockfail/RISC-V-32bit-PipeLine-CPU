`timescale 1ns / 1ps
`include "defines.sv"

module Decode_Cycle(
    // global signals
    input  logic        clk,
    input  logic        reset,
    // Fetch_Cycle side port
    input  logic [31:0] instrCode_IF,
    input  logic [31:0] PCOutData_IF,
    input  logic [31:0] PC_4_AdderResult_IF,
    // WB_Cycle side port
    input  logic        regFileWe_WB,
    input  logic [31:0] RFWDSrcMuxOut_WB,
    input  logic [31:0] instrCode_WB,
    // Decode_Cycle control side port
    output logic        regFileWe_ID,
    output logic [ 2:0] RFWDSrcMuxSel_ID,
    output logic        busWe_ID,
    //output logic        branch_ID,
    //output logic        jal_ID,
    //output logic        jalr_ID,
    output logic        aluSrcMuxSel_ID,
    output logic [ 3:0] aluControl_ID,
    // Decode_Cycle data side port
    output logic [31:0] instrCode_ID,
    output logic [31:0] RFData1_ID,
    output logic [31:0] RFData2_ID,
    output logic [31:0] immExt_ID,
    //output logic [31:0] PCOutData_ID,
    output logic [31:0] PC_4_AdderResult_ID,
    output logic [31:0] PC_Imm_AdderResult_ID,
    //
    output logic [31:0] PC_Imm_AdderResult,
    //Hazard_Unit side port
    input  logic        stall,
    //input  logic        flush_ID,
    output logic        PC_SrcMuxSel
    );
    // Control
    logic [2:0] RFWDSrcMuxSel;
    logic [3:0] aluControl;
    logic       regFileWe, busWe, branch, jalr, aluSrcMuxSel;
    // Data
    logic [31:0] RFData1, RFData2, immExt, PC_Imm_AdderSrcMuxOut;

    logic btaken;


    ControlUnit U_ControlUnit (
        .clk(clk),
        .reset(reset),
        .instrCode(instrCode_IF),
        .stall(stall), //
        //.flush_ID(flush_ID), //
        .regFileWe(regFileWe),
        .aluControl(aluControl),
        .aluSrcMuxSel(aluSrcMuxSel),
        .busWe(busWe),
        .RFWDSrcMuxSel(RFWDSrcMuxSel),
        .branch(branch),
        .jal(jal),
        .jalr(jalr)
    );

    RegisterFile U_RegFile (
        .clk(clk),
        .we (regFileWe_WB),
        .RA1(instrCode_IF[19:15]),
        .RA2(instrCode_IF[24:20]),
        .WA (instrCode_WB[11:7]),
        .WD (RFWDSrcMuxOut_WB),
        .RD1(RFData1),
        .RD2(RFData2)
    );

    immExtend U_ImmExtend (
        .instrCode(instrCode_IF),
        .immExt   (immExt)
    );

    assign PC_SrcMuxSel = jal | (btaken & branch);

    always_comb begin
        btaken = 1'b0;
        case (aluControl[2:0])
            `BEQ:  btaken = (RFData1 == RFData2);
            `BNE:  btaken = (RFData1 != RFData2);
            `BLT:  btaken = ($signed(RFData1) < $signed(RFData2));
            `BGE:  btaken = ($signed(RFData1) >= $signed(RFData2));
            `BLTU: btaken = (RFData1 < RFData2);
            `BGEU: btaken = (RFData1 >= RFData2);
        endcase
    end

    mux_2x1 U_PC_Imm_AdderSrcMux (
        .sel(jalr),
        .x0 (PCOutData_IF),
        .x1 (RFData1),
        .y  (PC_Imm_AdderSrcMuxOut)
    );

    adder U_PC_Imm_Adder (
        .a(immExt),
        .b(PC_Imm_AdderSrcMuxOut),
        .y(PC_Imm_AdderResult)
    );

    always_ff @( posedge clk, posedge reset ) begin 
        if (reset) begin
            // Decode_Cycle control side port
            regFileWe_ID        <= 0;
            RFWDSrcMuxSel_ID    <= 3'b0;
            busWe_ID            <= 0;
            //branch_ID           <= 0;
            //jal_ID              <= 0;
            //jalr_ID             <= 0;
            aluSrcMuxSel_ID     <= 0;
            aluControl_ID       <= 4'b0;
            // Decode_Cycle data side port
            instrCode_ID        <= 32'b0;
            RFData1_ID         <= 32'b0;
            RFData2_ID         <= 32'b0;
            immExt_ID          <= 32'b0;
            //PCOutData_ID      <= 32'b0;
            PC_4_AdderResult_ID <= 32'b0;
            PC_Imm_AdderResult_ID <= 32'b0;
        end else begin
            // Decode_Cycle control side port
            regFileWe_ID        <= regFileWe;
            RFWDSrcMuxSel_ID    <= RFWDSrcMuxSel;
            busWe_ID            <= busWe;
            //branch_ID           <= branch;
            //jal_ID              <= jal;
            //jalr_ID             <= jalr;
            aluSrcMuxSel_ID     <= aluSrcMuxSel;
            aluControl_ID       <= aluControl;
            // Decode_Cycle data side port
            instrCode_ID        <= instrCode_IF;
            RFData1_ID         <= RFData1;
            RFData2_ID         <= RFData2;
            immExt_ID          <= immExt;
            //PCOutData_ID      <= PCOutData_IF;
            PC_4_AdderResult_ID <= PC_4_AdderResult_IF;
            PC_Imm_AdderResult_ID <= PC_Imm_AdderResult;
        end
    end
endmodule
