module MiaoBiao_Top(clk,inClr,inPause,seg,sel);
input clk,inClr,inPause;
output[6:0] seg;
output[7:0] sel;

wire clr,pause;
wire clk100Hz,clk150Hz,clk1Hz,clk1_60Hz,clk1_3600Hz,clk1_24HHz;
wire[6:0] cnt100Val,miaoCntVal,fenCntVal,shiCntVal;
wire[3:0] BCD7,BCD6,BCD5,BCD4,BCD3,BCD2,BCD1,BCD0;

debounce clr_debounce(clk100Hz,inClr,clr);
debounce Pause_debounce(clk100Hz,inPause,pause);

freqDiv  myFreq  (clk,       clk100Hz,clk150Hz);//freqDiv(clk,clk100Hz,clk150Hz);
count100 mycnt100(clk100Hz,  clr,     pause,   clk1Hz,       cnt100Val);//count100 (clk,clr,pause,clkout,cntVal);
count60  miaoCnt (clk1Hz,    clr,     pause,   clk1_60Hz,    miaoCntVal);//count60(clk,clr,pause,clkout,cntVal);
count60  fenCnt  (clk1_60Hz, clr,     pause,   clk1_3600Hz,  fenCntVal);
count24  shiCnt  (clk1_3600Hz, clr,   pause,   clk1_24HHz,  shiCntVal);

//HEX2BCD(HexVal,BCD10,BCD1);
HEX2BCD myHex2BCD_BFM (cnt100Val, BCD1,BCD0);
HEX2BCD myHex2BCD_Miao(miaoCntVal,BCD3,BCD2);
HEX2BCD myHex2BCD_Fen (fenCntVal, BCD5,BCD4);
HEX2BCD myHex2BCD_Shi (shiCntVal, BCD7,BCD6);

//module DDisplay8(clk,rst,D0,D1,D2,D3,D4,D5,D6,D7,seg,sel);
DDisplay8 MyDisp(clk150Hz,clr,BCD0,BCD1,BCD2,BCD3,BCD4,BCD5,BCD6,BCD7,seg,sel);


endmodule

module debounce(
    input wire clk,
    input wire key_in,
    output reg key_out
    );

    reg key_TempH,key_TempL;

    always @(posedge clk) 
        begin
            key_TempH<=key_in;
        end

    always @(negedge clk ) 
        begin
            key_TempL<=key_in;
        end

    always @(*) 
        begin
            if (key_TempL==key_TempH) key_out=key_TempH;
        end
endmodule


module freqDiv(clk,clk100Hz,clk150Hz);

input clk;//50MHz
output reg clk100Hz,clk150Hz;

reg[19:0] cnt100Hz,cnt150Hz;//111 1010 0001 0010 0000

always @(posedge clk)//100Hz Div
	begin
	  	cnt100Hz = cnt100Hz+1;
		if (cnt100Hz >500000/*50*/) begin cnt100Hz=0; clk100Hz=1; end
		else clk100Hz=0;
	end

always @(posedge clk)//100Hz Div
  begin
		if (cnt100Hz >300000/*50*/) begin cnt100Hz=0; clk100Hz=1; end
		else clk100Hz=0;
	end
	
always @(posedge clk)//150Hz Div
	begin
	  	cnt150Hz = cnt150Hz+1;
		if (cnt150Hz >333333/*33*/) begin cnt150Hz=0; clk150Hz=1; end
		else clk150Hz=0;
	end	

endmodule

module count24(clk,clr,pause,clkout,cntVal);
input clk,clr,pause;
output reg clkout;//
output reg[6:0] cntVal;//

always @(posedge clk)
	begin
		if (clr) cntVal =0;
		if (!pause)
			begin
				cntVal = cntVal+1;
				if (cntVal==24) 
					begin 
						cntVal =0;
						clkout =1;
					end
				else clkout =0;
			end	
	end

endmodule 

module count60(clk,clr,pause,clkout,cntVal);
input clk,clr,pause;
output reg clkout;//
output reg[6:0] cntVal;//

always @(posedge clk)
	begin
		if (clr) cntVal =0;
		if (!pause)
			begin
				cntVal = cntVal+1;
				if (cntVal==60) 
					begin 
						cntVal =0;
						clkout =1;
					end
				else clkout =0;
			end	
	end

endmodule 

module count100 (clk,clr,pause,clkout,cntVal);
input clk,clr,pause;
output reg clkout;//
output reg[6:0] cntVal;//

always @(posedge clk)
	begin
		if (clr) cntVal =0;
		if (!pause)
			begin
				cntVal = cntVal+1;
				if (cntVal==100) 
					begin 
						cntVal =0;
						clkout =1;
					end
				else clkout =0;
			end	
	end
endmodule

module HEX2BCD(HexVal,BCD10,BCD1);
input[6:0] HexVal;
output reg[3:0] BCD10,BCD1;

