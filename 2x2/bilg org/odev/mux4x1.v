`include "mux2x1.v"

module mux_4x1(out, a, b, c, d, s1,s0);
    input a, b, c, d;
    input s1,s0; //2-bitlik seçim bitleri
    output out;

    wire out1, out2;

    // first level 2x1 MUXes
    mux_2x1 mux1( // mux1, a ve b girişlerini seçer
        .out(out1),
        .a(a),
        .b(b),
        .select(s0)
    );

    mux_2x1 mux2( // mux2, c ve d girişlerini seçer
        .out(out2),
        .a(c),
        .b(d),
        .select(s0)
    );

    // second level 2x1 MUX
    mux_2x1 mux3( // mux3, mux1 ve mux2 çıkışlarını seçer
        .out(out),
        .a(out1),
        .b(out2),
        .select(s1)
    );
endmodule