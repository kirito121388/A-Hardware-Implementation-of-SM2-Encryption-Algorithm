`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/23 10:36:42
// Design Name: 
// Module Name: mul_256
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: karatsuba&booth multiplier
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mul_256(
input          clk,
input          booth_clk,
input          rst,
input          start,
input  [255:0] a,
input  [255:0] b,
output reg [511:0] result,
output         done
    );
    localparam IDLE = 3'd0,
               ADD  = 3'd1,
               MUL  = 3'd2,
               SUM  = 3'd3;
    reg [127:0] a1,a0,b1,b0;
    reg [128:0] ap,bp;
    reg [257:0] a1b1,apbp,a0b0;
    wire [257:0] a1b1_out,apbp_out,a0b0_out;
    reg [2:0]   state;
    reg         done_reg;
    wire        booth_done1,booth_done2,booth_done3;
    reg         booth_start,booth_rst;
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            a1 <= 0;
            a0 <= 0;
            b1 <= 0;
            b0 <= 0;
            ap <= 0;
            bp <= 0;
            result<=0;
            done_reg <=0;
            state <= 0;
            booth_start <=0;
            booth_rst   <=0;
        end
        else if(start)begin
            case(state)
                IDLE: begin
                         a1 <= a[255:128];
                         a0 <= a[127:0];
                         b1 <= b[255:128];
                         b0 <= b[127:0];
                         done_reg <= 0;
                         booth_start <= 0;
                         booth_rst   <=1;
                         state <= ADD;
                 end
                 ADD: begin //计算a1+a0,b1+b0
                        ap <= a1 + a0;
                        bp <= b1 + b0;
                        state <= MUL;
                 end
                 MUL: begin //通过booth乘法器进行a1*b1,ap*bp,a0*b0的计算（129位输入）
                    booth_start = 1;
                    booth_rst   = 0;
                    if(booth_done1 & booth_done2 & booth_done3) begin 
                        state <= SUM;
                        booth_start <= 0;
                        a1b1 <= a1b1_out;
                        apbp <= apbp_out;
                        a0b0 <= a0b0_out;
                        //$display("ap=%d,bp=%d",ap,bp);
                        //$display("a1b1=%d,apbp=%d,a0b0=%d",a1b1_out,apbp_out,a0b0_out);
                        booth_rst <= 1;
                    end
                    else                                        state <= state;
                 end
                 SUM: begin:sum
                    reg [511:0] A1B1,APBP,IA1B1,IA0B0,A0B0;
                    reg [511:0] ia1b1,ia0b0;
                    reg [511:0] sum1,car1,sum2,car2,sum3,car3,car1p2,car2p2,car3p2;
                    A1B1 = {a1b1,256'b0};
                    APBP = apbp << 128;
                    A0B0 = a0b0;
                    ia1b1 = a1b1 << 128;
                    ia0b0 = a0b0 << 128;
                    IA1B1 = ~ia1b1 + 1'b1;
                    IA0B0 = ~ia0b0 + 1'b1;
    	    //使用csa对最终结果进行计算
                    sum1  = A1B1 ^ APBP ^ A0B0;
                    car1  = (A1B1 & APBP) | (APBP & A0B0) | (A0B0 & A1B1);
                    sum2  = sum1 ^ IA1B1 ^ IA0B0;
                    car2  = (sum1 & IA1B1) | (IA1B1 & IA0B0) | (IA0B0 & sum1);
                    car1p2= car1 << 1;
                    car2p2= car2 << 1;
                    sum3  = sum2 ^ car1p2 ^ car2p2;
                    car3  = (sum2 & car1p2) | (car1p2 & car2p2) | (car2p2 & sum2);
                    car3p2= car3 << 1;
                    result <= car3p2 + sum3;
                    done_reg   <= 1;
                    state      <= IDLE;
                 end
             endcase
         end
         else begin
             a1 <= a1;
             a0 <= a0;
             b1 <= b1;
             b0 <= b0;
             done_reg <= 0;
             booth_start <= 0;
             booth_rst   <=1;
             state <= IDLE;
         end
end     
assign done   = done_reg;       
booth_128 a1pb1(booth_clk,booth_rst,booth_start,{1'b0,a1},{1'b0,b1},a1b1_out,booth_done1);
booth_128 appbp(booth_clk,booth_rst,booth_start,ap,bp,apbp_out,booth_done2);
booth_128 a0pb0(booth_clk,booth_rst,booth_start,{1'b0,a0},{1'b0,b0},a0b0_out,booth_done3);            
endmodule
