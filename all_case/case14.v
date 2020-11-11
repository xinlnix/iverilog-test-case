/**
    14
*/

module top; 
    reg q; 
    submod s1(); 
    submod s2(); 
endmodule 

module submod(); 
    reg d,clk; 
    always @(posedge clk) 
       top.q <= d; 
endmodule 