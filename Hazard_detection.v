module Hazard_Detection_Unit(
    input [4:0] rs1_ID,
    input [4:0] rs2_ID,
    input [4:0] rd_EX,
    input MemRead_EX,
    input UsesRs1_ID,
    input UsesRs2_ID,

    output reg PCWrite,
    output reg IF_ID_Write,
    output reg Control_Nop
);

always @(*) begin

    // Normal operation
    PCWrite     = 1'b1;
    IF_ID_Write = 1'b1;
    Control_Nop = 1'b0;

    // Load-use hazard
    if (MemRead_EX &&
        (rd_EX != 5'b00000) &&
        ((UsesRs1_ID && (rd_EX == rs1_ID)) ||
         (UsesRs2_ID && (rd_EX == rs2_ID)))) begin

        // Stall PC
        PCWrite = 1'b0;

        // Stall IF/ID
        IF_ID_Write = 1'b0;

        // Insert NOP into ID/EX
        Control_Nop = 1'b1;
    end
end

endmodule