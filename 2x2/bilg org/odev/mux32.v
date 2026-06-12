`include "mux8x1.v"

module mux8x1_32(out, a, b, c, d,e,f,g,h, s2,s1,s0);
    input [31:0]  a, b, c, d,e,f,g,h;
    input s2,s1,s0;
    output [31:0] out;

    generate
        genvar i;
        for(i=0;i<32;i=i+1)begin : genn
            mux_8x1 muxx(
                .out(out[i]),
                .a(a[i]),
                .b(b[i]),
                .c(c[i]),
                .d(d[i]),
                .e(e[i]),
                .f(f[i]),
                .g(g[i]),
                .h(h[i]),
                .s2(s2),
                .s1(s1),
                .s0(s0)
                );
        end
    endgenerate

endmodule


module mux2x1_32(out,a,b,select);
    input [31:0] a,b;
    input select;
    output [31:0] out;


    generate
        genvar i;
        for(i=0;i<32;i=i+1)begin : genn
            mux_2x1 muxx(
                .out(out[i]),
                .a(a[i]),
                .b(b[i]),
                .select(select)
                );
        end
    endgenerate
endmodule