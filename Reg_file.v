module Reg_file(
	input clk,
	input [4:0] rd,
	input [4:0] rs1,
	input [4:0] rs2,
	input RegWEn,
	input [31:0] wdata,
	output [31:0] rdata1_ID,
	output [31:0] rdata2_ID);
	
	reg [31:0] registers [0:31];
	
	always@(posedge clk) begin 
		if(RegWEn) 
			registers[rd] <= wdata;
	end
	
	assign rdata1_ID = registers[rs1];
	assign rdata2_ID = registers[rs2];
	
endmodule 
			
			
		 
		
