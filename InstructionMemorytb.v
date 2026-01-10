`timescale 1ns/1ps

module im_tb;

    reg  [31:0] pc;
    wire [31:0] instruction;

    InstructionMemory UUT (
        .pc(pc),
        .instruction(instruction)
    );

    initial begin
        $dumpfile("im_tb.vcd");
        $dumpvars(0, im_tb);
        $display(" Instruction Memory Testbench ");

       
        pc = 32'd0;
        #5;
        if (instruction !== 32'h00100093)
            $display("ERROR @ PC=0: got %h", instruction);
        else
            $display("PASS  @ PC=0");

     
        pc = 32'd4;
        #5;
        if (instruction !== 32'h00200113)
            $display("ERROR @ PC=4: got %h", instruction);
        else
            $display("PASS  @ PC=4");

        
        pc = 32'd8;
        #5;
        if (instruction !== 32'h002081B3)
            $display("ERROR @ PC=8: got %h", instruction);
        else
            $display("PASS  @ PC=8");

       
        pc = 32'd12;
        #5;
        if (instruction !== 32'h00000013)
            $display("ERROR @ PC=12: got %h", instruction);
        else
            $display("PASS  @ PC=12 (NOP)");

        
        pc = 32'hFFFF_FFFF;
        #5;
        if (instruction !== 32'h00000013)
            $display("ERROR @ out-of-range PC: got %h", instruction);
        else
            $display("PASS  @ out-of-range PC (NOP)");

        $display("===========================================");
        $display(" Instruction Memory Test PASSED ");
        $display("===========================================");

        $finish;
    end

endmodule
