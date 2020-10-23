// //
// // instruction set
// //

// //op_code [4:0]
// `define ACALL 	8'bxxx1_0001 // absolute call
// `define AJMP 	8'bxxx0_0001 // absolute jump

// //op_code [7:3]
// `define INC_R 	8'b0000_1xxx // increment Rn
// `define DEC_R 	8'b0001_1xxx // decrement reg Rn=Rn-1
// `define ADD_R 	8'b0010_1xxx // add A=A+Rx
// `define ADDC_R 	8'b0011_1xxx // add A=A+Rx+c
// `define ORL_R 	8'b0100_1xxx // or A=A or Rn
// `define ANL_R 	8'b0101_1xxx // and A=A^Rx
// `define XRL_R 	8'b0110_1xxx // XOR A=A XOR Rn
// `define MOV_CR 	8'b0111_1xxx // move Rn=constant
// `define MOV_RD 	8'b1000_1xxx // move (direct)=Rn
// `define SUBB_R 	8'b1001_1xxx // substract with borrow  A=A-c-Rn
// `define MOV_DR 	8'b1010_1xxx // move Rn=(direct)
// `define CJNE_R 	8'b1011_1xxx // compare and jump if not equal; Rx<>constant
// `define XCH_R 	8'b1100_1xxx // exchange A<->Rn
// `define DJNZ_R 	8'b1101_1xxx // decrement and jump if not zero
// `define MOV_R 	8'b1110_1xxx // move A=Rn
// `define MOV_AR 	8'b1111_1xxx // move Rn=A

// //op_code [7:1]
// `define ADD_I 	8'b0010_011x // add A=A+@Ri
// `define ADDC_I 	8'b0011_011x // add A=A+@Ri+c
// `define ANL_I 	8'b0101_011x // and A=A^@Ri
// `define CJNE_I 	8'b1011_011x // compare and jump if not equal; @Ri<>constant
// `define DEC_I 	8'b0001_011x // decrement indirect @Ri=@Ri-1
// `define INC_I 	8'b0000_011x // increment @Ri
// `define MOV_I 	8'b1110_011x // move A=@Ri
// `define MOV_ID 	8'b1000_011x // move (direct)=@Ri
// `define MOV_AI 	8'b1111_011x // move @Ri=A
// `define MOV_DI 	8'b1010_011x // move @Ri=(direct)
// `define MOV_CI 	8'b0111_011x // move @Ri=constant
// `define MOVX_IA 8'b1110_001x // move A=(@Ri)
// `define MOVX_AI 8'b1111_001x // move (@Ri)=A
// `define ORL_I 	8'b0100_011x // or A=A or @Ri
// `define SUBB_I 	8'b1001_011x // substract with borrow  A=A-c-@Ri
// `define XCH_I 	8'b1100_011x // exchange A<->@Ri
// `define XCHD 	8'b1101_011x // exchange digit A<->Ri
// `define XRL_I 	8'b0110_011x // XOR A=A XOR @Ri

