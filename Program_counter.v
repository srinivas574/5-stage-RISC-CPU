module Program_counter(
    input clk,
    input PCWrite,
    input [31:0] pc_in,
    output reg [31:0] pc_IF
);

    initial begin
        pc_IF = 32'd0;
    end

    always @(posedge clk) begin
        if (PCWrite)
            pc_IF <= pc_in;
    end

endmodule