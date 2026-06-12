`timescale 1ns / 1ps

module TestBenchForSRA;

    reg clk = 0;
    reg reset = 1;
    reg [31:0] instruction;
    reg [31:0] read_data;

    wire [31:0] pc;
    wire [31:0] alu_result;
    wire [31:0] write_data;

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
        read_data = 32'b0;

        #20;
        reset = 0;

        #20;

        // Init registers for SRA
        uut.registers[4] = -128;  // R4 = -128 (in two's complement, this is 32'hFFFFFF80)
        uut.registers[5] = 3;     // R5 = 3 (shift right by 3 positions)

        // Instruction Format: funct7, rs2, rs1, funct3, rd, opcode
        uut.instruction_memory[0] = {7'b0100000, 5'b00101, 5'b00100, 3'b101, 5'b00110, 7'b0110011}; // SRA R6, R4, R5

        #60;

        if (uut.registers[6] === 32'hFFFFFFF0) begin
            $display("Correct shift: R6 = %h", uut.registers[6]);
        end else begin
            $display("Failed result: R6 = %h", uut.registers[6]);
        end

        #20;
        $finish;
    end

    initial begin
        $dumpfile("processor_sim.vcd");
        $dumpvars(0, TestBenchForSRA);
    end

endmodule

//iverilog -o testbench_output RiscV_SingleCycle.v TestBenchForSRA.v
//vvp testbench_output    