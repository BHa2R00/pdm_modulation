`timescale 1ns / 100ps

module pdm_tb;

reg rstn, clk;

wire u_pdm_modulator_sdo;
reg [31:0] u_pdm_modulator_din;
reg u_pdm_modulator_ock;
pdm_modulator u_pdm_modulator(
	.sdo(u_pdm_modulator_sdo), 
	.din(u_pdm_modulator_din), 
	.ock(u_pdm_modulator_ock), 
	.rstn(rstn), .clk(clk)
);

wire u_audio_pdm_modulator_sdo;
reg [31:0] u_audio_pdm_modulator_din_l, u_audio_pdm_modulator_din_r;
reg u_audio_pdm_modulator_ock;
audio_pdm_modulator u_audio_pdm_modulator(
	.sdo(u_audio_pdm_modulator_sdo), 
	.din_l(u_audio_pdm_modulator_din_l), 
	.din_r(u_audio_pdm_modulator_din_r), 
	.ock(u_audio_pdm_modulator_ock), 
	.rstn(rstn), .clk(clk)
);

reg u_pdm_demodulator_sdi;
wire [31:0] u_pdm_demodulator_dout;
reg u_pdm_demodulator_ock;
pdm_demodulator u_pdm_demodulator(
	.sdi(u_pdm_demodulator_sdi), 
	.dout(u_pdm_demodulator_dout), 
	.ock(u_pdm_demodulator_ock), 
	.rstn(rstn), .clk(clk)
);

reg u_audio_pdm_demodulator_sdi;
wire [31:0] u_audio_pdm_demodulator_dout_l, u_audio_pdm_demodulator_dout_r;
reg u_audio_pdm_demodulator_ock;
audio_pdm_demodulator u_audio_pdm_demodulator(
	.sdi(u_audio_pdm_demodulator_sdi), 
	.dout_l(u_audio_pdm_demodulator_dout_l), 
	.dout_r(u_audio_pdm_demodulator_dout_r), 
	.ock(u_audio_pdm_demodulator_ock), 
	.rstn(rstn), .clk(clk)
);

always@(*) u_pdm_demodulator_ock = u_pdm_modulator_ock;
always@(*) u_pdm_demodulator_sdi = u_pdm_modulator_sdo;

always #33.3 clk = ~clk;
always #133.3 u_pdm_modulator_ock = ~u_pdm_modulator_ock;
always@(negedge u_pdm_modulator_ock) u_pdm_modulator_din = 2147483647*$sin(1e02*$time*2*3.1415926) + 2147483647;
always@(*) u_audio_pdm_modulator_ock = u_pdm_modulator_ock;
always@(negedge u_audio_pdm_modulator_ock) u_audio_pdm_modulator_din_l = 2147483647*$sin(1e02*$time*2*3.1415926) + 2147483647;
always@(negedge u_audio_pdm_modulator_ock) u_audio_pdm_modulator_din_r = 2147483647*$cos(1e02*$time*2*3.1415926) + 2147483647;
always@(*) u_audio_pdm_demodulator_ock = u_audio_pdm_modulator_ock;
always@(*) u_audio_pdm_demodulator_sdi = u_audio_pdm_modulator_sdo;

initial begin
	rstn = 0;
	clk = 0;
	//u_pdm_modulator_sdo init
	u_pdm_modulator_ock = 0;
	//u_pdm_modulator_sdo init end
	#3000
	rstn = 1;
	#3000000
	rstn = 0;
	#3000
	$finish(2);
end

initial begin
	$dumpfile("../work/pdm_tb.vcd");
	$dumpvars(0,pdm_tb);
end

endmodule