// //op_code [7:0]
// `define ADD_D 	8'b0010_0101 // add A=A+(direct)
// `define ADD_C 	8'b0010_0100 // add A=A+constant
// `define ADDC_D 	8'b0011_0101 // add A=A+(direct)+c
// `define ADDC_C 	8'b0011_0100 // add A=A+constant+c
// `define ANL_D 	8'b0101_0101 // and A=A^(direct)
// `define ANL_C 	8'b0101_0100 // and A=A^constant
// `define ANL_AD 	8'b0101_0010 // and (direct)=(direct)^A
// `define ANL_DC 	8'b0101_0011 // and (direct)=(direct)^constant
// `define ANL_B 	8'b1000_0010 // and c=c^bit
// `define ANL_NB 	8'b1011_0000 // and c=c^!bit
// `define CJNE_D 	8'b1011_0101 // compare and jump if not equal; a<>(direct)
// `define CJNE_C 	8'b1011_0100 // compare and jump if not equal; a<>constant
// `define CLR_A 	8'b1110_0100 // clear accumulator
// `define CLR_C 	8'b1100_0011 // clear carry
// `define CLR_B 	8'b1100_0010 // clear bit
// `define CPL_A 	8'b1111_0100 // complement accumulator
// `define CPL_C 	8'b1011_0011 // complement carry
// `define CPL_B 	8'b1011_0010 // complement bit
// `define DA 		8'b1101_0100 // decimal adjust (A)
// `define DEC_A 	8'b0001_0100 // decrement accumulator a=a-1
// `define DEC_D 	8'b0001_0101 // decrement direct (direct)=(direct)-1
// `define DIV 	8'b1000_0100 // divide
// `define DJNZ_D 	8'b1101_0101 // decrement and jump if not zero (direct)
// `define INC_A 	8'b0000_0100 // increment accumulator
// `define INC_D 	8'b0000_0101 // increment (direct)
// `define INC_DP 	8'b1010_0011 // increment data pointer
// `define JB 		8'b0010_0000 // jump if bit set
// `define JBC	 	8'b0001_0000 // jump if bit set and clear bit
// `define JC 		8'b0100_0000 // jump if carry is set
// `define JMP_D 	8'b0111_0011 // jump indirect
// `define JNB 	8'b0011_0000 // jump if bit not set
// `define JNC 	8'b0101_0000 // jump if carry not set
// `define JNZ 	8'b0111_0000 // jump if accumulator not zero
// `define JZ 		8'b0110_0000 // jump if accumulator zero
// `define LCALL 	8'b0001_0010 // long call
// `define LJMP 	8'b0000_0010 // long jump
// `define MOV_D 	8'b1110_0101 // move A=(direct)
// `define MOV_C 	8'b0111_0100 // move A=constant
// `define MOV_AD 	8'b1111_0101 // move (direct)=A
// `define MOV_DD 	8'b1000_0101 // move (direct)=(direct)
// `define MOV_CD 	8'b0111_0101 // move (direct)=constant
// `define MOV_BC 	8'b1010_0010 // move c=bit
// `define MOV_CB 	8'b1001_0010 // move bit=c
// `define MOV_DP 	8'b1001_0000 // move dptr=constant(16 bit)
// `define MOVC_DP 8'b1001_0011 // move A=dptr+A
// `define MOVC_PC 8'b1000_0011 // move A=pc+A
// `define MOVX_PA 8'b1110_0000 // move A=(dptr)
// `define MOVX_AP 8'b1111_0000 // move (dptr)=A
// `define MUL 	8'b1010_0100 // multiply a*b
// `define NOP 	8'b0000_0000 // no operation
// `define ORL_D 	8'b0100_0101 // or A=A or (direct)
// `define ORL_C 	8'b0100_0100 // or A=A or constant
// `define ORL_AD 	8'b0100_0010 // or (direct)=(direct) or A
// `define ORL_CD 	8'b0100_0011 // or (direct)=(direct) or constant
// `define ORL_B 	8'b0111_0010 // or c = c or bit
// `define ORL_NB 	8'b1010_0000 // or c = c or !bit
// `define POP 	8'b1101_0000 // stack pop
// `define PUSH 	8'b1100_0000 // stack push
// `define RET 	8'b0010_0010 // return from subrutine
// `define RETI 	8'b0011_0010 // return from interrupt
// `define RL 		8'b0010_0011 // rotate left
// `define RLC 	8'b0011_0011 // rotate left thrugh carry
// `define RR 		8'b0000_0011 // rotate right
// `define RRC 	8'b0001_0011 // rotate right thrugh carry
// `define SETB_C 	8'b1101_0011 // set carry
// `define SETB_B 	8'b1101_0010 // set bit
// `define SJMP 	8'b1000_0000 // short jump
// `define SUBB_D 	8'b1001_0101 // substract with borrow  A=A-c-(direct)
// `define SUBB_C 	8'b1001_0100 // substract with borrow  A=A-c-constant
// `define SWAP 	8'b1100_0100 // swap A(0-3) <-> A(4-7)
// `define XCH_D 	8'b1100_0101 // exchange A<->(direct)
// `define XRL_D 	8'b0110_0101 // XOR A=A XOR (direct)
// `define XRL_C 	8'b0110_0100 // XOR A=A XOR constant
// `define XRL_AD 	8'b0110_0010 // XOR (direct)=(direct) XOR A
// `define XRL_CD 	8'b0110_0011 // XOR (direct)=(direct) XOR constant


// module ramController(clk,rst,addr8,addr16,read,r_data,w_addr,write,w_data,next_bank,R0,R1,R0_valid,R1_valid,R_invalid);

// input clk,rst;
// //reg [7:0] rom [0:65536];


// input [7:0] addr8;
// input [15:0] addr16;
// input read,write;
// input [7:0] w_addr;
// input [7:0] w_data;
// output [7:0] r_data;

