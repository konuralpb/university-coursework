`include "full_adder_4bit.v"

module full_adder_32bit(a, b, cin, sum, cout);
    input [31:0] a, b;
    input cin;
    output [31:0] sum;
    output cout;
    wire [7:0] carry;

    full_adder_4bit fa0(a[3:0], b[3:0], cin, sum[3:0], carry[0]);
    full_adder_4bit fa1(a[7:4], b[7:4], carry[0], sum[7:4], carry[1]);
    full_adder_4bit fa2(a[11:8], b[11:8], carry[1], sum[11:8], carry[2]);
    full_adder_4bit fa3(a[15:12], b[15:12], carry[2], sum[15:12], carry[3]);
    full_adder_4bit fa4(a[19:16], b[19:16], carry[3], sum[19:16], carry[4]);
    full_adder_4bit fa5(a[23:20], b[23:20], carry[4], sum[23:20], carry[5]);
    full_adder_4bit fa6(a[27:24], b[27:24], carry[5], sum[27:24], carry[6]);
    full_adder_4bit fa7(a[31:28], b[31:28], carry[6], sum[31:28], cout);
endmodule