always @(HexVal)
	begin
		case (HexVal)
			7'd0:begin BCD10=4'd0; BCD1=4'd0; end
			7'd1:begin BCD10=4'd0; BCD1=4'd1; end
			7'd2:begin BCD10=4'd0; BCD1=4'd2; end
			7'd3:begin BCD10=4'd0; BCD1=4'd3; end
			7'd4:begin BCD10=4'd0; BCD1=4'd4; end
			7'd5:begin BCD10=4'd0; BCD1=4'd5; end
			7'd6:begin BCD10=4'd0; BCD1=4'd6; end
			7'd7:begin BCD10=4'd0; BCD1=4'd7; end
			7'd8:begin BCD10=4'd0; BCD1=4'd8; end
			7'd9:begin BCD10=4'd0; BCD1=4'd9; end
			7'd10:begin BCD10=4'd1; BCD1=4'd0; end
			7'd11:begin BCD10=4'd1; BCD1=4'd1; end
			7'd12:begin BCD10=4'd1; BCD1=4'd2; end
			7'd13:begin BCD10=4'd1; BCD1=4'd3; end
			7'd14:begin BCD10=4'd1; BCD1=4'd4; end
			7'd15:begin BCD10=4'd1; BCD1=4'd5; end
			7'd16:begin BCD10=4'd1; BCD1=4'd6; end
			7'd17:begin BCD10=4'd1; BCD1=4'd7; end
			7'd18:begin BCD10=4'd1; BCD1=4'd8; end
			7'd19:begin BCD10=4'd1; BCD1=4'd9; end
			7'd20:begin BCD10=4'd2; BCD1=4'd0; end
			7'd21:begin BCD10=4'd2; BCD1=4'd1; end
			7'd22:begin BCD10=4'd2; BCD1=4'd2; end
			7'd23:begin BCD10=4'd2; BCD1=4'd3; end
			7'd24:begin BCD10=4'd2; BCD1=4'd4; end
			7'd25:begin BCD10=4'd2; BCD1=4'd5; end
			7'd26:begin BCD10=4'd2; BCD1=4'd6; end
			7'd27:begin BCD10=4'd2; BCD1=4'd7; end
			7'd28:begin BCD10=4'd2; BCD1=4'd8; end
			7'd29:begin BCD10=4'd2; BCD1=4'd9; end
			7'd30:begin BCD10=4'd3; BCD1=4'd0; end
			7'd31:begin BCD10=4'd3; BCD1=4'd1; end
			7'd32:begin BCD10=4'd3; BCD1=4'd2; end
			7'd33:begin BCD10=4'd3; BCD1=4'd3; end
			7'd34:begin BCD10=4'd3; BCD1=4'd4; end
			7'd35:begin BCD10=4'd3; BCD1=4'd5; end
			7'd36:begin BCD10=4'd3; BCD1=4'd6; end
			7'd37:begin BCD10=4'd3; BCD1=4'd7; end
			7'd38:begin BCD10=4'd3; BCD1=4'd8; end
			7'd39:begin BCD10=4'd3; BCD1=4'd9; end
			7'd40:begin BCD10=4'd4; BCD1=4'd0; end
			7'd41:begin BCD10=4'd4; BCD1=4'd1; end
			7'd42:begin BCD10=4'd4; BCD1=4'd2; end
			7'd43:begin BCD10=4'd4; BCD1=4'd3; end
			7'd44:begin BCD10=4'd4; BCD1=4'd4; end
			7'd45:begin BCD10=4'd4; BCD1=4'd5; end
			7'd46:begin BCD10=4'd4; BCD1=4'd6; end
			7'd47:begin BCD10=4'd4; BCD1=4'd7; end
			7'd48:begin BCD10=4'd4; BCD1=4'd8; end
			7'd49:begin BCD10=4'd4; BCD1=4'd9; end
			7'd50:begin BCD10=4'd5; BCD1=4'd0; end
			7'd51:begin BCD10=4'd5; BCD1=4'd1; end
			7'd52:begin BCD10=4'd5; BCD1=4'd2; end
			7'd53:begin BCD10=4'd5; BCD1=4'd3; end
			7'd54:begin BCD10=4'd5; BCD1=4'd4; end
			7'd55:begin BCD10=4'd5; BCD1=4'd5; end
			7'd56:begin BCD10=4'd5; BCD1=4'd6; end
			7'd57:begin BCD10=4'd5; BCD1=4'd7; end
			7'd58:begin BCD10=4'd5; BCD1=4'd8; end
			7'd59:begin BCD10=4'd5; BCD1=4'd9; end
			7'd60:begin BCD10=4'd6; BCD1=4'd0; end
			7'd61:begin BCD10=4'd6; BCD1=4'd1; end
			7'd62:begin BCD10=4'd6; BCD1=4'd2; end
			7'd63:begin BCD10=4'd6; BCD1=4'd3; end
			7'd64:begin BCD10=4'd6; BCD1=4'd4; end
			7'd65:begin BCD10=4'd6; BCD1=4'd5; end
			7'd66:begin BCD10=4'd6; BCD1=4'd6; end
			7'd67:begin BCD10=4'd6; BCD1=4'd7; end
			7'd68:begin BCD10=4'd6; BCD1=4'd8; end
			7'd69:begin BCD10=4'd6; BCD1=4'd9; end
			7'd70:begin BCD10=4'd7; BCD1=4'd0; end
			7'd71:begin BCD10=4'd7; BCD1=4'd1; end
			7'd72:begin BCD10=4'd7; BCD1=4'd2; end
			7'd73:begin BCD10=4'd7; BCD1=4'd3; end
			7'd74:begin BCD10=4'd7; BCD1=4'd4; end
			7'd75:begin BCD10=4'd7; BCD1=4'd5; end
			7'd76:begin BCD10=4'd7; BCD1=4'd6; end
			7'd77:begin BCD10=4'd7; BCD1=4'd7; end
			7'd78:begin BCD10=4'd7; BCD1=4'd8; end
			7'd79:begin BCD10=4'd7; BCD1=4'd9; end
			7'd80:begin BCD10=4'd8; BCD1=4'd0; end
			7'd81:begin BCD10=4'd8; BCD1=4'd1; end
			7'd82:begin BCD10=4'd8; BCD1=4'd2; end
			7'd83:begin BCD10=4'd8; BCD1=4'd3; end
			7'd84:begin BCD10=4'd8; BCD1=4'd4; end
			7'd85:begin BCD10=4'd8; BCD1=4'd5; end
			7'd86:begin BCD10=4'd8; BCD1=4'd6; end
			7'd87:begin BCD10=4'd8; BCD1=4'd7; end
			7'd88:begin BCD10=4'd8; BCD1=4'd8; end
			7'd89:begin BCD10=4'd8; BCD1=4'd9; end
			7'd90:begin BCD10=4'd9; BCD1=4'd0; end
			7'd91:begin BCD10=4'd9; BCD1=4'd1; end
			7'd92:begin BCD10=4'd9; BCD1=4'd2; end
			7'd93:begin BCD10=4'd9; BCD1=4'd3; end
			7'd94:begin BCD10=4'd9; BCD1=4'd4; end
			7'd95:begin BCD10=4'd9; BCD1=4'd5; end
			7'd96:begin BCD10=4'd9; BCD1=4'd6; end
			7'd97:begin BCD10=4'd9; BCD1=4'd7; end
			7'd98:begin BCD10=4'd9; BCD1=4'd8; end
			7'd99:begin BCD10=4'd9; BCD1=4'd9; end
			default:begin BCD10=4'd0; BCD1=4'd0; end
		endcase
	end
