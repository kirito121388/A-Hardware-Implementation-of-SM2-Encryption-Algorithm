`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/31 11:36:59
// Design Name: 
// Module Name: ma
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


module ma(
    input [255:0] a,b,p,
    output[255:0] r
);
reg [256:0] A,B;
reg [256:0] s0,s1;
reg [255:0] r_reg;
always@(*) begin
    A       = {1'b0,a};
    B       = {1'b0,b};
    s0 = (A + B);
    s1 = (s0 - {1'b0,p});
    if(s1[256]) r_reg = s0;
    else   r_reg = s1;
end
assign r = r_reg;
endmodule
