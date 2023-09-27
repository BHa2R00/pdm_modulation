`timescale 100ns / 1ns


module ir_tb;

reg rstn, clk;
always #0.1041 clk = ~clk;

reg [2:0] ir_test_protocol;
localparam
	ir_test_protocol_rca	= 3'b111,
	ir_test_protocol_recs	= 3'b110,
	ir_test_protocol_sharp	= 3'b101,
	ir_test_protocol_rcmm	= 3'b100,
	ir_test_protocol_sony	= 3'b011,
	ir_test_protocol_rc6	= 3'b010,
	ir_test_protocol_nec	= 3'b001,
	ir_test_protocol_rc5	= 3'b000;
reg ock_36k, ock_38k, ock_40k, ock_56k;
always #138.8889 ock_36k = ~ock_36k;
always #131.57895 ock_38k = ~ock_38k;
always #125.0 ock_40k = ~ock_40k;
always #89.28571 ock_56k = ~ock_56k;
wire ock = 
	ir_test_protocol == ir_test_protocol_rca ? ock_56k : 
	ir_test_protocol == ir_test_protocol_recs ? ock_38k : 
	ir_test_protocol == ir_test_protocol_sharp ? ock_38k : 
	ir_test_protocol == ir_test_protocol_rcmm ? ock_36k : 
	ir_test_protocol == ir_test_protocol_sony ? ock_40k : 
	ir_test_protocol == ir_test_protocol_rc6 ? ock_36k : 
	ir_test_protocol == ir_test_protocol_nec ? ock_38k : 
	ir_test_protocol == ir_test_protocol_rc5 ? ock_36k : 
	ock_36k;
reg uck_889u, uck_444u, uck_560u, uck_600u, uck_56u, uck_320u, uck_158u, uck_500u;
always #4445.0 uck_889u = ~uck_889u;
always #2220.0 uck_444u = ~uck_444u;
always #2800.0 uck_560u = ~uck_560u;
always #3000.0 uck_600u = ~uck_600u;
always #280.0 uck_56u = ~uck_56u;
always #1600.0 uck_320u = ~uck_320u;
always #790.0 uck_158u = ~uck_158u;
always #2500.0 uck_500u = ~uck_500u;
wire uck = 
	ir_test_protocol == ir_test_protocol_rca ? uck_500u : 
	ir_test_protocol == ir_test_protocol_recs ? uck_158u : 
	ir_test_protocol == ir_test_protocol_sharp ? uck_320u : 
	ir_test_protocol == ir_test_protocol_rcmm ? uck_56u : 
	ir_test_protocol == ir_test_protocol_sony ? uck_600u : 
	ir_test_protocol == ir_test_protocol_rc6 ? uck_444u : 
	ir_test_protocol == ir_test_protocol_nec ? uck_560u : 
	ir_test_protocol == ir_test_protocol_rc5 ? uck_889u : 
	uck_889u;

wire u_ir_dsm_ack;
reg u_ir_dsm_req;
wire u_ir_dsm_sdo;
wire [159:0] u_ir_dsm_frame = 
	ir_test_protocol == ir_test_protocol_rca ? 160'b11111111000000001000010100001010100001000010100001010101010100001010000100001010100001010000100001000010000 : 
	ir_test_protocol == ir_test_protocol_recs ? 160'b1000000000000100000000000010000000010000000000001000000001000000000000100000000100000000100000000000010000000010000000010000 : 
	ir_test_protocol == ir_test_protocol_sharp ? 160'b10000001000000100010001000100000010001000100010000001000100010001000000100010000 : 
	ir_test_protocol == ir_test_protocol_rcmm ? 160'b111111100000111000001110000000011100000000000111000000000000001110000 : 
	ir_test_protocol == ir_test_protocol_sony ? 160'b1111011011010101101010110101010100000 : 
	ir_test_protocol == ir_test_protocol_rc6 ? 160'b11111100100101100011010101100101100110100110011010010000 : 
	ir_test_protocol == ir_test_protocol_nec ? 160'b11111111111111110000000010001010100010001010001010100010001010100010100010100010001010001010101000101010001010001000100010000 : 
	ir_test_protocol == ir_test_protocol_rc5 ? 160'b01011010100110010101100110010000 :
	160'd0;
reg u_ir_dsm_ock, u_ir_dsm_uck;
ir_dsm u_ir_dsm(
	.ack(u_ir_dsm_ack),
	.req(u_ir_dsm_req),
	.sdo(u_ir_dsm_sdo), 
	.dsm_din_ir_tx_carrier_on(32'h553f7d00), 
	.frame(u_ir_dsm_frame), 
	.enable(1'b1), .ock(u_ir_dsm_ock), .uck(u_ir_dsm_uck), 
	.rstn(rstn), .clk(clk)
);
always@(*) u_ir_dsm_ock = ock;
always@(*) u_ir_dsm_uck = uck;
reg u_ir_dsm_ack_full, u_ir_dsm_ack_drain;
wire u_ir_dsm_ack_ck = u_ir_dsm_ack_full ? u_ir_dsm_ack_drain : u_ir_dsm_ack;
always@(negedge rstn or posedge u_ir_dsm_ack_ck) begin
	if(!rstn) u_ir_dsm_ack_full <= 1'b1;
	else u_ir_dsm_ack_full <= ~u_ir_dsm_ack_full;
end

reg u_ir_dsdm_req_clear;
wire u_ir_dsdm_ack;
reg u_ir_dsdm_req;
wire u_ir_dsdm_sdi = ~(~u_ir_dsm_sdo);
wire [31:0] u_ir_dsdm_dsdm_dout_ir_rx_carrier_off = 
	ir_test_protocol == ir_test_protocol_rca ? 32'h7fffffe5 : 
	ir_test_protocol == ir_test_protocol_recs ? 32'h7ffffffb : 
	ir_test_protocol == ir_test_protocol_sharp ? 32'h7ffffff5 : 
	ir_test_protocol == ir_test_protocol_rcmm ? 32'h7fffffff : 
	ir_test_protocol == ir_test_protocol_sony ? 32'h7fffffe9 : 
	ir_test_protocol == ir_test_protocol_rc6 ? 32'h7ffffff2 : 
	ir_test_protocol == ir_test_protocol_nec ? 32'h7fffffec : 
	ir_test_protocol == ir_test_protocol_rc5 ? 32'h7fffffe1 : 
	32'h7ffffff5;
wire [159:0] u_ir_dsdm_frame;
reg u_ir_dsdm_ock, u_ir_dsdm_uck;
ir_dsdm u_ir_dsdm(
	.req_clear(u_ir_dsdm_req_clear),
	.ack(u_ir_dsdm_ack),
	.req(u_ir_dsdm_req),
	.sdi(u_ir_dsdm_sdi), 
	.dsdm_dout_ir_rx_carrier_off(u_ir_dsdm_dsdm_dout_ir_rx_carrier_off), 
	.frame(u_ir_dsdm_frame), 
	.enable(1'b1), .ock(u_ir_dsdm_ock), .uck(u_ir_dsdm_uck), 
	.rstn(rstn), .clk(clk)
);
always@(*) u_ir_dsdm_ock = ock;
always@(*) u_ir_dsdm_uck = uck;
reg u_ir_dsdm_ack_full, u_ir_dsdm_ack_drain;
wire u_ir_dsdm_ack_ck = u_ir_dsdm_ack_full ? u_ir_dsdm_ack_drain : u_ir_dsdm_ack;
always@(negedge rstn or posedge u_ir_dsdm_ack_ck) begin
	if(!rstn) u_ir_dsdm_ack_full <= 1'b1;
	else u_ir_dsdm_ack_full <= ~u_ir_dsdm_ack_full;
end

always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		ir_test_protocol = 3'b000;
		u_ir_dsm_req = 1'b0;
		u_ir_dsm_ack_drain = 1'b0;
		u_ir_dsdm_req = 1'b0;
		u_ir_dsdm_ack_drain = 1'b0;
		u_ir_dsdm_req_clear = 1'b0;
	end
	else begin
		if(u_ir_dsm_ack_full) begin
			u_ir_dsm_req = 1'b1;
			u_ir_dsm_ack_drain = 1'b1;
		end
		else begin
			u_ir_dsm_req = 1'b0;
			u_ir_dsm_ack_drain = 1'b0;
		end
		if(u_ir_dsdm_ack_full) begin
			$display("ir_test_protocol = %b",ir_test_protocol);
			ir_test_protocol = ir_test_protocol + 3'b001;
			u_ir_dsdm_req = 1'b1;
			u_ir_dsdm_ack_drain = 1'b1;
		end
		else begin
			u_ir_dsdm_req = 1'b0;
			u_ir_dsdm_ack_drain = 1'b0;
		end
		#1230;
	end
end

initial begin
	rstn = 0; clk = 0; 
	ock_36k = 0; ock_38k = 0; ock_40k = 0; ock_56k = 0;
	uck_889u = 0; uck_444u = 0; uck_560u = 0; uck_600u = 0; uck_56u = 0; uck_320u = 0; uck_158u = 0; uck_500u = 0;
	#3000
	rstn = 1;
	#8000000
	rstn = 0;
	#3000
	$finish(2);
end

initial begin
	$dumpfile("../work/ir_tb.fst");
	$dumpvars(0,ir_tb);
end

endmodule
