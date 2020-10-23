/**
	【例 6.6】阶乘运算函数
	13,15,20
*/

module funct(clk,n,result,reset);
output[31:0] result;
input[3:0] n;
input reset,clk;
reg[31:0] result;
always @(posedge clk) //在 clk 的上升沿时执行运算
	begin
	if(!reset) result<=0; //复位
	else begin
		result <= 2 * factorial(n); //调用 factorial 函数
		end
	end

always @(negedge reset) begin
	result <= 0;
end

function[31:0] factorial; //阶乘运算函数定义（注意无端口列表）
input[3:0] opa; //函数只能定义输入端，输出端口为函数名本身
reg[3:0] i;
begin
factorial = opa ? 1 : 0;
for(i= 2; i <= opa; i = i+1) //该句若要综合通过，opa 应赋具体的数值
	factorial = i* factorial; //阶乘运算
end
endfunction
endmodule