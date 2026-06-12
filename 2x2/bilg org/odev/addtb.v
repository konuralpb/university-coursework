
`include "full_adder_32bit.v"

module fulladd32();

    reg [31:0] a, b;
    wire [31:0]out;
    wire cout;    
    full_adder_32bit UUT(
        .a(a),
        .b(b),
        .cin(0),
        .sum(out),
        .cout(cout)
    );
    
    initial begin
        a = 32'h00000001;; b = 32'h00000001;;
        #10 $display("a=%b b=%b out=%b", a, b, out);
        

        #10 $finish;
    end

initial begin
        $dumpfile("fullad32.vcd");
        $dumpvars(0, fulladd32);
    end

endmodule

//iverilog -o mux_2x1_1_st_tb.vvp mux_2x1_1_st_tb.v
//vvp mux_2x1_1_st_tb.vvp