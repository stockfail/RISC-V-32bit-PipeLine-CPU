`timescale 1ns / 1ps

module RAM(
    input logic clk,
    input logic we,
    input logic S_HalfEn,
    input logic S_ByteEn,
    input logic [2:0] funct3,
    input logic [31:0] addr,
    input logic [31:0] wData,
    output logic [31:0] rData
    );
    logic [31:0] mem[0:9];

    always_ff @( posedge clk ) begin
        if (we) begin
            if (S_HalfEn) begin
                if (addr[31:1] % 2) mem[addr[31:2]][31:16] <= wData[15:0];
                else mem[addr[31:2]][15:0] <= wData[15:0];
            end
            else if (S_ByteEn) begin
                if(addr % 4 == 0) mem[addr[31:2]][7:0] <= wData[7:0]; 
                else if(addr % 4 == 1) mem[addr[31:2]][15:8] <= wData[7:0]; 
                else if(addr % 4 == 2) mem[addr[31:2]][23:16] <= wData[7:0];
                else mem[addr[31:2]][31:24] <= wData[7:0];
            end
            else mem[addr[31:2]] <= wData;
        end
    end

    always_comb begin 
        rData = 32'bx; //Latch 방지
        case (funct3)
            3'b000: begin
                if (addr % 4 == 1) rData = {{24{mem[addr[31:2]][15]}}, mem[addr[31:2]][15:8]};
                if (addr % 4 == 2) rData = {{24{mem[addr[31:2]][23]}}, mem[addr[31:2]][23:16]};
                if (addr % 4 == 3) rData = {{24{mem[addr[31:2]][31]}}, mem[addr[31:2]][31:24]};
                else rData = {{24{mem[addr[31:2]][7]}}, mem[addr[31:2]][7:0]};
            end
            3'b001: begin
                if (addr[31:1] % 2) rData = {{16{mem[addr[31:2]][31]}}, mem[addr[31:2]][31:16]};
                else rData = {{16{mem[addr[31:2]][15]}}, mem[addr[31:2]][15:0]};
            end
            3'b100: begin
                if (addr % 4 == 1) rData = {{24{1'b0}}, mem[addr[31:2]][15:8]};
                if (addr % 4 == 2) rData = {{24{1'b0}}, mem[addr[31:2]][23:16]};
                if (addr % 4 == 3) rData = {{24{1'b0}}, mem[addr[31:2]][31:24]};
                else rData = {{24{1'b0}}, mem[addr[31:2]][7:0]}; 
            end
            3'b101: begin
                if (addr[31:1] % 2) rData = {{16{1'b0}}, mem[addr[31:2]][31:16]};
                else rData = {{16{1'b0}}, mem[addr[31:2]][15:0]};
            end
            3'b010: rData = mem[addr[31:2]];
        endcase
    end

   // assign rData = mem[addr[31:2]];
endmodule


/*
module RAM (
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] addr,
    input  logic [31:0] wData,
    output logic [31:0] rData
);
    logic [31:0] mem[0:2**4-1]; // 0x00 ~ 0x0f => 0x10 * 4 => 0x40

    always_ff @( posedge clk ) begin
        if (we) mem[addr[31:2]] <= wData;
    end

    assign rData = mem[addr[31:2]];
endmodule
*/