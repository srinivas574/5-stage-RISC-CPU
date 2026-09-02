module Forwarding_Mux(
    input [31:0] rdata1_EX,
    input [31:0] rdata2_EX,

    input [31:0] ALUout_MEM,
    input [31:0] wdata,

    input [1:0] ForwardA,
    input [1:0] ForwardB,

    output [31:0] forwarded_rdata1_EX,
    output [31:0] forwarded_rdata2_EX
);

    // ALU input A
    assign forwarded_rdata1_EX =
        (ForwardA == 2'b10) ? ALUout_MEM :
        (ForwardA == 2'b01) ? wdata :
                              rdata1_EX;

    // ALU input B
    assign forwarded_rdata2_EX =
        (ForwardB == 2'b10) ? ALUout_MEM :
        (ForwardB == 2'b01) ? wdata :
                              rdata2_EX;

endmodule
