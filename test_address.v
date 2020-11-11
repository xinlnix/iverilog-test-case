
module sell(one_dollar,half_dollar,
collect,half_out,dispense,reset,clk);
parameter idle=0,one=2,half=1,two=3,three=4;
//idle,one,half,two,three 为中间状态变量，代表投入币值的几种情况
input one_dollar,half_dollar,reset,clk;
output collect,half_out,dispense;
reg collect,half_out,dispense,collect_t;
reg [4:0] test [0:2];
reg[2:0] D;
integer i, j;

initial begin
always @(posedge clk)
begin 
collect =0;
for (i=0; i<5; i=i+1)
for (j=0; j<3; j=j+1)
test[i][j]= collect;
end
always @(posedge clk)
begin
collect_t = 1;
for (i=0; i<5; i=i+1)
for (j=0; j<4; j=j+1)
test[i][j] = collect;
end
end

endmodule




// module vector_regs(vxout,datain,vx_select,index_select,mak,clk,reset);
// output [31:0]vxout;
// input [31:0]datain;
// input [2:0]vx_select;
// input [5:0]index_select;
// input mak,clk,reset;

// reg [31:0]vx[0:7][0:63];
// reg [31:0]mem[0:7];

// assign vxout=vx[vx_select][index_select];

// always @(negedge clk)
// begin
//     if(!reset && mak) begin
//         vx[vx_select][index_select]<=datain;
//         mem[vx_select] <= 0;
//     end
// //$display("%d %d %d %d %d %d %d %d",vx[2][0],vx[2][1],vx[2][2],vx[2][3],vx[2][4],vx[2][5],vx[2][6],vx[2][7]);
// end

// // integer x = 1;

// // initial
// // begin
// // // for(x=0;x<=32'd63;x=x+32'd1)
// // vx[1][x]<=x;
// // // for(x=0;x<=32'd63;x=x+32'd1)
// // vx[2][x]<=32'd0;
// // vx[vx_select][0] = 0;
// // mem[0] = 0;
// // mem[0][3] = 0;
// // mem[3] = 0;
// // mem[vx_select] = 0;
// // end

// endmodule




// module simple_ram
//   #(parameter width     = 4,
//     parameter widthad   = 2
//     )
//    (
//     input 		   clk,
    
//     input [widthad-1:0]    wraddress,
//     input 		   wren,
//     input [width-1:0] 	   data,
    
//     input [widthad-1:0]    rdaddress,
//     output reg [width-1:0] q
//     );

// reg [width-1:0] mem [(2**widthad)-1:0];

// always @(posedge clk) begin
//     if(wren) mem[wraddress] <= data[2];
    
//     q <= mem[rdaddress];
// end
// integer i;
// always@(data)begin
//   for(i=0;i<4;i = i+1) begin
//     q[i] = 1;
//     mem[i] <= data[2];
//   end
// end

// endmodule