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

reg [31:0] inte;
wire [31:0] delt = sdo ? 
	((inte == 32'hffffffff) ? 32'h00000000 : 32'h00000001) : 
	((inte == 32'h00000000) ? 32'h00000000 : 32'hffffffff);
always @(negedge rstn or posedge clk) begin
	if(!rstn) inte <= 32'h80000000;
	else if(ock_01) inte <= inte + (~din + 32'h00000001) + delt;
end
assign sdo = din > inte;

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

always @(negedge rstn or posedge clk) begin
	if(!rstn) dout <= 32'h80000000;
	else if(ock_01) 
		dout <= dout + (sdi ? 
			((dout == 32'hffffffff) ? 32'h00000000 : 32'h00000001) : 
			((dout == 32'h00000000) ? 32'h00000000 : 32'hffffffff));
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

reg [31:0] inte_l, inte_r;
wire [31:0] delt = sdo ? 
	(((ock_dd ? inte_r : inte_l) == 32'hffffffff) ? 32'h00000000 : 32'h00000001) : 
	(((ock_dd ? inte_r : inte_l) == 32'h00000000) ? 32'h00000000 : 32'hffffffff);
always @(negedge rstn or posedge clk) begin
	if(!rstn) begin
		inte_l <= 32'h80000000;
		inte_r <= 32'h80000000;
	end
	else if(ock_01) inte_l <= inte_l + (~din_l + 32'h00000001) + delt;
	else if(ock_10) inte_r <= inte_r + (~din_r + 32'h00000001) + delt;
end
assign sdo = (ock_dd ? din_r : din_l) > (ock_dd ? inte_r : inte_l);

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
			((dout_l == 32'hffffffff) ? 32'h00000000 : 32'h00000001) : 
			((dout_l == 32'h00000000) ? 32'h00000000 : 32'hffffffff));
	else if(ock_10) 
		dout_r <= dout_r + (sdi ? 
			((dout_r == 32'hffffffff) ? 32'h00000000 : 32'h00000001) : 
			((dout_r == 32'h00000000) ? 32'h00000000 : 32'hffffffff));
end

endmodule
