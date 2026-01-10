`timescale 1ns/1ps

module data_memory(
    input  wire         clk,
    input  wire         mem_write,
    input  wire         mem_read,
    input  wire [2:0]   funct3,
    input  wire [31:0]  addr,
    input  wire [31:0]  write_data,
    output reg  [31:0]  read_data
);

    reg [31:0] mem [0:2047];

    wire [10:0] word_index;
    assign word_index = addr[12:2];   

    integer i;
    initial begin
        for (i = 0; i < 2048; i = i + 1)
            mem[i] = 32'b0;
             mem[0] = 32'h00000007;
    end

    always @(posedge clk) begin
        if (mem_write && funct3 == 3'b010) begin
            mem[word_index] <= write_data;

            $display("MEM WRITE: addr=%h idx=%0d data=%h time=%0t",
                     addr, word_index, write_data, $time);
        end
    end

    always @(*) begin
        read_data = 32'b0;

        if (mem_read && funct3 == 3'b010) begin
            read_data = mem[word_index];

            $display("MEM READ : addr=%h idx=%0d -> read_data=%h time=%0t",
                     addr, word_index, read_data, $time);
        end
    end

endmodule
