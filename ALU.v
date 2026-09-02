module ALU(
	input [31:0] ALU_mux1,
	input [31:0] ALU_mux2,
	input [3:0] ALU_control,
	output reg [31:0] ALUout_EX);
	
	always@(*) begin
		case(ALU_control) 
			4'd0: ALUout_EX = ALU_mux1 + ALU_mux2;
			4'd1: ALUout_EX = ALU_mux1 - ALU_mux2;
			4'd2: ALUout_EX = ALU_mux1 & ALU_mux2;
			4'd3: ALUout_EX = ALU_mux1 | ALU_mux2;
			4'd4: ALUout_EX = ALU_mux1 ^ ALU_mux2;
			4'd5: ALUout_EX = ALU_mux1 << ALU_mux2[4:0];
			4'd6: ALUout_EX = ALU_mux1 >> ALU_mux2[4:0];
			4'd7: ALUout_EX = $signed(ALU_mux1) >>> ALU_mux2[4:0];   		
			4'd8: ALUout_EX = ($signed(ALU_mux1) < $signed(ALU_mux2));
			4'd9: ALUout_EX = ($unsigned(ALU_mux1) < $unsigned(ALU_mux2));
			default: ALUout_EX = 32'd0;
		endcase
	end
endmodule 
	
