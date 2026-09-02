module Top(
    input clk
);

    // ============================================================
    // IF STAGE
    // ============================================================

    wire [31:0] pc_IF;
    wire [31:0] pc_4;
    wire [31:0] pc_in;
    wire [31:0] instruction_IF;

    wire PCWrite;

    Program_counter PC(
        .clk(clk),
        .PCWrite(PCWrite),
        .pc_in(pc_in),
        .pc_IF(pc_IF)
    );

    instruction_memory IMEM(
        .pc_IF(pc_IF),
        .instruction_IF(instruction_IF)
    );

    pc_adder PC_ADDER(
        .pc_IF(pc_IF),
        .pc_4(pc_4)
    );


    // ============================================================
    // IF / ID PIPELINE REGISTER
    // ============================================================

    wire [31:0] pc_ID;
    wire [31:0] instruction_ID;

    wire IF_ID_Write;
    wire Flush;

    IF_ID_Register IF_ID(
        .clk(clk),
        .IF_ID_Write(IF_ID_Write),
        .Flush(Flush),

        .pc_IF(pc_IF),
        .instruction_IF(instruction_IF),

        .pc_ID(pc_ID),
        .instruction_ID(instruction_ID)
    );


    // ============================================================
    // ID STAGE
    // ============================================================

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    wire [4:0] rs1_ID;
    wire [4:0] rs2_ID;
    wire [4:0] rd_ID;

    assign opcode = instruction_ID[6:0];
    assign funct3 = instruction_ID[14:12];
    assign funct7 = instruction_ID[31:25];

    assign rs1_ID = instruction_ID[19:15];
    assign rs2_ID = instruction_ID[24:20];
    assign rd_ID  = instruction_ID[11:7];


    // ============================================================
    // JAL / LUI DETECTION
    // ============================================================

    wire JAL_ID;
    wire LUI_ID;

    assign JAL_ID = (opcode == 7'b1101111);
    assign LUI_ID = (opcode == 7'b0110111);


    // ============================================================
    // CONTROL UNIT
    // ============================================================

    wire RegWrite_ID;
    wire ALUSrc_ID;
    wire Branch_ID;
    wire MemRead_ID;
    wire MemWrite_ID;

    wire [3:0] ALU_control_ID;
    wire [3:0] DMEM_control_ID;
    wire [1:0] wdata_sel_ID;

    wire [2:0] imm_IDSel;

    wire UsesRs1_ID;
    wire UsesRs2_ID;

    Control_Unit CU(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),

        .RegWrite_ID(RegWrite_ID),
        .ALUSrc_ID(ALUSrc_ID),
        .Branch_ID(Branch_ID),
        .MemRead_ID(MemRead_ID),
        .MemWrite_ID(MemWrite_ID),

        .ALU_control_ID(ALU_control_ID),
        .DMEM_control_ID(DMEM_control_ID),
        .wdata_sel_ID(wdata_sel_ID),

        .imm_IDSel(imm_IDSel),

        .UsesRs1_ID(UsesRs1_ID),
        .UsesRs2_ID(UsesRs2_ID)
    );


    // ============================================================
    // IMMEDIATE GENERATOR
    // ============================================================

    wire [31:0] imm_ID;

    imm_IDGen IMM_GEN(
        .instruction_ID(instruction_ID),
        .imm_IDSel(imm_IDSel),
        .imm_ID(imm_ID)
    );


    // ============================================================
    // REGISTER FILE
    // ============================================================

    wire [31:0] rdata1_ID;
    wire [31:0] rdata2_ID;

    wire [31:0] wdata;

    wire [4:0] rd_WB;
    wire RegWrite_WB;

    Reg_file RF(
        .clk(clk),

        .rd(rd_WB),
        .rs1(rs1_ID),
        .rs2(rs2_ID),

        .RegWEn(RegWrite_WB),
        .wdata(wdata),

        .rdata1_ID(rdata1_ID),
        .rdata2_ID(rdata2_ID)
    );


    // ============================================================
    // ID / EX SIGNALS
    // ============================================================

    wire [31:0] pc_EX;
    wire [31:0] rdata1_EX;
    wire [31:0] rdata2_EX;
    wire [31:0] imm_EX;
    wire [31:0] instruction_EX;

    wire JAL_EX;
    wire LUI_EX;
    wire [2:0] funct3_EX;

    wire [4:0] rs1_EX;
    wire [4:0] rs2_EX;
    wire [4:0] rd_EX;

    wire [3:0] ALU_control_EX;
    wire ALUSrc_EX;
    wire Branch_EX;
    wire RegWrite_EX;
    wire MemRead_EX;
    wire MemWrite_EX;

    wire [3:0] DMEM_control_EX;
    wire [1:0] wdata_sel_EX;


    // ============================================================
    // LOAD-USE HAZARD DETECTION
    // ============================================================

    wire Control_Nop;

    Hazard_Detection_Unit HDU(
        .rs1_ID(rs1_ID),
        .rs2_ID(rs2_ID),

        .rd_EX(rd_EX),
        .MemRead_EX(MemRead_EX),

        .UsesRs1_ID(UsesRs1_ID),
        .UsesRs2_ID(UsesRs2_ID),

        .PCWrite(PCWrite),
        .IF_ID_Write(IF_ID_Write),
        .Control_Nop(Control_Nop)
    );


    // ============================================================
    // ID / EX PIPELINE REGISTER
    // ============================================================

    wire ID_EX_Nop;

    // Either a load-use hazard or control hazard creates a bubble
    assign ID_EX_Nop = Control_Nop | Flush;

    ID_EX_Register ID_EX(
        .clk(clk),

        .pc_ID(pc_ID),
        .rdata1_ID(rdata1_ID),
        .rdata2_ID(rdata2_ID),
        .imm_ID(imm_ID),
        .instruction_ID(instruction_ID),

        .JAL_ID(JAL_ID),
        .LUI_ID(LUI_ID),
        .funct3_ID(funct3),

        .rs1_ID(rs1_ID),
        .rs2_ID(rs2_ID),

        .rd_ID(rd_ID),

        .ALU_control_ID(ALU_control_ID),
        .ALUSrc_ID(ALUSrc_ID),
        .Branch_ID(Branch_ID),
        .RegWrite_ID(RegWrite_ID),
        .MemRead_ID(MemRead_ID),
        .MemWrite_ID(MemWrite_ID),

        .DMEM_control_ID(DMEM_control_ID),
        .wdata_sel_ID(wdata_sel_ID),

        .Control_Nop(ID_EX_Nop),

        .pc_EX(pc_EX),
        .rdata1_EX(rdata1_EX),
        .rdata2_EX(rdata2_EX),
        .imm_EX(imm_EX),
        .instruction_EX(instruction_EX),

        .JAL_EX(JAL_EX),
        .LUI_EX(LUI_EX),
        .funct3_EX(funct3_EX),

        .rs1_EX(rs1_EX),
        .rs2_EX(rs2_EX),

        .rd_EX(rd_EX),

        .ALU_control_EX(ALU_control_EX),
        .ALUSrc_EX(ALUSrc_EX),
        .Branch_EX(Branch_EX),
        .RegWrite_EX(RegWrite_EX),
        .MemRead_EX(MemRead_EX),
        .MemWrite_EX(MemWrite_EX),

        .DMEM_control_EX(DMEM_control_EX),
        .wdata_sel_EX(wdata_sel_EX)
    );


    // ============================================================
    // EX / MEM SIGNALS
    // ============================================================

    wire [31:0] pc_MEM;
    wire [31:0] ALUout_MEM;
    wire [31:0] rdata2_MEM;
    wire [31:0] instruction_MEM;

    wire JAL_MEM;

    wire [4:0] rd_MEM;

    wire Branch_MEM;
    wire Breq_MEM;

    wire RegWrite_MEM;
    wire MemRead_MEM;
    wire MemWrite_MEM;

    wire [3:0] DMEM_control_MEM;
    wire [1:0] wdata_sel_MEM;


    // ============================================================
    // DATA FORWARDING
    // ============================================================

    wire [1:0] ForwardA;
    wire [1:0] ForwardB;

    Forwarding_Unit FU(
        .rs1_EX(rs1_EX),
        .rs2_EX(rs2_EX),

        .rd_MEM(rd_MEM),
        .RegWrite_MEM(RegWrite_MEM),

        .rd_WB(rd_WB),
        .RegWrite_WB(RegWrite_WB),

        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );


    // ============================================================
    // FORWARDING MUX
    // ============================================================

    wire [31:0] forwarded_rdata1_EX;
    wire [31:0] forwarded_rdata2_EX;

    Forwarding_Mux FORWARDING_MUX(
        .rdata1_EX(rdata1_EX),
        .rdata2_EX(rdata2_EX),

        .ALUout_MEM(ALUout_MEM),
        .wdata(wdata),

        .ForwardA(ForwardA),
        .ForwardB(ForwardB),

        .forwarded_rdata1_EX(forwarded_rdata1_EX),
        .forwarded_rdata2_EX(forwarded_rdata2_EX)
    );


    // ============================================================
    // EX STAGE
    // ============================================================

    wire [31:0] ALU_mux1;
    wire [31:0] ALU_mux2;
    wire [31:0] ALUout_EX;

    ALU_muxA ALU_MUX_A(
        .pc_EX(pc_EX),
        .rdata1_EX(forwarded_rdata1_EX),
        .ALU_muxsel1(Branch_EX | JAL_EX),
        .LUI_EX(LUI_EX),
        .ALU_mux1(ALU_mux1)
    );

    ALU_muxB ALU_MUX_B(
        .rdata2_EX(forwarded_rdata2_EX),
        .imm_EX(imm_EX),
        .ALU_muxsel2(ALUSrc_EX),
        .ALU_mux2(ALU_mux2)
    );

    ALU ALU_UNIT(
        .ALU_mux1(ALU_mux1),
        .ALU_mux2(ALU_mux2),
        .ALU_control(ALU_control_EX),
        .ALUout_EX(ALUout_EX)
    );


    // ============================================================
    // BRANCH COMPARATOR
    // Use forwarded values
    // ============================================================

    wire Breq_EX;
    wire Brlt_EX;
    wire Brun_EX;

    // funct3[1] = 1 for BLTU (110) / BGEU (111) -> unsigned compare
    assign Brun_EX = funct3_EX[1];

    branch_comp BRANCH_COMP(
        .rdata1_EX(forwarded_rdata1_EX),
        .rdata2_EX(forwarded_rdata2_EX),

        .Brun(Brun_EX),

        .Breq(Breq_EX),
        .Brlt(Brlt_EX)
    );


    // ============================================================
    // CONTROL HAZARD
    // Branch and JAL are resolved in EX
    // ============================================================

    wire BranchCond_EX;
    wire BranchTaken;

    assign BranchCond_EX =
        (funct3_EX == 3'b000) ?  Breq_EX :   // BEQ
        (funct3_EX == 3'b001) ? ~Breq_EX :   // BNE
        (funct3_EX == 3'b100) ?  Brlt_EX :   // BLT
        (funct3_EX == 3'b101) ? ~Brlt_EX :   // BGE
        (funct3_EX == 3'b110) ?  Brlt_EX :   // BLTU
        (funct3_EX == 3'b111) ? ~Brlt_EX :   // BGEU
                                  1'b0;

    assign BranchTaken = Branch_EX & BranchCond_EX;

    assign Flush = BranchTaken | JAL_EX;


    // ============================================================
    // EX / MEM PIPELINE REGISTER
    // ============================================================

    EX_MEM_Register EX_MEM(
        .clk(clk),

        .pc_EX(pc_EX),
        .ALUout_EX(ALUout_EX),
        .rdata2_EX(forwarded_rdata2_EX),
        .instruction_EX(instruction_EX),

        .JAL_EX(JAL_EX),

        .rd_EX(rd_EX),

        .Branch_EX(Branch_EX),
        .Breq_EX(Breq_EX),

        .RegWrite_EX(RegWrite_EX),
        .MemRead_EX(MemRead_EX),
        .MemWrite_EX(MemWrite_EX),

        .DMEM_control_EX(DMEM_control_EX),
        .wdata_sel_EX(wdata_sel_EX),

        .pc_MEM(pc_MEM),
        .ALUout_MEM(ALUout_MEM),
        .rdata2_MEM(rdata2_MEM),
        .instruction_MEM(instruction_MEM),

        .JAL_MEM(JAL_MEM),

        .rd_MEM(rd_MEM),

        .Branch_MEM(Branch_MEM),
        .Breq_MEM(Breq_MEM),

        .RegWrite_MEM(RegWrite_MEM),
        .MemRead_MEM(MemRead_MEM),
        .MemWrite_MEM(MemWrite_MEM),

        .DMEM_control_MEM(DMEM_control_MEM),
        .wdata_sel_MEM(wdata_sel_MEM)
    );


    // ============================================================
    // MEM STAGE
    // ============================================================

    wire [31:0] mem_MEM;

    DMEM DATA_MEMORY(
        .clk(clk),

        .ALUout_MEM(ALUout_MEM),
        .rdata2_MEM(rdata2_MEM),

        .DMEM_control(DMEM_control_MEM),

        .mem_MEM(mem_MEM)
    );


    // ============================================================
    // PC SELECTION
    // Branch/JAL target comes from EX
    // ============================================================

    wire PCSel;

    assign PCSel = BranchTaken | JAL_EX;

    pc_mux PC_MUX(
        .PCSel(PCSel),

        .ALUout_MEM(ALUout_EX),

        .pc_4(pc_4),

        .pc_in(pc_in)
    );


    // ============================================================
    // PC + 4 FOR JAL
    // ============================================================

    wire [31:0] pc4_MEM;

    pc_adder2 PC_ADDER2(
        .pc_MEM(pc_MEM),
        .pc4_MEM(pc4_MEM)
    );


    // ============================================================
    // MEM / WB SIGNALS
    // ============================================================

    wire [31:0] ALUout_WB;
    wire [31:0] mem_WB;
    wire [31:0] pc4_WB;
    wire [31:0] instruction_WB;

    wire [1:0] wdata_sel_WB;


    // ============================================================
    // MEM / WB PIPELINE REGISTER
    // ============================================================

    MEM_WB_Register MEM_WB(
        .clk(clk),

        .ALUout_MEM(ALUout_MEM),
        .mem_MEM(mem_MEM),
        .pc4_MEM(pc4_MEM),
        .instruction_MEM(instruction_MEM),

        .rd_MEM(rd_MEM),

        .RegWrite_MEM(RegWrite_MEM),
        .wdata_sel_MEM(wdata_sel_MEM),

        .ALUout_WB(ALUout_WB),
        .mem_WB(mem_WB),
        .pc4_WB(pc4_WB),
        .instruction_WB(instruction_WB),

        .rd_WB(rd_WB),

        .RegWrite_WB(RegWrite_WB),
        .wdata_sel_WB(wdata_sel_WB)
    );


    // ============================================================
    // WB STAGE
    // ============================================================

    wdata_mux WDATA_MUX(
        .ALUout_WB(ALUout_WB),
        .mem_WB(mem_WB),
        .pc4_WB(pc4_WB),

        .wdata_sel(wdata_sel_WB),

        .wdata(wdata)
    );

endmodule