// input [1:0] next_bank;
// output reg R0_valid, R1_valid;
// output R_invalid;

// output reg [7:0] R0;
// output reg [7:0] R1;
// reg [1:0] bank;

// reg Read;
// reg [7:0] R_addr;
// wire [7:0] R_data;

// localparam INIT = 2'b00, FETCH_R0 = 2'b01, FETCH_R1 = 2'b10, VALID = 2'b11;

// reg [1:0] state, next_state, prev_state;
// reg q;
// ram ram(clk,rst,Read,R_addr,R_data,write,w_addr,w_data);

// assign r_data = R_data;

// always@(posedge clk)
// 	if (rst) state <= INIT;
//   else state <= next_state;

// always@(posedge clk)
//   if (rst) prev_state <= INIT;
//   else prev_state <= state;

// always@(*) begin
//   next_state = state;
// 	case(state)
//     INIT:
//       next_state = FETCH_R0;
//     FETCH_R0:
//       if(R0_valid && R1_valid)  next_state = VALID;
//       else if (R0_valid)        next_state = FETCH_R1;
//       else if(!read)            next_state = FETCH_R1;
//     FETCH_R1:
//       if(R0_valid && R1_valid)  next_state = VALID;
//       else if (R1_valid)        next_state = FETCH_R0;
//       else if(!read)            next_state = VALID;
//     VALID:
//       if(!R0_valid)             next_state = FETCH_R0;
//       else if (!R1_valid)       next_state = FETCH_R1;
//   endcase
// end

// always@(*) begin
//   if (rst) begin
//     R_addr = 8'b0;
//     Read = 1'b0;
//   end
//   else if (read) begin
//     R_addr = addr8;
//     Read = 1'b1;
//   end
//   else begin
//     case(state)
//       FETCH_R0: begin
//         R_addr = {3'b0,next_bank,3'b0};
//         Read = 1'b1;
//       end
//       FETCH_R1: begin
//         R_addr = {3'b0,next_bank,3'b1};
//         Read = 1'b1;
//       end
//       default: begin
//         R_addr = addr8;
//         Read = read;
//       end
//     endcase
//   end
// end

// assign R_invalid = (bank != next_bank);

// always@(posedge clk)
//   if (rst) R0_valid <= 1'b0;
//   else if (write && (w_addr == {3'b0,next_bank,3'b0})) R0_valid <= 1'b1;
//   else if ((prev_state == FETCH_R0)&&(state != FETCH_R0)) R0_valid <= 1'b1;
//   else if (R_invalid) R0_valid <= 1'b0;

// always@(posedge clk)
//   if (rst) R1_valid <= 1'b0;
//   else if (write && (w_addr == {3'b0,next_bank,3'b1})) R1_valid <= 1'b1;
//   else if ((prev_state == FETCH_R1)&&(state != FETCH_R1)) R1_valid <= 1'b1;
//   else if (R_invalid) R1_valid <= 1'b0;

// always@(posedge clk)
//   if (rst) R0 <= 8'b0;
//   else if ((prev_state == FETCH_R0) && (state != FETCH_R0)) R0 <= R_data;
//   else if (write && (w_addr == {3'b0,next_bank,3'b0})) R0 <= w_data;

// always@(posedge clk)
//   if (rst) R1 <= 8'b0;
//   else if ((prev_state == FETCH_R1) && (state != FETCH_R1)) R1 <= R_data;
//   else if (write && (w_addr == {3'b0,next_bank,3'b1})) R1 <= w_data;

// always@(posedge clk)
// 	if (rst) bank <= 2'b0;
// 	else if (bank != next_bank) bank <= next_bank;

// endmodule



module ram(clk,rst,read,r_addr,r_data,write,w_addr,w_data);

input clk, rst;
input read,write;
input [7:0] r_addr,w_addr,w_data;
output reg [7:0] r_data;

reg [7:0] ram [0:255];

integer k;
initial
begin
for (k = 0; k < 256; k = k + 1)
begin
    ram[k] = 8'b0;
end
end
//  always @(posedge clk)
//         ramController.q <= rst;    //154
// always@(posedge clk)
//   if (rst) r_data <= 8'b0;
//   else if (read) r_data <= ram[r_addr];
//always@(posedge clk)
//	if(read) r_data <= ram[addr8];

always@(posedge clk) begin
	if (write) ram[w_addr] <= w_data;	
end

endmodule

