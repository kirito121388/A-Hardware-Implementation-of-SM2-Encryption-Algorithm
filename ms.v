`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/31 11:36:59
// Design Name: 
// Module Name: ms
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


module ms(
    input [255:0] a,
    input [256:0] b,
    input [255:0] p,
    output[255:0] r
);
reg signed [257:0] A,B;
reg signed [257:0] s0,s1,s2;
reg [255:0] r_reg;
always@(*) begin
     A      = {2'b00,a};
     B      = {1'b0,b};
    s0      = (A - B);
    s1      = (s0 + {2'b0,p});
    s2      = (s1 + {2'b0,p});
    if(s0[257]&s1[257]) r_reg = s2[255:0];
    else if(s0[257]&(!s1[257]))   r_reg = s1[255:0];
    else    r_reg = s0[255:0];
end
assign r = r_reg;
endmodule
