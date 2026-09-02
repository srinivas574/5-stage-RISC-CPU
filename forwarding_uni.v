module Forwarding_Unit(
    input [4:0] rs1_EX,
    input [4:0] rs2_EX,

    input [4:0] rd_MEM,
    input RegWrite_MEM,

    input [4:0] rd_WB,
    input RegWrite_WB,

    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin

        // Default: use normal register-file values
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // ------------------------------------------------
        // MEM -> EX forwarding
        // ------------------------------------------------

        if (RegWrite_MEM &&
            (rd_MEM != 5'b00000) &&
            (rd_MEM == rs1_EX))
            ForwardA = 2'b10;

        if (RegWrite_MEM &&
            (rd_MEM != 5'b00000) &&
            (rd_MEM == rs2_EX))
            ForwardB = 2'b10;


        // ------------------------------------------------
        // WB -> EX forwarding
        // ------------------------------------------------

        if (RegWrite_WB &&
            (rd_WB != 5'b00000) &&
            (rd_WB == rs1_EX) &&
            !(RegWrite_MEM &&
              (rd_MEM != 5'b00000) &&
              (rd_MEM == rs1_EX)))
            ForwardA = 2'b01;

        if (RegWrite_WB &&
            (rd_WB != 5'b00000) &&
            (rd_WB == rs2_EX) &&
            !(RegWrite_MEM &&
              (rd_MEM != 5'b00000) &&
              (rd_MEM == rs2_EX)))
            ForwardB = 2'b01;

    end

endmodule