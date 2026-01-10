module programcounter (
    input              clock,
    input              reset,    
    input      [31:0]  next_pc,
    input              pc_en,    
    output reg [31:0]  pc
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            pc <= 32'b0;
        end 
        else if (pc_en) begin
            pc <= next_pc;
        end
        else begin
            pc <= pc;   
        end
    end

endmodule
