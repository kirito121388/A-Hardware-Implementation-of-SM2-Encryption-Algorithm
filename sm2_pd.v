`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/30 11:25:33
// Design Name: 
// Module Name: sm2_pa
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


module sm2_pd(
input clk,
input clkin,
input rst,
input start,
input  [255:0] a,
input  [255:0] x1,y1,z1,
output reg [255:0] x3,y3,z3,
output         done
    );
parameter[255:0] p = 256'hFFFFFFFE_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_00000000_FFFFFFFF_FFFFFFFF; 
reg          mulstart,mulrst;
wire         muldone1,muldone2;
reg  [255:0] mula1,mula2,mulb1,mulb2;
wire [255:0] r1,r2;
wire [511:0] mulre1,mulre2;
reg  [3:0]   state;
reg  [255:0] W,B,A;
reg          done_reg;
reg  [255:0] X1,Y1,Z1,X3,Y3;
reg  [255:0] maa1,mab1,msa1;
wire [255:0] mar1,msr1;
reg  [256:0] msb1;

always@(posedge clk or posedge muldone1) begin
    if(muldone1) mulstart <= 0;
    else if (start) mulstart <= 1 ;
    else mulstart <= 0;
end
always@(posedge clk or posedge rst) begin
    if(rst) begin
        {W,A,B} <= 0;
        {mulrst} <= 0;
        {mula1,mula2,mulb1,mulb2} <= 0;
        done_reg <= 0;
        state <= 0;
        {x3,y3,z3} <= 0;
    end
    else if(start)begin  
        case(state)
            4'd0:begin
               {W,A,B} <= 0;
               {mula1,mula2,mulb1,mulb2} <= 0;
               {mulrst} <= 0;
                X1  = x1;
                Y1  = y1;
                Z1  = z1;
                mula1 <= Z1;
                mulb1 <= Z1;
                mula2 <= X1;
                mulb2 <= X1;
                done_reg <= 0;
                state <= state + 1'b1;
            end
            4'd1:begin
                mula1 <= Y1;
                mulb1 <= Y1;
                mula2 <= r1; //r1 = z1*z1 mp 
                mulb2 <= r1; //
                A    <= r1; //A = Z1^2
                W    <= r2; //W = X1^2
                state <= state+1'b1;
            end
            4'd2:begin
                mula1  <= r2;//z1^4
                mulb1  <= a;
                mula2  <= W;
                mulb2  <= 2'b11;
                B    <= r1;//B=y1^2
                A    <= r2;//A=z1^4
                state <= state + 1'b1;
            end
            4'd3:begin
                mula1  <= B;//y1^2
                mulb1  <= X1;
                mula2  <= B;//y1^2
                mulb2  <= B;
                maa1   <= r1;
                mab1   <= r2;
                X3      <= r1;//X3 = a*z1^4 
                Y3      <= r2;//Y3 = 3*x1^2
                state <= state + 1'b1;
            end 
            4'd4:begin
                mula1  <= 256'd8;//¼ÆËã8*x1*y1^2
                mulb1  <= r1;
                mula2  <= 256'd8;//¼ÆËã8*y1^4
                mulb2  <= r2;
                B     <= mar1; //B = 3*x1^2 + a*z1^4
                W     <= r1;//x1*y1^2
                A     <= r2;//y1^4
                state <= state + 1'b1;
            end
            4'd5:begin
                mula1  <= B;//B^2
                mulb1  <= B;
                mula2  <= 256'd4;//4x1y1^2
                mulb2  <= W;
                X3    <= r1;//X3 = 8*x1*y1^2
                Y3    <= r2;//Y3 = 8*y1^4
                state <= state +1'b1;
            end
            4'd6:begin
                mula1  <= Y1;//¼ÆËãz1*z2*t3
                mulb1  <= Z1;
                msa1   <= r1;//t4 = t6^2
                msb1   <= {1'b0,X3};//t2 = t7*t3^2
                A     <= r1;//A = B^2
                W     <= r2;//W = 4x1y1^2
                state <= state +1'b1;
            end
            4'd7:begin
                mula1  <= r1;
                mulb1  <= 256'd2;//
                msa1   <= W;
                msb1   <= {1'b0,msr1};
                x3    <= msr1;//x3 = B^2 - X3
                A     <= r1;//A = y1z1
                state <= state +1'b1;
            end
            4'd8:begin
                mula1  <= msr1;
                mulb1  <= B;
                z3    <= r1;//z3 = 2y1z1
                state <= state +1'b1;
            end
            4'd9:begin
                msa1   <= r1;
                msb1   <= {1'b0,Y3};
                state <= state +1'b1;
            end
            4'd10:begin:t10
                y3 <= msr1;
                done_reg <= 1;
                state <= 0;
            end
        endcase
    end 
    else begin
        {W,A,B} <= {W,A,B};
        {mulrst} <= 0;
        X1 <= X1;
        Y1 <= Y1;
        Z1 <= Z1;
        state <= 0;
        done_reg <= 0;
    end  
end  
assign done = done_reg;
mul_256 mul1(clkin,clkin,mulrst,mulstart,mula1,mulb1,mulre1,muldone1);
mul_256 mul2(clkin,clkin,mulrst,mulstart,mula2,mulb2,mulre2,muldone2);
reduction reduc1(mulre1,r1);
reduction reduc2(mulre2,r2);
ma ma1(maa1,mab1,p,mar1);
ms ms1(msa1,msb1,p,msr1);
endmodule
