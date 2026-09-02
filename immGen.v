module imm_IDGen(
	input [31:0] instruction_ID,
	input [2:0] imm_IDSel,
	output reg [31:0] imm_ID);
	
	always@(*) begin 
		case(imm_IDSel)
			3'd0: imm_ID = 32'b0;
			3'd1: imm_ID = {{20{instruction_ID[31]}},instruction_ID[31:20]};
			3'd2: imm_ID = {{20{instruction_ID[31]}},instruction_ID[31:25],instruction_ID[11:7]};
			3'd3: imm_ID = {{20{instruction_ID[31]}},instruction_ID[7],instruction_ID[30:25],instruction_ID[11:8],1'b0};
			3'd4: imm_ID = {instruction_ID[31:12],12'b0};
			3'd5: imm_ID = {{12{instruction_ID[31]}}, instruction_ID[19:12], instruction_ID[20], instruction_ID[30:21], 1'b0};   
			default: imm_ID = 32'b0;
	    endcase
	end 
endmodule 

