module hazard_detection_unit (
    input  wire        idex_memread,
    input  wire [4:0]  idex_rd,
    input  wire [4:0]  ifid_rs1,
    input  wire [4:0]  ifid_rs2,

    output reg         pc_write,
    output reg         ifid_write,
    output reg         idex_flush
);

    always @(*) begin
       
        pc_write   = 1'b1;
        ifid_write = 1'b1;
        idex_flush = 1'b0;

        if (idex_memread &&
            (idex_rd != 0) &&
            ((idex_rd == ifid_rs1) || (idex_rd == ifid_rs2))) begin

            pc_write   = 1'b0;
            ifid_write = 1'b0;
            idex_flush = 1'b1;
        end
    end

endmodule
