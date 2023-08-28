module pdm (
	output sdo, 
	input signed_data, 
	input [31:0] din, 
	input ock, uck, 
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
	else if(uck_full) begin
		undersampled_din <= unsigned_din;
		uck_drain <= 1'b1;
	end
	else uck_drain <= 1'b0;
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
	else if(ock_full) begin
		sigma <= sigma + (~undersampled_din + 32'h00000001) + delta;
		ock_drain <= 1'b1;
	end
	else ock_drain <= 1'b0;
end
assign sdo = undersampled_din > sigma;

endmodule


module pddm (
	input sdi, 
	input signed_data, 
	output [31:0] dout, 
	input ock, uck, 
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
	if(!rstn) sigma <= 32'h80000000;
	else if(ock_full) sigma <= sigma + delta;
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
	else if(uck_full) begin
		undersampled_sigma <= sigma;
		deriv <= sigma - undersampled_sigma + 32'h80000000;
		uck_drain <= 1'b1;
	end
	else uck_drain <= 1'b0;
end
assign dout = signed_data ? 32'h80000000 + deriv : deriv;

endmodule
