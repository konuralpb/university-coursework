`timescale 1ns / 1ps

module TestBenchForBranch;
    reg clk = 0;
    reg reset = 1;
    wire [31:0] pc;
    wire [31:0] alu_result;
    wire [31:0] write_data;
    reg [31:0] read_data;

    RiscV_SingleCycle uut(
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
        #20;
        reset = 0;

        uut.registers[4] = 10; // Set R4 = 10
        uut.registers[5] = 10; // Set R5 = 10 (equal to R4)

        uut.instruction_memory[0] = 32'b0000000_00101_00100_000_10000_1100011;
        #19;
        
        clk = 0;
        if (uut.pc !== 16)
            $display("Error: BEQ failed to branch as expected, PC: %d", uut.pc);
        else
            $display("BEQ operation successful: branched as expected to PC: %d", uut.pc);
        #20;

        $finish;
    end

    initial begin
        $dumpfile("processor_sim.vcd");
        $dumpvars(0, TestBenchForBranch);
    end

endmodule

//iverilog -o testbench_output RiscV_SingleCycle.v TestBenchForBranch.v
//vvp testbench_output    