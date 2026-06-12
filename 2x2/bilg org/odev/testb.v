/* Test bench for full_adder.v */

`include "full_adder_32bit.v"

module testb;
    reg [31:0] a,b;

    wire sum, cout;

    full_adder_32bit add1(a, b, cin, sum, cout);

    initial
        begin
            $dumpfile("full_adder32bit.vcd");
            $dumpvars(0, testb);
            a = 32'h11111111;
            b = 32'h11111111;

        end
endmodule

//iverilog -o full_adder_tb.vvp full_adder_tb.v
//vvp full_adder_tb.vvp