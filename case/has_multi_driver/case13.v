/**
    13,17
*/

module dut (input wire [0:7] bb,
    input wire [0:7] cc,
    input clk, 
    output reg [0:7] aa); 
    reg [4:0] i;

    always @(posedge clk)            
        for (i=0; i<4; i=i+1)
            aa[i] <= cc[i];                    
                    
    always @(posedge clk) begin 
        for (i=3; i<8; i=i+1)                
            aa[i] <= bb[i];         
    end

endmodule