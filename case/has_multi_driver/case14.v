/**
    14
*/

module top; 
    reg q; 
    wire q_recept;
    wire q_recept2;
    submod s1(q_recept); 
    submod s2(q_recept2); 


    initial begin
      q = 0;
      #10 q = 1;
    end
    // always@(*)begin
    //   q <= q_recept;
    // end
    // submod2 s2_1();

    // always@(*)begin
    //   q <= q_recept;
    // end
    // // submod2 s2_1();

endmodule 

module submod( output reg  q_local); 
    reg d,clk; 
    reg q;
    always @(posedge clk) begin
       top.q <= d; 
    //    q_local<= d;
       q <= d; 
end
endmodule 

module submod2(); 
    reg d,clk; 
     reg q;
     submod s1();
    always @(posedge clk) 
       q <= clk; 
endmodule 