`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/11 09:55:35
// Design Name: 
// Module Name: sm2pm_tb
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


module sm2pm_tb;
reg clkin=0,rst,start;
reg [255:0] x,y,z,k,a;
wire [255:0] xo,yo,zo,xf,yf;
wire done;
wire [511:0] z2,z3;
wire [255:0] z2f,z3f;
reg z2start,z3start,xfstart,yfstart;
wire xfdone,yfdone,z2done,z3done;
parameter[255:0] p = 256'hFFFFFFFE_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_00000000_FFFFFFFF_FFFFFFFF; 
always #5 clkin =~clkin;
initial begin
    a = 256'hFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFFFFFFFFFC;
    x = 256'h32C4AE2C1F1981195F9904466A39C9948FE30BBFF2660BE1715A4589334C74C7;
    y = 256'hBC3736A2F4F6779C59BDCEE36B692153D0A9877CC62A474002DF32E52139F0A0;
    z = 256'h1;
    k = 256'h384F30353079B0A86F48B7C55B6D6D7C8B1A2E3F4A5B6C7D8E9F0A1B2C3D4E5F;
    rst = 0;
    #10   rst = 1;
    #1000 rst=0;
    start = 1;
    #5100 xfstart = 1;yfstart = 1;
end
always@(*) begin
    if(done) z2start = 1;
end
always@(z2f) z3start = 1;
ECC_PM pm(clkin,rst,start,x,y,z,k,a,xo,yo,zo,done);
mul_256 arz2(clkin,clkin,rst,z2start,zo,zo,z2,z2done);
mul_256 arz3(clkin,clkin,rst,z3start,z2f,zo,z3,z3done);
reduction rez2(z2,z2f);
reduction rez3(z3,z3f);
mi arxf(clkin,rst,xfstart,xo,z2f,p,xf,xfdone);
mi aryf(clkin,rst,yfstart,yo,z3f,p,yf,yfdone);
endmodule
