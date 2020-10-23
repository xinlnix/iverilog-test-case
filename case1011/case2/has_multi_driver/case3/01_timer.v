`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/04/27 14:33:07
// Design Name: 
// Module Name: timer
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


module timer(clk,pause,clr,sel_seg,seg);
   input clk;//系统时钟
   input pause;//暂停
   input clr;//清零
   output [7:0] sel_seg;
   output [6:0] seg;
wire clk_10ms;
wire [23:0]this_time;//时间

frequency_divider_10ms u1(
   .clk(clk),
   .clk_10ms(clk_10ms)  );
   
timer_func u2(
   .clk_10ms(clk_10ms),
   .pause(pause),
   .clr(clr),
   .this_time(this_time)   );
   
seven_segment u3(
   .clk(clk),
   .this_time(this_time),
   .sel_seg(sel_seg),
   .seg(seg)   );
endmodule

module frequency_divider_10ms(
   input clk,//开发平台的内部时钟，周期10ns
   output reg clk_10ms   //分频后的时钟信号，周期1s
   );
reg [20:0]count=21'd0;
reg temp2=1'b0;
always @ (posedge clk)
if(count==21'd500000)//F==?Hz
  begin
    temp2=~temp2;
    clk_10ms<=temp2;
    count<=21'd0;
  end  
else
  count<=count+1'b1;

endmodule

module timer_func(clk_10ms,pause,clr,this_time);
   input clk_10ms;//时钟周期为1s
   input pause;//暂停
   input clr;//清零
   output reg [23:0]this_time;//时间 
always @(posedge clr)
begin
   this_time[23:0]= 24'b000000000000000000000000;
end
always @(posedge clk_10ms)
begin
   if(clr)
      begin  this_time<=24'h000000;  end
   //clr=0
   else
      begin 
      if(!pause)//jinwei
      begin
         if(this_time[3:0]==4'b1001)//10
         begin
                   if(this_time[7:4]==4'b0101)//6
                   begin
                            if(this_time[11:8]==4'b1001)//10
                            begin
                                           if(this_time[15:12]==4'b0101)//6
                                           begin
                                                   if(this_time[19:16]==4'b1001)//10
                                                   begin
                                                          if(this_time[23:20]==4'b0010&&this_time[19:16]==4'b0100)//24
                                                          begin
                                                                this_time[23:20]<=4'b0000;
                                                          end
                                                          else
                                                          this_time[23:20]<=this_time[23:20]+1'b1;
                                                          this_time[19:16]<=4'b0000;
                                                   end
                                                   else
                                                   this_time[19:16]<=this_time[19:16]+1'b1;
                                                   this_time[15:12]<=4'b0000;
                                           end
                                           else
                                           this_time[15:12]<=this_time[15:12]+1'b1;
                                           this_time[11:8]<=4'b0000;
                            end
                            else
                            this_time[11:8]<=this_time[11:8]+1'b1;
                            this_time[7:4]<=4'b0000;
                   end
                   else
                   this_time[7:4]<=this_time[7:4]+1'b1;
                   this_time[3:0]<=4'b0000;
         end  
         else
         this_time[3:0]<=this_time[3:0]+1'b1;
      end
      end
end
endmodule

module seven_segment(clk,this_time,sel_seg,seg);
   input clk;
   input [23:0]this_time;
   output reg [7:0] sel_seg;
   output reg [6:0] seg;

reg [15:0]count=16'h0000;
reg [5:0]temp=6'b111110;
always @ (posedge clk)
begin
     if(count==16'hffff)
     begin
       temp<={temp[0],temp[5:1]};//循环右移
       sel_seg<=8'b11000000+temp;
       count<=16'h0000;
     end
     else
       count<=count+1'b1;
end

always @(this_time or sel_seg)
begin
  if(sel_seg==8'b11111110)
   begin
    case(this_time[3:0])
    4'b0000: seg=7'b1000000;  
    4'b0001: seg=7'b1111001;
    4'b0010: seg=7'b0100100; 
    4'b0011: seg=7'b0110000; 
    4'b0100: seg=7'b0011001; 
    4'b0101: seg=7'b0010010; 
    4'b0110: seg=7'b0000010;
    4'b0111: seg=7'b1111000;
    4'b1000: seg=7'b0000000;
    4'b1001: seg=7'b0010000;
    default: seg=7'b1111111;
    endcase
   end
  else if(sel_seg==8'b11111101)
   begin
    case(this_time[7:4])
    4'b0000: seg=7'b1000000;  
    4'b0001: seg=7'b1111001;
    4'b0010: seg=7'b0100100; 
    4'b0011: seg=7'b0110000; 
    4'b0100: seg=7'b0011001; 
    4'b0101: seg=7'b0010010; 
    4'b0110: seg=7'b0000010;
    4'b0111: seg=7'b1111000;
    4'b1000: seg=7'b0000000;
    4'b1001: seg=7'b0010000;
    default: seg=7'b1111111;
    endcase
   end
  else if(sel_seg==8'b11111011)
    begin
     case(this_time[11:8])
     4'b0000: seg=7'b1000000;  
     4'b0001: seg=7'b1111001;
     4'b0010: seg=7'b0100100; 
     4'b0011: seg=7'b0110000; 
     4'b0100: seg=7'b0011001; 
     4'b0101: seg=7'b0010010; 
     4'b0110: seg=7'b0000010;
     4'b0111: seg=7'b1111000;
     4'b1000: seg=7'b0000000;
     4'b1001: seg=7'b0010000;
     default: seg=7'b1111111;
     endcase
    end 
  else if(sel_seg==8'b11110111)
     begin
      case(this_time[15:12])
      4'b0000: seg=7'b1000000;  
      4'b0001: seg=7'b1111001;
      4'b0010: seg=7'b0100100; 
      4'b0011: seg=7'b0110000; 
      4'b0100: seg=7'b0011001; 
      4'b0101: seg=7'b0010010; 
      4'b0110: seg=7'b0000010;
      4'b0111: seg=7'b1111000;
      4'b1000: seg=7'b0000000;
      4'b1001: seg=7'b0010000;
      default: seg=7'b1111111;
      endcase
     end
  else if(sel_seg==8'b11101111)
      begin
       case(this_time[19:16])
       4'b0000: seg=7'b1000000;  
       4'b0001: seg=7'b1111001;
       4'b0010: seg=7'b0100100; 
       4'b0011: seg=7'b0110000; 
       4'b0100: seg=7'b0011001; 
       4'b0101: seg=7'b0010010; 
       4'b0110: seg=7'b0000010;
       4'b0111: seg=7'b1111000;
       4'b1000: seg=7'b0000000;
       4'b1001: seg=7'b0010000;
       default: seg=7'b1111111;
       endcase
      end
  else//sel_seg==8'b11011111
       begin
        case(this_time[23:20])
        4'b0000: seg=7'b1000000;  
        4'b0001: seg=7'b1111001;
        4'b0010: seg=7'b0100100; 
        4'b0011: seg=7'b0110000; 
        4'b0100: seg=7'b0011001; 
        4'b0101: seg=7'b0010010; 
        4'b0110: seg=7'b0000010;
        4'b0111: seg=7'b1111000;
        4'b1000: seg=7'b0000000;
        4'b1001: seg=7'b0010000;
        default: seg=7'b1111111;
        endcase
       end
end  
endmodule
