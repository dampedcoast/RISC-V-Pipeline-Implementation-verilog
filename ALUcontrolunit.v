

module alu_control (
    input  wire [1:0] ALUOp,     
    input  wire [2:0] funct3, 
    input  wire [6:0] funct7,    
    output reg  [3:0] alu_ctrl   
);


parameter ALU_ADD  = 4'b0000; // ADD / Address Calc
parameter ALU_SUB  = 4'b0001; // SUB / Branch Compare
parameter ALU_AND  = 4'b0010; // AND
parameter ALU_OR   = 4'b0011; // OR
parameter ALU_XOR  = 4'b0100; // XOR
parameter ALU_SLL  = 4'b0101; // SLL
parameter ALU_SRL  = 4'b0110; // SRL
parameter ALU_SRA  = 4'b0111; // SRA
parameter ALU_SLT  = 4'b1000; // SLT (not used in spec)
parameter ALU_SLTU = 4'b1001; // SLTU (used)

always @(*) begin
    case (ALUOp)
        // R-type: ALUOp = 2'b00
        2'b00: begin
            case ({funct3, funct7})
                
                {3'b001, 7'b0010000}: alu_ctrl = ALU_ADD;

               
                {3'b001, 7'b0110000}: alu_ctrl = ALU_SUB;

                {3'b000, 7'b0010000}: alu_ctrl = ALU_AND;

                // OR: funct3=7, funct7=0x10 (7'b0010000)
                {3'b111, 7'b0010000}: alu_ctrl = ALU_OR;

                // XOR: funct3=5, funct7=0x10 (7'b0010000)
                {3'b101, 7'b0010000}: alu_ctrl = ALU_XOR;

                // SLTU: funct3=4, funct7=0x01 (7'b0000001)
                {3'b100, 7'b0000001}: alu_ctrl = ALU_SLTU;

                
                // SRL: funct3=6, funct7=0x10 (7'b0010000)
                {3'b110, 7'b0010000}: alu_ctrl = ALU_SRL;

                // SRA: funct3=6, funct7=0x30 (7'b0110000)
                {3'b110, 7'b0110000}: alu_ctrl = ALU_SRA;

                // Default fallback
                default: alu_ctrl = ALU_ADD;
            endcase
        end

        // I-type ALU: ALUOp = 2'b01 (ADDIW, ANDI, ORI, SLLI, etc.)
        2'b01: begin
            case (funct3)
                3'b000: alu_ctrl = ALU_ADD;   // ADDIW
                3'b001: alu_ctrl = ALU_SLL;   // SLLI
                3'b010: alu_ctrl = ALU_SLT;   // SLTI (not in spec, but included for completeness)
                3'b011: alu_ctrl = ALU_SLTU;  // SLTIU
                3'b100: alu_ctrl = ALU_XOR;   // XORI
                3'b110: alu_ctrl = ALU_OR;    // ORI
                3'b111: alu_ctrl = ALU_AND;   // ANDI
                default: alu_ctrl = ALU_ADD;
            endcase
        end

        // Load/Store/JAL/JALR: ALUOp = 2'b10 → address calculation = ADD
        2'b10: alu_ctrl = ALU_ADD;

        // Branch: ALUOp = 2'b11 → compare via SUB
        2'b11: alu_ctrl = ALU_SUB;

        // Safe default
        default: alu_ctrl = ALU_ADD;
    endcase
end

endmodule



