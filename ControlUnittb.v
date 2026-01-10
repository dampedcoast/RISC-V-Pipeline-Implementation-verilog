`timescale 1ns/1ps

module control_unit_tb;

    reg  [6:0] Opcode;
    reg  [2:0] funct3;
    reg  [6:0] funct7;

    wire RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, Branch, Jump;
    wire [1:0] ALUOp;

    control_unit uut (
        .Opcode(Opcode),
        .funct3(funct3),
        .funct7(funct7),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp)
    );

    initial begin
        $dumpfile("control_unit.vcd");
        $dumpvars(0, control_unit_tb);

        Opcode = 7'b0110011; #5;
        $display("R-type: RegWrite=%b ALUOp=%b", RegWrite, ALUOp);

        Opcode = 7'b0010011; #5;
        $display("I-type: RegWrite=%b ALUSrc=%b ALUOp=%b", RegWrite, ALUSrc, ALUOp);

        Opcode = 7'b0000011; #5;
        $display("Load: RegWrite=%b MemRead=%b MemtoReg=%b", RegWrite, MemRead, MemtoReg);

        Opcode = 7'b0100011; #5;
        $display("Store: MemWrite=%b ALUSrc=%b", MemWrite, ALUSrc);

        Opcode = 7'b1100011; #5;
        $display("Branch: Branch=%b ALUOp=%b", Branch, ALUOp);

        Opcode = 7'b1101111; #5;
        $display("JAL: RegWrite=%b Jump=%b", RegWrite, Jump);

        Opcode = 7'b1100111; #5;
        $display("JALR: RegWrite=%b Jump=%b ALUSrc=%b", RegWrite, Jump, ALUSrc);

        Opcode = 7'b0110111; #5;
        $display("LUI: RegWrite=%b ALUSrc=%b", RegWrite, ALUSrc);

        $finish;
    end

endmodule
