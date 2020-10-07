module conflict(
    input clk,
    input a,
    input b,
    input e,
    output  reg [3:0] q,
    output reg [3:0] comb_q
);

    integer i;


    // always@(posedge clk) begin
    //     for(i=0;i<4;i++) begin
    //         q[i] <= a&b ;
    //     end
    // end

    // always@(posedge clk) begin
    //     for(i=0;i<4;i++) begin
    //         q[i] <= a|b ;
    //     end
    // end
    always@(posedge clk) begin
            q <= a&b ;
    end

    always@(posedge clk) begin
            q <= a|b ;
    end

    // assign wire_q = {4{e}};
   always@(*) begin
        for(i=0;i<4;i++) begin
            comb_q[i] = e ;
        end
   end






endmodule//the end
