`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/10/07 15:04:43
// Design Name: 
// Module Name: add_8
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module add_8(
	input [7:0] X,Y, 
	input Cin, 
	output reg[7:0] S, 
	output reg C, 
	output OF 
     ); 
	always @ (X or Y or Cin) 
	{ C,S } = X + Y + Cin; 
	assign OF = (X[7] == Y[7] && (S[7] != X[7])); 
	assign OF = (X[6] == Y[6] && (S[6] != X[6]));  
endmodule


module ALU_8(
    input Cin,
    input [7:0] X,
    input [7:0] Y,
    output reg [7:0] S,
    output reg OF,
    output reg ZF,
    output reg Cout
    );
    always@(*)
    begin
    	if(Cin)
			{Cout,S}=X+~Y+Cin;
    	else
    		{Cout,S}=X+Y+Cin;
    	OF=((X[7]==Y[7])&&(S[7]!=X[7]));
		ZF= (S==8'b00000000);
   	end
endmodule

module test_add_8();
	reg [7:0]X; 
	reg [7:0]Y; 
	reg Cin; 
	wire [7:0]S; 
	wire C; 
	wire OF;  
	add_8 a( 
    .X(X), 
    .Y(Y), 
    .Cin(Cin), 
    .S(S), 
    .C(C), 
    .OF(OF) 
	);  
	initial begin 
			Cin = 1'b0; 
			X = 8'b00000000;Y = 8'b00000001;#10; 
			X = 8'b01111111;Y = 8'b00000001;#10; 
			X = 8'b11111111;Y = 8'b00000001;#10; 
			X = 8'b11111111;Y = 8'b11111111;#10; 
			X = 8'b10000000;Y = 8'b10000000;#10; 
			X = 8'b01000000;Y = 8'b01000000;#10; 
			X = 8'b01111111;Y = 8'b11111111;#10; 
			X = 8'b00000000;Y = 8'b00000000;#10; 
			Cin = 1'b1; 
			X = 8'b00000000;Y = 8'b00000001;#10; 
			X = 8'b01111111;Y = 8'b00000001;#10; 
			X = 8'b11111111;Y = 8'b00000001;#10; 
			X = 8'b11111111;Y = 8'b11111111;#10; 
			X = 8'b10000000;Y = 8'b10000000;#10; 
			X = 8'b01000000;Y = 8'b01000000;#10; 
			X = 8'b01111111;Y = 8'b11111111;#10; 
			X = 8'b00000000;Y = 8'b00000000;#10; 
			end 
endmodule


module test_ALU_8();
	reg Cin;
	reg [7:0] X;
	reg [7:0] Y;
	wire [7:0] S;
	wire OF;
	wire ZF;
	wire Cout;
	ALU_8 a(
			.Cin(Cin),
			.X(X),
			.Y(Y),
			.S(S),
			.OF(OF),
			.ZF(ZF),
			.Cout(Cout)
			);
	initial begin
		Cin=1'b0;
		X=8'b00000000; Y=8'b00000000;#10;
					   Y=8'b00000001;#10;
		X=8'b01111111; Y=8'b00000000;#10;
					   Y=8'b00000001;#10;
					   Y=8'b01111111;#10;
					   Y=8'b11111111;#10;
					   Y=8'b10000000;#10;
		X=8'b10000000; Y=8'b00000001;#10;
					   Y=8'b01111111;#10;
					   Y=8'b11111111;#10;
					   Y=8'b10000001;#10;
		X=8'b11111111; Y=8'b00000001;#10;
					   Y=8'b01111111;#10;
					   Y=8'b11111111;#10;
					   Y=8'b10000001;#10;
		Cin=1'b1;
		X=8'b00000000; Y=8'b00000000;#10;
					   Y=8'b00000001;#10;
		X=8'b01111111; Y=8'b00000000;#10;
					   Y=8'b00000001;#10;
					   Y=8'b01111111;#10;
					   Y=8'b11111111;#10;
					   Y=8'b10000000;#10;
		X=8'b10000000; Y=8'b00000001;#10;
					   Y=8'b01111111;#10;
					   Y=8'b11111111;#10;
					   Y=8'b10000001;#10;
		X=8'b11111111; Y=8'b00000001;#10;
					   Y=8'b01111111;#10;
					   Y=8'b11111111;#10;
					   Y=8'b10000001;#10;		
		end
endmodule
