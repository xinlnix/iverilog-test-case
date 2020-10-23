/**
    【例 5.8】阻塞赋值方式定义的 2 选 1 多路选择器
*/

module MUX21_2(out,a,b,sel);
input a,b,sel;
output out;
reg out;
always@(a or b or sel)
    begin
    if(sel==0) out=a; //阻塞赋值
    else out=b;
    end
endmodule

