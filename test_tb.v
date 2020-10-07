module test();

    wire out;
    reg in0, in1, in2, in3;
    reg [1:0] sel;

    mux4_1 dut(.out(out), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .sel(sel));

    initial begin
        in0 = 2'b00;
        in1 = 2'b01;
        in2 = 2'b10;
        in3 = 2'b11;
        #1 sel = 2'b00;
        #1 sel = 2'b01;
        #1 sel = 2'b10;
        #1 sel = 2'b11;
    end

    initial begin
        $dumpfile("./test.vcd");
        $dumpvars(-1, test);
        $dumpon();
        #6
        $dumpoff();
        $finish;
    end

    always #1
    $display("%t:    cout=%b %h %h %h %h %b", $time, out, in0, in1, in2, in3, sel);

endmodule