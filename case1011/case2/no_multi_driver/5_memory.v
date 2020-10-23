`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/10/26 22:44:39
// Design Name: 
// Module Name: shift_reg
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


module shift_reg(sel,q,d,CLK,sw);
	input CLK,sw;
	input [2:0]sel;
	input [7:0]d;
	output reg [7:0]q;
	always @(posedge CLK)
	begin
		case(sel)
			0:q<=0;
			1:q<=d;
			2:q<={1'b0,q[7:1]};
			3:q<={q[6:0],1'b0};
			4:q<={q[7],q[7:1]};
			5:q<={sw,q[7:1]};
			6:q<={q[0],q[7:1]};
			7:q<={q[6:0],q[7]};
		endcase
	end
endmodule

module RAND(cclk, clk, clr, seg, sel);
    input clk;
    input cclk;
    input clr;
    output reg[6:0] seg;
    output reg[7:0] sel;

    reg [3:0]out1;
    reg [3:0]out2;

    reg [6:0]seg1;
    reg [6:0]seg2;

    reg flash;

integer clkcount2;
always @ (posedge clk) begin
    if(clkcount2==400000) begin
    	clkcount2<=0;
    	flash=~flash;
    end
    else
    	clkcount2<=clkcount2 + 1;
end

always @ (posedge cclk) begin 
    if(clr==1'b1) begin 
        out1<=4'b0000;
        out2<=4'b0000;
    end
    else if(out1==4'b0000 && out2==4'b0000) begin
        out2<=4'b1000;
    end
    else begin 
    	out2<={out2[0]^out1[3]^out1[2]^out1[0],out2[3:1]};
    	out1<={out2[0],out1[3:1]};
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
        4'd10:seg1 = 7'b0001000;         
        4'd11:seg1 = 7'b0000011;             
        4'd12:seg1 = 7'b1000110;   
        4'd13:seg1 = 7'b0100001;        
        4'd14:seg1 = 7'b0000110;        
        4'd15:seg1 = 7'b0001110;                

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
        4'd10:seg2 = 7'b0001000;         
        4'd11:seg2 = 7'b0000011;             
        4'd12:seg2 = 7'b1000110;   
        4'd13:seg2 = 7'b0100001;        
        4'd14:seg2 = 7'b0000110;        
        4'd15:seg2 = 7'b0001110;                
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
endmodule


