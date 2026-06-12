module and4bit(a,b,out);
    input [3:0] a,b;
    output [3:0] out;

    and(out[0],a[0],b[0]);
    and(out[1],a[1],b[1]);
    and(out[2],a[2],b[2]);
    and(out[3],a[3],b[3]);
endmodule

module and8bit(a,b,out);
    input [7:0] a,b;
    output [7:0] out;

    and4bit a1(a[3:0],b[3:0],out[3:0]);
    and4bit a2(a[7:4],b[7:4],out[7:4]);
endmodule


module and32bit(a,b,out);
    input [31:0] a,b;
    output [31:0] out;

    and8bit a1(a[7:0],b[7:0],out[7:0]);
    and8bit a2(a[15:8],b[15:8],out[15:8]);
    and8bit a3(a[23:16],b[23:16],out[23:16]);
    and8bit a4(a[31:24],b[31:24],out[31:24]);
endmodule


module xor4bit(a,b,out);
    input [3:0] a,b;
    output [3:0] out;

    xor(out[0],a[0],b[0]);
    xor(out[1],a[1],b[1]);
    xor(out[2],a[2],b[2]);
    xor(out[3],a[3],b[3]);
endmodule

module xor8bit(a,b,out);
    input [7:0] a,b;
    output [7:0] out;

    xor4bit x1(a[3:0],b[3:0],out[3:0]);
    xor4bit x2(a[7:4],b[7:4],out[7:4]);
endmodule

module xor32bit(a,b,out);
    input [31:0] a,b;
    output [31:0] out;

    xor8bit x1(a[7:0],b[7:0],out[7:0]);
    xor8bit x2(a[15:8],b[15:8],out[15:8]);
    xor8bit x3(a[23:16],b[23:16],out[23:16]);
    xor8bit x4(a[31:24],b[31:24],out[31:24]);
endmodule

module not4bit(a,out);
    input [3:0] a;
    output [3:0] out;

    not(out[0],a[0]);
    not(out[1],a[1]);
    not(out[2],a[2]);
    not(out[3],a[3]);
endmodule

module not8bit(a,out);
    input [7:0] a;
    output [7:0] out;

    not4bit n1(a[3:0],out[3:0]);
    not4bit n2(a[7:4],out[7:4]);
endmodule

module not32bit(a,out);
    input [31:0] a;
    output [31:0] out;

    not8bit n1(a[7:0],out[7:0]);
    not8bit n2(a[15:8],out[15:8]);
    not8bit n3(a[23:16],out[23:16]);
    not8bit n4(a[31:24],out[31:24]);
endmodule