module UART_Transmitter (
input clk,
input rst,
input [7:0] tx_data,
input tx_data_valid,
output tx_data_ready,
output reg tx_pin
);
localparam CLOCK = 27; //MHZ
localparam BAUD = 115200;
localparam CYCLE = (27*1000000)/115200;
localparam IDLE = 0;
localparam START = 1;
localparam DATA = 2;
localparam STOP = 3;
reg bit_counter;
reg [3:0] data_counter;
reg [3:0] state, nextstate;
reg [$clog2(CYCLE)-1:0] counter;
reg [7:0] bit_data;
always @(*) begin
 tx_pin =1;
 nextstate = state;
 case (state)
  IDLE: begin 
   tx_pin = 1;
   if(tx_data_valid == 1)
    nextstate = START;
   else
    nextstate = IDLE;
  end
  START: begin
  tx_pin = 0;
  if(bit_counter == 1) begin
   nextstate = DATA;
   end else
    nextstate = START;
  end
  DATA: begin
   tx_pin = bit_data[data_counter];
   if(bit_counter == 1 && data_counter == 7) begin
   nextstate = STOP;
   end else begin
   nextstate = DATA;
   end
  end
  STOP: begin
   tx_pin = 1;
   if(bit_counter == 1)
    nextstate = IDLE;

  end
 endcase
end
  
always @(posedge clk or posedge rst) begin
 state <= nextstate;
 if(tx_data_valid && state == IDLE) begin
  
 bit_data <= tx_data;
  
 end
 if  (rst) begin
  state <= IDLE;
  data_counter <= 0;
  bit_data <= 0;
 end else if(state == DATA) begin
  if (bit_counter == 1) begin
   data_counter <= data_counter + 1;
  end
 end else if (state == IDLE) begin
  data_counter <= 0;
  end

end
  
 
 
assign tx_data_ready = (state == IDLE);
always @(posedge clk or posedge rst) begin
 if (rst || (state == IDLE && nextstate != IDLE)) begin
  counter <= 0;
  bit_counter <= 0;
  end else if (counter == (CYCLE-1)) begin
   counter <= 0;
   bit_counter <=1;
   end else begin
    counter <= counter+1;
    bit_counter <= 0;
    end
end
endmodule
