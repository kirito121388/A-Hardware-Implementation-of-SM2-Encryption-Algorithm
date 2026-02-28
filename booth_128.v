`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/24 16:44:29
// Design Name: 
// Module Name: booth_128
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



module booth_128(
	input              clk,
	input              rst,
	input              start,
	input  [128:0]     a,
	input  [128:0]     b,
	output reg [257:0] result,
	output reg         done
);

reg [1:0]   i;
reg [260:0] p,p1;
reg [129:0] a_reg,a_tc;
reg [8:0]   n;


always @ ( posedge clk or posedge rst )
begin
	if (rst)
	begin
		i     <= 0;
		p     <= 0;
		a_reg <= 0;
		a_tc  <= 0;
		n     <=0;
		done  <= 0;
	end
	else if (start) begin
		case (i)
			2'b00:
				begin
					a_reg  <= {1'b0,a};
					//complement code of A 计算A的补码,方便后面的+-操作
					a_tc   <= ~{1'b0,a}+1'b1;    
					p      <= { 131'b0, b, 1'b0 };  //B add to last 8bit of P
					i      <= i + 1'b1;
					n      <= 0;
					p1     <= 0;
				end
			//operating 这一个状态用来判断最低两位，然后决定执行什么操作
			2'b01:
				begin
				    if (n == 9'd130) begin
                    n <= 0;
                    i <= 2'b11;
                end
                else begin
                   if (p[1:0] == 2'b00 | p[1:0] == 2'b11)begin
                       p1   = p;
                   end
                   else if (p[1:0] == 2'b01)begin
                       p1   = {p[260:131] + a_reg,p[130:0]};
                   end
                   else if (p[1:0] == 2'b10)begin
                       p1   = {p[260:131] + a_tc,p[130:0]};
                   end
                   p = {p1[260],p1[260:1]};
                   n = n + 1'b1;
                   if (n == 9'd130) begin
                       n <= 0;
                       i <= 2'b11;
                   end
                   else begin
                    if (p[1:0] == 2'b00 | p[1:0] == 2'b11)begin
                        p1   <= p;
                        i    <= 2'b10;
                    end
                    else if (p[1:0] == 2'b01)begin
                        p1   <= {p[260:131] + a_reg,p[130:0]};
                        i    <= 2'b10;
                    end
                    else if (p[1:0] == 2'b10)begin
                        p1   <= {p[260:131] + a_tc,p[130:0]};
                        i    <= 2'b10;
                    end
                    end
                end
				end
			//shift 这是无论最低两位是什么，最后都要执行的移位操作
			2'b10:
				begin
				    p <= {p1[260],p1[260:1]};
				    n <= n + 1'b1;
					i <= i - 1'b1;
				end
			2'b11:
				begin
					done   <= 1;
					result <= p[258:1];
					//$display("p=%h",p);
					i <= 0;
				end
		
		endcase
	end
	else begin
	   	i <= 0;
        p <= 0;
        a_reg <= 0;
        a_tc <= 0;
        n <= 0;
    end
end
endmodule

