`timescale 1ns / 1ps
module reduction(
	input  [511:0] c,
	output [255:0] result
);
    parameter[255:0] p = 256'hFFFFFFFE_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_00000000_FFFFFFFF_FFFFFFFF;
	//c=(c15,c14,c13,c12,c11,c10,c9,c8,c7,c6,c5,c4,c3,c2,c1,c0)
	reg [31:0] c15,c14,c13,c12,c11,c10,c9,c8,c7,c6,c5,c4,c3,c2,c1,c0;
	always@(*) {c15,c14,c13,c12,c11,c10,c9,c8,c7,c6,c5,c4,c3,c2,c1,c0}=c;
	
	//定义1~s14
	reg [259:0] s14,s13,s12,s11,s10,s9,s8,s7,s6,s5,s4,s3,s2,s1;
	always@(*) begin
		s1  = {4'b0000,c7,c6,c5,c4,c3,c2,c1,c0};
		s2  = {4'b0000,c15,c14,c13,c12,c11,{32{1'b0}},c9,c8};
		s3  = {4'b0000,c14,{32{1'b0}},c15,c14,c13,{32{1'b0}},c14,c13};
		s4  = {4'b0000,c13,{160{1'b0}},c15,c14};
		s5  = {4'b0000,c12,{192{1'b0}},c15};
		s6  = {4'b0000,c11,c11,c10,c15,c14,{32{1'b0}},c13,c12};
		s7  = {4'b0000,c10,c15,c14,c13,c12,{32{1'b0}},c11,c10};
		s8  = {4'b0000,c9,{64{1'b0}},c9,c8,{32{1'b0}},c10,c9};
		s9  = {4'b0000,c8,{96{1'b0}},c15,{32{1'b0}},c12,c11};
		s10 = {4'b0000,c15,{224{1'b0}}};
		s11 = {4'b0000,{160{1'b0}},c14,{64{1'b0}}};
		s12 = {4'b0000,{160{1'b0}},c13,{64{1'b0}}};
		s13 = {4'b0000,{160{1'b0}},c9,{64{1'b0}}};
		s14 = {4'b0000,{160{1'b0}},c8,{64{1'b0}}};
	end
	
	//csa加法树第一层，r=s1+s2+2s3+2s4+2s5+s6+s7+s8+s9+2s10-s11-s12-s13-s14
	wire [259:0] sum126,car126,sum345,car345,sum789,car789,sum1123,car1123;//先计算s1+s2+s6,s3+s4+s5,s7+s8+s9,s11+s12+s13
	csa_reduction t1_add126(
		.A(s1),
		.B(s2),
		.C(s6),
		.SUM(sum126),
		.CARRY(car126)
		);
	csa_reduction t1_add345_w2(
		.A(s3),
		.B(s4),
		.C(s5),
		.SUM(sum345),
		.CARRY(car345)
		);
	csa_reduction t1_add789(
		.A(s7),
		.B(s8),
		.C(s9),
		.SUM(sum789),
		.CARRY(car789)
		);
	csa_reduction t1_add1123(
		.A(s11),
		.B(s12),
		.C(s13),
		.SUM(sum1123),
		.CARRY(car1123)
		);
	
	//csa加法树第二层
	wire [259:0] sum2_1,car2_1,sum2_2,car2_2,sum2_3,car2_3;
	wire [259:0] car126p2,car1123p2;
	
	assign car126p2  = car126  << 1,
		   car1123p2 = car1123 << 1;
	
	csa_reduction t2_csa1(  
		.A(sum126),
		.B(sum789),
		.C(car126p2),
		.SUM(sum2_1),
		.CARRY(car2_1)
		);
	csa_reduction t2_csa2_w2(  
		.A(sum345),
		.B(car789),
		.C(s10),
		.SUM(sum2_2),
		.CARRY(car2_2)
		);
	csa_reduction t2_csa3(  
		.A(sum1123),
		.B(car1123p2),
		.C(s14),
		.SUM(sum2_3),
		.CARRY(car2_3)
		);
	
	//csa加法树第三层
	wire [259:0] sum3_1,car3_1;
	wire [259:0] car2_1p2,car2_2p4;
	
	assign car2_1p2 = car2_1 << 1,
		   car2_2p4 = car2_2 << 2;
	
	csa_reduction t3_csa1(
		.A(car2_1p2),
		.B(sum2_1),
		.C(car2_2p4),
		.SUM(sum3_1),
		.CARRY(car3_1)
		);
	
	//csa加法树第四层
	wire [259:0] sum4_1,car4_1;
	wire [259:0] car3_1p2,sum2_2p2;
	

	assign car3_1p2 = car3_1 << 1,
		   sum2_2p2 = sum2_2 << 1;
	
	csa_reduction t4_csa1(
		.A(car3_1p2),
		.B(sum3_1),
		.C(sum2_2p2),
		.SUM(sum4_1),
		.CARRY(car4_1)
		);
	
	//csa加法树第五层
	wire [259:0] sum5_1,car5_1;
	wire [259:0] car4_1p2,car345p4;
	
	assign car4_1p2 = car4_1 << 1,
		   car345p4 = car345 << 2;

	
	csa_reduction t5_csa1(
		.A(car4_1p2),
		.B(sum4_1),
		.C(car345p4),
		.SUM(sum5_1),
		.CARRY(car5_1)
		);
		
	//加减法结果计算
	reg [259:0] sum,sub;
	always@(*) begin
		sum = (car5_1 << 1)+sum5_1;
		sub = (car2_3 << 1) +sum2_3;
	end
	
	//最初的余数计算
	reg [259:0] r;
	always@(*)  begin
	r=sum - sub;
	//$display("r mod p = %h",r%p);
	end
	
	//最后进行对余数的简单约减
	reg [259:0] result_temp16,result_temp8,result_temp4,result_temp2,result_temp;
	reg [259:0] p_16 = p << 4 , p_8 = p << 3 , p_4 = p << 2 , p_2 = p << 1 , p_1={4'b0000,p};
	reg [2:0] i=3'b000;
	always@(*) begin
		 
		if(r > p_16) begin
		    result_temp16 = r - p_16;
		    //$display("16-\r");
		    end
		else result_temp16 = r;
		    
		if(result_temp16 > p_8) begin
		    result_temp8 = result_temp16 -p_8;
		    //$display("8-\r");
		    end
        else result_temp8 = result_temp16;
        
		if(result_temp8 > p_4) begin
            result_temp4 = result_temp8 -p_4;
            //$display("4-\r");
            end
        else result_temp4 = result_temp8;
        
		if(result_temp4 > p_2) begin
            result_temp2 = result_temp4 -p_2;
            //$display("2-\r");
            end
        else result_temp2 = result_temp4;
        
		if(result_temp2 > p_1) begin
            result_temp = result_temp2 -p_1;
            //$display("1-\r");
            end
        else result_temp = result_temp2;
		         
	end
	assign result = result_temp;
endmodule