endmodule

module DDisplay8(clk,rst,D0,D1,D2,D3,D4,D5,D6,D7,seg,sel);
input clk,rst;
input[3:0] D0,D1,D2,D3,D4,D5,D6,D7;
output[6:0] seg;
output[7:0] sel;

wire[3:0] disData;

sel8_1 mysel8_1(clk,rst,D0,D1,D2,D3,D4,D5,D6,D7,disData,sel);

decode4_7 mydec(disData,seg);

endmodule

module sel8_1(clk,rst,D0,D1,D2,D3,D4,D5,D6,D7,disData,sel);
input clk,rst;
input[3:0] D0,D1,D2,D3,D4,D5,D6,D7;
output reg[3:0] disData;
output reg[7:0] sel;
reg[2:0] cnt;

always @(posedge clk)
	begin
	   if(rst) cnt<=0;
		else cnt<=cnt+1;
	end

always @(*)
	begin
		case (cnt)
			3'd0:begin sel<=~8'b00000001;disData<=D0; end
			3'd1:begin sel<=~8'b00000010;disData<=D1; end
			3'd2:begin sel<=~8'b00000100;disData<=D2; end
			3'd3:begin sel<=~8'b00001000;disData<=D3; end
			3'd4:begin sel<=~8'b00010000;disData<=D4; end
			3'd5:begin sel<=~8'b00100000;disData<=D5; end
			3'd6:begin sel<=~8'b01000000;disData<=D6; end
			3'd7:begin sel<=~8'b10000000;disData<=D7; end
		   default:begin sel<=8'b00000000;disData<=4'd10; end
		endcase 
	end	
	
endmodule

module decode4_7(disData,seg);
input[3:0] disData;
output reg[6:0] seg;

always @(disData)
	begin
		case (disData)
		4'd0:seg=7'b1111110;
		4'd1:seg=7'b0110000;
		4'd2:seg=7'b1101101;
		4'd3:seg=7'b1111001;
		4'd4:seg=7'b0110011;
		4'd5:seg=7'b1011011;
		4'd6:seg=7'b1011111;
		4'd7:seg=7'b1110000;
		4'd8:seg=7'b1111111;
		4'd9:seg=7'b1111011;
		default:seg=7'b1001111;
		endcase
	end

endmodule

