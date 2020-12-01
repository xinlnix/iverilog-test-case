
module simple_ram
  #(parameter width     = 1,
    parameter widthad   = 4
    )
   (
    input 		   clk,
    
    input [widthad-1:0]    wraddress,
    input 		   wren,
    input [width-1:0] 	   data,
    
    input [widthad-1:0]    rdaddress,
    output reg [width-1:0] q
    );

reg [width-1:0] mem [(2**widthad)-1:0];

always @(posedge clk) begin
    if(wren) mem[wraddress] <= data;
    
end
always @(posedge clk) begin
    if(wren) mem[wraddress] <= data;
    
end



always @(posedge clk) begin
    if(wren) mem[1] <= data;
    if(wren) mem[2] <= data;
    if(wren) mem[3] <= data;
    if(wren) mem[4] <= data;
    
end

always @(posedge clk) begin
    if(wren) mem[6] <= data;
    if(wren) mem[7] <= data;
    if(wren) mem[8] <= data;
    if(wren) mem[9] <= data;
    
end

always @(posedge clk) begin
    if(wren) mem[11] <= data;
    if(wren) mem[12] <= data;
    if(wren) mem[13] <= data;
    if(wren) mem[14] <= data;
    
end
endmodule
