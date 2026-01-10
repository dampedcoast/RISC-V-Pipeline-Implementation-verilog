`timescale 1ns/1ps

module imm_gen_tb;

    reg  [31:0] instr;
    wire [31:0] imm_i, imm_s, imm_sb, imm_u, imm_uj;

    imm_gen uut (
        .instr(instr),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_sb(imm_sb),
        .imm_u(imm_u),
        .imm_uj(imm_uj)
    );

    initial begin
        $dumpfile("imm_gen_tb.vcd");
        $dumpvars(0, imm_gen_tb);

        instr = 32'b000000000011_00010_000_00001_0010011;
        #5;
        if (imm_i !== 32'd3)
            $display("ERROR I-type: %d", imm_i);
        else
            $display("PASS I-type");

        instr = 32'b0000001_00001_00010_010_10000_0100011;
        #5;
        if (imm_s !== 32'd48)
            $display("ERROR S-type: %d", imm_s);
        else
            $display("PASS S-type");

        instr = 32'b0000000_00010_00001_001_10000_1100011;
        #5;
        if (imm_sb !== 32'd32)
            $display("ERROR SB-type: %d", imm_sb);
        else
            $display("PASS SB-type");

        instr = 32'b00010010001101000101_00001_0110111;
        #5;
        if (imm_u !== 32'h12345000)
            $display("ERROR U-type: %h", imm_u);
        else
            $display("PASS U-type");

        instr = 32'b00000010000_00000000_00001_1101111;
        #5;
        if (imm_uj !== 32'd32)
            $display("ERROR UJ-type: %d", imm_uj);
        else
            $display("PASS UJ-type");

        $finish;
    end

endmodule
