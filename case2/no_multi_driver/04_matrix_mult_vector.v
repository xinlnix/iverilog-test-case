module matrix_mult_vector
  #(parameter
      M = 4, // matrix dimension M x N
      N = 4, // matrix dimension M x N, also vector dimension
      DW = 8
  )
  (
      input wire[(DW * N * M) -1 : 0] matrix_inp,
      input wire[(DW * N) -1 : 0] vector_inp,
      output wire[(2*DW+$bits(N))*M - 1 : 0] outp
  );

  //locals
  genvar i;
  wire [(2*DW + $bits(N)) * M - 1 : 0] dot_products; // dot products from each row 


  ///compute
  generate 
      for (i = 0; i < M; i = i + 1) begin: product_loop
        // instantiate 
        inner_product
          #(
                .N(N),
                .DW(DW)
          ) my_inner_product (
                .inp1( matrix_inp[(DW * N * (i+1)) - 1 : (DW * N * i)] ),
                .inp2(vector_inp),  
                .outp(dot_products[(2*DW + $bits(N))*(i+1) - 1 : 
                                    (2*DW + $bits(N))*i ])
          );
      end
  endgenerate

  assign outp = dot_products; 

endmodule

// Verilog testbench

`timescale 1ps/1ps
`define DATA_WIDTH 2
`define NUM_ELEMS  2
`define NUM_ROWS 2 

module matrix_mult_vector_tb ();

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
	wire [(2*`DATA_WIDTH + $bits(`NUM_ELEMS)) * `NUM_ROWS - 1  : 0] outp;
	wire [(`NUM_ELEMS * `DATA_WIDTH) - 1 : 0] inps;

	matrix_mult_vector_test #(
		.data_width(`DATA_WIDTH),
		.n_columns(`NUM_ELEMS),
                .m_rows(`NUM_ROWS)
	) my_matrix_mult_vector_test (
		.clk(tb_clk),
		.outp(outp),
		.outp_inps(inps) // the count
		);
	// display inputs and output on each clock cycle
	always @(posedge tb_clk) begin
		$display("inps = ", inps, " => outp = ", outp);
	end

endmodule

module matrix_mult_vector_test
  #(parameter 
      m_rows = 4,
      n_columns = 4, //also is the dimension of vector
      data_width = 8)
  (
      input wire clk,
      output wire [(2*data_width + $bits(n_columns))*m_rows - 1  : 0] outp,
      output wire [n_columns * data_width - 1 : 0] outp_inps
  );

  localparam
      num_bits = data_width * n_columns; // size in bits of a vector

      //counter 
      reg [num_bits - 1 : 0] count;
      reg [num_bits * m_rows -1 : 0] multiple_counts; // for matrix input
      initial begin
          count = 0;
          multiple_counts = 0;
      end
      always @ (posedge clk) begin
          count <= count + 1;
          multiple_counts <= multiple_counts + 1; // TODO: count value in all rows
      end
      assign outp_inps = count;

      // instantiate 
      matrix_mult_vector
          #(
                .M(m_rows),    
                .N(n_columns),
                .DW(data_width)
          ) my_matrix_mult_vector (
                .matrix_inp(multiple_counts),
                .vector_inp(count), // takes in count as 2 inputs 
                .outp(outp)
          );

endmodule

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
  endgenerate

  assign outp = sums[N-1]; 


endmodule