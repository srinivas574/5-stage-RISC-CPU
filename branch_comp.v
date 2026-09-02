module branch_comp (
	input [31:0] rdata1_EX,
	input [31:0] rdata2_EX,
	input Brun,
	output Breq,
	output Brlt);
	
	assign Breq = (rdata1_EX == rdata2_EX);
	assign Brlt = Brun? ($unsigned(rdata1_EX) < $unsigned(rdata2_EX)): 
						($signed(rdata1_EX) < $signed(rdata2_EX));
	
endmodule 

