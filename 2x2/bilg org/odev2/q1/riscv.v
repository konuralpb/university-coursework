module testbench;
	reg clk;
	reg reset;
	wire [31:0] writedata;
	wire [31:0] dataadr;
	wire memwrite;
	top dut(
		.clk(clk),
		.reset(reset),
		.writedata(writedata),
		.dataadr(dataadr),
		.memwrite(memwrite)
	);
	initial begin
		reset <= 1;
		#(22)
			;
		reset <= 0;
	end
	always begin
		clk <= 1;
		#(5)
			;
		clk <= 0;
		#(5)
			;
	end

	always@(negedge clk)
    begin
      if(memwrite) begin
        if(dataadr === 84 & writedata === 7) begin
          $display("Simulation succeeded");
          $stop;
        end else if (dataadr !== 80) begin
          $display("Simulation failed");
          $stop;
        end
      end
    end
	initial begin  
		$dumpfile("test_tb.vcd");
		$dumpvars(0,testbench);
	end   

endmodule
module top (
	clk,
	reset,
	writedata,
	dataadr,
	memwrite
);
	input clk;
	input reset;
	output wire [31:0] writedata;
	output wire [31:0] dataadr;
	output wire memwrite;
	wire [31:0] pc;
	wire [31:0] instr;
	wire [31:0] readdata;
	riscv riscv(
		.clk(clk),
		.reset(reset),
		.pc(pc),
		.instr(instr),
		.memwrite(memwrite),
		.aluout(dataadr),
		.writedata(writedata),
		.readdata(readdata)
	);
	imem imem(
		.a(pc[7:2]),
		.rd(instr)
	);
	dmem dmem(
		.clk(clk),
		.we(memwrite),
		.a(dataadr),
		.wd(writedata),
		.rd(readdata)
	);
endmodule
module riscv (
	clk,
	reset,
	pc,
	instr,
	memwrite,
	aluout,
	writedata,
	readdata
);
	input clk;
	input reset;
	output wire [31:0] pc;
	input [31:0] instr;
	output wire memwrite;
	output wire [31:0] aluout;
	output wire [31:0] writedata;
	output wire [1:0] aluop;
	input [31:0] readdata;
	wire regwrite;
	wire [1:0] immsrc;
	wire branch;
	wire alusrc;
	wire [1:0] resultsrc;
	wire jump;
	wire [2:0] alucontrol;
	wire zero;
	wire pcsrc;
	controller c(
		.op(instr[6:0]),
		.funct3(instr[14:12]),
		.funct7(instr[30]),
		.zero(zero),
		.regwrite(regwrite),
		.immsrc(immsrc),
		.branch(branch),
		.alusrc(alusrc),
		.memwrite(memwrite),
		.resultsrc(resultsrc),
		.jump(jump),
		.aluop(aluop),
		.alucontrol(alucontrol),
		.pcsrc(pcsrc)
	);
	datapath dp(
		.clk(clk),
		.reset(reset),
		.pcsrc(pcsrc),
		.alusrc(alusrc),
		.regwrite(regwrite),
		.jump(jump),
		.alucontrol(alucontrol),
		.zero(zero),
		.pc(pc),
		.instr(instr),
		.aluout(aluout),
		.writedata(writedata),
		.readdata(readdata),
		.resultsrc(resultsrc),
		.immsrc(immsrc)
	);
endmodule
module controller (
	op,
	funct3,
	funct7,
	zero,
	regwrite,
	immsrc,
	branch,
	alusrc,
	memwrite,
	resultsrc,
	jump,
	aluop,
	alucontrol,
	pcsrc
);
	input [6:0] op;
	input [2:0] funct3;
	input funct7;
	input zero;
	output wire regwrite;
	output wire [1:0] immsrc;
	output wire branch;
	output wire alusrc;
	output wire memwrite;
	output wire [1:0] resultsrc;
	output wire jump;
	output wire [2:0] alucontrol;
	output wire [1:0] aluop;
	output pcsrc;
	maindec md(
		.op(op),
		.regwrite(regwrite),
		.immsrc(immsrc),
		.branch(branch),
		.alusrc(alusrc),
		.memwrite(memwrite),
		.resultsrc(resultsrc),
		.jump(jump),
		.aluop(aluop)
	);
	aludec ad(
		.funct7(funct7),
		.funct3(funct3),
		.op5(op[5]),
		.aluop(aluop),
		.alucontrol(alucontrol)
	);
	/*assign pcsrc = (branch & zero) | jump;*/
	assign pcsrc = (branch & zero) | jump;
