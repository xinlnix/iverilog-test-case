/**
    15,23
*/

module dut (input wire [0:7] bb,
    input wire [0:7] cc,
    input clk, 
    output reg [0:7] dd ); 
    reg i,j;
    reg [0:7] aa [0:15];

    always @(posedge clk) begin
        for (i=0; i<7; i++)         
            for (j=0; j <i+1; j ++)            
                aa[i][j] = cc;
        dd = cc & bb;
    end      
        
 
    always @(posedge clk) begin
        for (i=0; i<7; i++)         
            for (j=i; j <15; j ++)           
                aa[i][j] = bb; 
    end   
        
endmodule