/**
	【例 5.16】用 for 语句实现 2 个 8 位数相乘
	15,17,22
*/

module mult_for(outcome,a,b,c);
parameter size=8;
input[size:1] a,b; //两个操作数
input c;
output[2*size:1] outcome; //结果
reg[2*size:1] outcome;
integer i;
always @(a or b)
	begin
	outcome=0;
	for(i=1; i<=size; i=i+1) //for 语句
		if(b[i]) outcome=outcome +(a << (i-1));
	end

always @(posedge c)
	begin
		outcome=0;
	end
endmodule