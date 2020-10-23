/**
	【例 5.17】用 repeat 实现 8 位二进制数的乘法
	15,21,28
*/

module mult_repeat(outcome,a,b,c);
parameter size=8;
input[size:1] a,b;
input c;
output[2*size:1] outcome;
reg[2*size:1] temp_a,outcome;
reg[size:1] temp_b;
always @(a or b)
	begin
	outcome=1;
	temp_a=a;
	temp_b=b;
	repeat(size) //repeat 语句，size 为循环次数
		begin
		if(temp_b[1]) //如果 temp_b 的最低位为 1，就执行下面的加法
			outcome=outcome+temp_a;
		temp_a=temp_a<<1; //操作数 a 左移一位
		temp_b=temp_b>>1; //操作数 b 右移一位
		end
 	end

always @(posedge c) begin
	outcome=0;
end
endmodule
