module pipeline(cout,sum,ina,inb,cin,clk);
output[7:0] sum;
output cout;
input[7:0] ina,inb;
input cin,clk;
reg[7:0] tempa,tempb,sum;
reg tempci,firstco,secondco,thirdco,cout;
reg[1:0] firsts,thirda,thirdb;
reg[3:0] seconda,secondb,seconds;
reg[5:0] firsta,firstb,thirds;
always @(posedge clk)
begin
tempa=ina; tempb=inb; tempci=cin; //输入数据缓存
end
always @(posedge clk)
begin
{firstco,firsts}=tempa[1:0]+tempb[1:0]+tempci;
//第一级加（低2 位）
firsta=tempa[7:2]; //未参加计算的数据缓存
firstb=tempb[7:2];
end
always @(posedge clk)
begin
{secondco,seconds}={firsta[1:0]+firstb[1:0]+firstco,firsts};
//第二级加（第2、3 位相加）
seconda=firsta[5:2]; //数据缓存
secondb=firstb[5:2];
end
always @(posedge clk)
begin
{thirdco,thirds}={seconda[1:0]+secondb[1:0]+secondco,seconds};
//第三级加（第4、5 位相加）
thirda=seconda[3:2]; //数据缓存
thirdb=secondb[3:2];
end
always @(posedge clk)
begin
{cout,sum}={thirda[1:0]+thirdb[1:0]+thirdco,thirds};
//第四级加（高两位相加）
end
endmodule