module dsm (
	output sdo, 
	input signed_data, 
	input [31:0] din, 
	input enable, ock, uck, 
	input rstn, clk
);

wire [31:0] unsigned_din = signed_data ? 32'h80000000 + din : din;

reg uck_full, uck_drain;
wire uck_ck = uck_full ? uck_drain : uck;
always@(negedge rstn or posedge uck_ck) begin
	if(!rstn) uck_full <= 1'b0;
	else uck_full <= ~uck_full;
end

reg [31:0] undersampled_din;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		undersampled_din <= 32'h80000000;
		uck_drain <= 1'b0;
	end
	else if(enable) begin
		if(uck_full) begin
			undersampled_din <= unsigned_din;
			uck_drain <= 1'b1;
		end
		else uck_drain <= 1'b0;
	end
end

reg ock_full, ock_drain;
wire ock_ck = ock_full ? ock_drain : ock;
always@(negedge rstn or posedge ock_ck) begin
	if(!rstn) ock_full <= 1'b0;
	else ock_full <= ~ock_full;
end

reg [31:0] sigma;
wire [31:0] delta = sdo ? 
	((sigma == 32'hffffffff) ? 32'h80000000 : 32'h00000001) : 
	((sigma == 32'h00000000) ? 32'h80000000 : 32'hffffffff);
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		sigma <= 32'h80000000;
		ock_drain <= 1'b0;
	end
	else if(enable) begin
		if(ock_full) begin
			sigma <= sigma + (~undersampled_din + 32'h00000001) + delta;
			ock_drain <= 1'b1;
		end
		else ock_drain <= 1'b0;
	end
end
assign sdo = undersampled_din > sigma;

endmodule


module dsdm (
	input sdi, 
	input signed_data, 
	output [31:0] dout, 
	input enable, ock, uck, 
	input rstn, clk
);

reg ock_full, ock_drain;
wire ock_ck = ock_full ? ock_drain : ock;
always@(negedge rstn or posedge ock_ck) begin
	if(!rstn) ock_full <= 1'b0;
	else ock_full <= ~ock_full;
end

reg [31:0] sigma, sigma_d;
wire [31:0] delta = sdi ? 
	((sigma == 32'hffffffff) ? 32'h80000000 : 32'h00000001) : 
	((sigma == 32'h00000000) ? 32'h80000000 : 32'hffffffff);
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		sigma <= 32'h80000000;
		ock_drain <= 1'b0;
	end
	else if(enable) begin
		if(ock_full) begin
			sigma <= sigma + delta;
			ock_drain <= 1'b1;
		end
		else ock_drain <= 1'b0;
	end
end

reg uck_full, uck_drain;
wire uck_ck = uck_full ? uck_drain : uck;
always@(negedge rstn or posedge uck_ck) begin
	if(!rstn) uck_full <= 1'b0;
	else uck_full <= ~uck_full;
end

reg [31:0] undersampled_sigma, deriv;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		undersampled_sigma <= 32'h80000000;
		deriv <= 32'h80000000;
		uck_drain <= 1'b0;
	end
	else if(enable) begin
		if(uck_full) begin
			undersampled_sigma <= sigma;
			deriv <= sigma - undersampled_sigma + 32'h80000000;
			uck_drain <= 1'b1;
		end
		else uck_drain <= 1'b0;
	end
end
assign dout = signed_data ? 32'h80000000 + deriv : deriv;

endmodule


module audio_dsm(
	output sdo, 
	input signed_data, 
	input [31:0] din_l, din_r, 
	input enable, bck, lrck, 
	input rstn, clk
);

wire ul_dsm_sdo;
dsm ul_dsm(
	.sdo(ul_dsm_sdo), 
	.signed_data(signed_data), 
	.din(din_l), 
	.enable(enable), .ock(~bck), .uck(~lrck), 
	.rstn(rstn), .clk(clk)
);

wire ur_dsm_sdo;
dsm ur_dsm(
	.sdo(ur_dsm_sdo), 
	.signed_data(signed_data), 
	.din(din_r), 
	.enable(enable), .ock(bck), .uck(lrck), 
	.rstn(rstn), .clk(clk)
);

assign sdo = bck ? ur_dsm_sdo : ul_dsm_sdo;

endmodule


module audio_dsdm (
	input sdi, 
	input signed_data, 
	output [31:0] dout_l, dout_r,  
	input enable, bck, lrck, 
	input rstn, clk
);

dsdm ul_dsdm(
	.sdi(sdi), 
	.signed_data(signed_data), 
	.dout(dout_l), 
	.enable(enable), .ock(~bck), .uck(~lrck), 
	.rstn(rstn), .clk(clk)
);

dsdm ur_dsdm(
	.sdi(sdi), 
	.signed_data(signed_data), 
	.dout(dout_r), 
	.enable(enable), .ock(bck), .uck(lrck), 
	.rstn(rstn), .clk(clk)
);

endmodule


module ir_dsm(
	output ack, 
	input req, 
	output sdo, 
	input [31:0] dsm_din_ir_tx_carrier_on, 
	input [159:0] frame, 
	input enable, ock, uck, 
	input rstn, clk
);

reg [31:0] u_dsm_din;
dsm u_dsm(
	.sdo(sdo), 
	.signed_data(1'b0), 
	.din(u_dsm_din), 
	.enable(enable), .ock(ock), .uck(uck), 
	.rstn(rstn), .clk(clk)
);

reg uck_full, uck_drain;
wire uck_ck = uck_full ? uck_drain : uck;
always@(negedge rstn or posedge uck_ck) begin
	if(!rstn) uck_full <= 1'b0;
	else uck_full <= ~uck_full;
end

reg req_full, req_drain;
wire req_ck = req_full ? req_drain : req;
always@(negedge rstn or posedge req_ck) begin
	if(!rstn) req_full <= 1'b0;
	else req_full <= ~req_full;
end

reg [7:0] frame_cnt;
assign ack = frame_cnt == 8'd0;

always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		u_dsm_din <= 32'h00000000;
		frame_cnt <= 8'd0;
		uck_drain <= 1'b0;
		req_drain <= 1'b0;
	end
	else if(enable) begin
		if(uck_full) begin
			u_dsm_din <= frame[frame_cnt] ? dsm_din_ir_tx_carrier_on : 32'h00000000;
			if(req_full) begin
				frame_cnt <= 8'd159;
				req_drain <= 1'b1;
			end
			else begin
				frame_cnt <= ack ? 8'd0 : frame_cnt - 8'd1;
				req_drain <= 1'b0;
			end
			uck_drain <= 1'b1;
		end
		else uck_drain <= 1'b0;
	end
end

endmodule


module ir_dsdm(
	input req_clear, 
	output ack, 
	input req, 
	input sdi, 
	input [31:0] dsdm_dout_ir_rx_carrier_off, 
	output reg [159:0] frame, 
	input enable, ock, uck, 
	input rstn, clk 
);

wire [31:0] u_dsdm_dout;
dsdm u_dsdm(
	.sdi(sdi), 
	.signed_data(1'b0), 
	.dout(u_dsdm_dout), 
	.enable(enable), .ock(ock), .uck(uck), 
	.rstn(rstn), .clk(clk)
);
wire ir_rx_carrier_on = u_dsdm_dout > dsdm_dout_ir_rx_carrier_off;

reg uck_full, uck_drain;
wire uck_ck = uck_full ? uck_drain : uck;
always@(negedge rstn or posedge uck_ck) begin
	if(!rstn) uck_full <= 1'b0;
	else uck_full <= ~uck_full;
end

reg req_full, req_drain;
wire req_ck = req_full ? req_drain : req;
always@(negedge rstn or posedge req_ck) begin
	if(!rstn) req_full <= 1'b0;
	else req_full <= ~req_full;
end

reg ir_rx_carrier_on_full, ir_rx_carrier_on_drain;
wire ir_rx_carrier_on_ck = ir_rx_carrier_on_full ? ir_rx_carrier_on_drain : ir_rx_carrier_on;
always@(negedge rstn or posedge ir_rx_carrier_on_ck) begin
	if(!rstn) ir_rx_carrier_on_full <= 1'b0;
	else ir_rx_carrier_on_full <= ~ir_rx_carrier_on_full;
end

reg [7:0] frame_cnt;
assign ack = frame_cnt == 8'd0;

always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		frame <= 160'd0;
		frame_cnt <= 8'd0;
		uck_drain <= 1'b0;
		req_drain <= 1'b0;
		ir_rx_carrier_on_drain <= 1'b0;
	end
	else if(enable) begin
		if(uck_full) begin
			frame[frame_cnt] <= ir_rx_carrier_on;
			if(req_full) begin
				frame <= 160'd0;
				frame_cnt <= 8'd159;
				if(ir_rx_carrier_on_full) begin
					req_drain <= 1'b1;
					ir_rx_carrier_on_drain <= 1'b1;
				end
				else req_drain <= req_clear;
			end
			else begin
				frame_cnt <= ack ? 8'd0 : frame_cnt - 8'd1;
				req_drain <= 1'b0;
				ir_rx_carrier_on_drain <= 1'b0;
			end
			uck_drain <= 1'b1;
		end
		else uck_drain <= 1'b0;
	end
end

endmodule


module dsck(
	output reg ock, uck, 
	input [31:0] div, 
	input enable, 
	input rstn, clk 
);

wire [23:0] odiv = div[23:0];
wire [7:0] udiv = div[31:24];
reg [23:0] ocnt;
reg [7:0] ucnt;

always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		ocnt <= 24'd0;
		ucnt <= 8'd0;
		ock <= 1'b0;
		uck <= 1'b0;
	end
	else if(enable) begin
		if(ocnt == 24'd0) begin
			ocnt <= odiv;
			ock <= ~ock;
			if(ucnt == 8'd0) begin
				ucnt <= udiv;
				uck <= ~uck;
			end 
			else ucnt <= ucnt - 8'd1;
		end
		else ocnt <= ocnt - 24'd1;
	end
end

endmodule


module cic5 (
	output [31:0] dout, 
	input [31:0] din, 
	input ock, uck, 
	input enable, 
	input rstn, clk 
);

reg ock_full, ock_drain;
wire ock_ck = ock_full ? ock_drain : ock;
always@(negedge rstn or posedge ock_ck) begin
	if(!rstn) ock_full <= 1'b0;
	else ock_full <= ~ock_full;
end

reg uck_full, uck_drain;
wire uck_ck = uck_full ? uck_drain : uck;
always@(negedge rstn or posedge uck_ck) begin
	if(!rstn) uck_full <= 1'b0;
	else uck_full <= ~uck_full;
end

reg [31:0] i1,i2,i3,i4,i5;
wire [31:0] a1 = din + i1;
wire [31:0] a2 = a1 + i2;
wire [31:0] a3 = a2 + i3;
wire [31:0] a4 = a3 + i4;
wire [31:0] a5 = a4 + i5;
reg [31:0] c1,c2,c3,c4,c5;
wire [31:0] s1 = a4 - c1;
wire [31:0] s2 = s1 - c2;
wire [31:0] s3 = s2 - c3;
wire [31:0] s4 = s3 - c4;
wire [31:0] s5 = s4 - c5;

always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		i1 <= 32'd0;
		i2 <= 32'd0;
		i3 <= 32'd0;
		i4 <= 32'd0;
		i5 <= 32'd0;
		c1 <= 32'd0;
		c2 <= 32'd0;
		c3 <= 32'd0;
		c4 <= 32'd0;
		c5 <= 32'd0;
		ock_drain <= 1'b0;
		uck_drain <= 1'b0;
	end
	else if(enable) begin
		if(ock_full) begin
			i1 <= a1;
			i2 <= a2;
			i3 <= a3;
			i4 <= a4;
			i5 <= a5;
			ock_drain <= 1'b1;
		end
		else ock_drain <= 1'b0;
		if(uck_full) begin
			c1 <= a4;
			c2 <= s1;
			c3 <= s2;
			c4 <= s3;
			c5 <= s4;
			uck_drain <= 1'b1;
		end
		else uck_drain <= 1'b0;
	end
end
assign dout = s5;

endmodule


module dsmdm(
	input dsmdm_din_dma_ack, dsmdm_dout_dma_ack,
	output dsmdm_din_dma_req, dsmdm_dout_dma_req, 
	output [1:0] sdo, 
	input [1:0] sdi, 
	input we, sel, 
	output [31:0] rdata, 
	input [31:0] wdata, addr, 
	input rstn, clk 
);

reg u0_dsck_enable, u1_dsck_enable;
reg [31:0] u0_dsck_div, u1_dsck_div;
wire u0_dsck_ock, u1_dsck_ock;
wire u0_dsck_uck, u1_dsck_uck;

dsck u0_dsck(
	.ock(u0_dsck_ock),.uck(u0_dsck_uck),
	.div(u0_dsck_div),
	.enable(u0_dsck_enable),
	.rstn(rstn),.clk(clk)
);

dsck u1_dsck(
	.ock(u1_dsck_ock),.uck(u1_dsck_uck),
	.div(u1_dsck_div),
	.enable(u1_dsck_enable),
	.rstn(rstn),.clk(clk)
);

reg u0_dsm_signed_data, u1_dsm_signed_data;
reg [31:0] u0_dsm_din, u1_dsm_din;
reg u0_dsm_enable, u1_dsm_enable;
reg u0_dsm_ock_edge, u1_dsm_ock_edge;
reg u0_dsm_uck_edge, u1_dsm_uck_edge;
wire u0_dsm_ock = u0_dsm_ock_edge ? u0_dsck_ock : ~u0_dsck_ock;
wire u1_dsm_ock = u1_dsm_ock_edge ? u1_dsck_ock : ~u1_dsck_ock;
wire u0_dsm_uck = u0_dsm_uck_edge ? u0_dsck_uck : ~u0_dsck_uck;
wire u1_dsm_uck = u1_dsm_uck_edge ? u1_dsck_uck : ~u1_dsck_uck;

dsm u0_dsm(
	.sdo(sdo[0]), 
	.signed_data(u0_dsm_signed_data), 
	.din(u0_dsm_din), 
	.enable(u0_dsm_enable), .ock(u0_dsm_ock), .uck(u0_dsm_uck), 
	.rstn(rstn), .clk(clk)
);

dsm u1_dsm(
	.sdo(sdo[1]), 
	.signed_data(u1_dsm_signed_data), 
	.din(u1_dsm_din), 
	.enable(u1_dsm_enable), .ock(u1_dsm_ock), .uck(u1_dsm_uck), 
	.rstn(rstn), .clk(clk)
);

reg sel_cic;
reg u0_dsdm_signed_data, u1_dsdm_signed_data;
wire [31:0] u0_dsdm_dout, u1_dsdm_dout;
reg u0_dsdm_enable, u1_dsdm_enable;
reg u0_dsdm_ock_edge, u1_dsdm_ock_edge;
reg u0_dsdm_uck_edge, u1_dsdm_uck_edge;
wire u0_dsdm_ock = u0_dsdm_ock_edge ? u0_dsck_ock : ~u0_dsck_ock;
wire u1_dsdm_ock = u1_dsdm_ock_edge ? u1_dsck_ock : ~u1_dsck_ock;
wire u0_dsdm_uck = u0_dsdm_uck_edge ? u0_dsck_uck : ~u0_dsck_uck;
wire u1_dsdm_uck = u1_dsdm_uck_edge ? u1_dsck_uck : ~u1_dsck_uck;

dsdm u0_dsdm(
	.sdi(sdi[0]), 
	.signed_data(u0_dsdm_signed_data), 
	.dout(u0_dsdm_dout), 
	.enable(~sel_cic&&u0_dsdm_enable), .ock(u0_dsdm_ock), .uck(u0_dsdm_uck), 
	.rstn(rstn), .clk(clk)
);

dsdm u1_dsdm(
	.sdi(sdi[1]), 
	.signed_data(u1_dsdm_signed_data), 
	.dout(u1_dsdm_dout), 
	.enable(~sel_cic&&u1_dsdm_enable), .ock(u1_dsdm_ock), .uck(u1_dsdm_uck), 
	.rstn(rstn), .clk(clk)
);

wire [31:0] u0_cic_dout, u1_cic_dout;

cic5 u0_cic(
	.dout(u0_cic_dout), 
	.din({31'd0,sdi[0]}), 
	.ock(u0_dsdm_ock), .uck(u0_dsdm_uck), 
	.enable(sel_cic&&u0_dsdm_enable), 
	.rstn(rstn), .clk(clk) 
);

cic5 u1_cic(
	.dout(u1_cic_dout), 
	.din({31'd0,sdi[1]}), 
	.ock(u1_dsdm_ock), .uck(u1_dsdm_uck), 
	.enable(sel_cic&&u1_dsdm_enable), 
	.rstn(rstn), .clk(clk) 
);

reg din_dma_mode, dout_dma_mode;

reg u0_dsm_uck_full, u0_dsm_uck_drain;
wire u0_dsm_uck_ck = u0_dsm_uck_full ? (din_dma_mode ? dsmdm_din_dma_ack : u0_dsm_uck_drain) : u0_dsm_uck;
always@(negedge rstn or posedge u0_dsm_uck_ck) begin
	if(!rstn) u0_dsm_uck_full <= 1'b0;
	else u0_dsm_uck_full <= ~u0_dsm_uck_full;
end
assign dsmdm_din_dma_req = din_dma_mode && u0_dsm_uck_full;

reg u1_dsdm_uck_full, u1_dsdm_uck_drain;
wire u1_dsdm_uck_ck = u1_dsdm_uck_full ? (dout_dma_mode ? dsmdm_dout_dma_ack : u1_dsdm_uck_drain) : u1_dsdm_uck;
always@(negedge rstn or posedge u1_dsdm_uck_ck) begin
	if(!rstn) u1_dsdm_uck_full <= 1'b0;
	else u1_dsdm_uck_full <= ~u1_dsdm_uck_full;
end
assign dsmdm_dout_dma_req = dout_dma_mode && u1_dsdm_uck_full;

wire sel_ctrl	= sel && (addr == 32'h00000000);
wire sel_div0	= sel && (addr == 32'h00000001);
wire sel_div1	= sel && (addr == 32'h00000002);
wire sel_din0	= sel && (addr == 32'h00000003);
wire sel_din1	= sel && (addr == 32'h00000004);
wire sel_dout0	= sel && (addr == 32'h00000005);
wire sel_dout1	= sel && (addr == 32'h00000006);
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		sel_cic <= 1'b0;
		din_dma_mode <= 1'b0; dout_dma_mode <= 1'b0;
		u0_dsck_enable <= 1'b0; u1_dsck_enable <= 1'b0;
		u0_dsck_div <= 32'h00000000; u1_dsck_div <= 32'h00000000;
		u0_dsm_uck_drain <= 1'b0;
		u1_dsdm_uck_drain <= 1'b0;
		u0_dsm_signed_data <= 1'b1; u1_dsm_signed_data <= 1'b1;
		u0_dsm_din <= 32'h00000000; u1_dsm_din <= 32'h00000000;
		u0_dsm_enable <= 1'b0; u1_dsm_enable <= 1'b0;
		u0_dsm_ock_edge <= 1'b0; u1_dsm_ock_edge <= 1'b0;
		u0_dsm_uck_edge <= 1'b0; u1_dsm_uck_edge <= 1'b0;
		u0_dsdm_signed_data <= 1'b1; u1_dsdm_signed_data <= 1'b1;
		u0_dsdm_enable <= 1'b0; u1_dsdm_enable <= 1'b0;
		u0_dsdm_ock_edge <= 1'b0; u1_dsdm_ock_edge <= 1'b0;
		u0_dsdm_uck_edge <= 1'b0; u1_dsdm_uck_edge <= 1'b0;
	end
	else if(we) begin
		if(sel_ctrl) 
			{
			sel_cic,
			din_dma_mode,dout_dma_mode,
			u0_dsck_enable,u1_dsck_enable,
			u0_dsm_uck_drain,
			u1_dsdm_uck_drain,
			u0_dsm_signed_data,u1_dsm_signed_data,
			u0_dsm_enable,u1_dsm_enable,
			u0_dsm_ock_edge,u1_dsm_ock_edge,
			u0_dsm_uck_edge,u1_dsm_uck_edge,
			u0_dsdm_signed_data,u1_dsdm_signed_data,
			u0_dsdm_enable,u1_dsdm_enable,
			u0_dsdm_ock_edge,u1_dsdm_ock_edge,
			u0_dsdm_uck_edge,u1_dsdm_uck_edge
			} <= wdata[22:0];
		else begin
			u0_dsm_uck_drain <= 1'b0;
			u1_dsdm_uck_drain <= 1'b0;
			if(sel_div0) u0_dsck_div <= wdata;
			else if(sel_div1) u1_dsck_div <= wdata;
			else if(sel_din0) u0_dsm_din <= wdata;
			else if(sel_din1) u1_dsm_din <= wdata;
		end
	end
	else begin
		u0_dsm_uck_drain <= 1'b0;
		u1_dsdm_uck_drain <= 1'b0;
	end
end

assign rdata = 
	sel_ctrl ? {9'd0,
				sel_cic,
				din_dma_mode,dout_dma_mode,
				u0_dsck_enable,u1_dsck_enable,
				u0_dsm_uck_full,
				u1_dsdm_uck_full,
				u0_dsm_signed_data,u1_dsm_signed_data,
				u0_dsm_enable,u1_dsm_enable,
				u0_dsm_ock_edge,u1_dsm_ock_edge,
				u0_dsm_uck_edge,u1_dsm_uck_edge,
				u0_dsdm_signed_data,u1_dsdm_signed_data,
				u0_dsdm_enable,u1_dsdm_enable,
				u0_dsdm_ock_edge,u1_dsdm_ock_edge,
				u0_dsdm_uck_edge,u1_dsdm_uck_edge
				} : 
	sel_div0 ? u0_dsck_div : 
	sel_div1 ? u1_dsck_div : 
	sel_din0 ? u0_dsm_din : 
	sel_din1 ? u1_dsm_din : 
	sel_dout0 ? (sel_cic ? u0_cic_dout : u0_dsdm_dout) : 
	sel_dout1 ? (sel_cic ? u1_cic_dout : u1_dsdm_dout) : 
	32'h00000000;

endmodule
