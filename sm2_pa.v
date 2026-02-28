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


module sm2_pa(
input clk,
input clkin,
input rst,
input start,
input  [255:0] x1,x2,y1,y2,z1,z2,
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
reg  [255:0] t1,t2,t3,t4,t5,t6,t7,t8,t9;
reg          done_reg;
reg  [255:0] X1,X2,Y1,Y2,Z1,Z2,X3,Y3;
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
        {t1,t2,t3,t4,t5,t6,t7,t8,t9} <= 0;
        {mulrst} <= 0;
        {mula1,mula2,mulb1,mulb2} <= 0;
        done_reg <= 0;
        state <= 0;
        {x3,y3,z3} <= 0;
    end
    else if(start)begin  
        case(state)
            4'd0:begin
               {t1,t2,t3,t4,t5,t6,t7,t8,t9} <= 0;
               {mula1,mula2,mulb1,mulb2} <= 0;
               {mulrst} <= 0;
                X1  = x1;
                X2  = x2;
                Y1  = y1;
                Y2  = y2;
                Z1  = z1;
                Z2  = z2;
                mula1 <= Z1;
                mulb1 <= Z1;
                mula2 <= Z2;
                mulb2 <= Z2;
                done_reg <= 0;
                state <= state + 1'b1;
            end
            4'd1:begin
                mula1 <= X1;
                mula2 <= X2;
                mulb2 <= r1; //r1 = z1*z1 mp 
                mulb1 <= r2; //r2 = z2*z2 mp
                t6    <= r1; //t6 = z1^2
                t8    <= r2; //t8 = z2^2
                state <= state+1'b1;
            end
            4'd2:begin
                mula1  <= Z1;
                mulb1  <= t6;
                mula2  <= Z2;
                mulb2  <= t8;
                maa1   <= r1;
                mab1   <= r2;
                msa1   <= r1;
                msb1   <= {1'b0,r2};
                t1    <= r1;//t1=x1*z2^2
                t2    <= r2;//t2=x2*z1^2
                state <= state + 1'b1;
            end
            4'd3:begin
                mula1  <= r2;//z2^3
                mulb1  <= Y1;
                mula2  <= r1;//z1^3
                mulb2  <= Y2;
                t3    <= msr1;//t1-t2
                t7    <= mar1;//t1+t2
                X3      <= r1;//X3 = z1^3 
                Y3      <= r2;//Y3 = z2^3
                state <= state + 1'b1;
            end 
            4'd4:begin
                mula1  <= t3;//计算t3^2
                mulb1  <= t3;
                mula2  <= Z1;//计算z1*z2
                mulb2  <= Z2;
                maa1   <= r1;
                mab1   <= r2;
                msa1   <= r1;
                msb1   <= {1'b0,r2};
                t4    <= r1;//y1*z2^3
                t5    <= r2;//y2*z1^3
                state <= state + 1'b1;
            end
            4'd5:begin
                mula1  <= r1;//t3^2
                mulb1  <= t7;
                mula2  <= msr1;
                mulb2  <= msr1;
                t8    <= mar1;//t4+t5
                t6    <= msr1;//t4-t5
                t1    <= r1;//t1 = t3^2
                t9    <= r2;//t9 = z1*z2
                state <= state +1'b1;
            end
            4'd6:begin
                mula1  <= t9;//计算z1*z2*t3
                mulb1  <= t3;
                mula2  <= t3;//计算t3^3
                mulb2  <= t1;
                msa1   <= r2;//t4 = t6^2
                msb1   <= {1'b0,r1};//t2 = t7*t3^2
                t2    <= r1;//t2 = t7*t3^2
                t4    <= r2;//t4 = t6^2
                state <= state +1'b1;
            end
            4'd7:begin
                mula1  <= t8;
                mulb1  <= r2;//t3^3
                msa1   <= t2;
                msb1   <= {msr1,1'b0};
                x3    <= msr1;//X3 = t6^2 - t7*t3^2
                z3    <= r1;//Z3 = z1*z2*t3
                t5    <= r2;//t5 = t3^3
                state <= state +1'b1;
            end
            4'd8:begin
                mula1  <= msr1;
                mulb1  <= t6;
                t9    <= msr1;//t9 = t7*t3^2 - 2X3
                t4    <= r1;//t4 = t8*t3^3
                state <= state +1'b1;
            end
            4'd9:begin
                msa1   <= r1;
                msb1   <= {1'b0,t4};
                t5    <= r1;//t5 = t9*t6
                state <= state +1'b1;
            end
            4'd10:begin:t10
                reg [255:0] sub;
                reg [256:0] sum;
                sub = msr1;
                sum = {1'b0,sub} + {1'b0,p};
                y3 <= sub[0]? {sum[256:1]}:{1'b0,sub[255:1]};
                done_reg <= 1;
                state <= 0;
            end
        endcase
    end 
    else begin
        {t1,t2,t3,t4,t5,t6,t7,t8,t9} <= {t1,t2,t3,t4,t5,t6,t7,t8,t9};
        {mulrst} <= 0;
        X1 <= X1;
        X2 <= X2;
        Y1 <= Y1;
        Y2 <= Y2;
        Z1 <= Z1;
        Z2 <= Z2;
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
