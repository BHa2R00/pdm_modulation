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
wire [31:0] delt = sdo ? 32'h00000001 : 32'hffffffff;
always @(negedge rstn or posedge clk) begin
	if(!rstn) inte <= 32'h7fffffff;
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
	if(!rstn) dout <= 32'h7fffffff;
	else if(ock_01) dout <= dout + (sdi ? 32'h00000001 : 32'hffffffff);
end

endmodule
