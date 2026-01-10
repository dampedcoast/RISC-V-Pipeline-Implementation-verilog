module forwarding_unit (
    input  wire        exmem_regwrite,
    input  wire [4:0]  exmem_rd,
    input  wire        memwb_regwrite,
    input  wire [4:0]  memwb_rd,
    input  wire [4:0]  idex_rs1,
    input  wire [4:0]  idex_rs2,
    output reg  [1:0]  forward_a,
    output reg  [1:0]  forward_b
);

    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        if (exmem_regwrite && (exmem_rd != 0) && (exmem_rd == idex_rs1))
            forward_a = 2'b10;
        else if (memwb_regwrite && (memwb_rd != 0) && (memwb_rd == idex_rs1))
            forward_a = 2'b01;

        if (exmem_regwrite && (exmem_rd != 0) && (exmem_rd == idex_rs2))
            forward_b = 2'b10;
        else if (memwb_regwrite && (memwb_rd != 0) && (memwb_rd == idex_rs2))
            forward_b = 2'b01;
    end

endmodule
