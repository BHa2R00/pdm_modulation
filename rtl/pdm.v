module pdm_modulator (
	output sdo, 
	input [31:0] din, 
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

reg [31:0] sigma;
wire [31:0] delta = sdo ? 
	((sigma == 32'hffffffff) ? 32'h80000000 : 32'h00000001) : 
	((sigma == 32'h00000000) ? 32'h80000000 : 32'hffffffff);
always @(negedge rstn or posedge clk) begin
	if(!rstn) sigma <= 32'h80000000;
	else if(ock_01) sigma <= sigma + (~din + 32'h00000001) + delta;
end
assign sdo = din > sigma;

endmodule


module pdm_demodulator (
	input sdi, 
	output reg [31:0] dout, 
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

wire [31:0] delta = sdi ? 
	((dout == 32'hffffffff) ? 32'h80000000 : 32'h00000001) : 
	((dout == 32'h00000000) ? 32'h80000000 : 32'hffffffff);
always @(negedge rstn or posedge clk) begin
	if(!rstn) dout <= 32'h80000000;
	else if(ock_01) dout <= dout + delta;
end

endmodule


module audio_pdm_modulator (
	output sdo, 
	input [31:0] din_l, din_r, 
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
wire ock_10 = ock_dd & ~ock_d;

reg [31:0] sigma_l, sigma_r;
wire [31:0] delta = sdo ? 
	(((ock_dd ? sigma_r : sigma_l) == 32'hffffffff) ? 32'h80000000 : 32'h00000001) : 
	(((ock_dd ? sigma_r : sigma_l) == 32'h00000000) ? 32'h80000000 : 32'hffffffff);
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		sigma_l <= 32'h80000000;
		sigma_r <= 32'h80000000;
	end
	else if(ock_01) sigma_l <= sigma_l + (~din_l + 32'h00000001) + delta;
	else if(ock_10) sigma_r <= sigma_r + (~din_r + 32'h00000001) + delta;
end
assign sdo = (ock_dd ? din_r : din_l) > (ock_dd ? sigma_r : sigma_l);

endmodule


module audio_pdm_demodulator (
	input sdi, 
	output reg [31:0] dout_l, dout_r, 
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
wire ock_10 = ock_dd & ~ock_d;

always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		dout_l <= 32'h80000000;
		dout_r <= 32'h80000000;
	end
	else if(ock_01) 
		dout_l <= dout_l + (sdi ? 
			((dout_l == 32'hffffffff) ? 32'h80000000 : 32'h00000001) : 
			((dout_l == 32'h00000000) ? 32'h80000000 : 32'hffffffff));
	else if(ock_10) 
		dout_r <= dout_r + (sdi ? 
			((dout_r == 32'hffffffff) ? 32'h80000000 : 32'h00000001) : 
			((dout_r == 32'h00000000) ? 32'h80000000 : 32'hffffffff));
end

endmodule


module ir_pdm_modulator(
	output sdo, 
	input [7:0] din, 
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

reg [7:0] sigma;
assign done = sigma == 8'h80;
wire [7:0] delta = 
	(sigma < 8'h80) ? 8'h01 : 
	(sigma > 8'h80) ? 8'hff : 
	8'h00;
always@(negedge rstn or posedge clk) begin
	if(!rstn) sigma <= 8'h80;
	else begin
		if(load) sigma <= din;
		else if(bck_01) sigma <= sigma + delta;
	end
end
wire [31:0] sigma_bin = (delta == 8'hff) ? 32'h80000000 : 32'h00000000;
pdm_modulator u_pdm_modulator(
	.sdo(sdo), 
	.din(sigma_bin), 
	.ock(ock), 
	.rstn(rstn), .clk(clk)
);

endmodule


module ir_pdm_demodulator(
	input sdi, 
	output reg [7:0] dout, 
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
	.dout(sigma), 
	.ock(ock), 
	.rstn(rstn), .clk(clk)
);
reg [31:0] sigma_d, sigma_10;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		sigma_d <= 32'h80000000;
		sigma_10 <= 32'h00000000;
	end
	else if(bck_01) begin
		sigma_d <= sigma;
		sigma_10 <= sigma_d - sigma;
	end
end
wire sigma_sign = ((sigma_10 < 32'h80000000) & (sigma_10 > 32'h00000003)) ? 1'b1 : 1'b0;

reg [7:0] ir_sigma;
wire [7:0] delta = sigma_sign ? 
	(((ir_sigma == 8'h00) | done) ? 8'h00 : 8'hff) :
	(((ir_sigma == 8'hff) | done) ? 8'h00 : 8'h01); 
wire delta_sign = delta[7];
reg delta_sign_d;
always @(negedge rstn or posedge clk) begin
	if(!rstn) delta_sign_d <= 1'b0;
	else if(bck_01) delta_sign_d <= delta_sign;
end
wire delta_sign_xor = delta_sign ^ delta_sign_d;
always@(negedge rstn or posedge clk) begin
	if(!rstn) begin
		done <= 1'b1;
		ir_sigma <= 8'h80;
		dout <= 8'h80;
	end
	else if(load) begin
		done <= 1'b0;
		ir_sigma <= 8'h80;
	end
	else if(bck_01) begin
		if(delta_sign_xor) begin
			done <= 1'b1;
			dout <= ir_sigma + 8'h01;
		end
		else ir_sigma <= ir_sigma + delta;
	end
end

endmodule
