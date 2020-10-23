/**
	【例 8.21】8 位计数器的仿真
*/

`timescale 10ns/1ns
module count8_tp;
reg clk,reset; //输入激励信号定义为 reg 型
wire[7:0] qout; //输出信号定义为 wire 型
parameter DELY=100;

counter C1(qout,reset,clk); //调用测试对象

always #(DELY/2) clk = ~clk; //产生时钟波形

initial
begin //激励波形定义
	clk =0; reset=0;
	#DELY reset=1;
	#DELY reset=0;
	#(DELY*300) $finish;
end

//结果显示
initial $monitor($time,,,"clk=%d reset=%d qout=%d",clk,reset,qout);
endmodule

module counter(qout,reset,clk); //待测试的 8 位计数器模块
output[7:0] qout;
input clk,reset;
reg[7:0] qout;
always @(posedge clk)
	begin	if (reset) qout<=0;
			else qout<=qout+1;
	end
endmodule
