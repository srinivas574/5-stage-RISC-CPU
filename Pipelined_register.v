module Reuse #(
    parameter WIDTH = 32
)(
    input clk,
    input enable,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    always @(posedge clk) begin
        if (enable)
            data_out <= data_in;
    end

endmodule


// ============================================================
// IF / ID PIPELINE REGISTER
// ============================================================

module IF_ID_Register(
    input clk,

    input IF_ID_Write,

    input [31:0] pc_IF,
    input [31:0] instruction_IF,

    output [31:0] pc_ID,
    output [31:0] instruction_ID
);

    Reuse #(.WIDTH(32)) pc_reg (
        .clk(clk),
        .enable(IF_ID_Write),
        .data_in(pc_IF),
        .data_out(pc_ID)
    );

    Reuse #(.WIDTH(32)) instruction_reg (
        .clk(clk),
        .enable(IF_ID_Write),
        .data_in(instruction_IF),
        .data_out(instruction_ID)
    );

endmodule


// ============================================================
// ID / EX PIPELINE REGISTER
// ============================================================

module ID_EX_Register(
    input clk,

    input [31:0] pc_ID,
    input [31:0] rdata1_ID,
    input [31:0] rdata2_ID,
    input [31:0] imm_ID,
    input [31:0] instruction_ID,

    input JAL_ID,

    // Source registers needed for forwarding
    input [4:0] rs1_ID,
    input [4:0] rs2_ID,

    input [4:0] rd_ID,

    input [3:0] ALU_control_ID,
    input ALUSrc_ID,
    input Branch_ID,
    input RegWrite_ID,
    input MemRead_ID,
    input MemWrite_ID,

    input [3:0] DMEM_control_ID,
    input [1:0] wdata_sel_ID,

    // Used to insert a bubble during a load-use hazard
    input Control_Nop,

    output [31:0] pc_EX,
    output [31:0] rdata1_EX,
    output [31:0] rdata2_EX,
    output [31:0] imm_EX,
    output [31:0] instruction_EX,

    output JAL_EX,

    // Source registers carried into EX
    output [4:0] rs1_EX,
    output [4:0] rs2_EX,

    output [4:0] rd_EX,

    output [3:0] ALU_control_EX,
    output ALUSrc_EX,
    output Branch_EX,
    output RegWrite_EX,
    output MemRead_EX,
    output MemWrite_EX,

    output [3:0] DMEM_control_EX,
    output [1:0] wdata_sel_EX
);

    // --------------------------------------------------------
    // Data registers
    // These still pass the instruction/data.
    // Control_Nop only changes the control signals.
    // --------------------------------------------------------

    Reuse #(.WIDTH(32)) pc_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(pc_ID),
        .data_out(pc_EX)
    );

    Reuse #(.WIDTH(32)) rdata1_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(rdata1_ID),
        .data_out(rdata1_EX)
    );

    Reuse #(.WIDTH(32)) rdata2_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(rdata2_ID),
        .data_out(rdata2_EX)
    );

    Reuse #(.WIDTH(32)) imm_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(imm_ID),
        .data_out(imm_EX)
    );

    Reuse #(.WIDTH(32)) instruction_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(instruction_ID),
        .data_out(instruction_EX)
    );


    // --------------------------------------------------------
    // JAL
    // --------------------------------------------------------

    Reuse #(.WIDTH(1)) JAL_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(JAL_ID),
        .data_out(JAL_EX)
    );


    // --------------------------------------------------------
    // Source register numbers
    // Needed by the forwarding unit
    // --------------------------------------------------------

    Reuse #(.WIDTH(5)) rs1_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(rs1_ID),
        .data_out(rs1_EX)
    );

    Reuse #(.WIDTH(5)) rs2_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(rs2_ID),
        .data_out(rs2_EX)
    );


    // --------------------------------------------------------
    // Destination register
    // --------------------------------------------------------

    Reuse #(.WIDTH(5)) rd_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(rd_ID),
        .data_out(rd_EX)
    );


    // --------------------------------------------------------
    // Control signals
    //
    // If Control_Nop = 1:
    // all control signals become 0.
    //
    // This turns the instruction into a bubble.
    // --------------------------------------------------------

    Reuse #(.WIDTH(4)) ALU_control_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(Control_Nop ? 4'd0 : ALU_control_ID),
        .data_out(ALU_control_EX)
    );

    Reuse #(.WIDTH(1)) ALUSrc_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(Control_Nop ? 1'b0 : ALUSrc_ID),
        .data_out(ALUSrc_EX)
    );

    Reuse #(.WIDTH(1)) Branch_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(Control_Nop ? 1'b0 : Branch_ID),
        .data_out(Branch_EX)
    );

    Reuse #(.WIDTH(1)) RegWrite_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(Control_Nop ? 1'b0 : RegWrite_ID),
        .data_out(RegWrite_EX)
    );

    Reuse #(.WIDTH(1)) MemRead_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(Control_Nop ? 1'b0 : MemRead_ID),
        .data_out(MemRead_EX)
    );

    Reuse #(.WIDTH(1)) MemWrite_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(Control_Nop ? 1'b0 : MemWrite_ID),
        .data_out(MemWrite_EX)
    );

    Reuse #(.WIDTH(4)) DMEM_control_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(Control_Nop ? 4'd0 : DMEM_control_ID),
        .data_out(DMEM_control_EX)
    );

    Reuse #(.WIDTH(2)) wdata_sel_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(Control_Nop ? 2'd0 : wdata_sel_ID),
        .data_out(wdata_sel_EX)
    );

