`timescale 1ns/1ps

module pc_tb;

    reg         clock;
    reg         reset;
    reg         pc_en;
    reg  [31:0] next_pc;
    wire [31:0] pc;

    programcounter UUT (
        .clock   (clock),
        .reset   (reset),
        .next_pc (next_pc),
        .pc_en   (pc_en),
        .pc      (pc)
    );

    always #5 clock = ~clock;

    initial begin
        
        $dumpfile("pc_tb.vcd");
        $dumpvars(0, pc_tb);

        clock   = 0;
        reset   = 1;
        pc_en   = 0;
        next_pc = 32'h00000000;

        #10;
        if (pc !== 32'h00000000)
            $display("ERROR: PC not reset correctly. PC = %h", pc);
        else
            $display("PASS: PC reset correctly");

        #10;
        reset = 0;

  
        next_pc = 32'h00000004;
        pc_en   = 0;

        #10;
        if (pc !== 32'h00000000)
            $display("ERROR: PC changed while pc_en = 0. PC = %h", pc);
        else
            $display("PASS: PC held value when pc_en = 0");

  
        pc_en   = 1;
        next_pc = 32'h00000004;

        #10;
        if (pc !== 32'h00000004)
            $display("ERROR: PC did not update to 0x4. PC = %h", pc);
        else
            $display("PASS: PC updated to 0x4");

   
        next_pc = 32'h00000008;
        #10;
        if (pc !== 32'h00000008)
            $display("ERROR: PC did not update to 0x8. PC = %h", pc);
        else
            $display("PASS: PC updated to 0x8");

        next_pc = 32'h0000000C;
        #10;
        if (pc !== 32'h0000000C)
            $display("ERROR: PC did not update to 0xC. PC = %h", pc);
        else
            $display("PASS: PC updated to 0xC");

        pc_en   = 0;
        next_pc = 32'hDEADBEEF;

        #10;
        if (pc !== 32'h0000000C)
            $display("ERROR: PC changed while disabled. PC = %h", pc);
        else
            $display("PASS: PC correctly held value when disabled");

   
        reset = 1;
        #10;
        if (pc !== 32'h00000000)
            $display("ERROR: PC did not reset during operation. PC = %h", pc);
        else
            $display("PASS: PC reset correctly during operation");

        reset = 0;
        #10;

        $display("=================================");
        $display("PC TESTBENCH COMPLETED SUCCESSFULLY");
        $display("=================================");

        $finish;
    end

endmodule
