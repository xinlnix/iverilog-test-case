/*
The following drivers conflict:
line 29
line 35
*/
module mult4x4(out,a,b,clk);
output[7:0] out;
input[3:0] a,b;
input clk;
reg[7:0] out;
reg[3:0] out_t [7:0];
reg[1:0] firsta,firstb;
reg[1:0] seconda,secondb;
wire[3:0] outa,outb,outc,outd;
integer i,j;
always @(posedge clk)
begin
firsta = a[3:2]; seconda = a[1:0];
firstb = b[3:2]; secondb = b[1:0];
end
lookup m1(outa,firsta,firstb,clk),
m2(outb,firsta,secondb,clk),
m3(outc,seconda,firstb,clk),
m4(outd,seconda,secondb,clk); //模块调用
always @(posedge clk)
begin
for (i=0; i<4; i=i+1)
for (j=0; j<8; j=j+1)
out_t[i][j]<= 0;
end
always @(posedge clk)
begin
for (i=0; i<4; i=i+1)
for (j=0; j<4; j=j+1)
out_t[i][j]<= 1;
end
always @(posedge clk)
begin
out = (outa << 4) + (outb << 2) + (outc << 2) + outd;
end
endmodule
module lookup(out,a,b,clk); //用查找表方式实现2×2 乘法
output[3:0] out;
input[1:0] a,b;
input clk;
reg[3:0] out;
reg[3:0] address;
always @(posedge clk)
begin
address = {a,b};
case(address)
4'h0 : out = 4 'b0000;
4'h1 : out = 4'b0000;
4'h2 : out = 4'b0000;
4'h3 : out = 4'b0000;
4'h4 : out = 4'b0000;
4'h5 : out = 4'b0001;
4'h6 : out = 4'b0010;
4'h7 : out = 4'b0011;
4'h8 : out = 4'b0000;
4'h9 : out = 4'b0010;
4'ha : out = 4'b0100;
4'hb : out = 4'b0110;
4'hc : out = 4'b0000;
4'hd : out = 4'b0011;
4'he : out = 4'b0110;
4'hf : out = 4'b1001;
default : out='bx;
endcase
end
endmodule
