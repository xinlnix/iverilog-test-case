// Copyright 2018 Schuyler Eldridge
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Implements a "good" reset signal that is asserted asynchronously
// and deasserted synchronously. See Cliff Cummings work for the
// reasoning behind this:
//   Cummings, C. and Milis, D. "Synchronous Resets? Asynchronous
//     resets? I am so confused! How will I ever know which to use?"
//     Synopsys Users Group Conference, 2002.
//   Cummings, C., Millis, D., and Golson, S. "Asynchronous &
//     synchronous reset design techniques-part deux." Synopsys Users
//     Group Conference, 2003.

/**
  94,99,109,113 reset_flops1,reset_flops2
*/

module reset
  (
   input clk1,       // input clock
   input clk2,
   input rst_n_in,  // asynchronous reset from userland
   output rst_n_out // asynchronous assert/synchronous deassert chip broadcast
   );

  // You have two DFFs in series (a two stage pipe) with the input to
  // the first DFF tied to 1. When the input active low reset is
  // deasserted this asynchronously resets the DFFs. This causes the
  // second DFF to broadcast an asynchronous reset out to the whole
  // chip. However, when the input rest is asserted, the flip flops
  // are enabled, and you get a synchronous assert of the active low
  // reset to the entire chip.

  pipeline_registers
    #(
      .BIT_WIDTH(1),
      .NUMBER_OF_STAGES(2)
      )
  reset_flops1
    (
     .clk(clk1),           // input clk
     .reset_n(rst_n_in),  // convert to active low
     .pipe_in(1'b1),      // input is always 1
     .pipe_out(rst_n_out) // asynchronous reset output
     );

  pipeline_registers
    #(
      .BIT_WIDTH(1),
      .NUMBER_OF_STAGES(2)
      )
  reset_flops2
    (
     .clk(clk2),           // input clk
     .reset_n(rst_n_in),  // convert to active low
     .pipe_in(1'b1),      // input is always 1
     .pipe_out(rst_n_out) // asynchronous reset output
     );

endmodule

`timescale 1ns / 1ps
module pipeline_registers
  #(
    parameter
    BIT_WIDTH         = 10,
    NUMBER_OF_STAGES  = 5
    )
  (
   input                      clk,
   input                      reset_n,
   input [BIT_WIDTH-1:0]      pipe_in,
   output reg [BIT_WIDTH-1:0] pipe_out
   );

  // Main generate function for conditional hardware instantiation
  generate
    genvar                                 i;
    // Pass-through case for the odd event that no pipeline stages are
    // specified.
    if (NUMBER_OF_STAGES == 0) begin
      always @ *
        pipe_out = pipe_in;
    end
    // Single flop case for a single stage pipeline
    else if (NUMBER_OF_STAGES == 1) begin
      always @ (posedge clk or negedge reset_n)
        pipe_out <= (!reset_n) ? 0 : pipe_in;
    end
    // Case for 2 or more pipeline stages
    else begin
      // Create the necessary regs
      reg [BIT_WIDTH*(NUMBER_OF_STAGES-1)-1:0] pipe_gen;
      // Create logic for the initial and final pipeline registers
      always @ (posedge clk or negedge reset_n) begin
        if (!reset_n) begin
          pipe_gen[BIT_WIDTH-1:0] <= 0;
          pipe_out                <= 0;
        end
        else begin
          pipe_gen[BIT_WIDTH-1:0] <= pipe_in;
          pipe_out                <= pipe_gen[BIT_WIDTH*(NUMBER_OF_STAGES-1)-1:BIT_WIDTH*(NUMBER_OF_STAGES-2)];
        end
      end
      // Create the intermediate pipeline registers if there are 3 or
      // more pipeline stages
      for (i = 1; i < NUMBER_OF_STAGES-1; i = i + 1) begin : pipeline
        always @ (posedge clk or negedge reset_n)
          pipe_gen[BIT_WIDTH*(i+1)-1:BIT_WIDTH*i] <= (!reset_n) ? 0 : pipe_gen[BIT_WIDTH*i-1:BIT_WIDTH*(i-1)];
      end
    end
  endgenerate

endmodule
