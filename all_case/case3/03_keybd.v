`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/05/18 15:03:32
// Design Name: 
// Module Name: ps2_keyboard
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ps2_keyboard(clk,clrn,ps2_clk,ps2_data,data,ready,overflow,count,an,seg,led);
input clk,clrn,ps2_clk,ps2_data;
output [7:0] data;
reg [7:0] data;
output reg [6:0] seg;
output reg [7:0] led;
reg mark;
output ready;
reg ready;
output reg overflow; 
output reg [3:0] count; 

reg [9:0] buffer; 
reg [7:0] fifo[7:0]; 
reg [2:0] w_ptr,r_ptr; 

reg [2:0] ps2_clk_sync;
output [7:0] an;
assign an=8'b11111110;
always @ (posedge clk)
begin
ps2_clk_sync <= {ps2_clk_sync[1:0],ps2_clk};
end
wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
always @ (posedge clk)
begin
if (clrn == 0) 
begin
count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; mark=1'b1; end
else
if (sampling)
begin
if (count == 4'd10)
begin
if ((buffer[0] == 0) && 
(ps2_data) && 
(^buffer[9:1])) 
begin
fifo[w_ptr] <= buffer[9:2]; 
w_ptr <= w_ptr+3'b1; ready <= 1'b1;
overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
end
count <= 0; 
end
else
begin
buffer[count] <= ps2_data; 
count <= count + 3'b1; end 
end
if ( ready ) 
begin
data = fifo[r_ptr];
r_ptr <= r_ptr + 3'd1;
ready <= 1'b0;
end
   begin 
   if(mark==1'b1)
                  begin
                      if(data==8'hF0)
                      begin
                      mark=1'b0;
                      end//end if(data==8'hF0)
   
                      if(data!=8'hF0)
                      begin
                      led=data;
                         case(data)
                         8'h70:seg=7'b1000000;//0
                         8'h69:seg=7'b1111001;//1
                         8'h72:seg=7'b0100100;//2
                         8'h7A:seg=7'b0110000;//3
                         8'h6B:seg=7'b0011001;//4
                         8'h73:seg=7'b0010010;//5
                         8'h74:seg=7'b0000010;//6
                         8'h6C:seg=7'b1111000;//7
                         8'h75:seg=7'b0000000;//8
                         8'h7D:seg=7'b0010000;//9
                         8'h1C:seg=7'b0001000;//a
                         8'h32:seg=7'b0000011;//b
                         8'h21:seg=7'b0100111;//c
                         8'h23:seg=7'b0100001;//d
                         8'h24:seg=7'b0000110;//e
                         8'h2B:seg=7'b0001110;//f
                         endcase
                      end//end  if(data!=8'hF0)
                  end//end  if(mark==1'b1)
   
                  if(mark==1'b0)
                  begin
                  mark=1'b1;
                  end//end  if(mark==1'b0)
   
        end
end
always @ (posedge clk) begin
  ready <= 1'b1;
end

endmodule

