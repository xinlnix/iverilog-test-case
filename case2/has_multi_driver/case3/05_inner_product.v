module inner_product
  #(parameter
      N = 4,
      DW = 8
  )
  (
      input wire[(DW * N) -1 : 0] inp1,
      input wire[(DW * N) -1 : 0] inp2,
      output wire[(2*DW + $bits(N)) - 1 : 0] outp
  );

  //locals
  genvar i;
  wire [(2*DW + $bits(N)) - 1 : 0] sums[0 : N - 1]; // intermediate product sums

  ///compute
  assign sums[0] = inp1[DW - 1 : 0] * inp2[DW - 1 : 0];

  generate 
      for (i = 1; i < N; i = i + 1) begin: sum_loop
          assign sums[i] = sums[i-1] + inp1[ (i + 1) * DW - 1 : i * DW ] * inp2[ (i + 1) * DW - 1 : i * DW ];
      end
          assign sums[1] = sums[1] + inp1[ 2 * DW - 1 : 1 * DW ] * inp2[ (1 + 1) * DW - 1 : 1 * DW + 1];
  endgenerate

  assign outp = sums[N-1]; 


endmodule

// Verilog testbench

`timescale 1ps/1ps
`define DATA_WIDTH 2
`define NUM_ELEMS  5

module inner_product_tb ();

	// note this only runs for 50 cycles with the below settings
	// alter TB_TIMEOUT to run longer
	localparam TB_TIMEOUT    = 100000;
	localparam TB_CLK_PERIOD = 2000;
	localparam TB_RST_PERIOD = 4000;

	initial  #(TB_TIMEOUT) $finish();

	// clock
	reg tb_clk = 1'b0;
	always #(TB_CLK_PERIOD/2) tb_clk = ~tb_clk;


	// DUT
	wire [(2*`DATA_WIDTH + $bits(`NUM_ELEMS)) - 1  : 0] outp;
	wire [(`NUM_ELEMS * `DATA_WIDTH) - 1 : 0] inps;

	inner_product_test #(
		.data_width(`DATA_WIDTH),
		.num_elems(`NUM_ELEMS)
	) my_inner_product_test (
		.clk(tb_clk),
		.outp(outp),
		.outp_inps(inps) // the count
		);
	// display inputs and output on each clock cycle
	always @(posedge tb_clk) begin
		$display("inps = ", inps, " => outp = ", outp);
	end

endmodule

module inner_product_test
  #(parameter 
      num_elems = 4,
      data_width = 8)
  (
      input wire clk,
      output wire [(2*data_width + $bits(num_elems)) - 1  : 0] outp,
      output wire [num_elems * data_width - 1 : 0] outp_inps
  );

  localparam
      num_bits = data_width * num_elems;

      //counter 
      reg [num_bits - 1 : 0] count;
      initial begin
          count = 0;
      end
      always @ (posedge clk)
          count <= count + 1;
      assign outp_inps = count;

      // instantiate 
      inner_product
          #(
                .N(num_elems),
                .DW(data_width)
          ) my_inner_product (
                .inp1(count),
                .inp2(count), // takes in count as 2 inputs 
                .outp(outp)
          );

endmodule
