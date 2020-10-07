/*
The following drivers conflict:
line21
line 28
*/
module sell(one_dollar,half_dollar,
collect,half_out,dispense,reset,clk);
parameter idle=0,one=2,half=1,two=3,three=4;
//idle,one,half,two,three 为中间状态变量，代表投入币值的几种情况
input one_dollar,half_dollar,reset,clk;
output collect,half_out,dispense;
reg collect,half_out,dispense,collect_t;
reg [0:4] test [2:0];
reg[2:0] D;
integer i, j;
always @(posedge clk)
begin 
collect =0;
for (i=0; i<5; i++)
for (j=0; j<3; j++)
test[i][j]= collect;
end
always @(posedge clk)
begin
collect_t = 1;
for (i=0; i<5; i++)
for (j=0; j<2; j++)
test[i][j] = collect;
end
always @(posedge clk)
begin
if(reset)
begin
dispense=0; collect=0;
half_out=0; D=idle;
end
case(D)
idle:
if(half_dollar) D=half;
else if(one_dollar)
D=one;
half:
if(half_dollar) D=one;
else if(one_dollar)
D=two;
one:
if(half_dollar) D=two;
else if(one_dollar)
D=three;
two:
if(half_dollar) D=three;
else if(one_dollar)
begin
dispense=1; //售出饮料
collect=1; D=idle;
end
three:
if(half_dollar)
begin
dispense=1; //售出饮料
collect=1; D=idle;
end
else if(one_dollar)
begin
dispense=1; //售出饮料
collect=1;
half_out=1; D=idle;
end
endcase
end
endmodule