`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/25 09:41:09
// Design Name: 
// Module Name: booth_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module booth_tb;
reg clk=0,rst,start;
reg [128:0] a,b;
wire [257:0] result;
wire done;
always #2 clk = ~clk;
initial begin 
    rst = 1;
    start = 1;
    #20 rst = 0;
    a = 129'h1F7B345015171879820E8F3AE4CC1E3A7;
    b = 129'h1146D602911F2839661BE68D96F02A4ED;
    //#1500
    //rst = 1;
end
booth_128 ins1(clk,rst,start,a,b,result,done);
endmodule
