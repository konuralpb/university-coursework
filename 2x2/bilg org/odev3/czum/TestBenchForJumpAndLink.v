`timescale 1ns / 1ps

module TestBenchForJumpAndLink;

    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] alu_result;
    wire [31:0] write_data;
    wire [31:0] read_data = 32'b0;


    RiscV_SingleCycle uut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .alu_result(alu_result),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        #20 reset = 0;

        uut.instruction_memory[0] = 32'b00000100_00000000_000_00001_1101111;
        #20
        $finish;
    end

    initial begin
        $monitor("Time = %t, PC = %d, Next PC = %d, Register[1] = %d",
                 $time, uut.pc, uut.next_pc, uut.registers[1]);
    end
    initial begin
$dumpfile("processor_sim.vcd");
$dumpvars(0, TestBenchForJumpAndLink);
end

endmodule

//iverilog -o testbench_output RiscV_SingleCycle.v TestBenchForJumpAndLink.v
//vvp testbench_output    