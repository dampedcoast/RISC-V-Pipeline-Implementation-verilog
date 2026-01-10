`timescale 1ns/1ps

module alu_tb;

    reg  [31:0] a, b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire zero;

    alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        a = 10; b = 5;

        alu_ctrl = 4'b0000; #5;
        if (result !== 15) $display("ERROR ADD"); else $display("PASS ADD");

        alu_ctrl = 4'b0001; #5;
        if (result !== 5) $display("ERROR SUB"); else $display("PASS SUB");

        alu_ctrl = 4'b0010; #5;
        if (result !== 0) $display("ERROR AND"); else $display("PASS AND");

        alu_ctrl = 4'b0011; #5;
        if (result !== 15) $display("ERROR OR"); else $display("PASS OR");

        alu_ctrl = 4'b0100; #5;
        if (result !== 15) $display("ERROR XOR"); else $display("PASS XOR");

        alu_ctrl = 4'b0101; #5;
        if (result !== (10 << 5)) $display("ERROR SLL"); else $display("PASS SLL");

        alu_ctrl = 4'b0110; #5;
        if (result !== (10 >> 5)) $display("ERROR SRL"); else $display("PASS SRL");

        a = -32; b = 2;
        alu_ctrl = 4'b0111; #5;
        if (result !== -8) $display("ERROR SRA"); else $display("PASS SRA");

        a = 3; b = 20;
        alu_ctrl = 4'b1000; #5;
        if (result !== 1) $display("ERROR SLT"); else $display("PASS SLT");

        a = 32'hFFFFFFFF; b = 0;
        alu_ctrl = 4'b1001; #5;
        if (result !== 0) $display("ERROR SLTU"); else $display("PASS SLTU");

        alu_ctrl = 4'b0001; #5;
        if (zero !== 1) $display("ERROR ZERO FLAG"); else $display("PASS ZERO FLAG");

        $finish;
    end

endmodule
