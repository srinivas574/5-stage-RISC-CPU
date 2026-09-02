module wdata_mux(
    input [31:0] ALUout_WB,
    input [31:0] mem_WB,
    input [31:0] pc4_WB,
    input [1:0] wdata_sel,
    output [31:0] wdata
);

    assign wdata = (wdata_sel == 2'd0) ? mem_WB :
                   (wdata_sel == 2'd1) ? ALUout_WB :
                   (wdata_sel == 2'd2) ? pc4_WB :
                   32'd0;

endmodule