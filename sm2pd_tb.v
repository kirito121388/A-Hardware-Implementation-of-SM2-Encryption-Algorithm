`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/15 09:51:22
// Design Name: 
// Module Name: sm2pd_tb
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


module sm2pd_tb;
reg clk0=0,clk=0;
reg rst=1,start=0;
reg [255:0] x1,y1,z1;
wire [255:0] x3,y3,z3;
wire done;
parameter[255:0] a = 256'hFFFFFFFE_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_00000000_FFFFFFFF_FFFFFFFC; 
always #900 clk0 = ~clk0;
always #5 clk = ~clk;
initial begin
    //x1 = 256'h32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7;
    //y1 = 256'hBC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0;
    //z1 = 256'h1;
    x1 = 256'h90570b3c36ff14254403c3a3a9573df208b5784b0e4459f92400f67a1db15a50;
    y1 = 256'h5ee4f16ee0ebd93b1b90403577fe47a1e3bc8e3c6d853110fe3157abb638dc31;
    z1 = 256'he31dcd9313d499673c261974f8a6cafc789f51ffb6c825a4637458e6cf413a7c;
    #600
    rst = 0;
    start = 1;
end
sm2_pd pd(clk0,clk,rst,start,a,x1,y1,z1,x3,y3,z3,done);
endmodule
