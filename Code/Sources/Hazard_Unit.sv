`timescale 1ns / 1ps
`include "defines.sv"

module Hazard_Unit(
    input  logic [31:0] instrCode_IF,
    input  logic [31:0] instrCode_ID,
    input  logic [31:0] instrCode_EXE,
    input  logic [31:0] instrCode_MEM,
    input  logic [31:0] instrCode_WB,
    input  logic        regFileWe_EXE,
    input  logic        regFileWe_MEM,
    input  logic        PC_SrcMuxSel,
    output logic [ 1:0] Forward1,
    output logic [ 1:0] Forward2,
    output logic        PCEn,
    output logic        flush_IF, //
    //output logic        flush_ID, //
    output logic        stall
    );

    wire  [6:0] opcode_IF   = instrCode_IF[6:0];
    wire  [4:0] rs2_IF      = instrCode_IF[24:20];
    wire  [4:0] rs1_IF      = instrCode_IF[19:15];
    wire  [4:0] rd_IF       = instrCode_IF[11:7];

    wire  [6:0] opcode_ID   = instrCode_ID[6:0];
    wire  [4:0] rs2_ID      = instrCode_ID[24:20];
    wire  [4:0] rs1_ID      = instrCode_ID[19:15];
    wire  [4:0] rd_ID       = instrCode_ID[11:7];

    wire  [6:0] opcode_EXE  = instrCode_EXE[6:0];
    wire  [4:0] rs2_EXE     = instrCode_EXE[24:20];
    wire  [4:0] rs1_EXE     = instrCode_EXE[19:15];
    wire  [4:0] rd_EXE      = instrCode_EXE[11:7];

    wire  [6:0] opcode_MEM  = instrCode_MEM[6:0];
    wire  [4:0] rs2_MEM     = instrCode_MEM[24:20];
    wire  [4:0] rs1_MEM     = instrCode_MEM[19:15];
    wire  [4:0] rd_MEM      = instrCode_MEM[11:7];

    logic Load_UseDataHazard;

    assign Load_UseDataHazard = ((opcode_ID == `OP_TYPE_L) && ((rd_ID == rs1_IF) || (rd_ID == rs2_IF))) ? 1:0;
    assign PCEn     = ~Load_UseDataHazard;
    assign stall    =  Load_UseDataHazard;

    // 새로운 명령어는 가장 최신 rd를 원하기에 우선순위(rd_EXE > rd_MEM) 설정
    assign Forward1 = ((regFileWe_EXE == 1'b1) && (rd_EXE != 5'b0) && (rd_EXE == rs1_ID)) ? 2'b01 :
                      ((regFileWe_MEM == 1'b1) && (rd_MEM != 5'b0) && (rd_MEM == rs1_ID)) ? 2'b10 : 2'b00; 
    assign Forward2 = ((regFileWe_EXE == 1'b1) && (rd_EXE != 5'b0) && (rd_EXE == rs2_ID)) ? 2'b01 :
                      ((regFileWe_MEM == 1'b1) && (rd_MEM != 5'b0) && (rd_MEM == rs2_ID)) ? 2'b10 : 2'b00;

    assign flush_IF = PC_SrcMuxSel;


endmodule
