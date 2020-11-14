// /**
//     【例 5.8】阻塞赋值方式定义的 2 选 1 多路选择器
// */

// module MUX21_2(sel,a,b,q[7:0]);
// input a,b,sel;
// output reg [7:0] q;

// always@(a or b or sel)
//     begin
//     q=a;
//     if(sel==0) q=a; //阻塞赋值
//     else q=b;
//     q=b;
//     end
// endmodule


module dut(input a,b,c,e,clk, output reg [7:0] q );
// //wire a,b,c;
// // reg r;
// // reg clk;
// // reg q[3:0];
reg [7:0] mem[6:0];

wire [3:0] address;

integer i,j;

reg [31:0] tmp;
// always@(a)begin
//   for(i=0;i<8;i++)begin
//     tmp[i*4+3] = a;
//   end
// end

// always@(a)begin
//   for(i=0;i<8;i++)begin
//     tmp[i+3] = a;
//   end
// end

// always@(a)begin
//   // for(i=0;i<4;i++)begin
//     // tmp[i*4+3] = a;
//     tmp[address] = a;
//   // end
// end
// always@(a)begin
//   // for(i=0;i<4;i++)begin
//     // tmp[i*4+3] = a;
//     tmp[address] = a;
//   // end
// end
// initial begin
//   for(i=0;i<8;i++)begin
//     tmp[i*4+3] = a;
//   end
// end
// reg h= 0;

// reg f = 1;
// reg [3:0] g = 111;

// always@(*)begin
//   q   = e;
//   case(e)
//   1:begin end
//   0:begin q = {3{e}};end
//   endcase

// end

// reg rr = 0;
// reg rr2 = 1;

// initial
// begin
//   #5 rr = 1;
// end

// always@(*)begin
//   q = clk;
// end

// always@(*)begin
//   rr2 = 11; //warning! no sensitive list,never triger.
// end

// initial
// begin
// q[0]=32'd0;
// q[1]=32'd1;
// q[2]=32'd2;
// q[3]=32'd3;
// q[4]=32'd4;
// q[5]=32'd5;
// q[6]=32'd6;
// q[7]=32'd7;
// end

// initial
// begin
// q=1;

// end

// always@(*)begin
//    mem[2][3:3] = b;
//   // mem[2][3:3] = b;
//   mem[3][3:1] = a;
//   // mem[2][4:3] = b;
//   // mem[2][3:1] = b;
//   // mem[2][7:6] = b;
//   // mem[5][5:1] = b;
//   // mem[5][6] = b;

//   q = b;
//   // q[2] = b;
//   //   q[4] = b;

//   // rr2 = 0;
// end
// always@(*)begin
//    mem[2][3:3] = b;
//   // mem[2][3:3] = b;
//   mem[3][3:1] = a;
//   // mem[2][4:3] = b;
//   // mem[2][3:1] = b;
//   // mem[2][7:6] = b;
//   // mem[5][5:1] = b;
//   // mem[5][6] = b;

//   q = b;
//   // q[2] = b;
//   //   q[4] = b;

//   // rr2 = 0;
// end

// always@(*)begin
//    mem[2][3:3] = b;
//   mem[2][3:3] = b;
//   mem[3][3:1] = a;
//   mem[2][4:3] = b;
//   mem[2][3:1] = b;
//   mem[2][7:6] = b;
//   mem[5][5:1] = b;
//   mem[5][6] = b;

//   q = b;
//   // q[2] = b;
//   //   q[4] = b;

//   // rr2 = 0;
// end

// wire  [3:0] d;

// assign d={a,b,c,e};

// integer i;

