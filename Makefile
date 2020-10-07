all:
	iverilog -S -Wall -v  -o vvpfile test.v test_tb.v
	vvp vvpfile
	gtkwave test.vcd

conflict:
	# iverilog  -Wall -v  -S  -d synth2 -o vvpfile conflict.v
	# iverilog  -Wall -v -N netlist     -o vvpfile conflict.v
	# iverilog  -Wall -v   -d elaborate -o vvpfile conflict.v
	 iverilog   conflict.v




clean:
	rm vvpfile
	rm test.vcd
	rm a.out

