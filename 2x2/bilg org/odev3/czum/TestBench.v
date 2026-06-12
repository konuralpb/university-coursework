`timescale 1ns / 1ps
`include "RiscV_SingleCycle.v"
module TestBench;
    reg clk = 0;
    reg reset = 1;

    wire [31:0] pc;
    wire [31:0] alu_result;
    wire [31:0] write_data;
    wire [31:0] read_data = 32'b0;

    RiscV_SingleCycle uut(
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .alu_result(alu_result),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #10 clk = !clk;

    initial begin
        $dumpfile("processor_sim.vcd");
        $dumpvars(0, TestBench);

        // Assert reset
        reset = 1;
        #20; // Hold reset for 100ns
        reset = 0;

        // Initialize memory
        #20;
        uut.memory[0] = 3;    uut.memory[1] = 7;    uut.memory[2] = 2;    uut.memory[3] = 6;
        uut.memory[4] = 5;    uut.memory[5] = 4;    uut.memory[6] = 1;    uut.memory[7] = 1000;
        uut.memory[8] = 999;  uut.memory[9] = 25;   uut.memory[10] = 90;  uut.memory[11] = 100;
        uut.memory[12] = 30;  uut.memory[13] = 20;  uut.memory[14] = 10;  uut.memory[15] = 200;
        uut.memory[16] = 3300; uut.memory[17] = 250; uut.memory[18] = 12;  uut.memory[19] = 75;
        uut.memory[20] = 17;  uut.memory[21] = 13;  uut.memory[22] = 18;  uut.memory[23] = 14;
        uut.memory[24] = 15;  uut.memory[25] = 16;  uut.memory[26] = 19;  uut.memory[27] = 1;
        uut.memory[28] = 2;   uut.memory[29] = 9;   uut.memory[30] = 6;   uut.memory[31] = 5;
        uut.memory[32] = 8;   uut.memory[33] = 10;  uut.memory[34] = 12;  uut.memory[35] = 4;
        uut.memory[36] = 0;   uut.memory[37] = 3;   uut.memory[38] = 11;  uut.memory[39] = 7;

        uut.registers[0] = 0;
        uut.registers[1] = 0;
        uut.registers[2] = 80;
        uut.registers[3] = 160;
        uut.registers[4] = 80;
    
        // load instructions into the instruction memory
        uut.instruction_memory[0] = 32'h00000013;
        uut.instruction_memory[1] = 32'h02408663;
        uut.instruction_memory[2] = 32'h0000a303;
        uut.instruction_memory[3] = 32'h00012383;
        uut.instruction_memory[4] = 32'h007383b3;
        uut.instruction_memory[5] = 32'h007383b3;
        uut.instruction_memory[6] = 32'h007383b3;
        uut.instruction_memory[7] = 32'h007184b3;
        uut.instruction_memory[8] = 32'h0064a023;
        uut.instruction_memory[9] = 32'h00408093;
        uut.instruction_memory[10] = 32'h00110113;
        uut.instruction_memory[11] = 32'hfd9ff56f;

        #30000;

        // final states
        $display("Time: %t", $time);
        $display("PC: %d", pc);
        $display("hmm: %d %d %d %d %d", uut.memory[40], uut.memory[45], uut.registers[0], uut.registers[1], uut.registers[2], uut.registers[3], uut.registers[4]);
        $finish;
    end
endmodule

//iverilog -o testbench_output RiscV_SingleCycle.v TestBench.v
//vvp testbench_output    