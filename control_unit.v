module Control_Unit(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg RegWrite_ID,
    output reg ALUSrc_ID,
    output reg Branch_ID,
    output reg MemRead_ID,
    output reg MemWrite_ID,

    output reg [3:0] ALU_control_ID,
    output reg [3:0] DMEM_control_ID,
    output reg [1:0] wdata_sel_ID,

    output reg [2:0] imm_IDSel,

    output reg UsesRs1_ID,
    output reg UsesRs2_ID
);

always @(*) begin

    // Default values
    RegWrite_ID     = 1'b0;
    ALUSrc_ID       = 1'b0;
    Branch_ID       = 1'b0;
    MemRead_ID      = 1'b0;
    MemWrite_ID     = 1'b0;

    ALU_control_ID  = 4'd0;
    DMEM_control_ID = 4'd0;
    wdata_sel_ID    = 2'd0;

    imm_IDSel       = 3'd0;

    UsesRs1_ID      = 1'b0;
    UsesRs2_ID      = 1'b0;


    case(opcode)

        // ====================================================
        // R-TYPE
        // ====================================================
        7'b0110011: begin

            RegWrite_ID = 1'b1;
            ALUSrc_ID   = 1'b0;

            wdata_sel_ID = 2'd1;

            UsesRs1_ID = 1'b1;
            UsesRs2_ID = 1'b1;

            case(funct3)

                3'b000: begin
                    if(funct7 == 7'b0100000)
                        ALU_control_ID = 4'd1;   // SUB
                    else
                        ALU_control_ID = 4'd0;   // ADD
                end

                3'b001:
                    ALU_control_ID = 4'd5;       // SLL

                3'b010:
                    ALU_control_ID = 4'd8;       // SLT

                3'b011:
                    ALU_control_ID = 4'd9;       // SLTU

                3'b100:
                    ALU_control_ID = 4'd4;       // XOR

                3'b101: begin
                    if(funct7 == 7'b0100000)
                        ALU_control_ID = 4'd7;   // SRA
                    else
                        ALU_control_ID = 4'd6;   // SRL
                end

                3'b110:
                    ALU_control_ID = 4'd3;       // OR

                3'b111:
                    ALU_control_ID = 4'd2;       // AND

                default:
                    ALU_control_ID = 4'd0;

            endcase
        end


        // ====================================================
        // I-TYPE ALU
        // ====================================================
        7'b0010011: begin

            RegWrite_ID = 1'b1;
            ALUSrc_ID   = 1'b1;

            wdata_sel_ID = 2'd1;

            imm_IDSel = 3'd1;

            UsesRs1_ID = 1'b1;
            UsesRs2_ID = 1'b0;

            case(funct3)

                3'b000:
                    ALU_control_ID = 4'd0;       // ADDI

                3'b010:
                    ALU_control_ID = 4'd8;       // SLTI

                3'b011:
                    ALU_control_ID = 4'd9;       // SLTIU

                3'b100:
                    ALU_control_ID = 4'd4;       // XORI

                3'b110:
                    ALU_control_ID = 4'd3;       // ORI

                3'b111:
                    ALU_control_ID = 4'd2;       // ANDI

                3'b001:
                    ALU_control_ID = 4'd5;       // SLLI

                3'b101: begin
                    if(funct7 == 7'b0100000)
                        ALU_control_ID = 4'd7;   // SRAI
                    else
                        ALU_control_ID = 4'd6;   // SRLI
                end

                default:
                    ALU_control_ID = 4'd0;

            endcase
        end


        // ====================================================
        // LOAD
        // ====================================================
        7'b0000011: begin

            RegWrite_ID = 1'b1;
            ALUSrc_ID   = 1'b1;
            MemRead_ID  = 1'b1;

            wdata_sel_ID = 2'd0;

            imm_IDSel = 3'd1;

            UsesRs1_ID = 1'b1;
            UsesRs2_ID = 1'b0;

            case(funct3)

                3'b000:
                    DMEM_control_ID = 4'd1;       // LB

                3'b001:
                    DMEM_control_ID = 4'd3;       // LH

                3'b010:
                    DMEM_control_ID = 4'd5;       // LW

                3'b100:
                    DMEM_control_ID = 4'd2;       // LBU

                3'b101:
                    DMEM_control_ID = 4'd4;       // LHU

                default:
                    DMEM_control_ID = 4'd0;

            endcase
        end


        // ====================================================
        // STORE
        // ====================================================
        7'b0100011: begin

            ALUSrc_ID   = 1'b1;
            MemWrite_ID = 1'b1;

            imm_IDSel = 3'd2;

            UsesRs1_ID = 1'b1;
            UsesRs2_ID = 1'b1;

            case(funct3)

                3'b000:
                    DMEM_control_ID = 4'd6;       // SB

                3'b001:
                    DMEM_control_ID = 4'd7;       // SH

                3'b010:
                    DMEM_control_ID = 4'd8;       // SW

                default:
                    DMEM_control_ID = 4'd0;

            endcase
        end


        // ====================================================
        // BRANCH
        // ====================================================
        7'b1100011: begin

            Branch_ID = 1'b1;
            ALUSrc_ID = 1'b1;

            ALU_control_ID = 4'd0;

            imm_IDSel = 3'd3;

            UsesRs1_ID = 1'b1;
            UsesRs2_ID = 1'b1;

        end


        // ====================================================
        // JAL
        // ====================================================
        7'b1101111: begin

            RegWrite_ID = 1'b1;
            ALUSrc_ID   = 1'b1;

            ALU_control_ID = 4'd0;

            wdata_sel_ID = 2'd2;

            imm_IDSel = 3'd5;

            UsesRs1_ID = 1'b0;
            UsesRs2_ID = 1'b0;

        end


        // ====================================================
        // LUI
        // ====================================================
        7'b0110111: begin

            RegWrite_ID = 1'b1;
            ALUSrc_ID   = 1'b1;

            ALU_control_ID = 4'd0;

            wdata_sel_ID = 2'd1;

            imm_IDSel = 3'd4;

            UsesRs1_ID = 1'b0;
            UsesRs2_ID = 1'b0;

        end


        // ====================================================
        // DEFAULT
        // ====================================================
        default: begin

            RegWrite_ID     = 1'b0;
            ALUSrc_ID       = 1'b0;
            Branch_ID       = 1'b0;
            MemRead_ID      = 1'b0;
            MemWrite_ID     = 1'b0;

            ALU_control_ID  = 4'd0;
            DMEM_control_ID = 4'd0;
            wdata_sel_ID    = 2'd0;

            imm_IDSel       = 3'd0;

            UsesRs1_ID      = 1'b0;
            UsesRs2_ID      = 1'b0;

        end

    endcase

end

endmodule