endmodule


// ============================================================
// EX / MEM PIPELINE REGISTER
// ============================================================

module EX_MEM_Register(
    input clk,

    input [31:0] pc_EX,
    input [31:0] ALUout_EX,
    input [31:0] rdata2_EX,
    input [31:0] instruction_EX,

    input JAL_EX,

    input [4:0] rd_EX,

    input Branch_EX,
    input Breq_EX,

    input RegWrite_EX,
    input MemRead_EX,
    input MemWrite_EX,

    input [3:0] DMEM_control_EX,
    input [1:0] wdata_sel_EX,

    output [31:0] pc_MEM,
    output [31:0] ALUout_MEM,
    output [31:0] rdata2_MEM,
    output [31:0] instruction_MEM,

    output JAL_MEM,

    output [4:0] rd_MEM,

    output Branch_MEM,
    output Breq_MEM,

    output RegWrite_MEM,
    output MemRead_MEM,
    output MemWrite_MEM,

    output [3:0] DMEM_control_MEM,
    output [1:0] wdata_sel_MEM
);

    Reuse #(.WIDTH(32)) pc_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(pc_EX),
        .data_out(pc_MEM)
    );

    Reuse #(.WIDTH(32)) ALUout_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(ALUout_EX),
        .data_out(ALUout_MEM)
    );

    Reuse #(.WIDTH(32)) rdata2_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(rdata2_EX),
        .data_out(rdata2_MEM)
    );

    Reuse #(.WIDTH(32)) instruction_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(instruction_EX),
        .data_out(instruction_MEM)
    );


    // --------------------------------------------------------
    // JAL
    // --------------------------------------------------------

    Reuse #(.WIDTH(1)) JAL_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(JAL_EX),
        .data_out(JAL_MEM)
    );


    // --------------------------------------------------------
    // Destination register
    // --------------------------------------------------------

    Reuse #(.WIDTH(5)) rd_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(rd_EX),
        .data_out(rd_MEM)
    );


    // --------------------------------------------------------
    // Branch information
    // --------------------------------------------------------

    Reuse #(.WIDTH(1)) Branch_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(Branch_EX),
        .data_out(Branch_MEM)
    );

    Reuse #(.WIDTH(1)) Breq_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(Breq_EX),
        .data_out(Breq_MEM)
    );


    // --------------------------------------------------------
    // Control signals
    // --------------------------------------------------------

    Reuse #(.WIDTH(1)) RegWrite_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(RegWrite_EX),
        .data_out(RegWrite_MEM)
    );

    Reuse #(.WIDTH(1)) MemRead_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(MemRead_EX),
        .data_out(MemRead_MEM)
    );

    Reuse #(.WIDTH(1)) MemWrite_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(MemWrite_EX),
        .data_out(MemWrite_MEM)
    );

    Reuse #(.WIDTH(4)) DMEM_control_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(DMEM_control_EX),
        .data_out(DMEM_control_MEM)
    );

    Reuse #(.WIDTH(2)) wdata_sel_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(wdata_sel_EX),
        .data_out(wdata_sel_MEM)
    );

endmodule


// ============================================================
// MEM / WB PIPELINE REGISTER
// ============================================================

module MEM_WB_Register(
    input clk,

    input [31:0] ALUout_MEM,
    input [31:0] mem_MEM,
    input [31:0] pc4_MEM,
    input [31:0] instruction_MEM,

    input [4:0] rd_MEM,

    input RegWrite_MEM,
    input [1:0] wdata_sel_MEM,

    output [31:0] ALUout_WB,
    output [31:0] mem_WB,
    output [31:0] pc4_WB,
    output [31:0] instruction_WB,

    output [4:0] rd_WB,

    output RegWrite_WB,
    output [1:0] wdata_sel_WB
);

    Reuse #(.WIDTH(32)) ALUout_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(ALUout_MEM),
        .data_out(ALUout_WB)
    );

    Reuse #(.WIDTH(32)) mem_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(mem_MEM),
        .data_out(mem_WB)
    );

    Reuse #(.WIDTH(32)) pc4_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(pc4_MEM),
        .data_out(pc4_WB)
    );

    Reuse #(.WIDTH(32)) instruction_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(instruction_MEM),
        .data_out(instruction_WB)
    );


    // --------------------------------------------------------
    // Destination register
    // --------------------------------------------------------

    Reuse #(.WIDTH(5)) rd_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(rd_MEM),
        .data_out(rd_WB)
    );


    // --------------------------------------------------------
    // Control signals
    // --------------------------------------------------------

    Reuse #(.WIDTH(1)) RegWrite_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(RegWrite_MEM),
        .data_out(RegWrite_WB)
    );

    Reuse #(.WIDTH(2)) wdata_sel_reg (
        .clk(clk),
        .enable(1'b1),
        .data_in(wdata_sel_MEM),
        .data_out(wdata_sel_WB)
    );

endmodule