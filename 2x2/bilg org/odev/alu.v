`include "full_adder_32bit.v"
`include "gates.v"
`include "mux32.v"
//`include "mux2x1_32.v"
module alu(a,b,control,out);
    input [31:0] a,b;
    input [2:0] control;
    output [31:0] out;


    wire [31:0] bnot,bsum,addsub,andw,xorw;
    wire cout,over,cn1,xor1,xnor1,alun,slt;

    not32bit n(b,bnot);

   mux2x1_32 m1(bsum, bnot,b, control[0]);

    full_adder_32bit addd(a,bsum,control[0],addsub,cout);

    and32bit andd(a,b,andw);
    xor32bit xorr(a,b,xorw);
    assign xnor1 = ~((control[0])^(b[31])^(a[31]));
    xor xor3(xor1,addsub[31],a[31]);
    not not1(alun,control[1]);
    assign over = (xnor1 & xor1 & alun);
    xor xor2(slt,over,addsub[31]);
    mux8x1_32 m2(out,0,0,slt,0,xorw,andw,addsub,addsub,control[2],control[1],control[0]);
    
endmodule