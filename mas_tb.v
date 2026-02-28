`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/06 11:18:56
// Design Name: 
// Module Name: mas_tb
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


module mas_tb;
parameter[255:0] p = 256'hFFFFFFFE_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_00000000_FFFFFFFF_FFFFFFFF; 
reg [255:0] a1,a2,b1;
reg [256:0] b2;
wire [255:0] r1,r2;
initial begin
    a1 = 256'h10daaeee222a053a2fc5a21afa027415c2dcc8838dbb04f7082f79983532ce98;
    b1 = 256'h76efc6cb5833c0f0032a8035472408b949587102700bc92eec1bdeeb74f11865;
    a2 = 256'hcbfb303235c8766f77b22fea839505c9f7cc440eca3c041d9ed945fe6c10b556;
    b2 = 257'hc9983c411b2f9a15fb3a6f01893e37172ee4cc17aeef69d3b0ae8c1dbcaac2d4;
    #1000
    a2 = 256'hc9983c411b2f9a15fb3a6f01893e37172ee4cc17aeef69d3b0ae8c1dbcaac2d4;
    b2 = 257'h1cbfb303235c8766f77b22fea839505c9f7cc440eca3c041d9ed945fe6c10b556;
end    
ma ma(a1,b1,p,r1);
ms ms(a2,b2,p,r2);
endmodule
