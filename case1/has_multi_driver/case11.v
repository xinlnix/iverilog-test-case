/**
    14,16
*/

module dut (input a,b,c,e, output q); 
    wire a, b, c; 
    reg r; 
    reg clk; 
    reg q; 
    reg d; 
    always @(a,b,c) 
       d = a & (b|c); 
    always @(e) 
       q = e; 
    always @(posedge clk) 
        q <= d;    
endmodule