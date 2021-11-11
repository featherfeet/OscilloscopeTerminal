`timescale 1ns / 100ps

module test();
    reg clk = 1'b1;
    always #10 clk = ~clk;

    initial begin
        $dumpfile("dump.lxt");
        $dumpvars(0, test);
        #1000000 $finish;
    end

    top top_instantiation(.CLOCK_50(clk));
endmodule
