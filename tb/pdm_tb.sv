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

reg [5:0] u_audio_pdm_modulator_scale;
reg [31:0] u_audio_pdm_modulator_align;
wire u_audio_pdm_modulator_sdo;
reg [31:0] u_audio_pdm_modulator_din_l, u_audio_pdm_modulator_din_r;
reg u_audio_pdm_modulator_ock;
audio_pdm_modulator u_audio_pdm_modulator(
	.scale(u_audio_pdm_modulator_scale),
	.align(u_audio_pdm_modulator_align),
	.sdo(u_audio_pdm_modulator_sdo), 
	.din_l(u_audio_pdm_modulator_din_l), 
	.din_r(u_audio_pdm_modulator_din_r), 
	.ock(u_audio_pdm_modulator_ock), 
	.rstn(rstn), .clk(clk)
);

wire u_ir_pdm_modulator_sdo;
reg [4:0] u_ir_pdm_modulator_din;
reg u_ir_pdm_modulator_ock, u_ir_pdm_modulator_bck;
reg u_ir_pdm_modulator_load;
wire u_ir_pdm_modulator_done;
ir_pdm_modulator u_ir_pdm_modulator(
	.sdo(u_ir_pdm_modulator_sdo), 
	.din(u_ir_pdm_modulator_din), 
	.ock(u_ir_pdm_modulator_ock), .bck(u_ir_pdm_modulator_bck), 
	.load(u_ir_pdm_modulator_load), 
	.done(u_ir_pdm_modulator_done), 
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

reg [5:0] u_audio_pdm_demodulator_scale;
reg [31:0] u_audio_pdm_demodulator_align;
reg u_audio_pdm_demodulator_sdi;
wire [31:0] u_audio_pdm_demodulator_dout_l, u_audio_pdm_demodulator_dout_r;
reg u_audio_pdm_demodulator_ock;
audio_pdm_demodulator u_audio_pdm_demodulator(
	.scale(u_audio_pdm_demodulator_scale),
	.align(u_audio_pdm_demodulator_align),
	.sdi(u_audio_pdm_demodulator_sdi), 
	.dout_l(u_audio_pdm_demodulator_dout_l), 
	.dout_r(u_audio_pdm_demodulator_dout_r), 
	.ock(u_audio_pdm_demodulator_ock), 
	.rstn(rstn), .clk(clk)
);

reg u_ir_pdm_demodulator_sdi;
wire [4:0] u_ir_pdm_demodulator_dout;
reg u_ir_pdm_demodulator_ock, u_ir_pdm_demodulator_bck;
reg u_ir_pdm_demodulator_load;
wire u_ir_pdm_demodulator_done;
ir_pdm_demodulator u_ir_pdm_demodulator(
	.sdi(u_ir_pdm_demodulator_sdi), 
	.dout(u_ir_pdm_demodulator_dout), 
	.ock(u_ir_pdm_demodulator_ock), .bck(u_ir_pdm_demodulator_bck), 
	.load(u_ir_pdm_demodulator_load), 
	.done(u_ir_pdm_demodulator_done), 
	.rstn(rstn), .clk(clk)
);

always #33.3 clk = ~clk;
always #133.3 u_pdm_modulator_ock = ~u_pdm_modulator_ock;
always #138.8 u_ir_pdm_modulator_ock = ~u_ir_pdm_modulator_ock;
always #2800 u_ir_pdm_modulator_bck = ~u_ir_pdm_modulator_bck;
always@(*) u_pdm_demodulator_ock = u_pdm_modulator_ock;
always@(*) u_pdm_demodulator_sdi = u_pdm_modulator_sdo;
reg [7:0] u_pdm_modulator_din_cnt;
always@(negedge rstn or negedge u_pdm_modulator_ock) begin
	if(!rstn) begin
		u_pdm_modulator_din = 0;
		u_pdm_modulator_din_cnt = 0;
	end
	else if(u_pdm_modulator_din_cnt == 0) begin
		if(u_pdm_modulator_din == 0) u_pdm_modulator_din = 1073741824;
		else if(u_pdm_modulator_din == 1073741824) u_pdm_modulator_din = 1430224128;
		else if(u_pdm_modulator_din == 1430224128) u_pdm_modulator_din = 2147483648;
		else if(u_pdm_modulator_din == 2147483648) u_pdm_modulator_din = 2860448256;
		else if(u_pdm_modulator_din == 2860448256) u_pdm_modulator_din = 3221225472;
		else if(u_pdm_modulator_din == 3221225472) u_pdm_modulator_din = 4294967295;
		else if(u_pdm_modulator_din == 4294967295) u_pdm_modulator_din = 0;
		else u_pdm_modulator_din = 0;
		u_pdm_modulator_din_cnt = u_pdm_modulator_din_cnt - 1;
	end
	else u_pdm_modulator_din_cnt = u_pdm_modulator_din_cnt - 1;
end
always@(*) u_audio_pdm_modulator_ock = u_pdm_modulator_ock;
always@(negedge u_audio_pdm_modulator_ock) u_audio_pdm_modulator_din_l = 2147483647*$sin(5e02*$time*2*3.1415926) + 2147483647;
always@(negedge u_audio_pdm_modulator_ock) u_audio_pdm_modulator_din_r = 2147483647*$cos(5e02*$time*2*3.1415926) + 2147483647;
always@(*) u_audio_pdm_demodulator_ock = u_audio_pdm_modulator_ock;
always@(*) u_audio_pdm_demodulator_sdi = u_audio_pdm_modulator_sdo;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		u_ir_pdm_modulator_din = 0;
		u_ir_pdm_modulator_load = 0;
	end
	else begin
		if(u_ir_pdm_modulator_done) begin
			u_ir_pdm_modulator_din = u_audio_pdm_modulator_din_l[4:0];
			u_ir_pdm_modulator_load = 1;
		end
		else u_ir_pdm_modulator_load = 0;
	end
end
always@(*) u_ir_pdm_demodulator_sdi = u_ir_pdm_modulator_sdo;
always@(*) u_ir_pdm_demodulator_ock = u_ir_pdm_modulator_ock;
always@(*) u_ir_pdm_demodulator_bck = u_ir_pdm_modulator_bck;
always@(negedge rstn or posedge clk) begin
	if(!rstn) u_ir_pdm_demodulator_load = 0;
	else begin
		if(u_ir_pdm_demodulator_done) u_ir_pdm_demodulator_load = 1;
		else u_ir_pdm_demodulator_load = 0;
	end
end

initial begin
	rstn = 0;
	clk = 0;
	//u_pdm_modulator_sdo init
	u_pdm_modulator_ock = 0;
	//u_pdm_modulator_sdo init end
	//u_audio_pdm_modulator_sdo init
	u_audio_pdm_modulator_scale = {1'b1,5'd2};
	u_audio_pdm_modulator_align = 32'd1;
	//u_audio_pdm_modulator_sdo init end
	//u_audio_pdm_demodulator_sdo init
	u_audio_pdm_demodulator_scale = {1'b0,5'd1};
	u_audio_pdm_demodulator_align = ~32'd2+32'd1;
	//u_audio_pdm_demodulator_sdo init end
	//u_ir_pdm_modulator_sdo init
	u_ir_pdm_modulator_ock = 0;
	u_ir_pdm_modulator_bck = 0;
	//u_ir_pdm_modulator_sdo init end
	#3000
	rstn = 1;
	#30000000
	rstn = 0;
	#3000
	$finish(2);
end

initial begin
	$dumpfile("../work/pdm_tb.vcd");
	$dumpvars(0,pdm_tb);
end

endmodule
