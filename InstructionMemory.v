module InstructionMemory (
    input      [31:0] pc,          
    output reg [31:0] instruction 
);

    reg [31:0] mem [0:16383];

    initial begin
        $readmemh("IMem.hex", mem);
    end

    always @(*) begin
        if (pc[31:2] < 16384)
            instruction = mem[pc[31:2]];
        else
            instruction = 32'h00000013; 
    end

endmodule
