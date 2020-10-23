module topmodule(pcout,pcinc,stride_enable,mask_enable,rw,startMAU,doneMAU,mask_bit,ready,ackMAU,ackMCN,ackMEM,reqMEM,reqMCN,halt,rwMCN,rwMEM,insout,vx_index,mask_index,vx_select,rx_select,ry_select,bankSelect,rxout,ryout,vxout,doutMAU,doutMCN,doutMEM,addrMCN,addrMEM,clk,reset);

input clk,reset;
output [3:0]pcout;
output pcinc,stride_enable,mask_enable,rw,startMAU,doneMAU;
output mask_bit,ready,ackMAU,ackMCN,ackMEM,reqMEM,reqMCN,halt,rwMCN,rwMEM;
output [11:0]insout;
output [5:0]vx_index,mask_index;
output [2:0]vx_select,rx_select,ry_select,bankSelect;
output [31:0]rxout,ryout,vxout,doutMAU,doutMCN,doutMEM;
output [8:0]addrMCN;
output [5:0]addrMEM;

pc PC(pcout,pcinc,clk,reset);
ins_mem IMEM(insout,pcout);
ins_decoder IDEC(vx_select,rx_select,ry_select,stride_enable,mask_enable,rw,pcinc,startMAU,insout,doneMAU,clk,reset);
mask_reg VMR(mask_bit,mask_index);
scalar_regs REGS(rxout,ryout,rx_select,ry_select);
vector_regs VREGS(vxout,doutMAU,vx_select,vx_index,ackMAU,clk,reset);
mau MAU(doutMAU,vx_index,mask_index,addrMCN,reqMCN,rwMCN,ackMAU,doneMAU,vxout,rxout,ryout,doutMCN,stride_enable,mask_enable,mask_bit,rw,startMAU,ackMCN,halt,clk,reset);
mcn MCN(doutMCN,addrMEM,bankSelect,reqMEM,ackMCN,halt,rwMEM,doutMAU,doutMEM,addrMCN,rwMCN,reqMCN,ready,ackMEM,clk,reset);
data_mem DMEM(doutMEM,ready,ackMEM,doutMCN,addrMEM,bankSelect,rwMEM,reqMEM,clk,reset);

endmodule

module pc(pcout,inc,clk,reset);
output reg [3:0]pcout;
input inc,reset,clk;

always @(posedge clk)
begin
if(reset)
pcout<=4'd0;
else
pcout<=inc?pcout+4'd1:pcout;
end

endmodule

module ins_mem(insout,pcin);
output [11:0]insout;
input [3:0]pcin;

reg [11:0]ins_store[0:15];

assign insout=ins_store[pcin];

localparam vli=3'b000,vsi=3'b001,vls=3'b100,vss=3'b101,vlm=3'b010,vsm=3'b011,stp=3'b111;

