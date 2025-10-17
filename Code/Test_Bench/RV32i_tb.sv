`timescale 1ns / 1ps

module RV32i_tb();

    logic clk;
    logic reset;

    MCU dut(.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0; 
        reset = 1;
        #10 reset = 0;
        #30000 $finish;
    end
endmodule
