/**
	【例 5.9】非阻塞赋值
    13,15,22,24     16,25
*/

module non_block(d,c,b,a,clk,sel);
output c,b;
input clk,a,d,sel;
reg c,b;
always @(posedge clk)
	begin
        if (sel)
            b<=a;
        else
            b<=d;
        c<=b;
    end

always @(negedge clk)
	begin
        if (sel)
            b<=d;
        else
            b<=a;
        c<=d;
    end
endmodule
