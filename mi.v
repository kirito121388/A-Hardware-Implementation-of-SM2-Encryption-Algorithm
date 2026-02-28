`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/14 15:39:59
// Design Name: 
// Module Name: mi
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


module mi(
    input clk,
    input rst,
    input start,
    input [255:0] x,
    input [255:0] y,
    input [255:0] pin,
    output reg [255:0] result,
    output reg done
    //output [256:0] a_reg,
    //output [256:0] b_reg
);
    localparam IDLE = 1'b0,
               PROCESSING = 1'b1;
    reg signed [256:0] a_reg,b_reg,c_reg,d_reg;
    reg signed [256:0] next_a,next_c;
    reg signed [257:0] absum,absub,cdsum,cdsub;
    reg signed [9:0] rho;
    reg signed [7:0] delta;
    reg state;
    wire signed [256:0] p;
    reg signed [256:0] z;
    assign p = pin;
    //Çó(x/2) mod p
    function signed [256:0] d2mp;
        input signed [257:0] x;
        input signed [256:0] p;
        if(x[0] == 0) begin
            d2mp = x /2;
            //$display("%d / 2 mod %d = %d",x,p,d2mp);
        end else begin : xpp
            reg signed [257:0] xpp;
            xpp  = x + p;
            d2mp = xpp /2;
            //$display("%d / 2 mod %d = %d",x,p,d2mp);
        end
    endfunction
    //Çó(x/4) mod p
    function signed [256:0] d4mp;
        input signed [257:0] x;
        input signed [256:0] p;
        if(p[1:0] == 2'b01) begin : d4mp1
            reg signed [258:0] xp2p,xpp;
            xp2p = x + 2*p;
            xpp  = x+ p;
            if(x[1:0] == 2'b00) d4mp = x /4;
            else if(x[1:0] == 2'b01) d4mp = (x - p) /4;
            else if(x[1:0] == 2'b10) d4mp = xp2p /4;
            else d4mp = xpp /4;
            //$display("%d / 4 mod %d = %d",x,p,d4mp);
        end else if(p[1:0] == 2'b11)begin :d4mp2
            reg signed [258:0] xp2p,xpp;
            xp2p = x + 2*p;
            xpp  = x+ p;
            if(x[1:0] == 2'b00) d4mp = x /4;
            else if(x[1:0] == 2'b01) d4mp = xpp /4;
            else if(x[1:0] == 2'b10) d4mp = xp2p /4;
            else d4mp = (x - p) /4;
            //$display("%d / 4 mod %d = %d",x,p,d4mp);
        end
        else d4mp = d4mp;
        
    endfunction
    
    always@(posedge clk or posedge rst) begin 
        if(rst) begin
            state <= IDLE;
            a_reg <= 0;
            b_reg <= 0;
            c_reg <= 0;
            d_reg <= 0;
            rho   <= 0;
            delta <= 0;
            done  <= 0;
            z     <= 0;
        end 
        else begin
            case (state) 
                IDLE: begin
                    if(start) begin
                        a_reg <= y;
                        b_reg <= p;
                        c_reg <= x;
                        d_reg <= 0;
                        rho   <= 9'd255;
                        delta <= 0;
                        done  <= 0;
                        state <= PROCESSING;
                        next_a <= 0;
                        next_c <= 0;
                    end 
                    else begin
                        a_reg <= a_reg;
                        b_reg <= b_reg;
                        c_reg <= c_reg;
                        d_reg <= d_reg;
                        rho   <= rho;
                        delta <= delta;
                        done  <= done;
                        state <= state;
                    end
                end
                PROCESSING: begin
                    //$display("delta = %d,rho = %d",delta,rho);
                    if(rho > 0) begin
                        if(a_reg[1:0] == 2'b00) begin
                            a_reg <= a_reg /4;
                            c_reg <= d4mp(c_reg,p); 
                            if(delta <= 0) rho <= rho - 2;
                            else if(delta == 1) rho <= rho -1;
                            delta <= delta - 2;
                            //$display("s1");
                        end 
                        else if(a_reg[0] == 1'b0) begin
                            a_reg <= a_reg /2;
                            c_reg <= d2mp(c_reg,p);
                            if(delta <= 0) rho <= rho -1;
                            delta <= delta -1;
                            //$display("s2");
                        end 
                        else begin
                            next_a  = a_reg;
                            next_c  = c_reg;
                            absum   = a_reg + b_reg;
                            absub   = a_reg - b_reg;
                            cdsum   = c_reg + d_reg;
                            cdsub   = c_reg - d_reg;
                            //$display("absum = %h,absub = %h",absum,absub);
                            if(absum[1:0] == 2'b00) begin
                                a_reg <= absum /4;
                                c_reg <= d4mp(cdsum,p);
                                if(delta>=0) begin
                                    if(delta == 0) rho <= rho - 1;
                                    else rho <= rho;
                                    delta <= delta -1;
                                    //$display("s3");
                                end
                                else begin
                                    b_reg <= next_a;
                                    d_reg <= next_c;
                                    delta <= -delta-1;
                                    //$display("b,d refresh");
                                    //$display("s4");
                                end
                            end 
                            else begin
                                //$strobe("absub= %d,a_reg= %d",absub,a_reg);
                                a_reg <= absub / 4;
                                c_reg <= d4mp(cdsub,p);
                                if(delta >= 0) begin
                                    if(delta == 0) rho <= rho - 1;
                                    else rho <= rho;
                                    delta <= delta - 1;
                                    //$display("s5");
                                end
                                else begin
                                    b_reg <= next_a;
                                    d_reg <= next_c;
                                    delta <= -delta -1;
                                    //$display("b,d refresh");
                                    //$display("s6");
                                end
                            end
                        end
                    end
                    else if(rho <= 0 )begin
                        if((b_reg < 0) & (d_reg < 0)) z <= -d_reg;
                        else if((b_reg < 0) & (d_reg >= 0)) z <= p - d_reg;
                        else if((b_reg > 0) & (d_reg < 0)) z <= p + d_reg;
                        else z <= d_reg;
                        done <= 1;
                        state <= IDLE;
                        //$display("a = %d,b = %d,d=%d",a_reg,b_reg,d_reg);
                        //$strobe("result = %h",z);
                    end
                end
            endcase
            result = z[255:0];
    end
 end
endmodule
