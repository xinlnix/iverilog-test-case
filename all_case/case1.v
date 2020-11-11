/**
    【例 5.8】阻塞赋值方式定义的 2 选 1 多路选择器
    12,13,17
*/

module MUX21_2(out,a,b,sel,sel2);
input a,b,sel,sel2;
output out;
reg tmp;
always@(a or b or sel)
    begin
    if(sel==0) tmp=a; //阻塞赋值
    else tmp=b;
    end
always@(sel2)
    begin
        tmp=a;
    end
assign out = tmp;
endmodule

module test();
reg a,b,sel,sel2;
wire out;
initial begin
    a = 1;
    b = 0;
    sel2 = 1;
    sel = 1;
end
MUX21_2 m1(out,a,b,sel,sel2);
endmodule