endmodule
module maindec (
	op,
	regwrite,
	immsrc,
	branch,
	alusrc,
	memwrite,
	resultsrc,
	jump,
	aluop
);
	input [6:0] op;
	output wire regwrite;
	output wire [1:0] immsrc;
	output wire branch;
	output wire alusrc;
	output wire memwrite;
	output wire [1:0] resultsrc;
	output wire jump;
	output wire [1:0] aluop;
	reg [10:0] controls;
	assign {regwrite, immsrc, alusrc, memwrite, resultsrc, branch, aluop, jump} = controls;
	always @(*)
		case (op)
			7'b0000011 : controls <= 11'b10010010000; // lw
			7'b0100011 : controls <= 11'b00111xx0000; // sw
			7'b0110011 : controls <= 11'b1xx00000100; // R
			7'b1100011 : controls <= 11'b01000xx1010; // beq
			7'b0010011 : controls <= 11'b10010000100; // i type
			7'b1101111 : controls <= 11'b111x0100xx1; // jal
			default : controls    <= 11'bxxxxxxxxxxx;
		endcase
endmodule
module aludec (
	funct3,
	funct7,
	aluop,
	alucontrol,
	op5
);
	input [2:0] funct3;
	input funct7;
	input [1:0] aluop;
	input op5;
	output reg [2:0] alucontrol;
	always @(*)
		case (aluop)
			2'b00: alucontrol <= 3'b000;
			2'b01: alucontrol <= 3'b001;
			default:
				case (funct3)
					3'b000: alucontrol <= ((op5 & funct7) ? 3'b001 : 3'b000);
					3'b010: alucontrol <= 3'b101;
					3'b110: alucontrol <= 3'b011;
					3'b111: alucontrol <= 3'b010;
					default: alucontrol <= 3'bxxx;
				endcase
		endcase
endmodule
module datapath (
	clk,
	reset,
	pcsrc,
	alusrc,
	regwrite,
	jump,
	alucontrol,
	zero,
	pc,
	instr,
	aluout,
	writedata,
	readdata,
	resultsrc,
	immsrc
);
	input clk;
	input reset;
	input pcsrc;
	input alusrc;
	input regwrite;
	input [1:0] resultsrc;
	input jump;
	input [2:0] alucontrol;
	output wire zero;
	output wire [31:0] pc;
	input [31:0] instr;
	output wire [31:0] aluout;
	output wire [31:0] writedata;
	input [31:0] readdata;
	input [1:0] immsrc;
	wire [4:0] writereg;
	wire [31:0] pcnext;
	wire [31:0] pcnextbr;
	wire [31:0] pcplus4;
	wire [31:0] pctarget;
	wire [31:0] signimm;
	wire [31:0] signimmsh;
	wire [31:0] srca;
	wire [31:0] srcb;
	wire [31:0] result;
	flopr #(.WIDTH(32)) pcreg(
		.clk(clk),
		.reset(reset),
		.d(pcnext),
		.q(pc)
	);
	adder pcadd1(
		.a(pc),
		.b(32'b00000000000000000000000000000100),
		.y(pcplus4)
	);

	adder pcadd2(
		.a(pc),
		.b(signimm),
		.y(pctarget)
	);
	mux2 #(.WIDTH(32)) pcbrmux(
		.d0(pcplus4),
		.d1(pctarget),
		.s(pcsrc),
		.y(pcnext)
	);
	/*mux2 #(.WIDTH(32)) pcmux(
		.d0(pcnextbr),
		.d1({pcplus4[31:28], instr[25:0], 2'b00}),
		.s(jump),
		.y(pcnext)
	);*/
	regfile rf(
		.clk(clk),
		.we3(regwrite),
		.ra1(instr[19:15]),
		.ra2(instr[24:20]),
		.wa3(instr[11:7]),
		.wd3(result),
		.rd1(srca),
		.rd2(writedata)
	);

	mux4 #(.WIDTH(32)) resmux(
		.d0(aluout),
		.d1(readdata),
		.d2(pcplus4),
		.d3(32'b00000000000000000000000000000000),
		.s(resultsrc),
		.y(result)
	);
	signext se(
		.a(instr),
		.immsrc(immsrc),
		.y(signimm)
	);
	mux2 #(.WIDTH(32)) srcbmux(
		.d0(writedata),
		.d1(signimm),
		.s(alusrc),
		.y(srcb)
	);
	alu alu(
		.a(srca),
		.b(srcb),
		.alucont(alucontrol),
		.result(aluout),
		.zero(zero)
	);
