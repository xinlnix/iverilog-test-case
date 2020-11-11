

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/11/13 16:54:14
// Design Name: 
// Module Name: bomb
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


module bomb(clk, clrn, seg, sel, led, ps2_clk, ps2_data, data);
    input clk;
    input clrn;
    output reg[6:0] seg;
    output reg[7:0] sel;
    reg [3:0]out1;
    reg [3:0]out2;
    reg [6:0]seg1;
    reg [6:0]seg2;
    reg flash;
    reg clk1;
    reg clk2;
    integer clkcount1, clkcount2;
    
      reg [3:0] state;
      parameter S0 = 0, S1 = 1,S2 = 2,S3 = 3,S4 = 4;
      output reg [3:0]led;
      input ps2_clk,ps2_data;
      output [7:0] data;
      reg [7:0] data; 
      //output ready;
      reg ready;
      //output
      reg overflow;
      reg [3:0] errcount;
      reg [3:0] count;              
      reg [9:0] buffer;
      reg [7:0] fifo [7:0];
      reg [2:0] w_ptr,r_ptr; 
      reg [2:0] ps2_clk_sync;
      always @ (posedge clk)
             begin
             ps2_clk_sync <= {ps2_clk_sync[1:0], ps2_clk};
             end
      wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
         
always @ (posedge clk) begin
      if(clkcount1==50000000) begin 
          clk1<=~clk1;
          clkcount1<=0;
      end
      else
          clkcount1<=clkcount1 + 1;
      if(clkcount2==4000) begin
      	clk2<=~clk2;
      	clkcount2<=0;
      	flash=~flash;
      end
      else
      	clkcount2<=clkcount2 + 1;
      out1 <= 4'h1;
end

always @ (posedge clk1) begin 
    if(clrn == 1'b0) begin 
        out1 <= 4'h0;
        out2 <= 4'h3;
    end
    else if(led == 4'b1111) begin
        out1 <= 4'ha;
        out2 <= 4'ha;
    end
    else if (out1 == 4'hb && out2 == 4'hb) begin
                       out1 <= 4'hb;
                       out2 <= 4'hb;
                end
    else if ((out1 == 1'b1 && out2 == 1'b0) || (errcount == 4'ha)) begin
            out1 = 4'hb;
            out2 = 4'hb;
        end
    else if (out1 == 4'd0) begin
            out1 = 9;
            out2 = out2 - 1;
        end
    else begin
            out1 = out1 - 1;
        end
    case(out1)
        4'd0:seg1 = 7'b1000000;
        4'd1:seg1 = 7'b1111001;
        4'd2:seg1 = 7'b0100100; 
        4'd3:seg1 = 7'b0110000; 
        4'd4:seg1 = 7'b0011001;
        4'd5:seg1 = 7'b0010010;
        4'd6:seg1 = 7'b0000010;
        4'd7:seg1 = 7'b1111000;
        4'd8:seg1 = 7'b0000000;
        4'd9:seg1 = 7'b0010000;
        4'ha:seg1 = 7'b0100111;
        4'hb:seg1 = 7'b0010000;
        default:seg1 = 7'b1111111;
    endcase
    case(out2)
        4'd0:seg2 = 7'b1000000; 
        4'd1:seg2 = 7'b1111001;
        4'd2:seg2 = 7'b0100100; 
        4'd3:seg2 = 7'b0110000; 
        4'd4:seg2 = 7'b0011001;
        4'd5:seg2 = 7'b0010010;
        4'd6:seg2 = 7'b0000010;
        4'd7:seg2 = 7'b1111000;
        4'd8:seg2 = 7'b0000000;
        4'd9:seg2 = 7'b0010000;
        4'ha:seg2 = 7'b0101011;
        4'hb:seg2 = 7'b0010000;
        default:seg2 = 7'b1111111;
    endcase
end

always @ (flash)
begin
	case(flash)
	    1'b0:
	    begin
	    	seg=seg1;
	    	sel<=8'b11111110;
	    end
	    1'b1:
	    begin
	    	seg=seg2;
	    	sel<=8'b11111101;
	    end
	endcase
end

always @ (posedge clk)
      begin
      if (clrn == 0) 
         begin
         count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; errcount <= 0;
         end
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
                  w_ptr <= w_ptr + 3'b1;
                  ready <= 1'b1;
                  overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
                  end
              count <= 0;
              end
              else 
                 begin
                 buffer[count] <= ps2_data; 
                 count <= count + 3'b1;
                end      
            end
      if (ready)
         begin 
         data = fifo[r_ptr];
         r_ptr <= r_ptr + 3'd1;
         ready <= 1'b0;
         end
         if (clrn == 0) begin
             state <= S0;
             led  = 4'b0000;
         end
         else begin
             if (data == 8'hf0)
                errcount = errcount + 1;
             case (state)
                      S0: begin led = 4'b0000; if (data == 8'h2c) begin errcount = errcount - 1; led = 4'b0001; state <= S1; end end
                      S1: begin led = 4'b0001; if (data == 8'h35) begin errcount = errcount - 1; led = 4'b0011; state <= S2; end end
                      S2: begin led = 4'b0011; if (data == 8'h3a) begin errcount = errcount - 1; led = 4'b0111; state <= S3; end end
                      S3: begin led = 4'b0111; if (data == 8'h4b) begin errcount = errcount - 1; led = 4'b1111; state <= S4; end end
                      S4: begin led = 4'b1111; state <= S4; end
             		  default state <= state;
             endcase
        end
    end
endmodule


