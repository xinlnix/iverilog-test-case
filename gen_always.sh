#!/bin/bash



echo "module mux4_1();
    input in0, in1, in2, in3;
    input [1:0] sel;
    integer i;"



for i in $(seq 1 150000)
do

    echo "
    reg [7:0] out${i};

    always @(in0)
    for(i = 0;i<8;i++) begin
        out${i} = in0;
    end"

done


for i in $(seq 1 10)
do
    echo "
    initial begin
        out${i} = 0;
    end"
done

echo "endmodule"


        # 2'b01: out${i} = in1;
        # 2'b10: out${i} = in2;
        # 2'b11: out${i} = in3;