initial
begin
ins_store[0]<={vsi,3'd1,3'd0,3'd0};//vsi v1,r0
ins_store[1]<={vli,3'd2,3'd0,3'd0};//vli v2,r0
ins_store[2]<={stp,3'd0,3'd0,3'd0};//stop
end

endmodule

module ins_decoder(vx_select,rx_select,ry_select,stride_enable,mask_enable,rw,pcinc,start,ins,done,clk,reset);
output reg [2:0]vx_select;
output reg [2:0]rx_select;
output reg [2:0]ry_select;
output reg stride_enable,mask_enable,rw,pcinc,start;
input [11:0]ins;
input done,clk,reset;

reg ps;

localparam idle=1'd0,busy=1'd1;
localparam vli=3'b000,vsi=3'b001,vls=3'b100,vss=3'b101,vlm=3'b010,vsm=3'b011;

always @(negedge clk)
begin
vx_select<=3'd1;
end

always @(negedge clk)
begin
if(reset)   
    begin
    vx_select<=3'd0;
    rx_select<=3'd0;
    ry_select<=3'd0;
    stride_enable<=1'd0;
    mask_enable<=1'd0;
    rw<=1'd0;
    pcinc<=1'd0;
    start<=1'd0;
    ps<=idle;
    end
else
    begin
    case(ps)
    idle:
        begin
        vx_select<=ins[8:6];
        rx_select<=ins[6:4];
        ry_select<=ins[4:2];
		pcinc<=1'd0;
        case(ins[11:9])
        vli:
            begin
            stride_enable<=1'd0;
            mask_enable<=1'd0;
            rw<=1'd0;
            start<=1'd1;
            ps<=busy;
            end
        vsi:
            begin
            stride_enable<=1'd0;
            mask_enable<=1'd0;
            rw<=1'd1;
            start<=1'd1;
            ps<=busy;
            end
        vls:
            begin
            stride_enable<=1'd1;
            mask_enable<=1'd0;
            rw<=1'd0;
            start<=1'd1;
            ps<=busy;
            end
        vss:
            begin
            stride_enable<=1'd1;
            mask_enable<=1'd0;
            rw<=1'd1;
            start<=1'd1;
            ps<=busy;
            end
        vlm:
            begin
            stride_enable<=1'd0;
            mask_enable<=1'd1;
            rw<=1'd0;
            start<=1'd1;
            ps<=busy;
            end
        vsm:
            begin
            stride_enable<=1'd0;
            mask_enable<=1'd1;
            rw<=1'd1;
            start<=1'd1;
            ps<=busy;
            end
        default:
            begin
            stride_enable<=1'd0;
            mask_enable<=1'd0;
            rw<=1'd0;
            start<=1'd0;
            end
        endcase
        end
    busy:
        begin
        start<=1'd0;
        if(done)
        begin
        pcinc<=1'd1;
        ps<=idle;
        end
        end
    endcase
    end
end

endmodule

module mask_reg(mask_bit,index_select);
output mask_bit;
input [5:0]index_select;

reg masks[0:63];

assign mask_bit=masks[index_select];

integer x;

initial
begin
for(x=0;x<=32'd63;x=x+32'd1)
masks[x]=1'd1;
masks[1]=1'd0;
masks[3]=1'd0;
masks[5]=1'd0;
masks[7]=1'd0;
end

endmodule

module scalar_regs(rxout,ryout,rx_select,ry_select);
output [31:0]rxout,ryout;
input [2:0]rx_select,ry_select;

reg [31:0]regs[0:7];

assign rxout=regs[rx_select];
assign ryout=regs[ry_select];

initial
begin
regs[0]<=32'd0;
regs[1]<=32'd1;
regs[2]<=32'd2;
regs[3]<=32'd3;
regs[4]<=32'd4;
regs[5]<=32'd5;
regs[6]<=32'd6;
regs[7]<=32'd7;
end

endmodule

module vector_regs(vxout,datain,vx_select,index_select,mak,clk,reset);
output [31:0]vxout;
input [31:0]datain;
input [2:0]vx_select;
input [5:0]index_select;
input mak,clk,reset;

reg [31:0]vx[0:7][0:63];

assign vxout=vx[vx_select][index_select];

always @(negedge clk)
begin
if(!reset && mak)vx[vx_select][index_select]<=datain;
//$display("%d %d %d %d %d %d %d %d",vx[2][0],vx[2][1],vx[2][2],vx[2][3],vx[2][4],vx[2][5],vx[2][6],vx[2][7]);
end

integer x;

initial
begin
for(x=0;x<=32'd63;x=x+32'd1)
vx[1][x]<=x;
for(x=0;x<=32'd63;x=x+32'd1)
vx[2][x]<=32'd0;
end

endmodule

module mau(dout,vx_index,mask_index,memaddr,startMCN,rw_out,mak_out,done,vx,rx,ry,din,stride_enable,mask_enable,mask_bit,rw,start,mak,halt,clk,reset);
output reg [31:0]dout;
output [5:0]vx_index,mask_index;
output reg mak_out;
output reg [8:0]memaddr;
output reg startMCN,done;
output rw_out;
input [31:0]vx,rx,ry,din;
input mask_enable,stride_enable,mask_bit,rw,start,mak,halt,clk,reset;

wire [31:0]stride;
reg mask;
reg [6:0]index_select;
reg [6:0]mak_count;
reg [6:0]num_masks;

assign rw_out=rw;
assign stride=stride_enable?ry:32'd1;
assign vx_index=rw?index_select:index_select-7'd5;
assign mask_index=index_select;

localparam idle=1'd0, busy=1'd1;
reg ps;

always @(posedge clk)
begin

if(reset)
begin
index_select<=7'd0;
memaddr<=9'd0;
mask<=1'd0;
dout<=32'd0;
mak_out<=1'd0;
mak_count<=7'd0;
num_masks<=7'd64;
done<=1'd0;
startMCN<=1'd0;
ps<=idle;
end
else
begin
case(ps)

    idle:
    begin
    index_select=7'd0;
	memaddr=rx;
	#1
	mask=mask_enable?mask_bit:1'd1;
	dout=rw?vx:din;
	mak_out=1'd0;
	mak_count=7'd0;
	num_masks=mask?7'd63:7'd64;
    done=1'd0;
    startMCN=mask&start;
	ps=start?busy:idle;
    end
    
    busy:
    begin
    index_select=(!halt)?index_select+7'd1:index_select;
    memaddr=((index_select<=7'd64)&(!halt))?rx+index_select*stride:memaddr;
    #1
    mask=mask_enable?mask_bit:1'd1;
    dout=rw?vx:din;
    mak_out=rw?1'd0:mak;
    if((index_select<=7'd64)&(!mask))
    num_masks=num_masks-7'd1;
    if(mak_count==num_masks) mak_count=7'd0;
    else if(mak) mak_count=mak_count+7'd1;
    done=(mak_count==num_masks);
    startMCN=mask&(index_select<=7'd64);
    ps=(mak_count==num_masks)?idle:busy;
    end

endcase
end
end

endmodule

module mcn(dout,addrOut,bankSelect,req,ack,halt,rwMEM,dinMAU,dinMEM,addrIn,rw,enable,ready,done,clk,reset);
output reg [31:0]dout;
output reg [5:0]addrOut;
output reg [2:0]bankSelect;
output reg req,ack,halt;
output rwMEM;
input [31:0]dinMAU,dinMEM;
input [8:0]addrIn;
input rw,enable,ready,done,clk,reset;

assign rwMEM=rw;

always @(negedge clk)
begin
if(reset) 
begin 
dout<=32'd0;
addrOut<=6'd0;
bankSelect<=3'd0;
req<=1'd0; 
halt<=1'd0;
ack<=1'd0; 
end
else
begin
ack=done;
dout=rw?dinMAU:dinMEM;
addrOut=addrIn[8:3];
bankSelect=addrIn[2:0];
req=ready&enable;
halt=~ready&enable;
end
end
endmodule

module data_mem(dout,ready,done,din,addr,bank_select,rw,start,clk,reset);
output [31:0]dout;
output ready,done;
input [31:0]din;
input [5:0]addr;
input [2:0]bank_select;
input rw,start,clk,reset;
wire [31:0]bank_dout[0:7];
wire bank_ready[0:7];
wire bank_start[0:7];
wire bank_done[0:7];
wire [2:0]bank_select_reg;

assign ready=bank_ready[bank_select];
assign dout=bank_dout[bank_select_reg];

assign bank_start[0]=(bank_select==3'd0)?start:1'd0;
assign bank_start[1]=(bank_select==3'd1)?start:1'd0;
assign bank_start[2]=(bank_select==3'd2)?start:1'd0;
assign bank_start[3]=(bank_select==3'd3)?start:1'd0;
assign bank_start[4]=(bank_select==3'd4)?start:1'd0;
assign bank_start[5]=(bank_select==3'd5)?start:1'd0;
assign bank_start[6]=(bank_select==3'd6)?start:1'd0;
assign bank_start[7]=(bank_select==3'd7)?start:1'd0;

assign bank_select_reg=bank_done[0]?3'd0:bank_done[1]?3'd1:bank_done[2]?3'd2:bank_done[3]?3'd3:bank_done[4]?3'd4:bank_done[5]?3'd5:bank_done[6]?3'd6:3'd7;
assign done=bank_done[0]|bank_done[1]|bank_done[2]|bank_done[3]|bank_done[4]|bank_done[5]|bank_done[6]|bank_done[7];

mem_bank M0(bank_dout[0],bank_ready[0],bank_done[0],din,addr,rw,bank_start[0],clk,reset);
mem_bank M1(bank_dout[1],bank_ready[1],bank_done[1],din,addr,rw,bank_start[1],clk,reset);
mem_bank M2(bank_dout[2],bank_ready[2],bank_done[2],din,addr,rw,bank_start[2],clk,reset);
mem_bank M3(bank_dout[3],bank_ready[3],bank_done[3],din,addr,rw,bank_start[3],clk,reset);
mem_bank M4(bank_dout[4],bank_ready[4],bank_done[4],din,addr,rw,bank_start[4],clk,reset);
mem_bank M5(bank_dout[5],bank_ready[5],bank_done[5],din,addr,rw,bank_start[5],clk,reset);
mem_bank M6(bank_dout[6],bank_ready[6],bank_done[6],din,addr,rw,bank_start[6],clk,reset);
mem_bank M7(bank_dout[7],bank_ready[7],bank_done[7],din,addr,rw,bank_start[7],clk,reset);

endmodule

module mem_bank(dout,ready,done,din,addr,rw,start,clk,reset);
output reg [31:0]dout;
output reg ready,done;
input [31:0]din;
input [5:0]addr;
input rw,start,clk,reset;

reg [31:0]mem[0:63];
reg [31:0]din_reg;
reg [5:0]addr_reg;

localparam idle=2'd0,phase1=2'd1,phase2=2'd2,phase3=2'd3;
reg [1:0]ps;

always @(posedge clk)
begin
if(reset)
begin
dout<=32'd0;
ready<=1'd1;
done<=1'd0;
ps<=idle;
end
else
begin
case(ps)

idle:
begin
ready<=1'd1;
done<=1'd0;
if(start)
begin
if(rw)
din_reg<=din;
addr_reg<=addr;
ps<=phase1;
end
end

phase1:
begin
ready<=1'd0;
ps<=phase2;
end

phase2:
ps<=phase3;

phase3:
begin
if(rw)
mem[addr_reg]<=din_reg;
else
dout<=mem[addr_reg];
done<=1'd1;
ps<=idle;
end

endcase
$display("%d %d %d %d %d %d %d %d",mem[0],mem[1],mem[2],mem[3],mem[4],mem[5],mem[6],mem[7]);
end
end

initial
begin
mem[0]<=32'd0;
mem[1]<=32'd0;
mem[2]<=32'd0;
mem[3]<=32'd0;
mem[4]<=32'd0;
mem[5]<=32'd0;
mem[6]<=32'd0;
mem[7]<=32'd0;
end

endmodule
