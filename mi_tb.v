`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/17 11:39:42
// Design Name: 
// Module Name: mi_tb
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


module mi_tb;
parameter p = 256'hFFFFFFFE_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_00000000_FFFFFFFF_FFFFFFFF;
reg clk=0,rst,start;
reg [255:0] x,y;
wire [255:0] z;
//wire [256:0] a_reg,b_reg;
wire done;
always #5.13 clk = ~clk;
initial begin
    //test 1 up edge
    rst = 1;
    start = 1;
    #10 rst = 0;
    x = 256'hacd24cbc01142dd4f40739f0ee48ba878ae13e645c09fa4ede44fad573347335;
    y = 256'hbedd6e926064e2fa763b372b41924bc28e627abe4ce32374f0d16db700782919;
    //x = 256'h5c11324fe764ba9029772823718831266379a385f88db5a41815d146dee43eb8;
    //y = 256'hfad4661144be97fa1ba99644dd2145c7e750ea30b56b26903943e0afbe060455;
    
    #8000
    $display("test 1 :result = %h",z);
    /*if(r == (a*b)%p) $display("true");
    else $display("false£¬true answer is %h",(a*b)%p); */
    //test 2 all 0
   /* rst = 1;
    start = 1;
    #10 rst = 0;
    x = 256'h0;
    y = 256'h0;
    #1500
    $display("test 2 :result = %h",z);
    //test 3 random
    rst = 1;
    start = 1;
    #10 rst = 0;
    x = {8{$urandom}};
    y = {8{$urandom}};
    #1500
    $display("test 3 :result = %h",z);*/
end
mi mitest(clk,rst,start,x,y,p,z,done);


endmodule
