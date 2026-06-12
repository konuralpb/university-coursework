`timescale 1ns / 1ps
`include "regfile.v"


module testbench();
    reg [31:0] a,b;
    reg [2:0] control;
    wire [31:0]out;

    wire [31:0] c;
    reg clk, wr, rst;
    reg [1:0] addr1, addr2, addr3;
    reg [`WORD_SIZE-1:0] data3;
    wire [`WORD_SIZE-1:0] data1, data2;
    reg [`WORD_SIZE-1:0] register[3:0];

    alu aaa(    
    .a(a),
    .b(b),
    .control(control),
    .out(out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    regfile regg(.addr1(addr1), .addr2(addr2), .addr3(addr3), .data1(data1), .data2(data2), .data3(data3), .clk(clk), .wr(wr), .rst(rst));
    initial begin

        addr1<=1;addr2<=2;addr3<=0;data3<=0;wr<=0;rst<=0;assign a = data1; assign b = data2;
        control <= 000;
        #10 $display("a<=%b b<=%b control<=%b out<=%b", a, b, control,out);
        assign data3=out;addr1<=0;addr2<=0;addr3<=0;wr<=1;rst<=0;
        #10;
        addr1<=2;addr2<=3;addr3<=0;data3<=0;wr<=0;rst<=0;assign a = data1; assign b = data2;
        control <= 010;
        #10 $display("a<=%b b<=%b control<=%b out<=%b", a, b, control,out);
        assign data3=out;addr1<=0;addr2<=0;addr3<=1;wr<=1;rst<=0;
         #10;
        addr1<=2;addr2<=0;addr3<=0;data3<=0;wr<=0;rst<=0;assign a = data1; assign b = data2;
        control <= 011;
        #10 $display("a<=%b b<=%b control<=%b out<=%b", a, b, control,out);
        assign data3=out;addr1<=0;addr2<=0;addr3<=3;wr<=1;rst<=0;
        #10;
        addr1<=1;addr2<=3;addr3<=0;data3<=0;wr<=0;rst<=0;assign a = data1; assign b = data2;
        control <= 001;
        #10 $display("a<=%b b<=%b control<=%b out<=%b", a, b, control,out);
        assign data3=out;addr1<=0;addr2<=0;addr3<=2;wr<=1;rst<=0;
        #10;

        addr1<=0;addr2<=0;addr3<=0;data3<=0;wr<=0;rst<=0;assign a = data1; assign b = data2;
        control <= 001;
        #10 $display("a<=%b b<=%b control<=%b out<=%b", a, b, control,out);
        assign data3=out;addr1<=0;addr2<=0;addr3<=0;wr<=1;rst<=0;
        #10;

        addr1<=0;addr2<=0;addr3<=0;data3<=0;wr<=0;rst<=0;assign a = data1; assign b = data2;
        assign data3=-1;addr1<=0;addr2<=0;addr3<=0;wr<=1;rst<=0;
        #10 $display("a<=%b b<=%b control<=%b out<=%b", a, b, control,out);
        
        addr1<=1;addr2<=0;addr3<=0;data3<=0;wr<=0;rst<=0;assign a = data1; assign b = 1;
        control <= 001;
        assign data3=out;addr1<=0;addr2<=0;addr3<=2;wr<=1;rst<=0;
         #10 $display("a<=%b b<=%b control<=%b out<=%b", a, b, control,out);

        addr1<=0;addr2<=0;addr3<=0;data3<=0;wr<=0;rst<=0;assign a = data1; assign b = 1;
        control <= 000;
        assign data3=out;addr1<=0;addr2<=0;addr3<=3;wr<=1;rst<=0;
        #10 $display("a<=%b b<=%b control<=%b out<=%b", a, b, control,out);
        #10 $finish;
    end

    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, testbench);
    end


endmodule