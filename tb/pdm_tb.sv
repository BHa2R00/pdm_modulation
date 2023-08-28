`timescale 1ns / 100ps


module pdm_tb;

reg rstn, clk, uck, ock;

wire u_pdm_sdo;
reg [31:0] u_pdm_din;
reg u_pdm_ock, u_pdm_uck;
pdm u_pdm(
	.sdo(u_pdm_sdo), 
	.signed_data(1'b0), 
	.din(u_pdm_din), 
	.ock(u_pdm_ock), .uck(u_pdm_uck), 
	.rstn(rstn), .clk(clk)
);
always@(*) u_pdm_ock = ock;
always@(*) u_pdm_uck = uck;
reg [7:0] u_pdm_din_cnt;
always@(negedge rstn or negedge ock) begin
	if(!rstn) begin
		u_pdm_din = 0;
		u_pdm_din_cnt = 0;
	end
	else if(u_pdm_din_cnt == 0) begin
		if(u_pdm_din == 0) u_pdm_din = 1073741824;
		else if(u_pdm_din == 1073741824) u_pdm_din = 1430224128;
		else if(u_pdm_din == 1430224128) u_pdm_din = 2147483648;
		else if(u_pdm_din == 2147483648) u_pdm_din = 2860448256;
		else if(u_pdm_din == 2860448256) u_pdm_din = 3221225472;
		else if(u_pdm_din == 3221225472) u_pdm_din = 4294967295;
		else if(u_pdm_din == 4294967295) u_pdm_din = 0;
		else u_pdm_din = 0;
		u_pdm_din_cnt = u_pdm_din_cnt - 1;
	end
	else u_pdm_din_cnt = u_pdm_din_cnt - 1;
end

reg u_pddm_sdi;
wire [31:0] u_pddm_dout;
reg u_pddm_ock, u_pddm_uck;
pddm u_pddm(
	.sdi(u_pddm_sdi), 
	.signed_data(1'b0), 
	.dout(u_pddm_dout), 
	.ock(u_pddm_ock), .uck(u_pddm_uck), 
	.rstn(rstn), .clk(clk)
);
always@(*) u_pddm_ock = ock;
always@(*) u_pddm_uck = uck;
always@(*) u_pddm_sdi = u_pdm_sdo;

always #33.3 clk = ~clk;
always #133.3 ock = ~ock;
always #2800.0 uck = ~uck;

initial begin
	rstn = 0;
	clk = 0; ock = 0; uck = 0;
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