endmodule
module dmem (
	clk,
	we,
	a,
	wd,
	rd
);
	input clk;
	input we;
	input [31:0] a;
	input [31:0] wd;
	output wire [31:0] rd;
	reg [31:0] RAM [63:0];
	assign rd = RAM[a[31:2]];
	always @(posedge clk)
		if (we)
			RAM[a[31:2]] <= wd;
endmodule
module imem (
	a,
	rd
);
	input [5:0] a;
	output wire [31:0] rd;
	reg [31:0] RAM [63:0];
	initial $readmemh("memfile.dat", RAM);
	assign rd = RAM[a];
endmodule
module alu (
	a,
	b,
	alucont,
	result,
	zero
);
	input [31:0] a;
	input [31:0] b;
	input [2:0] alucont;
	output reg [31:0] result;
	output wire zero;
	wire [31:0] b2;
	wire [31:0] sum;
	wire [31:0] slt;
	assign b2 = (alucont[0] ? ~b : b);
	assign sum = (a + b2) + alucont[0];
	assign slt = sum[31];
	always @(*)
		case (alucont[2:0])
			3'b010: result <= a & b;
			3'b011: result <= a | b;
			3'b000: result <= sum;
			3'b001: result <= sum;
			3'b101: result <= slt;
		endcase
	assign zero = (result == 32'b00000000000000000000000000000000);
endmodule
module regfile (
	clk,
	we3,
	ra1,
	ra2,
	wa3,
	wd3,
	rd1,
	rd2
);
	input clk;
	input we3;
	input [4:0] ra1;
	input [4:0] ra2;
	input [4:0] wa3;
	input [31:0] wd3;
	output wire [31:0] rd1;
	output wire [31:0] rd2;
	reg [31:0] rf [31:0];
	always @(posedge clk)
		if (we3)
			rf[wa3] <= wd3;
	assign rd1 = (ra1 != 0 ? rf[ra1] : 0);
	assign rd2 = (ra2 != 0 ? rf[ra2] : 0);
endmodule
module adder (
	a,
	b,
	y
);
	input [31:0] a;
	input [31:0] b;
	output wire [31:0] y;
	assign y = a + b;
endmodule
module sl2 (
	a,
	y
);
	input [31:0] a;
	output wire [31:0] y;
	assign y = {a[29:0], 2'b00};
endmodule
module signext (
	a,
	immsrc,
	y
);
	input [31:0] a;
	input [1:0] immsrc;
	output reg [31:0] y;
	always @(*)
		begin
			case(immsrc)
				2'b00: y <= {{20{a[31]}}, a[31:20]};
				2'b01: y <= {{20{a[31]}}, a[31:25], a[11:7]};
				2'b10: y<={{20{a[31]}}, a[7], a[30:25], a[11:8], {1'b0}};
				2'b11: y<={{12{a[31]}}, a[19:12], a[20], a[30:21], {1'b0}};
				default:  y<=1'b0;
			endcase
		end
endmodule
module flopr (
	clk,
	reset,
	d,
	q
);
	parameter WIDTH = 8;
	input clk;
	input reset;
	input [WIDTH - 1:0] d;
	output reg [WIDTH - 1:0] q;
	always @(posedge clk or posedge reset)
		if (reset)
			q <= 0;
		else
			q <= d;
endmodule
module flopenr (
	clk,
	reset,
	en,
	d,
	q
);
	parameter WIDTH = 8;
	input clk;
	input reset;
	input en;
	input [WIDTH - 1:0] d;
	output reg [WIDTH - 1:0] q;
	always @(posedge clk or posedge reset)
		if (reset)
			q <= 0;
		else if (en)
			q <= d;
endmodule
module mux2 (
	d0,
	d1,
	s,
	y
);
	parameter WIDTH = 8;
	input [WIDTH - 1:0] d0;
	input [WIDTH - 1:0] d1;
	input s;
	output wire [WIDTH - 1:0] y;
	assign y = (s ? d1 : d0);
endmodule


module mux4 (
	d0,
	d1,
	d2,
	d3,
	s,
	y
);
	parameter WIDTH = 8;
	input [WIDTH - 1:0] d0;
	input [WIDTH - 1:0] d1;
	input [WIDTH - 1:0] d2;
	input [WIDTH - 1:0] d3;
	input [1:0] s;
	output reg [WIDTH - 1:0] y;
	always @(*)
		begin
			case(s)
				2'b00: y<=d0;
				2'b01: y<=d1;
				2'b10: y<=d2;
				2'b11: y<=d3;
				default:  y<=1'b0;
			endcase
		end
endmodule