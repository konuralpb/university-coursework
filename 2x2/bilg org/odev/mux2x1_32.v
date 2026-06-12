`include "mux2x1.v"

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