// always@( clk) begin
//   for(i = 1; i<4;i++)begin
//     q[i] <= d[i];
//   end
// end


    // reg [0:7] aa [0:15];
    // integer i,j;

    // //    integer i;
    
    // initial begin
    //     for(i = 0; i <(2**3); i=i+1) begin
	  //       mem[0][i] = 0;
    //     end
    // end
    
    // initial begin
    //     for(i = 0; i <(2**3); i=i+1) begin
	  //       mem[1][i*4+3] = 0;
    //     end
    // end

    //     always@(a) begin
    //     for(i = 0; i <(2**3); i=i+1) begin
	  //       mem[0][i*4+3] = 0;
    //     end
    // end
    // always@(c)begin
    //   aa[2][0:3] = c;
    //   aa[2][5:7] = c;
    // end
    // always@(c)begin
    //   aa[2][3:6] = c;
    // end


    always @(posedge clk) begin
        for (i=0; i<5; i++)         //15
            for (j=0; j <i+4; j= j+1)            //7
                mem[i][j] = a;
    end     
        always @(posedge clk) begin
        for (i=0; i<5; i++)         //15
            for (j=0; j <i; j= j+1)            //7
                mem[i][j] = a;
    end 



    // always @(posedge clk) begin
    //     for (i=2; i<4; i++)         //15
    //         for (j=0; j <3; j= j+1)            //7
    //             mem[i][j] = a;
    //     // dd = cc & bb;
    // end      
    //     always @(posedge clk) begin
    //     for (i=2; i<4; i++)         //15
    //         for (j=0; j <3; j= j+1)            //7
    //             mem[i][j] = a;
    //     // dd = cc & bb;
    // end      
    // always @(posedge clk) begin
    //     for (i=2; i<4; i++)         //15
    //         for (j=0; j <i+3; j= j+1)            //7
    //             mem[i][j] = a;
    //     // dd = cc & bb;
    // end      
    // always @(posedge clk) begin
    //     for (i=2; i<4; i++)         //15
    //             mem[0][i] = a;
    // end      

    // always @(posedge clk) begin
    //     for (i=2; i<4; i++)         //15
    //             mem[0][i] = a;
    // end      


    // always @(posedge clk) begin
    //             mem[0][7] = a;
    // end      



    // always @(posedge clk) begin
    //     for (i=5; i>3; i=i-1)         //15
    //         for (j=i; j >1; j=j-1)            //7
    //             mem[i][j] = a;
    //     // dd = cc & bb;
    // end  
  //   always@(*)begin
  //     aa[1][0:2] = b;
  //   end

  //  always@(*)begin
  //     aa[1] = c;
  //   end

  // // always@(*)begin
  // //     aa[i] = e;
  // //   end

  //     always@(*)begin
  //     aa[1][1] = e;
  //   end




//     integer i;

// always@( clk) begin
//   for(i = 1; i<4;i++)begin
//     q[i] <= d[i];
//   end
// end


  //  always@(*)begin
  //     aa = e;
  //   end
// always@(*) begin
//   if(b) begin
//     if(a)
//       q=a;
//   end
//   else
//    q= c;

// end

// always@(*) begin
//   case(a)
//     1'b0:
//       q[0]=a;
//     1'b1:
//       q[0]= c;
//   endcase
// end

// always@(*)begin
//   {q[0],q}=a;
// end

// always@(*)begin
//   {q[1],q}=a;
// end

// // always@(a) begin
// //     //q = a;
// //     if(b) begin
// //       q = b;
// //     end
// //     else if(a) begin
// //       q = c;
// //     end
// //     else 
// //       q=a;
// // end



// always@(*) 
//   q[1] = b;


// always@( *) begin
//   q[0] = b;
//   q[3] = a;

// end

// always@(*) begin
//   q[0] = a;
//   mem[1][3:1]  =  a;
// end

// always@(*) begin
//   q = a;
// end



// // always@(b) begin
// //   r=a;
// // end


// // always@(b) begin
// //   q = b;
// //   r=b;
// // end


endmodule



// module dut(input a,b,c,e, output q);
// wire a,b,c;
// reg r;
// reg clk;
// reg q;
// reg d;
// reg q_v[3:0];
// integer i;
// always@(a,b,c)
//     d = a&(b|c);
// always@(a)
//     q = e;
// always@(posedge clk)
//     q = d;
// always@(posedge clk) begin
//     for(i=0;i<4;i++) begin
//         q_v[i] <= a|b ;
//     end
// end

// always@(c) begin
//   q_v[3:0] = {4{d}};
// end


// endmodule