module instruction_memory(
    input [31:0] pc_IF,
    output [31:0] instruction_IF
);

  reg [7:0] memory [0:255];

initial begin
    memory[0]  = 8'h13;
    memory[1]  = 8'h01;
    memory[2]  = 8'h50;
    memory[3]  = 8'h00;

    memory[4]  = 8'h93;
    memory[5]  = 8'h01;
    memory[6]  = 8'hC0;
    memory[7]  = 8'h00;

    memory[8]  = 8'h93;
    memory[9]  = 8'h83;
    memory[10] = 8'h71;
    memory[11] = 8'hFF;

    memory[12] = 8'h33;
    memory[13] = 8'hE2;
    memory[14] = 8'h23;
    memory[15] = 8'h00;

    memory[16] = 8'hB3;
    memory[17] = 8'hF2;
    memory[18] = 8'h41;
    memory[19] = 8'h00;

    memory[20] = 8'hB3;
    memory[21] = 8'h82;
    memory[22] = 8'h42;
    memory[23] = 8'h00;

    memory[24] = 8'h63;
    memory[25] = 8'h88;
    memory[26] = 8'h72;
    memory[27] = 8'h02;

    memory[28] = 8'h33;
    memory[29] = 8'hA2;
    memory[30] = 8'h41;
    memory[31] = 8'h00;

    memory[32] = 8'h63;
    memory[33] = 8'h04;
    memory[34] = 8'h02;
    memory[35] = 8'h00;

    memory[36] = 8'h93;
    memory[37] = 8'h02;
    memory[38] = 8'h00;
    memory[39] = 8'h00;

    memory[40] = 8'h33;
    memory[41] = 8'hA2;
    memory[42] = 8'h23;
    memory[43] = 8'h00;

    memory[44] = 8'hB3;
    memory[45] = 8'h03;
    memory[46] = 8'h52;
    memory[47] = 8'h00;

    memory[48] = 8'hB3;
    memory[49] = 8'h83;
    memory[50] = 8'h23;
    memory[51] = 8'h40;

    memory[52] = 8'h23;
    memory[53] = 8'hAA;
    memory[54] = 8'h71;
    memory[55] = 8'h04;

    memory[56] = 8'h03;
    memory[57] = 8'h21;
    memory[58] = 8'h00;
    memory[59] = 8'h06;

    memory[60] = 8'hB3;
    memory[61] = 8'h04;
    memory[62] = 8'h51;
    memory[63] = 8'h00;

    memory[64] = 8'hEF;
    memory[65] = 8'h01;
    memory[66] = 8'h80;
    memory[67] = 8'h00;

    memory[68] = 8'h13;
    memory[69] = 8'h01;
    memory[70] = 8'h10;
    memory[71] = 8'h00;

    memory[72] = 8'h33;
    memory[73] = 8'h01;
    memory[74] = 8'h91;
    memory[75] = 8'h00;

    memory[76] = 8'h23;
    memory[77] = 8'hA0;
    memory[78] = 8'h21;
    memory[79] = 8'h02;

    memory[80] = 8'h63;
    memory[81] = 8'h00;
    memory[82] = 8'h21;
    memory[83] = 8'h00;

    memory[84] = 8'h03;
    memory[85] = 8'h83;
    memory[86] = 8'h01;
    memory[87] = 8'h00;   // lb x6, 0(x3)

    memory[88] = 8'h83;
    memory[89] = 8'hC3;
    memory[90] = 8'h01;
    memory[91] = 8'h00;   // lbu x7, 0(x3)

    memory[92] = 8'h23;
    memory[93] = 8'h80;
    memory[94] = 8'h61;
    memory[95] = 8'h00;   // sb x6, 0(x3)
end
   assign instruction_IF = {
	memory[pc_IF + 3],
    memory[pc_IF + 2],
    memory[pc_IF + 1],
    memory[pc_IF]};

endmodule