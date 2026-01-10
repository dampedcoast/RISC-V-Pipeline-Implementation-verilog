`timescale 1ns / 1ps

module alu_control_tb;

reg  [1:0] ALUOp;
reg  [2:0] funct3;
reg  [6:0] funct7;
wire [3:0] alu_ctrl;

alu_control UUT (
    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7(funct7),
    .alu_ctrl(alu_ctrl)
);

initial begin
    $dumpfile("alu_control_tb.vcd");
    $dumpvars(0, alu_control_tb);

    $display("=== ALU Control Unit Test ===");

    ALUOp = 2'b00; funct3 = 3'b001; funct7 = 7'b0010000; #10;
    $display("ADDW : alu_ctrl = %b (exp: 0000)", alu_ctrl);

    ALUOp = 2'b00; funct3 = 3'b001; funct7 = 7'b0110000; #10;
    $display("SUB  : alu_ctrl = %b (exp: 0001)", alu_ctrl);

    ALUOp = 2'b00; funct3 = 3'b000; funct7 = 7'b0010000; #10;
    $display("AND  : alu_ctrl = %b (exp: 0010)", alu_ctrl);

    ALUOp = 2'b00; funct3 = 3'b111; funct7 = 7'b0010000; #10;
    $display("OR   : alu_ctrl = %b (exp: 0011)", alu_ctrl);

    ALUOp = 2'b00; funct3 = 3'b101; funct7 = 7'b0010000; #10;
    $display("XOR  : alu_ctrl = %b (exp: 0100)", alu_ctrl);

    ALUOp = 2'b00; funct3 = 3'b100; funct7 = 7'b0000001; #10;
    $display("SLTU : alu_ctrl = %b (exp: 1001)", alu_ctrl);

    ALUOp = 2'b00; funct3 = 3'b110; funct7 = 7'b0010000; #10;
    $display("SRL  : alu_ctrl = %b (exp: 0110)", alu_ctrl);

    ALUOp = 2'b00; funct3 = 3'b110; funct7 = 7'b0110000; #10;
    $display("SRA  : alu_ctrl = %b (exp: 0111)", alu_ctrl);

    ALUOp = 2'b01; funct3 = 3'b000; funct7 = 7'b0000000; #10;
    $display("ADDIW: alu_ctrl = %b (exp: 0000)", alu_ctrl);

    ALUOp = 2'b01; funct3 = 3'b110; funct7 = 7'b0000000; #10;
    $display("ORI  : alu_ctrl = %b (exp: 0011)", alu_ctrl);

    ALUOp = 2'b10; funct3 = 3'b000; funct7 = 7'b0000000; #10;
    $display("LW/SW: alu_ctrl = %b (exp: 0000)", alu_ctrl);

    ALUOp = 2'b11; funct3 = 3'b000; funct7 = 7'b0000000; #10;
    $display("BR   : alu_ctrl = %b (exp: 0001)", alu_ctrl);

    #20 $finish;
end

endmodule
