`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/25 11:26:36
// Design Name: 
// Module Name: mul256_tb
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


module mul256_tb;
reg clk=0,rst,start;
reg [255:0] a,b;
wire [511:0] result;
wire [255:0] r;
wire done;
always #2 clk=~clk;
always@(posedge done) start = 0;
initial begin
    rst = 1;
    start =1;
    #20 rst =0;
    //a = 256'h2c02ed59028c873dc56ab3b16fa8fec7fd330b2db063ce5bb680fae8759e1356;
    //b = 256'h12b89c2f5c2c7d3eff5e5561781f8c74a8e192c9f220958e7aee9fff60783a7a;
    //#1100
    start = 1;
    a = 256'hbedd6e926064e2fa763b372b41924bc28e627abe4ce32374f0d16db700782919;
    b = 256'h8a8c93ec7c98e3b3b0099d2940053f776e866b846b81f38cc3b1cce0d52ec400;

end
mul_256 ins1(clk,clk,rst,start,a,b,result,done);
reduction reduct1(result,r);
endmodule
