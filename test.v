module mux4_1(out, in0, in1, in2, in3, sel);

    output out;
    input in0, in1, in2, in3;
    input [1:0] sel;
    reg out=0;

    always @(*)
    case(sel)
        2'b00: out = in0;
        2'b01: out = in1;
        2'b10: out = in2;
        2'b11: out = in3;
        default: out = 2'bx;
    endcase

endmodule
