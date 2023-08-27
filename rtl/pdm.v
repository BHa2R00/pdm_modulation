module pdm_modulator (
	output sdo, 
	input signed_data, 
	input [31:0] din, 
	input ock, 
	input rstn, clk
);

wire [31:0] din_1 = signed_data ? 32'h80000000 + din : din;

reg ock_d, ock_dd;
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		ock_d <= 1'b0;
		ock_dd <= 1'b0;
	end
	else begin
		ock_d <= ock;
		ock_dd <= ock_d;
	end
end
wire ock_01 = ~ock_dd & ock_d;

reg [31:0] sigma;
wire [31:0] delta = sdo ? 
	((sigma == 32'hffffffff) ? 32'h80000000 : 32'h00000001) : 
	((sigma == 32'h00000000) ? 32'h80000000 : 32'hffffffff);
always @(negedge rstn or posedge clk) begin
	if(!rstn) sigma <= 32'h80000000;
	else if(ock_01) sigma <= sigma + (~din_1 + 32'h00000001) + delta;
end
assign sdo = din_1 > sigma;

endmodule


module pdm_demodulator (
	input sdi, 
	input signed_data, enable_diff, 
	output [31:0] dout, 
	input ock, 
	input rstn, clk
);

reg ock_d, ock_dd;
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		ock_d <= 1'b0;
		ock_dd <= 1'b0;
	end
	else begin
		ock_d <= ock;
		ock_dd <= ock_d;
	end
end
wire ock_01 = ~ock_dd & ock_d;

reg [31:0] dout_1, dout_1_d;
wire [31:0] delta = sdi ? 
	((dout_1 == 32'hffffffff) ? 32'h80000000 : 32'h00000001) : 
	((dout_1 == 32'h00000000) ? 32'h80000000 : 32'hffffffff);
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		dout_1 <= 32'h80000000;
		dout_1_d <= 32'h80000000;
	end
	else if(ock_01) begin
		dout_1 <= dout_1 + delta;
		dout_1_d <= dout_1;
	end
end
wire [31:0] dout_2 = dout_1 - dout_1_d;
assign dout = enable_diff ? (signed_data ? 32'h80000000 + dout_2 : dout_2) : dout_1;

endmodule


module boxcar (
	input [31:0] din, 
	output [31:0] dout, 
	input rstn, clk 
);

reg [31:0] d1,d2,d3,d4;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		d1 <= 32'h80000000;
		d2 <= 32'h80000000;
		d3 <= 32'h80000000;
		d4 <= 32'h80000000;
	end
	else begin
		d1 <= din;
		d2 <= d1;
		d3 <= d2;
		d4 <= d3;
	end
end
assign dout = ((d1 >> 2) + (d2 >> 2) + (d3 >> 2) + (d4 >> 2)) + 32'h80000000;

endmodule


module audio_pdm_modulator (
	input auto_dc_offset, 
	input [5:0] scale, 
	output sdo, 
	input [31:0] din_l, din_r, 
	input ock, lrck, 
	input rstn, clk
);

reg ock_d, ock_dd;
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		ock_d <= 1'b0;
		ock_dd <= 1'b0;
	end
	else begin
		ock_d <= ock;
		ock_dd <= ock_d;
	end
end
wire ock_01 = ~ock_dd & ock_d;
wire ock_10 = ock_dd & ~ock_d;

wire [31:0] din_l_ave, din_r_ave;
boxcar u_boxcar_l (.din(din_l),.dout(din_l_ave),.rstn(rstn),.clk(~lrck));
boxcar u_boxcar_r (.din(din_r),.dout(din_r_ave),.rstn(rstn),.clk(lrck));
wire [31:0] align_l = ~din_l_ave + 32'd1;
wire [31:0] align_r = ~din_r_ave + 32'd1;

wire [31:0] din_l_1 = auto_dc_offset ? din_l + align_l : din_l;
wire [31:0] din_l_2 = {din_l_1[31],(scale[5] ? din_l_1[30:0]>>scale[4:0] : din_l_1[30:0]<<scale[4:0])};
wire [31:0] din_r_1 = auto_dc_offset ? din_r + align_r : din_r;
wire [31:0] din_r_2 = {din_r_1[31],(scale[5] ? din_r_1[30:0]>>scale[4:0] : din_r_1[30:0]<<scale[4:0])};

reg [31:0] sigma_l, sigma_r;
wire [31:0] delta = sdo ? 
	(((ock_dd ? sigma_r : sigma_l) == 32'hffffffff) ? 32'h80000000 : 32'h00000001) : 
	(((ock_dd ? sigma_r : sigma_l) == 32'h00000000) ? 32'h80000000 : 32'hffffffff);
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		sigma_l <= 32'h80000000;
		sigma_r <= 32'h80000000;
	end
	else if(ock_01) sigma_l <= sigma_l + (~din_l_2 + 32'h00000001) + delta;
	else if(ock_10) sigma_r <= sigma_r + (~din_r_2 + 32'h00000001) + delta;
end
assign sdo = (ock_dd ? din_r : din_l) > (ock_dd ? sigma_r : sigma_l);

endmodule


module audio_pdm_demodulator (
	input auto_dc_offset, 
	input [5:0] scale, 
	input sdi, 
	output [31:0] dout_l, dout_r, 
	input ock, lrck, 
	input rstn, clk
);

reg ock_d, ock_dd;
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		ock_d <= 1'b0;
		ock_dd <= 1'b0;
	end
	else begin
		ock_d <= ock;
		ock_dd <= ock_d;
	end
end
wire ock_01 = ~ock_dd & ock_d;
wire ock_10 = ock_dd & ~ock_d;

reg [31:0] dout_l_1, dout_r_1;
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		dout_l_1 <= 32'h80000000;
		dout_r_1 <= 32'h80000000;
	end
	else if(ock_01) 
		dout_l_1 <= dout_l_1 + (sdi ? 
			((dout_l_1 == 32'hffffffff) ? 32'h80000000 : 32'h00000001) : 
			((dout_l_1 == 32'h00000000) ? 32'h80000000 : 32'hffffffff));
	else if(ock_10) 
		dout_r_1 <= dout_r_1 + (sdi ? 
			((dout_r_1 == 32'hffffffff) ? 32'h80000000 : 32'h00000001) : 
			((dout_r_1 == 32'h00000000) ? 32'h80000000 : 32'hffffffff));
end
wire [31:0] dout_l_ave, dout_r_ave;
boxcar u_boxcar_l (.din(dout_l_1),.dout(dout_l_ave),.rstn(rstn),.clk(lrck));
boxcar u_boxcar_r (.din(dout_r_1),.dout(dout_r_ave),.rstn(rstn),.clk(~lrck));
wire [31:0] align_l = ~dout_l_ave + 32'd1;
wire [31:0] align_r = ~dout_r_ave + 32'd1;
wire [31:0] dout_l_2 = auto_dc_offset ? dout_l_1 + align_l : dout_l_1;
assign dout_l = {dout_l_2[31],(scale[5] ? dout_l_2[30:0]>>scale[4:0] : dout_l_2[30:0]<<scale[4:0])};
wire [31:0] dout_r_2 = auto_dc_offset ? dout_r_1 + align_r : dout_r_1;
assign dout_r = {dout_r_2[31],(scale[5] ? dout_r_2[30:0]>>scale[4:0] : dout_r_2[30:0]<<scale[4:0])};

endmodule


`define ir_carrier_offset	32'h80000000


module ir_pdm_modulator(
	output sdo, 
	input [4:0] din, 
	input ock, bck, 
	input load, 
	output done, 
	input rstn, clk
);

reg bck_d, bck_dd;
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		bck_d <= 1'b0;
		bck_dd <= 1'b0;
	end
	else begin
		bck_d <= bck;
		bck_dd <= bck_d;
	end
end
wire bck_01 = ~bck_dd & bck_d;

reg [4:0] sigma;
assign done = sigma == 5'h10;
wire [4:0] delta = 
	(sigma < 5'h10) ? 5'h01 : 
	(sigma > 5'h10) ? 5'h1f : 
	5'h00;
always@(negedge rstn or posedge clk) begin
	if(!rstn) sigma <= 5'h10;
	else begin
		if(load) sigma <= din;
		else if(bck_01) sigma <= sigma + delta;
	end
end
wire [31:0] sigma_bin = (delta == 5'h1f) ? `ir_carrier_offset : 32'h00000000;
pdm_modulator u_pdm_modulator(
	.sdo(sdo), 
	.signed_data(1'b0), 
	.din(sigma_bin), 
	.ock(ock), 
	.rstn(rstn), .clk(clk)
);

endmodule


module ir_pdm_demodulator(
	input sdi, 
	output reg [4:0] dout, 
	input ock, bck, 
	input load, 
	output reg done, 
	input rstn, clk
);

reg bck_d, bck_dd;
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		bck_d <= 1'b0;
		bck_dd <= 1'b0;
	end
	else begin
		bck_d <= bck;
		bck_dd <= bck_d;
	end
end
wire bck_01 = ~bck_dd & bck_d;

wire [31:0] sigma;
pdm_demodulator u_pdm_demodulator(
	.sdi(sdi), 
	.signed_data(1'b0), .enable_diff(1'b0), 
	.dout(sigma), 
	.ock(ock), 
	.rstn(rstn), .clk(clk)
);
reg [31:0] sigma_d, sigma_10;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		sigma_d <= `ir_carrier_offset;
		sigma_10 <= 32'h00000000;
	end
	else if(bck_01) begin
		sigma_d <= sigma;
		sigma_10 <= sigma_d - sigma;
	end
end
wire sigma_sign = ((sigma_10 < `ir_carrier_offset) & (sigma_10 > 32'h00000003)) ? 1'b1 : 1'b0;

reg [4:0] ir_sigma;
wire [4:0] delta = sigma_sign ? 
	(((ir_sigma == 5'h00) | done) ? 5'h00 : 5'h1f) :
	(((ir_sigma == 5'h1f) | done) ? 5'h00 : 5'h01); 
wire delta_sign = delta[4];
reg delta_sign_d;
always @(negedge rstn or posedge clk) begin
	if(!rstn) delta_sign_d <= 1'b0;
	else if(bck_01) delta_sign_d <= delta_sign;
end
wire delta_sign_xor = delta_sign ^ delta_sign_d;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		done <= 1'b1;
		ir_sigma <= 5'h10;
		dout <= 5'h10;
	end
	else if(load) begin
		done <= 1'b0;
		ir_sigma <= 5'h10;
	end
	else if(bck_01) begin
		if(delta_sign_xor) begin
			done <= 1'b1;
			dout <= ir_sigma;
		end
		else ir_sigma <= ir_sigma + delta;
	end
end

endmodule
