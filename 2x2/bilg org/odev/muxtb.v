
`include "mux32.v"

module muxtb();

    reg [31:0] a, b,c,d,e,f,g,h;
    wire [31:0]out;
    reg [2:0] select;
     mux8x1_32 muxx(
        .out(out),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .h(h),
        .s0(select[0]),
        .s1(select[1]),
        .s2(select[2])
      );
    
    initial begin
        select=001; a = 32'h00000000; b = 32'h00000001;c=32'h00000002;d=32'h00000003;e=32'h00000004;f=32'h00000005;g=32'h00000006;h=32'h00000007;
        #10 $display("a=%b b=%b out=%b", a, b, out);
        

        #10 $finish;
    end

initial begin
        $dumpfile("muxtb.vcd");
        $dumpvars(0, muxtb);
    end

endmodule

//iverilog -o mux_2x1_1_st_tb.vvp mux_2x1_1_st_tb.v
//vvp mux_2x1_1_st_tb.vvp