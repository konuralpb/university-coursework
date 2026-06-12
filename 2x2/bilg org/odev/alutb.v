
`include "alu.v"

module alutb();

    reg [31:0] a, b;
    reg [2:0] control;
    wire [31:0]out;
    
    alu UUT(
        .a(a),
        .b(b),
        .control(control),
        .out(out)
    );
    
    initial begin
        control = 101; a = 32'h00000011; b = 32'h00000001;
        #10 $display("control[0] = %b select=%b a=%b b=%b out=%b", control[0],control, a, b, out);
        

        #10 $finish;
    end

initial begin
        $dumpfile("alutb.vcd");
        $dumpvars(0, alutb);
    end

endmodule

//iverilog -o mux_2x1_1_st_tb.vvp mux_2x1_1_st_tb.v
//vvp mux_2x1_1_st_tb.vvp