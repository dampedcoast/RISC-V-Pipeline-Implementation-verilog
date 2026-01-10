`timescale 1ns/1ps

module regfile_tb;

    reg clk;
    reg we;
    reg [4:0] ra1, ra2, wa;
    reg [31:0] wd;
    wire [31:0] rd1, rd2;

    regfile uut (
        .clk(clk),
        .we(we),
        .ra1(ra1),
        .ra2(ra2),
        .wa(wa),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("regfile_tb.vcd");
        $dumpvars(0, regfile_tb);

        clk = 0;
        we  = 0;
        ra1 = 0;
        ra2 = 0;
        wa  = 0;
        wd  = 0;

        we = 1; wa = 5; wd = 32'd99;
        #10;

        we = 1; wa = 10; wd = 32'd12345;
        #10;

        we = 0;
        ra1 = 5;
        ra2 = 10;
        #10;

        if (rd1 !== 32'd99 || rd2 !== 32'd12345)
            $display("ERROR: rd1=%d rd2=%d", rd1, rd2);
        else
            $display("PASS: Correct register reads");

        ra1 = 0;
        #10;

        if (rd1 !== 32'd0)
            $display("ERROR: x0 not zero");
        else
            $display("PASS: x0 is hardwired to zero");

        $finish;
    end

endmodule
