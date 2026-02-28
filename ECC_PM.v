`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/08 10:09:15
// Design Name: 
// Module Name: ECC_PM
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


module ECC_PM(
input clkin,
input rst,
input start,
input [255:0] x,y,z,
input [255:0] k,a,
output reg [255:0] xo,yo,zo,
output reg done
    );
localparam IDLE = 2'b0,FINDMSB=2'b01,PROCESSING = 2'b10;
reg [255:0] x1,x2,y1,y2,z1,z2;
reg [255:0] xdi,ydi,zdi,xai1,yai1,zai1,xai2,yai2,zai2;
wire [255:0] xdo,ydo,zdo,xao,yao,zao;
reg [255:0] ki;
reg [8:0] K;
reg pa_start,pd_start;
wire pa_done,pd_done;
reg [1:0] state;
reg clk,clk0;
reg [8:0]clkct;
reg [11:0]clkct0;
always@(posedge clkin or posedge rst) begin
    if(rst) begin  
        clkct <= 0;
        clk   <= 0;
    end
    else if(clkct <89) clkct <= clkct + 1;
    else begin 
        clkct <= 0;
        clk   <= ~clk;
    end
end
always@(posedge clkin or posedge rst) begin
    if(rst) begin  
        clkct0 <= 0;
        clk0   <= 0;
    end
    else if(clkct0 <1169) clkct0 <= clkct0 + 1;
    else begin 
        clkct0 <= 0;
        clk0   <= ~clk0;
    end
end
always@(posedge clk0 or posedge pa_done) begin
    if(pa_done) pa_start        <= 0;
    else if (start) pa_start    <= 1 ;
    else pa_start               <= 0;
end
always@(posedge clk0 or posedge pd_done) begin
    if(pd_done) pd_start        <= 0;
    else if (start) pd_start    <= 1 ;
    else pd_start               <= 0;
end
always@(posedge clk0 or posedge rst) begin
    if(rst) begin
        {xdi,ydi,zdi,xai1,yai1,zai1,xai2,yai2,zai2} <= 0;
        state               <= IDLE;
        K                   <= 256;
        {x1,y1,z1}          <= 0;
        {x2,y2,z2}          <= {x,y,z};
        done                <= 0;
        {xo,yo,zo}          <= 0;
    end
    else if (start) begin
        case (state) 
            IDLE:begin
                {x1,y1,z1}      <= {x,y,z};
                {x2,y2,z2}      <= 0;
                state       <= FINDMSB;
                {xdi,ydi,zdi}   <= {x,y,z};
                ki              <= {k[254:0],k[255]};
                K               <= 0;
                done            <= 0;
            end
            FINDMSB:begin
                {x2,y2,z2}      <= {xdo,ydo,zdo};
                if(ki[255] == 0) begin
                    state <= FINDMSB;
                    ki  <= {ki[254:0],ki[255]};
                    K   <= K+1;
                end
                else begin
                    {xdi,ydi,zdi}   <= ki[254]? {xdo,ydo,zdo}:{x1,y1,z1};
                    {xai1,yai1,zai1}   <= {xdo,ydo,zdo};
                    {xai2,yai2,zai2}   <= {x1,y1,z1};
                    state <= PROCESSING;
                    ki  <= {ki[253:0],ki[255:254]};
                    K   <= K+2;
                end

            end
            PROCESSING:begin
                if(K == 255) begin
                    state       <= IDLE;
                    done        <= 1;
                    {xo,yo,zo}  <= ki[0]? {xao,yao,zao}:{xdo,ydo,zdo};
                    K           <= 0;
                end
                else begin
                    if(ki[0] == 1) begin
                        {x1,y1,z1}  <= {xao,yao,zao};
                        {x2,y2,z2}  <= {xdo,ydo,zdo};
                    end
                    else begin
                        {x1,y1,z1}  <= {xdo,ydo,zdo};
                        {x2,y2,z2}  <= {xao,yao,zao};
                    end
                    {xai1,yai1,zai1}    <= {xao,yao,zao};
                    {xai2,yai2,zai2}    <= {xdo,ydo,zdo};
                    if(ki[255]^ki[0] == 1) begin
                        {xdi,ydi,zdi}   <= {xao,yao,zao};
                    end
                    else begin
                        {xdi,ydi,zdi}   <= {xdo,ydo,zdo};
                    end
                    K                   <= K+1;
                    ki                  <={ki[254:0],ki[255]};
                end
            end
        endcase
    end   
                    
end
sm2_pd pd(clk,clkin,rst,pd_start,a,xdi,ydi,zdi,xdo,ydo,zdo,pd_done);
sm2_pa pa(clk,clkin,rst,pa_start,xai1,xai2,yai1,yai2,zai1,zai2,xao,yao,zao,pa_done);              
endmodule
