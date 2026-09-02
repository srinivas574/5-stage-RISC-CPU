module pc_mux( 
	input PCSel,
	input [31:0] ALUout_MEM,
	input [31:0] pc_4,
	output [31:0] pc_in);

		assign pc_in = (PCSel == 1'b0)? pc_4 : ALUout_MEM;
endmodule
		
