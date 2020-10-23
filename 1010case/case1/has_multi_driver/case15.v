/**
    15,23
*/

module dut (input wire [0:7] bb,
    input wire [0:7] cc,
    input clk, 
    output reg [0:7] dd ); 
    reg [4:0] i,j;
    reg [0:7] aa [0:15];

    always @(posedge clk) begin
        for (i=0; i<7; i=i+1)         
            for (j=0; j <i+1; j =j+1)            
                aa[i][j] = cc;
        dd = cc & bb;
    end      
        
 
    always @(posedge clk) begin
        for (i=0; i<7; i=i+1)         
            for (j=i; j <15; j=j+1)           
                aa[i][j] = bb; 
    end   
        
endmodule
