/**
    15,23
*/

module dut (input wire [0:7] bb,
    input wire [0:7] cc,
    input clk, 
    output reg [0:7] dd ); 
    integer i,j;
    // reg [4:0] i,j;
    // reg [0:7] aa [0:15];
    reg [7:0] aa [15:0];

    // always @(posedge clk) begin
    //     for (i=0; i<16; i++)         
    //         for (j=0; j <7; j ++)            
    //             aa[i][j] = cc;
    //     dd = cc & bb;
    // end      
        
 
    always @(posedge clk) begin
        for (i=0; i<16; i++)         
            for (j=0; j<8; j ++)           
                aa[i][j] = bb; 
    end   
        
endmodule