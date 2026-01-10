`timescale 1ns/1ps

module data_memory_tb;

    reg clk;
    reg mem_write, mem_read;
    reg [2:0] funct3;
    reg [31:0] addr;
    reg [31:0] write_data;
    wire [31:0] read_data;

    data_memory UUT(
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .funct3(funct3),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        mem_write = 0;
        mem_read = 0;
        funct3 = 3'b010;
        addr = 0;
        write_data = 0;

        $display("Testing Data Memory LW/SW...");

        // Write
        addr = 32'd0;
        write_data = 32'h11223344;
        mem_write = 1;
        #10 mem_write = 0;

        // Read
        mem_read = 1;
        #1 $display("LW = %h (Expected 11223344)", read_data);
        #10 mem_read = 0;

        $finish;
    end

endmodule
