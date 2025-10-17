`timescale 1ns / 1ps

module Excute_Cycle(
    // global signals
    input  logic        clk,
    input  logic        reset,
    // Decode_Cycle control side port
    input  logic        regFileWe_ID,
    input  logic [ 2:0] RFWDSrcMuxSel_ID,
    input  logic        busWe_ID,
   // input  logic        branch_ID,
   // input  logic        jal_ID,
    //input  logic        jalr_ID,
    input  logic        aluSrcMuxSel_ID,
    input  logic [ 3:0] aluControl_ID,
    // Decode_Cycle data side port
    input  logic [31:0] instrCode_ID,
    input  logic [31:0] RFData1_ID,
    input  logic [31:0] RFData2_ID,
    input  logic [31:0] immExt_ID,
    //input  logic [31:0] PCOutData_ID,
    input  logic [31:0] PC_4_AdderResult_ID,
    input  logic [31:0] PC_Imm_AdderResult_ID,
    // WriteBack_cycle data side port
    input  logic [31:0] RFWDSrcMuxOut_WB,
    // Excute_cycle control side port
    output logic        regFileWe_EXE,
    output logic [ 2:0] RFWDSrcMuxSel_EXE,
    output logic        busWe_EXE,
    // Excute_cycle data side port
    output logic [31:0] instrCode_EXE,
    output logic [31:0] aluResult_EXE,
    output logic [31:0] RFData2_EXE,
    output logic [31:0] immExt_EXE,
    output logic [31:0] PC_Imm_AdderResult_EXE,
    output logic [31:0] PC_4_AdderResult_EXE,
    //
    //output logic        PCSrcMuxSel,
    //output logic [31:0] PC_Imm_AdderResult, // 확인바람
    //HazardUnit control side port
    input  logic [ 1:0]  Forward1, //
    input  logic [ 1:0]  Forward2 //
    //output logic         branch //
    );

    logic [31:0] aluResult, aluSrcMuxOut, PC_Imm_AdderSrcMuxOut, DataHazardMux1_Out, DataHazardMux2_Out;
    logic btaken;

    mux_3x1 U_DataHazardMux1(
        .sel(Forward1),
        .x0 (RFData1_ID),
        .x1 (aluResult_EXE),
        .x2 (RFWDSrcMuxOut_WB),
        .y  (DataHazardMux1_Out)
    );

    mux_3x1 U_DataHazardMux2(
        .sel(Forward2),
        .x0 (RFData2_ID),
        .x1 (aluResult_EXE),
        .x2 (RFWDSrcMuxOut_WB),
        .y  (DataHazardMux2_Out)
    );

    mux_2x1 U_AluSrcMux (
        .sel(aluSrcMuxSel_ID),
        .x0 (DataHazardMux2_Out),
        .x1 (immExt_ID),
        .y  (aluSrcMuxOut)
    );

    alu U_ALU (
        .aluControl(aluControl_ID),
        .a         (DataHazardMux1_Out),
        .b         (aluSrcMuxOut),
        .result    (aluResult)
        //
    );

    //assign branch = btaken & branch_ID;
   // assign PCSrcMuxSel = jal_ID | branch;
/*
    mux_2x1 U_PC_Imm_AdderSrcMux (
        .sel(jalr_ID),
        .x0 (PCOutData_ID),
        .x1 (RFData1_ID),
        .y  (PC_Imm_AdderSrcMuxOut)
    );

    adder U_PC_Imm_Adder (
        .a(immExt_ID),
        .b(PC_Imm_AdderSrcMuxOut),
        .y(PC_Imm_AdderResult)
    );
*/
    always_ff @( posedge clk, posedge reset ) begin 
        if (reset) begin
            // Execute_Cycle control side port
            regFileWe_EXE            <= 0;
            RFWDSrcMuxSel_EXE        <= 3'b0;
            busWe_EXE                <= 0;
            // Execute_Cycle data side port
            instrCode_EXE            <= 32'b0;
            aluResult_EXE            <= 32'b0;
            RFData2_EXE              <= 32'b0;
            immExt_EXE               <= 32'b0;
            PC_Imm_AdderResult_EXE   <= 32'b0;
            PC_4_AdderResult_EXE     <= 32'b0;
        end else begin
            // Execute_Cycle control side port
            regFileWe_EXE            <= regFileWe_ID;
            RFWDSrcMuxSel_EXE        <= RFWDSrcMuxSel_ID;
            busWe_EXE                <= busWe_ID;
            // Execute_Cycle data side port
            instrCode_EXE            <= instrCode_ID;
            aluResult_EXE            <= aluResult;
            RFData2_EXE              <= RFData2_ID;
            immExt_EXE               <= immExt_ID;
            PC_Imm_AdderResult_EXE   <= PC_Imm_AdderResult_ID;
            PC_4_AdderResult_EXE     <= PC_4_AdderResult_ID;
        end
    end
endmodule
