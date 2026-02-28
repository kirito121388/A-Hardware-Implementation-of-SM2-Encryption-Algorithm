`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/07 19:14:30
// Design Name: 
// Module Name: sm2pa_tb
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


module sm2pa_tb;
reg clk0=0,clk=0;
reg rst=1,start=0;
reg [255:0] x1,x2,y1,y2,z1,z2;
wire [255:0] x3,y3,z3;
wire done;
always #900 clk0 = ~clk0;
always #5 clk = ~clk;
initial begin
    x1 = 256'h1e4082db6ce38e2d8e4cf38c13661b38371272fe80b0ae43c90c059956a346bd;
    y1 = 256'h56a5a6dd79493b9a3da4ab9135bd30f05f091831daa0294225190e0982b02944;
    z1 = 256'h5706f4407399108ef2869e61de564d1b6be70486cb6e9de76517d1ecc3f784af;
    x2 = 256'h90570b3c36ff14254403c3a3a9573df208b5784b0e4459f92400f67a1db15a50;
    y2 = 256'h5ee4f16ee0ebd93b1b90403577fe47a1e3bc8e3c6d853110fe3157abb638dc31;
    z2 = 256'he31dcd9313d499673c261974f8a6cafc789f51ffb6c825a4637458e6cf413a7c;
    #600
    rst = 0;
    start = 1;
end
sm2_pa pa(clk0,clk,rst,start,x1,x2,y1,y2,z1,z2,x3,y3,z3,done);
endmodule
