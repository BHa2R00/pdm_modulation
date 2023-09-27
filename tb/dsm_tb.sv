`timescale 1ns / 100ps


module dsm_tb;

reg rstn, clk, uck, ock;

wire u_dsm_sdo;
reg [31:0] u_dsm_din;
reg u_dsm_ock, u_dsm_uck;
dsm u_dsm(
	.sdo(u_dsm_sdo), 
	.signed_data(1'b0), 
	.din(u_dsm_din), 
	.enable(1'b1), .ock(u_dsm_ock), .uck(u_dsm_uck), 
	.rstn(rstn), .clk(clk)
);
always@(*) u_dsm_ock = ock;
always@(*) u_dsm_uck = uck;
reg [7:0] u_dsm_din_cnt;
always@(negedge rstn or negedge ock) begin
	if(!rstn) begin
		u_dsm_din = 0;
		u_dsm_din_cnt = 0;
	end
	else if(u_dsm_din_cnt == 0) begin
		if(u_dsm_din == 0) u_dsm_din = 1073741824;
		else if(u_dsm_din == 1073741824) u_dsm_din = 1430224128;
		else if(u_dsm_din == 1430224128) u_dsm_din = 2147483648;
		else if(u_dsm_din == 2147483648) u_dsm_din = 2860448256;
		else if(u_dsm_din == 2860448256) u_dsm_din = 3221225472;
		else if(u_dsm_din == 3221225472) u_dsm_din = 4294967295;
		else if(u_dsm_din == 4294967295) u_dsm_din = 0;
		else u_dsm_din = 0;
		u_dsm_din_cnt = u_dsm_din_cnt - 1;
	end
	else u_dsm_din_cnt = u_dsm_din_cnt - 1;
end

reg u_dsdm_sdi;
wire [31:0] u_dsdm_dout;
reg u_dsdm_ock, u_dsdm_uck;
dsdm u_dsdm(
	.sdi(u_dsdm_sdi), 
	.signed_data(1'b0), 
	.dout(u_dsdm_dout), 
	.enable(1'b1), .ock(u_dsdm_ock), .uck(u_dsdm_uck), 
	.rstn(rstn), .clk(clk)
);
always@(*) u_dsdm_ock = ock;
always@(*) u_dsdm_uck = uck;
always@(*) u_dsdm_sdi = u_dsm_sdo;

wire u_audio_dsm_sdo;
reg [31:0] u_audio_dsm_din_l, u_audio_dsm_din_r;
reg u_audio_dsm_bck, u_audio_dsm_lrck;
audio_dsm u_audio_dsm(
	.sdo(u_audio_dsm_sdo), 
	.signed_data(1'b1), 
	.din_l(u_audio_dsm_din_l), .din_r(u_audio_dsm_din_r), 
	.enable(1'b1), .bck(u_audio_dsm_bck), .lrck(u_audio_dsm_lrck), 
	.rstn(rstn), .clk(clk)
);
always@(*) u_audio_dsm_bck = ock;
always@(*) u_audio_dsm_lrck = uck;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		u_audio_dsm_din_l = 32'h80000000;
		u_audio_dsm_din_r = 32'h80000000;
	end
	else begin
		u_audio_dsm_din_l = 2147483647*$sin(4.2e02*$time*2*3.1415926) + 0;
		u_audio_dsm_din_r = 2147483647*$cos(4.2e02*$time*2*3.1415926) + 0;
	end
end

reg u_audio_dsdm_sdi;
wire [31:0] u_audio_dsdm_dout_l, u_audio_dsdm_dout_r;
reg u_audio_dsdm_bck, u_audio_dsdm_lrck;
audio_dsdm u_audio_dsdm(
	.sdi(u_audio_dsdm_sdi), 
	.signed_data(1'b1), 
	.dout_l(u_audio_dsdm_dout_l), .dout_r(u_audio_dsdm_dout_r), 
	.enable(1'b1), .bck(u_audio_dsdm_bck), .lrck(u_audio_dsdm_lrck), 
	.rstn(rstn), .clk(clk)
);
always@(*) u_audio_dsdm_bck = ock;
always@(*) u_audio_dsdm_lrck = uck;
always@(*) u_audio_dsdm_sdi = u_audio_dsm_sdo;

always #10.41 clk = ~clk;
always #166.7 ock = ~ock;
always #5334.4 uck = ~uck;

initial begin
	rstn = 0;
	clk = 0; ock = 0; uck = 0;
	#3000
	rstn = 1;
	#2000000
	rstn = 0;
	#3000
	$finish(2);
end

initial begin
	$dumpfile("../work/dsm_tb.fst");
	$dumpvars(0,dsm_tb);
end

endmodule
