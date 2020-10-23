/**
    20,25
*/

module dut (input wire [3:0] a,
    input wire [3:0] b,
    input wire [3:0] c,
    input clk,
    output reg [3:0] q); 
    reg [3:0] aa;
    reg [3:0] r; 
    reg [3:0] d; 

    always @(a,b,c) begin
        d = a & (b|c); 
        r = a & b;
    end
       
    always @(d) begin
        aa[1:0] = d[1:0];
    end 

    always @(posedge clk) begin
        q <= d;    
        aa[3:0] = r[3:1];
    end
endmodule
