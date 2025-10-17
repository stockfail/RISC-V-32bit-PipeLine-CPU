`timescale 1ns / 1ps
`include "defines.sv"

module MemoryAcess_Cycle(
    // global signals
    input  logic        clk,
    input  logic        reset,
    // Excute_cycle control side port
    input  logic        regFileWe_EXE,
    input  logic [ 2:0] RFWDSrcMuxSel_EXE,
    input  logic        busWe_EXE,
    // Excute_cycle data side port
    input  logic [31:0] instrCode_EXE,
    input  logic [31:0] aluResult_EXE,
    input  logic [31:0] RFData2_EXE,
    input  logic [31:0] immExt_EXE,
    input  logic [31:0] PC_Imm_AdderResult_EXE,
    input  logic [31:0] PC_4_AdderResult_EXE,
    // MemAcess_cycle control side port
    output logic        regFileWe_MEM,
    output logic [ 2:0] RFWDSrcMuxSel_MEM,
    // MemAcess_cycle data side port
    output logic [31:0] instrCode_MEM,
    output logic [31:0] aluResult_MEM,
    output logic [31:0] busRData_MEM,
    output logic [31:0] immExt_MEM,
    output logic [31:0] PC_Imm_AdderResult_MEM,
    output logic [31:0] PC_4_AdderResult_MEM
    //
    );

    logic [31:0] busRData;

    logic S_HalfEn, S_ByteEn;
    logic [2:0] funct3;
    wire [2:0] func3 = instrCode_EXE[14:12];
    wire [6:0] opcode = instrCode_EXE[6:0];
    assign S_HalfEn = ((opcode == `OP_TYPE_S) && (func3 == 3'b001)) ? 1:0;
    assign S_ByteEn = ((opcode == `OP_TYPE_S) && (func3 == 3'b000)) ? 1:0;
    assign funct3 = (opcode == `OP_TYPE_L) ? func3 : 3'b0;

    RAM U_RAM (
        .clk(clk),
        .we (busWe_EXE),
        .S_HalfEn(S_HalfEn),
        .S_ByteEn(S_ByteEn),
        .funct3(funct3),
        .addr(aluResult_EXE),
        .wData(RFData2_EXE),
        .rData(busRData)
    );

    always_ff @( posedge clk, posedge reset ) begin 
        if (reset) begin
            // MemAcess_cycle control side port
            regFileWe_MEM        <= 0;
            RFWDSrcMuxSel_MEM    <= 3'b0;
            // MemAcess_cycle data side port
            instrCode_MEM        <= 32'b0;
            aluResult_MEM        <= 32'b0;
            busRData_MEM         <= 32'b0;
            immExt_MEM           <= 32'b0;
            PC_Imm_AdderResult_MEM <= 32'b0;
            PC_4_AdderResult_MEM <= 32'b0;
        end else begin
            // MemAcess_cycle control side port
            regFileWe_MEM        <= regFileWe_EXE;
            RFWDSrcMuxSel_MEM    <= RFWDSrcMuxSel_EXE;
            // MemAcess_cycle data side port
            instrCode_MEM        <= instrCode_EXE;
            aluResult_MEM        <= aluResult_EXE;
            busRData_MEM         <= busRData;
            immExt_MEM           <= immExt_EXE;
            PC_Imm_AdderResult_MEM <= PC_Imm_AdderResult_EXE;
            PC_4_AdderResult_MEM <= PC_4_AdderResult_EXE;
        end
    end
endmodule