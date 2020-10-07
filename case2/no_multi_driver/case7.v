module D_FF(input clk, input reset, input write, input d, output reg q);
  always @(negedge clk)
  if(reset) q=0;
  else
    if(write) q=d;
endmodule

module tagBlock(input clk, input reset, input write, input [23:0] tag,output [23:0] tagData);

  D_FF d00(clk, reset,write,tag[0],tagData[0]);
  D_FF d01(clk, reset,write,tag[1],tagData[1]);
  D_FF d02(clk, reset,write,tag[2],tagData[2]);
  D_FF d03(clk, reset,write,tag[3],tagData[3]);
  D_FF d04(clk, reset,write,tag[4],tagData[4]);
  D_FF d05(clk, reset,write,tag[5],tagData[5]);
  D_FF d06(clk, reset,write,tag[6],tagData[6]);
  D_FF d07(clk, reset,write,tag[7],tagData[7]);
  D_FF d08(clk, reset,write,tag[8],tagData[8]);
  D_FF d09(clk, reset,write,tag[9],tagData[9]);
  D_FF d10(clk, reset,write,tag[10],tagData[10]);
  D_FF d11(clk, reset,write,tag[11],tagData[11]);
  D_FF d12(clk, reset,write,tag[12],tagData[12]);
  D_FF d13(clk, reset,write,tag[13],tagData[13]);
  D_FF d14(clk, reset,write,tag[14],tagData[14]);
  D_FF d15(clk, reset,write,tag[15],tagData[15]);
  D_FF d16(clk, reset,write,tag[16],tagData[16]);
  D_FF d17(clk, reset,write,tag[17],tagData[17]);
  D_FF d18(clk, reset,write,tag[18],tagData[18]);
  D_FF d19(clk, reset,write,tag[19],tagData[19]);
  D_FF d20(clk, reset,write,tag[20],tagData[20]);
  D_FF d21(clk, reset,write,tag[21],tagData[21]);
  D_FF d22(clk, reset,write,tag[22],tagData[22]);
  D_FF d23(clk, reset,write,tag[23],tagData[23]);
endmodule

module tagArray(input clk, input reset, input [7:0] we, input [23:0] tag, output [23:0] tagOut0, output [23:0] tagOut1, output [23:0] tagOut2, output [23:0]  tagOut3, output [23:0]  tagOut4, output [23:0]  tagOut5, output [23:0]  tagOut6, output [23:0]  tagOut7);

  tagBlock t0(clk,reset,we[0],tag,tagOut0);
  tagBlock t1(clk,reset,we[1],tag,tagOut1);
  tagBlock t2(clk,reset,we[2],tag,tagOut2);
  tagBlock t3(clk,reset,we[3],tag,tagOut3);
  tagBlock t4(clk,reset,we[4],tag,tagOut4);
  tagBlock t5(clk,reset,we[5],tag,tagOut5);
  tagBlock t6(clk,reset,we[6],tag,tagOut6);
  tagBlock t7(clk,reset,we[7],tag,tagOut7);
endmodule

