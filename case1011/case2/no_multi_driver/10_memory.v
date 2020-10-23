//----------------------------------------------------------------------------
//-- Asynchronous serial receiver Unit
//------------------------------------------
//-- (C) BQ. December 2015. Written by Juan Gonzalez (Obijuan)
//-- GPL license
//----------------------------------------------------------------------------
//-- Tested at the standard baudrates:
//-- 300, 600, 1200, 4800, 9600, 19200, 38400, 115200
//----------------------------------------------------------------------------
//-- Although this transmitter has been written from the scratch, it has been
//-- inspired by the one developed in the swapforth proyect by James Bowman
//--
//-- https://github.com/jamesbowman/swapforth
//--
//----------------------------------------------------------------------------
`default_nettype none

//-----------------------------------------------------------------------------
//-- Constants for the serial asinchronous communication modules
//------------------------------------------------------------------------------
//-- (C) BQ. December 2015. Written by Juan Gonzalez (Obijuan)
//------------------------------------------------------------------------------
// These constans have been calculated for the ICESTICK board which have
// a 12MHz clock
//
//-- The calculation for the icestick board is:
//-- Divisor = 12000000 / BAUDRATE  (and the result is rounded to an integer number)
//--------------------------------------------------------------------------------
//-- The python3 script: baudgen.py contains the function for generating this table
//-----------------------------------------------------------------------------------

//-- Constants for obtaining standard BAURATES:
`define B115200 104
`define B57600  208
`define B38400  313

`define B19200  625
`define B9600   1250
`define B4800   2500
`define B2400   5000
`define B1200   10000
`define B600    20000
`define B300    40000

//-- Serial receiver unit module
module uart_rx #(
         parameter BAUDRATE = `B115200   //-- Default baudrate
)(
         input wire clk,         //-- System clock (12MHz in the ICEstick)
         input wire rstn,        //-- Reset (Active low)
         input wire rx,          //-- Serial data input
         output reg rcv,         //-- Data is available (1)
         output reg [7:0] data   //-- Data received
);

//-- Transmission clock
wire clk_baud;

//-- Control signals
reg bauden;  //-- Enable the baud generator
reg clear;   //-- Clear the bit counter
reg load;    //-- Load the received character into the data register


//-------------------------------------------------------------------
//--     DATAPATH
//-------------------------------------------------------------------

//-- The serial input is registered in order to follow the
//-- synchronous design rules
reg rx_r;

always @(posedge clk)
  rx_r <= rx;

//-- Baud generator
baudgen_rx #(BAUDRATE)
  baudgen0 (
    .rstn(rstn),
    .clk(clk),
    .clk_ena(bauden),
    .clk_out(clk_baud)
  );

//-- Bit counter
reg [3:0] bitc;

always @(posedge clk)
  if (clear)
    bitc <= 4'd0;
  else if (clear == 0 && clk_baud == 1)
    bitc <= bitc + 1;


//-- Shift register for storing the received bits
reg [9:0] raw_data;

always @(posedge clk)
  if (clk_baud == 1)
    raw_data <= {rx_r, raw_data[9:1]};

//-- Data register. Store the character received
always @(posedge clk)
  if (rstn == 0)
    data <= 0;
  else if (load)
    data[6:0] <= raw_data[7:1];

always @(posedge clk)
  if (rstn)
    if (load)
      data[7] <= raw_data[8];

//-------------------------------------------
//-- CONTROLLER  (Finite state machine)
//-------------------------------------------

//-- Receiver states
localparam IDLE = 2'd0;  //-- IDLEde reposo
localparam RECV = 2'd1;  //-- Receiving data
localparam LOAD = 2'd2;  //-- Storing the character received
localparam DAV = 2'd3;   //-- Data is available

//-- fsm states
reg [1:0] state;
reg [1:0] next_state;

//-- Transition between states
always @(posedge clk)
  if (!rstn)
    state <= IDLE;
  else
    state <= next_state;

//-- Control signal generation and next states
always @(*) begin

  //-- Default values
  next_state = state;      //-- Stay in the same state by default
  bauden = 0;
  clear = 0;
  load = 0;

  case(state)

    //-- Idle state
    //-- Remain in this state until a start bit is received in rx_r
    IDLE: begin
      clear = 1;
      rcv = 0;
      if (rx_r == 0)
        next_state = RECV;
    end

    //-- Receiving state
    //-- Turn on the baud generator and wait for the serial package to be received
    RECV: begin
      bauden = 1;
      rcv = 0;
      if (bitc == 4'd10)
        next_state = LOAD;
    end

    //-- Store the received character in the data register (1 cycle)
    LOAD: begin
      load = 1;
      rcv = 0;
      next_state = DAV;
    end

    //-- Data Available (1 cycle)
    DAV: begin
      rcv = 1;
      next_state = IDLE;
    end

    default:
      rcv = 0;

  endcase

end

endmodule

//-----------------------------------------------------------------------------
//-- Baudrate generator
//-- It generates a square signal, with a frequency for communicating at the given
//-- given baudrate
//-- The output is set to 1 only during one clock cycle. The rest of the time is 0
//-- Once enabled, the pulse is generated just in the middle of the period
//-- This is necessary for the implementation of the receptor
//--------------------------------------------------------------------------------
//-- (c) BQ. December 2015. written by Juan Gonzalez (obijuan)
//-----------------------------------------------------------------------------
//-- GPL license
//-----------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
//-- baudgen module
//--
//-- INPUTS:
//--     -clk: System clock (12 MHZ in the iceStick board)
//--     -clk_ena: clock enable:
//--            1. Normal working: The squeare signal is generated
//--            0: stoped. Output always 0
//-- OUTPUTS:
//--     - clk_out: Output signal. Pulse width: 1 clock cycle. Output not registered
//--                It tells the uart_rx when to sample the next bit
//--                       __                                         __
//--   ____________________| |________________________________________| |_____________________
//--   |                  ->  <- 1 clock cycle   |
//--   <-------  Period ------------------------->
//--
//---------------------------------------------------------------------------------------
module baudgen_rx #(
         parameter BAUDRATE = `B115200  //-- Default baudrate
)(
         input wire rstn,         //-- Reset (active low)
         input wire clk,          //-- System clock
         input wire clk_ena,      //-- Clock enable
         output wire clk_out      //-- Bitrate Clock output
);

//-- Number of bits needed for storing the baudrate divisor
localparam N = $clog2(BAUDRATE);

//-- Value for generating the pulse in the middle of the period
localparam M2 = (BAUDRATE >> 1);

//-- Counter for implementing the divisor (it is a BAUDRATE module counter)
//-- (when BAUDRATE is reached, it start again from 0)
reg [N-1:0] divcounter = 0;

//-- Contador módulo M
always @(posedge clk)

  if (!rstn)
    divcounter <= 0;

  else if (clk_ena)
    //-- Normal working: counting. When the maximum count is reached, it starts from 0
    divcounter <= (divcounter == BAUDRATE - 1) ? 0 : divcounter + 1;
  else
    //-- Counter fixed to its maximum value
    //-- When it is resumed it start from 0
    divcounter <= BAUDRATE - 1;

//-- The output is 1 when the counter is in the middle of the period, if clk_ena is active
//-- It is 1 only for one system clock cycle
assign clk_out = (divcounter == M2) ? clk_ena : 0;


endmodule
