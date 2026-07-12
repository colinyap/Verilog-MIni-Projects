module cache_array (
output reg [7:0] rdata_out,
input [7:0] wdata_in,
input wire refill_en,
input wire update_en,
input wire clk,
input wire [31:0] block_in,
input wire [2:0] index,
input wire  [1:0] offset

);
reg [7:0] data_array [7:0][3:0];

always @(posedge clk) begin
 if(refill_en) begin
  data_array[index][0] <= block_in[7:0];
  data_array[index][1] <= block_in[15:8];
  data_array[index][2] <= block_in[23:16];
  data_array[index][3] <= block_in[31:24];
 end else if (update_en) begin
  data_array[index][offset] <= wdata_in;
  end
end

always@(*) begin
 rdata_out = data_array[index][offset];
end
endmodule
