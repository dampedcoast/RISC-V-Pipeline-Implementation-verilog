//JAL jumps to a PC-relative immediate address, while JALR jumps to an address computed from a register + immediate.
module control_unit (
    input  [6:0] Opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,

    output reg   RegWrite,
    output reg   MemRead,
    output reg   MemWrite,
    output reg   MemtoReg,
    output reg   ALUSrc,
    output reg   Branch,
    output reg   Jump,
    output reg [1:0] ALUOp
);

    always @(*) begin
        RegWrite = 0;
        MemRead  = 0;
        MemWrite = 0;
        MemtoReg = 0;
        ALUSrc   = 0;
        Branch   = 0;
        Jump     = 0;
        ALUOp    = 2'b00;

        case (Opcode)
            7'b0110011: begin //R-type 
                RegWrite = 1;
                ALUOp    = 2'b00;
            end

            7'b0010011: begin // I-type 
                RegWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b01;
            end

            7'b0000011: begin //Load 
                RegWrite = 1;
                MemRead  = 1;
                MemtoReg = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b10;
            end

            7'b0100011: begin // store
                MemWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b10;
            end

            7'b1100011: begin // branch 
                Branch = 1;
                ALUOp  = 2'b11;
            end

            7'b1101111: begin //JAL 
                RegWrite = 1;
                Jump     = 1;
                ALUOp    = 2'b10;
            end

            7'b1100111: begin //JALR
                RegWrite = 1;
                Jump     = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b10;
            end

            7'b0110111: begin //Load upper immediate 
                RegWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b10;
            end

            default: begin
            end
        endcase
    end

endmodule
