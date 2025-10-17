`timescale 1ns / 1ps

module MCU (
    input logic clk,
    input logic reset
);

    // EXecute_Cycle -> Fetch_Cycle
    logic        PC_SrcMuxSel;
    logic [31:0] PC_Imm_AdderResult;
    // Fetch_Cycle -> Decode_Cycle
    logic [31:0] instrCode_IF, PCOutData_IF, PC_4_AdderResult_IF;
    // WriteBack_Cycle -> Decode_Cycle
    logic        regFileWe_WB;
    logic [31:0] RFWDSrcMuxOut_WB, instrCode_WB;
    // Decode_Cycle -> Excute_Cycle
    logic        regFileWe_ID, busWe_ID, branch_ID, jal_ID, jalr_ID, aluSrcMuxSel_ID;
    logic [ 2:0] RFWDSrcMuxSel_ID;
    logic [ 3:0] aluControl_ID;
    logic [31:0] instrCode_ID, RFData1_ID, RFData2_ID, immExt_ID, PCOutData_ID, PC_4_AdderResult_ID;
    // Excute_Cycle -> MemoryAcess_Cycle
    logic        regFileWe_EXE, busWe_EXE;
    logic [ 2:0] RFWDSrcMuxSel_EXE;
    logic [31:0] instrCode_EXE, aluResult_EXE, RFData2_EXE, immExt_EXE, PC_Imm_AdderResult_EXE, PC_4_AdderResult_EXE;
    // MemoryAcess_Cycle -> WriteBack_Cycle
    logic        regFileWe_MEM;
    logic [ 2:0] RFWDSrcMuxSel_MEM;
    logic [31:0] instrCode_MEM, aluResult_MEM, busRData_MEM, immExt_MEM, PC_Imm_AdderResult_MEM, PC_4_AdderResult_MEM;
    // Hazard_Unit
    logic [1:0] Forward1, Forward2;
    logic       PCEn, stall, flush_IF;

    Hazard_Unit U_Hazard_Unit(
        .instrCode_IF       (instrCode_IF),
        .instrCode_ID       (instrCode_ID),
        .instrCode_EXE      (instrCode_EXE),
        .instrCode_MEM      (instrCode_MEM),
        .instrCode_WB       (instrCode_WB),
        .regFileWe_EXE      (regFileWe_EXE),
        .regFileWe_MEM      (regFileWe_MEM),
        .PC_SrcMuxSel        (PC_SrcMuxSel),
        .Forward1           (Forward1),
        .Forward2           (Forward2),
        .PCEn               (PCEn),
        .flush_IF           (flush_IF), //
        .stall              (stall)
    );

    Fetch_Cycle         U_Fetch_Cycle(
        // global signals
        .clk                (clk),
        .reset              (reset),
        // Decode_Cycle side port
        .PC_SrcMuxSel       (PC_SrcMuxSel),
        .PC_Imm_AdderResult (PC_Imm_AdderResult),
        //Fetch_Cycle side port
        .instrCode_IF       (instrCode_IF),
        .PCOutData_IF       (PCOutData_IF),
        .PC_4_AdderResult_IF(PC_4_AdderResult_IF),
        //Hazard_Unit side port
        .PCEn               (PCEn),
        .stall              (stall),
        .flush_IF           (flush_IF) //
    );
    Decode_Cycle        U_Decode_Cycle(
        // global signals
        .clk                (clk),
        .reset              (reset),
        // Fetch_Cycle side port
        .instrCode_IF       (instrCode_IF),
        .PCOutData_IF       (PCOutData_IF),
        .PC_4_AdderResult_IF(PC_4_AdderResult_IF),
        // WB_Cycle side port
        .regFileWe_WB      (regFileWe_WB),
        .RFWDSrcMuxOut_WB  (RFWDSrcMuxOut_WB),
        .instrCode_WB      (instrCode_WB),
        // Decode_Cycle control side port
        .regFileWe_ID      (regFileWe_ID),
        .RFWDSrcMuxSel_ID  (RFWDSrcMuxSel_ID),
        .busWe_ID          (busWe_ID),
        //.branch_ID         (branch_ID),
        //.jal_ID            (jal_ID),
        //.jalr_ID           (jalr_ID),
        .aluSrcMuxSel_ID   (aluSrcMuxSel_ID),
        .aluControl_ID     (aluControl_ID),
        // Decode_Cycle data side port
        .instrCode_ID      (instrCode_ID),
        .RFData1_ID        (RFData1_ID),
        .RFData2_ID        (RFData2_ID),
        .immExt_ID         (immExt_ID),
        //.PCOutData_ID      (PCOutData_ID),
        .PC_4_AdderResult_ID(PC_4_AdderResult_ID),
        .PC_Imm_AdderResult_ID(PC_Imm_AdderResult_ID),
        //Hazard_Unit side port
        .stall             (stall),
        .PC_SrcMuxSel       (PC_SrcMuxSel),
        .PC_Imm_AdderResult(PC_Imm_AdderResult)
    );
    Excute_Cycle        U_Excute_Cycle(
        // global signals
        .clk                (clk),
        .reset              (reset),
        // Decode_Cycle control side port
        .regFileWe_ID      (regFileWe_ID),
        .RFWDSrcMuxSel_ID  (RFWDSrcMuxSel_ID),
        .busWe_ID          (busWe_ID),
        //.branch_ID         (branch_ID),
        //.jal_ID            (jal_ID),
        //.jalr_ID           (jalr_ID),
        .aluSrcMuxSel_ID   (aluSrcMuxSel_ID),
        .aluControl_ID     (aluControl_ID),
        // Decode_Cycle data side port
        .instrCode_ID      (instrCode_ID),
        .RFData1_ID        (RFData1_ID),
        .RFData2_ID        (RFData2_ID),
        .immExt_ID         (immExt_ID),
        //.PCOutData_ID      (PCOutData_ID),
        .PC_4_AdderResult_ID(PC_4_AdderResult_ID),
        .PC_Imm_AdderResult_ID(PC_Imm_AdderResult_ID),
        // WriteBack_cycle data side port
        .RFWDSrcMuxOut_WB  (RFWDSrcMuxOut_WB),
        // Excute_cycle control side port
        .regFileWe_EXE    (regFileWe_EXE),
        .RFWDSrcMuxSel_EXE(RFWDSrcMuxSel_EXE),
        .busWe_EXE        (busWe_EXE),
        // Excute_cycle data side port
        .instrCode_EXE    (instrCode_EXE),
        .aluResult_EXE    (aluResult_EXE),
        .RFData2_EXE      (RFData2_EXE),
        .immExt_EXE       (immExt_EXE),
        .PC_Imm_AdderResult_EXE(PC_Imm_AdderResult_EXE),
        .PC_4_AdderResult_EXE(PC_4_AdderResult_EXE),
        //
        //.PCSrcMuxSel     (PC_SrcMuxSel),
        //.PC_Imm_AdderResult(PC_Imm_AdderResult), // 확인바람
        //Hazard_Unit side port
        .Forward1         (Forward1),
        .Forward2         (Forward2)
        //.branch           (branch) //
    );
    MemoryAcess_Cycle   U_MemoryAcess_Cycle(
        // global signals
        .clk                (clk),
        .reset              (reset),
        // Excute_cycle control side port
        .regFileWe_EXE    (regFileWe_EXE),
        .RFWDSrcMuxSel_EXE(RFWDSrcMuxSel_EXE),
        .busWe_EXE        (busWe_EXE),
        // Excute_cycle data side port
        .instrCode_EXE    (instrCode_EXE),
        .aluResult_EXE    (aluResult_EXE),
        .RFData2_EXE      (RFData2_EXE),
        .immExt_EXE       (immExt_EXE),
        .PC_Imm_AdderResult_EXE(PC_Imm_AdderResult_EXE),
        .PC_4_AdderResult_EXE(PC_4_AdderResult_EXE),
        // MemAcess_cycle control side port
        .regFileWe_MEM    (regFileWe_MEM),
        .RFWDSrcMuxSel_MEM(RFWDSrcMuxSel_MEM),
        // MemAcess_cycle data side port
        .instrCode_MEM    (instrCode_MEM),
        .aluResult_MEM    (aluResult_MEM),
        .busRData_MEM     (busRData_MEM),
        .immExt_MEM       (immExt_MEM),
        .PC_Imm_AdderResult_MEM(PC_Imm_AdderResult_MEM),
        .PC_4_AdderResult_MEM(PC_4_AdderResult_MEM)
    );
    WriteBack_Cycle     U_WriteBack_Cycle(
        // global signals
        .clk                (clk),
        .reset              (reset),
        // MemAcess_cycle control side port
        .regFileWe_MEM    (regFileWe_MEM),
        .RFWDSrcMuxSel_MEM(RFWDSrcMuxSel_MEM),
        // MemAcess_cycle data side port
        .instrCode_MEM    (instrCode_MEM),
        .aluResult_MEM    (aluResult_MEM),
        .busRData_MEM     (busRData_MEM),
        .immExt_MEM       (immExt_MEM),
        .PC_Imm_AdderResult_MEM(PC_Imm_AdderResult_MEM),
        .PC_4_AdderResult_MEM(PC_4_AdderResult_MEM),
        // WriteBack_cycle control side port
        .regFileWe_WB    (regFileWe_WB),
        // WriteBack_cycle data side port
        .instrCode_WB    (instrCode_WB),
        .RFWDSrcMuxOut_WB(RFWDSrcMuxOut_WB)
    );
    
endmodule
