`timescale 1ns / 1ps
module csa_reduction(
	input[259:0] A,
	input[259:0] B,
	input[259:0] C,
	output[259:0] SUM,
	output[259:0] CARRY
);
	assign SUM = A ^ B ^ C;
	assign CARRY = (A & B) | (B & C) | (C & A);

endmodule
