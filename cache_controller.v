module cache_management (
input wire clk,
input wire rst,
input wire [11:0] cpu_addr,
input wire cpu_read,
input wire cpu_write,
output wire [2:0] index,
output wire [1:0] offset,
input wire memready,
output reg memread,
output reg memwrite,
output wire cpu_stall,
output wire refill_en,
output wire update_en,
output wire [11:0] mem_addr);


wire [6:0] tag;
assign index = cpu_addr [4:2];
assign offset = cpu_addr[1:0];
assign tag = cpu_addr[11:5];
assign mem_addr = (memwrite) ? cpu_addr:{tag, index, 2'b00};

reg [6:0] tag_array [7:0];
reg valid_array [7:0];
wire is_hit = (tag_array[index] == tag) && (valid_array[index]);



localparam IDLE = 2'b00;
localparam WAIT_MEM_READ = 2'b01;
localparam WAIT_MEM_WRITE = 2'b10;
localparam REFILL = 2'b11;


reg [1:0] state;
reg [1:0] nextstate;
always @(*) begin
 nextstate = state;
 case (state)
  IDLE: begin
   if (cpu_read && !is_hit) 
    nextstate = WAIT_MEM_READ;
   else if (cpu_write)
     nextstate = WAIT_MEM_WRITE;
  end
  
  WAIT_MEM_READ: begin
   if (memready)
    nextstate = REFILL;
  end
  
  REFILL: begin
   nextstate = IDLE;
  end
  
  WAIT_MEM_WRITE: begin
  if (memready)
   nextstate = IDLE;
  end
 endcase
end

always @(posedge clk or posedge rst) begin
 if (rst)
 state <= IDLE;
 else
 state <= nextstate;
end

always @(posedge clk or posedge rst) begin
integer i;
 if(rst) begin
  for(i = 0; i < 8; i=i+1) begin
  valid_array[i] = 0;
  end
 end else if (nextstate == REFILL) begin
 tag_array[index] = tag;
 valid_array[index] = 1;
 end
end


always @(*) begin
 memread = (nextstate == WAIT_MEM_READ);
 memwrite = (nextstate == WAIT_MEM_WRITE);
end
assign refill_en = (state == REFILL);
assign update_en = (state == IDLE) && (cpu_write) && (is_hit); 
assign cpu_stall = (state != IDLE)  (memwrite);

endmodule
