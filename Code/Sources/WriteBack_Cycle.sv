`timescale 1ns / 1ps

module WriteBack_Cycle(
    // global signals
    input  logic        clk,
    input  logic        reset,
    // MemAcess_cycle control side port
    input  logic        regFileWe_MEM,
    input  logic [ 2:0] RFWDSrcMuxSel_MEM,
    // MemAcess_cycle data side port
    input  logic [31:0] instrCode_MEM,
    input  logic [31:0] aluResult_MEM,
    input  logic [31:0] busRData_MEM,
    input  logic [31:0] immExt_MEM,
    input  logic [31:0] PC_Imm_AdderResult_MEM,
    input  logic [31:0] PC_4_AdderResult_MEM,
    // WriteBack_cycle control side port
    output logic        regFileWe_WB,
    // WriteBack_cycle data side port
    output logic [31:0] instrCode_WB,
    output logic [31:0] RFWDSrcMuxOut_WB
    );

    assign regFileWe_WB = regFileWe_MEM;
    assign instrCode_WB = instrCode_MEM;

    mux_5x1 U_RFWDSrcMux (
        .sel(RFWDSrcMuxSel_MEM),
        .x0 (aluResult_MEM),
        .x1 (busRData_MEM),
        .x2 (immExt_MEM),
        .x3 (PC_Imm_AdderResult_MEM),
        .x4 (PC_4_AdderResult_MEM),
        .y  (RFWDSrcMuxOut_WB)
    );
endmodule
