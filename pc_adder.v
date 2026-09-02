module pc_adder(
	input [31:0] pc_IF,
	output [31:0] pc_4);
	
	assign pc_4 = pc_IF + 32'd4;
endmodule 

module pc_adder2(
	input [31:0] pc_MEM,
	output [31:0] pc4_MEM);
	
	assign pc4_MEM = pc_MEM + 32'd4;
endmodule 

