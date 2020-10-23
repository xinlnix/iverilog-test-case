/**
	【例 6.2】任务举例
	26,29，30，31，38调用task导致mutil driver
*/

module alutask(code,a,b,c,d);
input[1:0] code;
input[3:0] a,b;
input d;
output[4:0] c;
reg[4:0] c;

task my_and; //任务定义，注意无端口列表
input[3:0] a,b; //a,b,out 名称的作用域范围为 task 任务内部
output[4:0] out;
integer i;
begin
	for(i=3;i>=0;i=i-1)
		out[i]=a[i]&b[i]; //按位与
	end
endtask

always@(code or a or b)
	begin
	case(code)
		2'b00: my_and(a,b,c);
 		/* 调用任务 my_and，需注意端口列表的顺序应与任务定义中的一致，这里的 a,b,c
			分别对应任务定义中的 a,b,out */
		2'b01: c=a|b; //或
		2'b10: c=a-b; //相减
		2'b11: c=a+b; //相加
	endcase
	end

always@(d)
	begin
		if (code == 2'b00) begin
			my_and(b,a,c);
		end
	end
endmodule