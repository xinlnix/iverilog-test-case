/*
The following drivers conflict:
line 108 112 114
line 118
*/
module clock(clk,clk_1k,mode,change,turn,alert,hour,min,sec,
 LD_alert,LD_hour,LD_min);
input clk,clk_1k,mode,change,turn;
output alert,LD_alert,LD_hour,LD_min;
output[7:0] hour,min,sec;
reg[7:0] hour,min,sec,hour1,min1,sec1,ahour,amin;

reg[1:0] m,fm,num1,num2,num3,num4;
reg[1:0] loop1,loop2,loop3,loop4,sound;
reg LD_hour,LD_min;
reg clk_1Hz,clk_2Hz,minclk,hclk;
reg alert1,alert2,ear;
reg count1,count2,counta,countb;
wire ct1,ct2,cta,ctb,m_clk,h_clk;
integer i;
always @(posedge clk)
begin
clk_2Hz<=~clk_2Hz;
if(sound==3) begin sound<=0; ear<=1; end
//ear 信号用于产生或屏蔽声音
else begin sound<=sound+1; ear<=0; end
end
always @(posedge clk_2Hz) //由4Hz 的输入时钟产生1Hz 的时基信号
clk_1Hz<=~clk_1Hz;
always @(posedge mode) //mode 信号控制系统在三种功能间转换
begin if(m==2) m<=0; else m<=m+1; end
always @(posedge turn)
fm<=~fm;
always @(posedge cta)//该进程产生count1,count2,counta,countb 四个信号
begin
case(m)
2: begin if(fm)
begin count1<=change; {LD_min,LD_hour}<=2; end
else
begin counta<=change; {LD_min,LD_hour}<=1; end
{count2,countb}<=0;
end
1: begin if(fm)
begin count2<=change; {LD_min,LD_hour}<=2; end
else
begin countb<=change; {LD_min,LD_hour}<=1; end
{count1,counta}<=2'b00;
end
default: {count1,count2,counta,countb,LD_min,LD_hour}<=0;
endcase
end
always @(negedge clk)
//如果长时间按下“change”键，则生成“num1”信号用于连续快速加1
if(count2) begin
if(loop1==3) num1<=1;
else
begin loop1<=loop1+1; num1<=0; end
end
else begin loop1<=0; num1<=0; end
always @(negedge clk) //产生num2 信号
if(countb) begin
if(loop2==3) num2<=1;
else
begin loop2<=loop2+1; num2<=0; end
end
else begin loop2<=0; num2<=0; end
always @(negedge clk)
if(count1) begin
if(loop3==3) num3<=1;
else
begin loop3<=loop3+1; num3<=0; end
end
else begin loop3<=0; num3<=0; end
always @(negedge clk)
if(counta) begin
if(loop4==3) num4<=1;
else
begin loop4<=loop4+1; num4<=0; end
end
else begin loop4<=0; num4<=0; end
assign ct1=(num3&clk)|(!num3&m_clk); //ct1 用于计时、校时中的分钟计数
assign ct2=(num1&clk)|(!num1&count2); //ct2 用于定时状态下调整分钟信号
assign cta=(num4&clk)|(!num4&h_clk); //cta 用于计时、校时中的小时计数
assign ctb=(num2&clk)|(!num2&countb); //ctb 用于定时状态下调整小时信号
always @(posedge clk_1Hz) //秒计时和秒调整进程
if(!(sec1^8'h59)|turn&(!m))
begin
sec1<=0; if(!(turn&(!m))) minclk<=1;
end
//按住“turn”按键一段时间，秒信号可清零，该功能用于手动精确调时
else begin
if(sec1[3:0]==4'b1001)
begin sec1[3:0]<=4'b0000; sec1[7:4]<=sec1[7:4]+1; end
else sec1[3:0]<=sec1[3:0]+1; minclk<=0;
end
assign m_clk=minclk||count1;
always @(posedge ct1) //分计时和分调整进程
begin
if(min1==8'h59) begin min1<=0; hclk<=1; end
else begin
if(min1[3:0]==9)
begin min1[3:0]<=0; min1[7:4]<=min1[7:4]+1; end
else min1[3:0]<=min1[3:0]+1; hclk<=0;
end
end
assign h_clk=hclk||counta;
always @(posedge cta) //小时计时和小时调整进程
if(hour1==8'h23) hour1<=0;
else if(hour1[3:0]==9)
begin 
hour1[7:4]<=hour1[7:4]+1; 
hour1[3:0]<=0;
end
else hour1[3:0]<=hour1[3:0]+1;
always @(posedge cta)
begin
for (i=0; i<4; i=i+1)
hour1[i]=8;
end
always @(posedge ct2) //闹钟定时功能中的分钟调节进程
if(amin==8'h59) amin<=0;
else if(amin[3:0]==9)
begin amin[3:0]<=0; amin[7:4]<=amin[7:4]+1; end
else amin[3:0]<=amin[3:0]+1;
always @(posedge ctb) //闹钟定时功能中的小时调节进程
if(ahour==8'h23) ahour<=0;
else if(ahour[3:0]==9)
begin ahour[3:0]<=0; ahour[7:4]<=ahour[7:4]+1; end
else ahour[3:0]<=ahour[3:0]+1;
always @(posedge cta)//闹铃功能
if((min1==amin)&&(hour1==ahour)&&(amin|ahour)&&(!change))
if(sec1<8'h20) alert1<=1; //控制闹铃的时间长短
else alert1<=0;
else alert1<=0;
always @(posedge cta)//时、分、秒的显示控制
case(m)
3'b00: begin hour<=hour1; min<=min1; sec<=sec1; end
//计时状态下的时、分、秒显示
3'b01: begin hour<=ahour; min<=amin; sec<=8'hzz; end
//定时状态下的时、分、秒显示
3'b10: begin hour<=hour1; min<=min1; sec<=8'hzz; end
//校时状态下的时、分、秒显示
endcase
assign LD_alert=(ahour|amin)?1:0; //指示是否进行了闹铃定时
assign alert=((alert1)?clk_1k&clk:0)|alert2; //产生闹铃音或整点报时音
always @(posedge cta)//产生整点报时信号alert2
begin
if((min1==8'h59)&&(sec1>8'h54)||(!(min1|sec1)))
if(sec1>8'h54) alert2<=ear&clk_1k; //产生短音
else alert2<=!ear&clk_1k; //产生长音
else alert2<=0;
end
endmodule
