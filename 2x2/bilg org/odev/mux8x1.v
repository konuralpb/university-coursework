
`include "mux4x1.v"

module mux_8x1(out, a, b, c, d,e,f,g,h, s2,s1,s0);
    input a, b, c, d,e,f,g,h;
    input s2,s1,s0; 
    output out;

    wire out1, out2,out3;

     mux_4x1 mux1( 
        .out(out1),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .s1(s1),
        .s0(s0)
    );

    mux_4x1 mux2( 
        .out(out2),
        .a(e),
        .b(f),
        .c(g),
        .d(h),
        .s1(s1),
        .s0(s0)
    );


    mux_2x1 mux3(
        .out(out),
        .a(out1),
        .b(out2),
        .select(s2)

    );
endmodule



