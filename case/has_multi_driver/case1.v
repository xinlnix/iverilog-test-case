/**
    【例 5.8】阻塞赋值方式定义的 2 选 1 多路选择器
    12,13,17
*/

module MUX21_2(out,a,b,sel,sel2);
input a,b,sel,sel2;
output out;
reg out;
always@(a or b or sel)
    begin
    if(sel==0) out=a; //阻塞赋值
    else out=b;
    end
always@(sel2)
    begin
        out=a;
    end
endmodule

