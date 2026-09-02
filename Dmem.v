module DMEM(
    input clk,
    input [31:0] ALUout_MEM,
    input [31:0] rdata2_MEM,
    input [3:0] DMEM_control,
    output reg [31:0] mem_MEM);

    reg [7:0] memory [0:1023];

    always @(*) begin
        mem_MEM = 32'd0;

        case (DMEM_control)

            4'd1: begin
                mem_MEM = {{24{memory[ALUout_MEM][7]}},
                             memory[ALUout_MEM]};
            end

            4'd2: begin
                mem_MEM = {24'd0,
                             memory[ALUout_MEM]};
            end

            4'd3: begin
                mem_MEM = {{16{memory[ALUout_MEM+1][7]}},
                             memory[ALUout_MEM+1],
                             memory[ALUout_MEM]};
            end

            4'd4: begin
                mem_MEM = {16'd0,
                             memory[ALUout_MEM+1],
                             memory[ALUout_MEM]};
            end

            4'd5: begin
                mem_MEM = {memory[ALUout_MEM+3],
                             memory[ALUout_MEM+2],
                             memory[ALUout_MEM+1],
                             memory[ALUout_MEM]};
            end

            default: begin
                mem_MEM = 32'd0;
            end

        endcase
    end

    always @(posedge clk) begin
        case (DMEM_control)

            4'd6: begin
                memory[ALUout_MEM] <= rdata2_MEM[7:0];
            end

            4'd7: begin
                memory[ALUout_MEM]   <= rdata2_MEM[7:0];
                memory[ALUout_MEM+1] <= rdata2_MEM[15:8];
            end

            4'd8: begin
                memory[ALUout_MEM]   <= rdata2_MEM[7:0];
                memory[ALUout_MEM+1] <= rdata2_MEM[15:8];
                memory[ALUout_MEM+2] <= rdata2_MEM[23:16];
                memory[ALUout_MEM+3] <= rdata2_MEM[31:24];
            end

            default: begin
            end

        endcase
    end

endmodule