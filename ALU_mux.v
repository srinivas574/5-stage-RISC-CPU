module ALU_muxA(
	input [31:0] pc_EX,
	input [31:0] rdata1_EX,
	input ALU_muxsel1,
	output [31:0] ALU_mux1);
	
	assign ALU_mux1 = ALU_muxsel1? pc_EX: rdata1_EX;
endmodule 

module ALU_muxB(
	input [31:0] rdata2_EX,
	input [31:0] imm_EX,
	input ALU_muxsel2,
	output [31:0] ALU_mux2);
	
	assign ALU_mux2 = ALU_muxsel2? imm_EX: rdata2_EX;
endmodule 

	
	
