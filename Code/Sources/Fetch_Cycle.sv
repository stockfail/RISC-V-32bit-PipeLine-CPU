`timescale 1ns / 1ps

module Fetch_Cycle(
    // global signals
    input  logic        clk,
    input  logic        reset,
    // Execute_Cycle side port
    input  logic        PC_SrcMuxSel,
    input  logic [31:0] PC_Imm_AdderResult,
    // Fetch_Cycle side port
    output logic [31:0] instrCode_IF,
    output logic [31:0] PCOutData_IF,
    output logic [31:0] PC_4_AdderResult_IF,
    // Hazard_Unit side port
    input  logic        PCEn,
    input  logic        stall,
    input  logic        flush_IF
    );

    logic [31:0] PCOutData, PCSrcMuxOut, instrCode, PC_4_AdderResult;

    ROM U_instructionMemory (
        .addr(PCOutData),
        .data(instrCode)
    );

    mux_2x1 U_PCSrcMux (
        .sel(PC_SrcMuxSel),
        .x0 (PC_4_AdderResult),
        .x1 (PC_Imm_AdderResult),
        .y  (PCSrcMuxOut)
    );

    adder U_PC_4_Adder (
        .a(32'd4),
        .b(PCOutData),
        .y(PC_4_AdderResult)
    );

    registerEn U_PC (
        .clk  (clk),
        .reset(reset),
        .en   (PCEn),
        .d    (PCSrcMuxOut),
        .q    (PCOutData)
    );

    always_ff @( posedge clk, posedge reset ) begin
        if (reset) begin
            instrCode_IF          <= 32'b0;
            PCOutData_IF          <= 32'b0;
            PC_4_AdderResult_IF   <= 32'b0;
        end else begin
            // 우선순위(flush > stall) 
            if (flush_IF) begin
                instrCode_IF          <= 32'b0; // NOP instruction
                PCOutData_IF          <= 32'b0;
                PC_4_AdderResult_IF   <= 32'b0;
            end else if (stall) begin
                instrCode_IF          <= instrCode_IF;
                PCOutData_IF          <= PCOutData_IF;
                PC_4_AdderResult_IF   <= PC_4_AdderResult_IF;
            end 
            else begin
                instrCode_IF          <= instrCode;
                PCOutData_IF          <= PCOutData;
                PC_4_AdderResult_IF   <= PC_4_AdderResult;
            end
        end
    end

endmodule