/*
The following drivers conflict:
line21
line44 
*/
module paobiao(CLK,CLR,PAUSE,MSH,MSL,SH,SL,MH,ML);
input CLK,CLR;
input PAUSE;
output[3:0] MSH,MSL,SH,SL,MH,ML;
reg[3:0] MSH,MSL,SH,SL,MH,ML;
reg[1:0] MSH_T [3:0];
integer j,i; 
reg cn1,cn2; //cn1 为百分秒向秒的进位，cn2 为秒向分的进位
//百分秒计数进程，每计满100，cn1 产生一个进位
always @(posedge CLK or posedge CLR)
begin
if(CLR) begin //异步复位
{MSH,MSL}<=8'h00;
for (j=0; j<2; j++)
for (i=0; i<4; i++)
MSH_T[j][i]<=MSH;
cn1<=0;
end
else if(!PAUSE) //PAUSE 为0 时正常计数，为1 时暂停计数
begin
if(MSL==9) begin
MSL<=0;
if(MSH==9)
begin MSH<=0; cn1<=1; end
else MSH<=MSH+1;
end
else begin
MSL<=MSL+1; cn1<=0;
end
end
end
//秒计数进程，每计满60，cn2 产生一个进位
always @(posedge cn1 or posedge CLR)
begin
if(CLR) begin //异步复位
{SH,SL}<=8'h01;
for (j=0; j<2; j++)
for (i=j+1; i<4; i++)
MSH_T[j][i]<=SH;
cn2<=0;
end
else if(SL==9) //低位是否为9
begin
SL<=0;
if(SH==5) begin SH<=0; cn2<=1; end
else SH<=SH+1;
end
else
begin SL<=SL+1; cn2<=0; end
end
//分钟计数进程，每计满60，系统自动清零
always @(posedge cn2 or posedge CLR)
begin
if(CLR)
begin {MH,ML}<=8'h00; end //异步复位
else if(ML==9) begin
ML<=0;
if(MH==5) MH<=0;
else MH<=MH+1;
end
else ML<=ML+1;
end
endmodule