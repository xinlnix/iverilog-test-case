`timescale 1ns / 1ps
`default_nettype wire
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    17:30:26 02/08/2018 
// Module Name:    boy 
// Project Name:   VerilogBoy
// Description: 
//   VerilogBoy portable top level file. This is the file connect the CPU and 
//   all the peripherals in the LR35902 together.
// Dependencies: 
//   cpu
// Additional Comments: 
//   Hardware specific code should be implemented outside of this file
//   So normally in an implementation, this will not be the top level.
////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    17:30:26 02/08/2018 
// Module Name:    None
// Project Name:   VerilogBoy
// Description: 
//   Common definitions for VerilogBoy. Use as a header inclusion.
// Dependencies: 
// 
// Additional Comments: 
//   It is also used in Verilated simulation
//////////////////////////////////////////////////////////////////////////////////

/**
    234,248
*/


`define ALU_ADD 3'b000
`define ALU_ADC 3'b001
`define ALU_SUB 3'b010
`define ALU_SBC 3'b011
`define ALU_AND 3'b100
`define ALU_XOR 3'b101
`define ALU_OR  3'b110
`define ALU_CP  3'b111

`define INT_LCDC   0
`define INT_STAT   1
`define INT_TIMER  2
`define INT_SERIAL 3
`define INT_JOYPAD 4

`define ALU_SRC_A_ACC               2'b00
`define ALU_SRC_A_PC                2'b01
`define ALU_SRC_A_REG               2'b10
`define ALU_SRC_A_DB                2'b11
`define ALU_SRC_B_ACC               3'b000
`define ALU_SRC_B_CARRY             3'b001
`define ALU_SRC_B_ZERO              3'b010
`define ALU_SRC_B_ONE               3'b011
`define ALU_SRC_B_H                 3'b100
`define ALU_SRC_B_L                 3'b101
`define ALU_SRC_B_ABSIMM            3'b110
`define ALU_SRC_B_IMM               3'b111
`define ALU_OP_PREFIX_NORMAL        2'b00
`define ALU_OP_PREFIX_SHIFT_ROTATE  2'b01
`define ALU_OP_PREFIX_SPECIAL       2'b10
`define ALU_OP_PREFIX_CB            2'b11
`define ALU_OP_SRC_INSTR_5TO3       2'b00
`define ALU_OP_SRC_INSTR_7TO6       2'b01
`define ALU_OP_SRC_ADD_FTOR         2'b10
`define ALU_OP_SRC_SUB_ATOF         2'b11
`define ALU_OP_SIGNED_FORCE         1'b1
`define ALU_OP_SIGNED_AUTO          1'b0
`define ALU_DST_ACC                 2'b00
`define ALU_DST_PC                  2'b01
`define ALU_DST_REG                 2'b10
`define ALU_DST_DB                  2'b11
`define PC_SRC_REG                  2'b00
`define PC_SRC_RST                  2'b01
`define PC_SRC_TEMP                 2'b10
`define PC_WRITE_ENABLE             1'b1
`define RF_SEL_B                    3'b000
`define RF_SEL_C                    3'b001
`define RF_SEL_D                    3'b010
`define RF_SEL_E                    3'b011
`define RF_SEL_H                    3'b100
`define RF_SEL_L                    3'b101
`define RF_SEL_SP_H                 3'b110
`define RF_SEL_SP_L                 3'b111
`define RF_SEL_BC                   3'b001
`define RF_SEL_DE                   3'b011
`define RF_SEL_HL                   3'b101
`define RF_SEL_SP                   3'b111
`define BUS_OP_IDLE                 2'b00
`define BUS_OP_IF                   2'b01
`define BUS_OP_WRITE                2'b10
`define BUS_OP_READ                 2'b11
`define DB_SRC_ACC                  2'b00
`define DB_SRC_ALU                  2'b01
`define DB_SRC_REG                  2'b10
`define DB_SRC_DB                   2'b11
`define AB_SRC_PC                   2'b00
`define AB_SRC_TEMP                 2'b01
`define AB_SRC_REG                  2'b10
`define AB_SRC_SP                   2'b11
`define CT_OP_IDLE                  2'b00
`define CT_OP_PC_INC                2'b01
`define CT_OP_SP_DEC                2'b10
`define CT_OP_SP_INC                2'b11
`define FLAGS_ZNHC                  2'b00
`define FLAGS_x0HC                  2'b01
`define FLAGS_00HC                  2'b10
`define FLAGS_ZNHx                  2'b11


module boy(
    input wire rst, // Async Reset Input
    input wire clk, // 4.19MHz Clock Input
    output wire phi, // 1.05MHz Reference Clock Output
    // Cartridge interface
    output wire [15:0] a, // Address Bus
    output wire [7:0] dout,  // Data Bus
    input wire [7:0] din,
    output wire wr, // Write Enable
    output wire rd, // Read Enable
    // Keyboard input
    input wire [7:0] key,
    // LCD output
    output wire hs, // Horizontal Sync Output
    output wire vs, // Vertical Sync Output
    output wire cpl, // Pixel Data Latch
    output wire [1:0] pixel, // Pixel Data
    output wire valid,
    // Sound output
    output reg [15:0] left,
    output reg [15:0] right,
    // Debug interface
    output wire done,
    output wire fault
    );
    
    // CPU
    wire        cpu_rd;            // CPU Read Enable
    wire        cpu_wr;            // CPU Write Enable
    reg  [7:0]  cpu_din;           // CPU Data Bus, to CPU
    wire [7:0]  cpu_dout;          // CPU Data Bus, from CPU
    wire [15:0] cpu_a;             // CPU Address Bus
    wire [4:0]  cpu_int_en;        // CPU Interrupt Enable input
    wire [4:0]  cpu_int_flags_in;  // CPU Interrupt Flags input
    wire [4:0]  cpu_int_flags_out; // CPU Interrupt Flags output
    wire [1:0]  cpu_ct;            // 0-3 T cycle number inside one M cycle
    
    cpu cpu(
        .clk(clk),
        .rst(rst),
        .phi(phi),
        .ct(cpu_ct),
        .a(cpu_a),
        .dout(cpu_dout),
        .din(cpu_din),
        .rd(cpu_rd),
        .wr(cpu_wr),
        .int_en(cpu_int_en),
        .int_flags_in(cpu_int_flags_in),
        .int_flags_out(cpu_int_flags_out),
        .key_in(key),
        .done(done),
        .fault(fault));
        
    // High RAM
    reg [7:0] high_ram [0:127];
    wire high_ram_rd = cpu_rd;
    reg high_ram_wr;
    wire [6:0] high_ram_a = cpu_a[6:0];
    wire [7:0] high_ram_din = cpu_dout;
    reg [7:0] high_ram_dout;
    always @(posedge clk) begin
        if (high_ram_wr)
            high_ram[high_ram_a] <= high_ram_din;
        else
            high_ram_dout <= (high_ram_rd) ? high_ram[high_ram_a] : 8'bx;
    end

    //DMA
    wire dma_rd; // DMA Memory Write Enable
    wire dma_wr; // DMA Memory Read Enable
    wire [15:0] dma_a; // Main Address Bus
    reg  [7:0]  dma_din; // Main Data Bus
    wire [7:0]  dma_dout;
    wire [7:0]  dma_mmio_dout;
    reg dma_mmio_wr; // actually wire
    wire dma_occupy_extbus; // 0x0000 - 0x7FFF, 0xA000 - 0xFFFF
    wire dma_occupy_vidbus; // 0x8000 - 0x9FFF
    wire dma_occupy_oambus; // 0xFE00 - 0xFE9F
    dma dma(
        .clk(clk),
        .rst(rst),
        .dma_rd(dma_rd),
        .dma_wr(dma_wr),
        .dma_a(dma_a),
        .dma_din(dma_din),
        .dma_dout(dma_dout),
        .mmio_wr(dma_mmio_wr),
        .mmio_din(cpu_dout),
        .mmio_dout(dma_mmio_dout),
        .dma_occupy_extbus(dma_occupy_extbus),
        .dma_occupy_vidbus(dma_occupy_vidbus),
        .dma_occupy_oambus(dma_occupy_oambus)
    );

    // Interrupt
    // int_req is the request signal from peripherals.
    // When an interrupt is generated, the peripheral should send a pulse on
    // the int_req for exactly one clock (using 4MHz clock).
    wire [4:0] int_req;

    wire int_key_req;  
    wire int_serial_req;
    wire int_serial_ack;
    wire int_tim_req;
    wire int_tim_ack;
    wire int_lcdc_req;
    wire int_lcdc_ack;
    wire int_vblank_req;
    wire int_vblank_ack;

    assign int_req[4] = int_key_req;
    assign int_req[3] = int_serial_req;
    assign int_req[2] = int_tim_req;
    assign int_req[1] = int_lcdc_req;
    assign int_req[0] = int_vblank_req;

    //reg reg_ie_rd;
    reg reg_ie_wr;
    reg [4:0] reg_ie;
    wire [4:0] reg_ie_din = cpu_dout[4:0];
    wire [4:0] reg_ie_dout;
    always @(posedge clk) begin
        if (reg_ie_wr)
            reg_ie <= reg_ie_din;
    end

    always @(posedge clk) begin
        if (reg_ie_wr)
            reg_ie[0] <= 0;
    end

    assign reg_ie_dout = reg_ie;
    assign cpu_int_en = reg_ie_dout;

    // Interrupt may be manually triggered
    // int_req should only stay high for only 1 cycle for each interrupt
    //reg reg_if_rd;
    reg reg_if_wr;
    reg [4:0] reg_if;
    wire [4:0] reg_if_din = cpu_dout[4:0];
    wire [4:0] reg_if_dout;
    always @(posedge clk) begin
        if (reg_if_wr)
            reg_if <= reg_if_din | int_req;
        else
            reg_if <= cpu_int_flags_out | int_req;
    end
    assign reg_if_dout = reg_if | int_req;
    assign cpu_int_flags_in = reg_if_dout;

    assign int_serial_ack = reg_if[3];
    assign int_tim_ack = reg_if[2];
    assign int_lcdc_ack = reg_if[1];
    assign int_vblank_ack = reg_if[0];

    // PPU
    wire [7:0] ppu_mmio_dout;
    reg ppu_mmio_wr; // actually wire
    wire [15:0] vram_a;
    wire [7:0] vram_dout;
    //wire [7:0] vram_din;
    wire vram_rd;
    wire vram_wr;
    reg vram_cpu_wr;
    wire [15:0] oam_a;
    wire [7:0] oam_dout;
    wire [7:0] oam_din;
    wire oam_rd;
    wire oam_wr;
    reg oam_cpu_wr;

    assign vram_a = (dma_occupy_vidbus) ? (dma_a) : (cpu_a);
    //assign vram_din = (dma_occupy_vidbus) ? (dma_dout) : (cpu_dout);
    assign vram_rd = (dma_occupy_vidbus) ? (dma_rd) : (cpu_rd);
    assign vram_wr = (dma_occupy_vidbus) ? (1'b0) : (vram_cpu_wr);
    assign oam_a = (dma_occupy_oambus) ? (dma_a) : (cpu_a);
    assign oam_din = (dma_occupy_oambus) ? (dma_dout) : (cpu_dout);
    assign oam_rd = (dma_occupy_oambus) ? (1'b0) : (cpu_rd);
    assign oam_wr = (dma_occupy_oambus) ? (dma_wr) : (oam_cpu_wr);

    ppu ppu(
        .clk(clk),
        .rst(rst),
        .mmio_a(cpu_a), // mmio bus is always accessable to CPU
        .mmio_dout(ppu_mmio_dout),
        .mmio_din(cpu_dout),
        .mmio_rd(cpu_rd),
        .mmio_wr(ppu_mmio_wr),
        .vram_a(vram_a),
        .vram_dout(vram_dout),
        .vram_din(cpu_dout), // DMA never writes to VRAM
        .vram_rd(vram_rd),
        .vram_wr(vram_wr),
        .oam_a(oam_a),
        .oam_dout(oam_dout),
        .oam_din(oam_din),
        .oam_rd(oam_rd),
        .oam_wr(oam_wr),
        .int_vblank_req(int_vblank_req),
        .int_lcdc_req(int_lcdc_req),
        .int_vblank_ack(int_vblank_ack),
        .int_lcdc_ack(int_lcdc_ack),
        .cpl(cpl), // Pixel clock
        .pixel(pixel), // Pixel Data (2bpp)
        .valid(valid),
        .hs(hs), // Horizontal Sync, Low Active
        .vs(vs)  // Vertical Sync, Low Active
    );

    // Timer
    wire [7:0] timer_dout;
    reg timer_wr; // actually wire

    timer timer(
        .clk(clk),
        .rst(rst),
        .ct(cpu_ct),
        .a(cpu_a),
        .dout(timer_dout),
        .din(cpu_dout),
        .rd(cpu_rd),
        .wr(timer_wr),
        .int_tim_req(int_tim_req),
        .int_tim_ack(int_tim_ack)
    );
    
    // Dummy Serial
    wire [7:0] serial_dout;
    reg serial_wr; // actually wire

    serial serial(
        .clk(clk),
        .rst(rst),
        .a(cpu_a),
        .dout(serial_dout),
        .din(cpu_dout),
        .rd(cpu_rd),
        .wr(serial_wr),
        .int_serial_req(int_serial_req),
        .int_serial_ack(int_serial_ack)
    );
    
    // Sound
    wire [7:0] sound_dout;
    reg sound_wr; // wire
    wire [15:0] left_pre;
    wire [15:0] right_pre;
    
    sound sound(
        .clk(clk),
        .rst(rst),
        .a(cpu_a),
        .dout(sound_dout),
        .din(cpu_dout),
        .rd(cpu_rd),
        .wr(sound_wr),
        .left(left_pre),
        .right(right_pre)
        /*.ch1_level(ch1_level),
        .ch2_level(ch2_level),
        .ch3_level(ch3_level),
        .ch4_level(ch4_level)*/
    );
    
    always @(posedge clk) begin
        left <= left_pre;
        right <= right_pre;
    end

    // Boot ROM Enable Register
    reg brom_disable;
    reg brom_disable_wr; // actually wire
    always @(posedge clk, posedge rst) begin
        if (rst)
            brom_disable <= 1'b0;
        else
            if (brom_disable_wr && (!brom_disable))
                brom_disable <= cpu_dout[0];
    end

    wire [7:0] brom_dout;
    brom brom(
        .a(cpu_a[7:0]),
        .d(brom_dout)
    );

    // Work RAM
    wire [7:0] wram_dout;
    wire [12:0] wram_a;
    wire wram_wr;
    reg wram_cpu_wr; // actually wire

    assign wram_a = (dma_occupy_extbus) ? (dma_a[12:0]) : (cpu_a[12:0]);
    assign wram_wr = (dma_occupy_extbus) ? (1'b0) : (wram_cpu_wr);

    singleport_ram #(
        .WORDS(8192)
    ) br_wram (
        .clka(clk),
        .wea(wram_wr),
        .addra(wram_a), 
        .dina(cpu_dout), // DMA never writes to Work RAM
        .douta(wram_dout)
    );

    // Keypad
    wire [7:0] keypad_reg;
    reg keypad_reg_wr; // actually wire
    reg [1:0] keypad_high;
    always @(posedge clk, posedge rst) begin
        if (rst)
            keypad_high <= 2'b11;
        else
            if (keypad_reg_wr)
                keypad_high <= cpu_dout[5:4];
    end
    assign keypad_reg[7:6] = 2'b11;
    assign keypad_reg[5:4] = keypad_high[1:0];
    assign keypad_reg[3:0] = 
        ~(((keypad_high[1] == 1'b1) ? (key[7:4]) : 4'h0) | 
          ((keypad_high[0] == 1'b1) ? (key[3:0]) : 4'h0)); 
    assign int_key_req = (keypad_reg[3:0] != 4'hf) ? (1'b1) : (1'b0);

    // External Bus
    reg ext_cpu_wr;  // wire
    assign a = (dma_occupy_extbus) ? (dma_a) : (cpu_a);
    assign dout = cpu_dout; // DMA never writes to external bus
    assign wr = (dma_occupy_extbus) ? (1'b0) : (ext_cpu_wr);
    assign rd = (dma_occupy_extbus) ? (dma_rd) : (cpu_rd);

    // Bus Multiplexing, CPU
    always @(*) begin
        reg_ie_wr = 1'b0;
        reg_if_wr = 1'b0;
        keypad_reg_wr = 1'b0;
        timer_wr = 1'b0;
        serial_wr = 1'b0;
        dma_mmio_wr = 1'b0;
        brom_disable_wr = 1'b0;
        high_ram_wr = 1'b0;
        sound_wr = 1'b0;
        ppu_mmio_wr = 1'b0;
        vram_cpu_wr = 1'b0;
        oam_cpu_wr = 1'b0;
        wram_cpu_wr = 1'b0;
        ext_cpu_wr = 1'b0;
        // -- These are exclusive to CPU --
        if (cpu_a == 16'hffff) begin  // 0xFFFF - IE
            //reg_ie_rd = bus_rd;
            reg_ie_wr = cpu_wr;
            cpu_din = {3'b0, reg_ie_dout};
        end
        else if (cpu_a == 16'hff0f) begin // 0xFF0F - IF
            //reg_if_rd = bus_rd;
            reg_if_wr = cpu_wr;
            cpu_din = {3'b111, reg_if_dout};
        end
        else if (cpu_a == 16'hff00) begin // 0xFF00 - Keypad
            keypad_reg_wr = cpu_wr;
            cpu_din = keypad_reg;
        end
        else if ((cpu_a == 16'hff04) || (cpu_a == 16'hff05) ||  // Timer
                (cpu_a == 16'hff06) || (cpu_a == 16'hff07)) begin
            timer_wr = cpu_wr;
            cpu_din = timer_dout;
        end
        else if ((cpu_a == 16'hff01) || (cpu_a == 16'hff02)) begin // Serial
            serial_wr = cpu_wr;
            cpu_din = serial_dout;
        end
        else if (cpu_a == 16'hff46) begin // 0xFF46 - DMA
            dma_mmio_wr = cpu_wr;
            cpu_din = dma_mmio_dout;
        end
        else if (cpu_a == 16'hff50) begin // 0xFF50 - BROM DISABLE
            brom_disable_wr = cpu_wr;
            cpu_din = {7'b0, brom_disable};
        end
        else if (cpu_a >= 16'hff80) begin // 0xFF80 - High RAM
            high_ram_wr = cpu_wr;
            cpu_din = high_ram_dout;
        end
        else if ((cpu_a >= 16'hff10 && cpu_a <= 16'hff1e) ||
            (cpu_a >= 16'hff20 && cpu_a <= 16'hff26) ||
            (cpu_a >= 16'hff30 && cpu_a <= 16'hff3f)) begin // Sound
            sound_wr = cpu_wr;
            cpu_din = sound_dout;
        end
        else if (cpu_a >= 16'hff40 && cpu_a <= 16'hff4b) begin // PPU MMIO
            ppu_mmio_wr = cpu_wr;
            cpu_din = ppu_mmio_dout;
        end
        else if ((cpu_a <= 16'h00ff) && (!brom_disable)) begin // Boot ROM
            cpu_din = brom_dout;
        end 
        // -- These are shared between CPU and DMA --
        else if (cpu_a >= 16'h8000 && cpu_a <= 16'h9fff) begin // VRAM
            vram_cpu_wr = cpu_wr;
            cpu_din = (dma_occupy_vidbus) ? (8'hff) : (vram_dout);
        end
        else if (cpu_a >= 16'hfe00 && cpu_a <= 16'hfe9f) begin // OAM
            oam_cpu_wr = cpu_wr;
            cpu_din = (dma_occupy_oambus) ? (8'hff) : (oam_dout);
        end
        else if ((cpu_a >= 16'hc000 && cpu_a <= 16'hdfff) ||
                 (cpu_a >= 16'he000 && cpu_a <= 16'hfdff)) begin // WRAM
            wram_cpu_wr = cpu_wr;
            cpu_din = (dma_occupy_extbus) ? (8'hff) : (wram_dout);
        end
        else if ((cpu_a <= 16'h7fff) ||
                 (cpu_a >= 16'ha000 && cpu_a <= 16'hbfff)) begin // External
            ext_cpu_wr = cpu_wr;
            cpu_din = (dma_occupy_extbus) ? (8'hff) : (din);
        end
        else begin
            // Unmapped area
            cpu_din = 8'hff;
        end
    end

    // Bus Multiplexing, DMA
    always @(*) begin
        if (dma_a >= 16'h8000 && dma_a <= 16'h9fff) begin // VRAM
            dma_din = vram_dout;
        end
        else if ((dma_a >= 16'hc000 && dma_a <= 16'hdfff) ||
                 (dma_a >= 16'he000 && dma_a <= 16'hfdff)) begin // WRAM
            dma_din = wram_dout;
        end
        else begin
            dma_din = din;
        end
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    17:30:26 02/08/2018 
// Module Name:    alu
// Project Name:   VerilogBoy
// Description: 
//   The Game Boy ALU.
// Dependencies: 
// 
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module alu(
    input [7:0] alu_b,
    input [7:0] alu_a,
    input [2:0] alu_bit_index,
    output reg [7:0] alu_result,
    input [3:0] alu_flags_in,
    output reg [3:0] alu_flags_out,
    input [4:0] alu_op
    );

    localparam OP_ADD = 5'b00000;
    localparam OP_ADC = 5'b00001;
    localparam OP_SUB = 5'b00010;
    localparam OP_SBC = 5'b00011;
    localparam OP_AND = 5'b00100;
    localparam OP_XOR = 5'b00101;
    localparam OP_OR  = 5'b00110;
    localparam OP_CP  = 5'b00111;
    localparam OP_RLC = 5'b01000;
    localparam OP_RRC = 5'b01001;
    localparam OP_RL  = 5'b01010;
    localparam OP_RR  = 5'b01011;
    localparam OP_SLA = 5'b01100;
    localparam OP_SRA = 5'b01101;
    localparam OP_SWAP= 5'b01110;
    localparam OP_SRL = 5'b01111;
    localparam OP_LF  = 5'b10000; // Load Flags
    //           unused 5'b10001
    localparam OP_SF  = 5'b10010; // Save Flags
    //           unused 5'b10011
    localparam OP_DAA = 5'b10100;
    localparam OP_CPL = 5'b10101;
    localparam OP_SCF = 5'b10110;
    localparam OP_CCF = 5'b10111;
    //           unused 5'b11000
    //           unused 5'b11001
    //           unused 5'b11010
    //           unused 5'b11011
    //           unused 5'b11100
    localparam OP_BIT = 5'b11101;
    localparam OP_RES = 5'b11110;
    localparam OP_SET = 5'b11111;

    localparam F_Z = 2'd3;
    localparam F_N = 2'd2;
    localparam F_H = 2'd1;
    localparam F_C = 2'd0;

    reg [8:0]        intermediate_result1, intermediate_result2;
    reg [4:0]        result_low;
    reg [4:0]        result_high;
    wire [2:0]       bit_index;
    reg carry;
 
    assign bit_index = alu_bit_index;

    always@(*) begin
        alu_flags_out = 4'b0;
        carry = 1'b0;
        result_low = 5'd0;
        result_high = 5'd0;
        intermediate_result1 = 9'd0;
        intermediate_result2 = 9'd0;
        case (alu_op)
            OP_ADD, OP_ADC: begin
                carry = (alu_op == OP_ADC) ? alu_flags_in[F_C] : 1'b0;
                result_low = {1'b0, alu_a[3:0]} + {1'b0, alu_b[3:0]} + 
                    {4'b0, carry};
                alu_flags_out[F_H] = result_low[4];
                result_high = {1'b0, alu_a[7:4]} + 
                    {1'b0, alu_b[7:4]} + 
                    {4'b0, result_low[4]};
                alu_flags_out[F_C] = result_high[4];
                alu_result = {result_high[3:0], result_low[3:0]};
                alu_flags_out[F_Z] = (alu_result == 8'd0) ? 1'b1 : 1'b0;
            end
            OP_SUB, OP_SBC, OP_CP: begin
                alu_flags_out[F_N] = 1'b1;
                carry = (alu_op == OP_SBC) ? alu_flags_in[F_C] : 1'b0;
                result_low = {1'b0, alu_a[3:0]} + 
                    ~({1'b0, alu_b[3:0]} + 
                    {4'b0, carry}) + 5'b1;
                alu_flags_out[F_H] = result_low[4];
                result_high = {1'b0, alu_a[7:4]} + 
                    ~({1'b0, alu_b[7:4]}) +
                    {4'b0, ~result_low[4]};
                alu_flags_out[F_C] = result_high[4];
                alu_result = (alu_op == OP_CP) ? (alu_a[7:0]) : {result_high[3:0], result_low[3:0]};
                alu_flags_out[F_Z] = ({result_high[3:0], result_low[3:0]} == 8'd0) ? 1'b1 : 1'b0;
            end
            OP_AND: begin
                alu_flags_out[F_H] = 1'b1;
                alu_result = alu_a & alu_b;
                alu_flags_out[F_Z] = (alu_result == 8'd0) ? 1'b1 : 1'b0;
            end
            OP_OR: begin
                alu_result = alu_a | alu_b;
                alu_flags_out[F_Z] = (alu_result == 8'd0) ? 1'b1 : 1'b0;
            end
            OP_XOR: begin
                alu_result = alu_a ^ alu_b;
                alu_flags_out[F_Z] = (alu_result == 8'd0) ? 1'b1 : 1'b0;
            end
            OP_DAA: begin
                if (~alu_flags_in[F_N]) begin
                    if (alu_flags_in[F_H] | 
                        ((alu_a & 8'h0f) > 8'h9)) begin
                        intermediate_result1 = {1'b0, alu_a} + 9'h6;
                    end
                    else begin
                        intermediate_result1 = {1'b0, alu_a};
                    end
                    if (alu_flags_in[F_C] | (intermediate_result1 > 9'h9f)) begin
                        intermediate_result2 = intermediate_result1 + 9'h60;
                    end
                    else begin
                        intermediate_result2 = intermediate_result1;
                    end
                end
                else begin
                    if (alu_flags_in[F_H]) begin
                        intermediate_result1 = {1'b0, (alu_a - 8'h6)};
                    end
                    else begin
                        intermediate_result1 = {1'b0, alu_a};
                    end
                    if (alu_flags_in[F_C]) begin
                        intermediate_result2 = intermediate_result1 - 9'h60;
                    end
                    else begin
                        intermediate_result2 = intermediate_result1;
                    end
                end // else: !if(alu_flags_in[F_N])

                alu_result = intermediate_result2[7:0];
                
                alu_flags_out[F_N] = alu_flags_in[F_N];
                alu_flags_out[F_H] = 1'b0;
                alu_flags_out[F_C] = intermediate_result2[8] ? 1'b1 : 
                                        alu_flags_in[F_C];
                alu_flags_out[F_Z] = (intermediate_result2[7:0] == 8'd0) ? 
                                        1'b1 : 1'b0;
            end
            OP_CPL: begin
                alu_flags_out[F_Z] = alu_flags_in[F_Z];
                alu_flags_out[F_N] = 1'b1;
                alu_flags_out[F_H] = 1'b1;
                alu_flags_out[F_C] = alu_flags_in[F_C];
                alu_result = ~alu_a;
            end
            OP_CCF: begin
                alu_flags_out[F_Z] = alu_flags_in[F_Z];
                alu_flags_out[F_N] = 1'b0;
                alu_flags_out[F_H] = 1'b0;
                alu_flags_out[F_C] = ~alu_flags_in[F_C];
                alu_result = alu_b;
            end
            OP_SCF: begin
                alu_flags_out[F_Z] = alu_flags_in[F_Z];
                alu_flags_out[F_N] = 1'b0;
                alu_flags_out[F_H] = 1'b0;
                alu_flags_out[F_C] = 1'b1;
                alu_result = alu_b;
            end
            OP_RLC: begin
                alu_result[0] = alu_a[7];
                alu_result[7:1] = alu_a[6:0];
                alu_flags_out[F_C] = alu_a[7];
                alu_flags_out[F_Z] = (alu_result == 8'd0) ? 1'b1 : 1'b0;
            end
            OP_RL: begin
                alu_result[0] = alu_flags_in[F_C];
                alu_result[7:1] = alu_a[6:0];
                alu_flags_out[F_C] = alu_a[7];
                alu_flags_out[F_Z] = (alu_result == 8'd0) ? 1'b1 : 1'b0;
            end
            OP_RRC: begin
                alu_result[7] = alu_a[0];
                alu_result[6:0] = alu_a[7:1];
                alu_flags_out[F_C] = alu_a[0];
                alu_flags_out[F_Z] = (alu_result == 8'd0) ? 1'b1 : 1'b0;
            end
            OP_RR: begin
                alu_result[7] = alu_flags_in[F_C];
                alu_result[6:0] = alu_a[7:1];
                alu_flags_out[F_C] = alu_a[0];
                alu_flags_out[F_Z] = (alu_result == 8'd0) ? 1'b1 : 1'b0;
            end
            OP_SLA: begin
                alu_result[7:1] = alu_a[6:0];
                alu_result[0] = 1'b0;
                alu_flags_out[F_C] = alu_a[7];
                alu_flags_out[F_Z] = (alu_result == 8'd0) ? 1'b1 : 1'b0;
            end
            OP_SRA: begin
                alu_result[7] = alu_a[7];
                alu_result[6:0] = alu_a[7:1];
                alu_flags_out[F_C] = alu_a[0];
                alu_flags_out[F_Z] = (alu_result == 8'd0) ? 1'b1 : 1'b0;
            end
            OP_SRL: begin
                alu_result[7] = 1'b0;
                alu_result[6:0] = alu_a[7:1];
                alu_flags_out[F_C] = alu_a[0];
                alu_flags_out[F_Z] = (alu_result == 8'd0) ? 1'b1 : 1'b0;
            end
            OP_BIT: begin
            // Bit index must be in data0[5:3]
                alu_flags_out[F_C] = alu_flags_in[F_C];
                alu_flags_out[F_H] = 1'b1;
                alu_flags_out[F_N] = 1'b0;
                alu_flags_out[F_Z] = ~alu_a[bit_index];
                alu_result = alu_b;
            end
            OP_SET: begin
                alu_flags_out = alu_flags_in;
                alu_result = alu_a;
                alu_result[bit_index] = 1'b1;
            end
            OP_RES: begin
                alu_flags_out = alu_flags_in;
                alu_result = alu_a;
                alu_result[bit_index] = 1'b0;
            end
            OP_SWAP: begin
                alu_flags_out[F_Z] = (alu_a == 8'd0) ? 1'd1: 1'd0;
                alu_flags_out[F_H] = 1'b0;
                alu_flags_out[F_C] = 1'b0;
                alu_flags_out[F_N] = 1'b0;
                alu_result = {alu_a[3:0], alu_a[7:4]};
            end
            OP_SF: begin
                alu_flags_out = alu_b[7:4];
                alu_result = alu_a;
            end
            OP_LF: begin
                alu_result = {alu_flags_in, 4'b0};
            end
            default: begin
                alu_result = alu_b;
                alu_flags_out = alu_flags_in;
            end
        endcase
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:10:17 02/09/2018 
// Design Name: 
// Module Name:    brom 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module brom(
    input [7:0] a,
    output [7:0] d
    );
    
    reg [7:0] brom_array [0:255]; // 256 Bytes BROM array
   
    initial begin
        $readmemh("bootrom.mif", brom_array, 0, 255);
    end
    
    assign d = brom_array[a];

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    09:50:37 04/07/2018 
// Module Name:    clk_div 
// Project Name:   VerilogBoy
// Description: 
//
// Dependencies: 
//
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clk_div(
    input i,
    output reg o = 0
    );

    parameter WIDTH = 15, DIV = 1000;
    
    reg [WIDTH - 1:0] counter = 0;
    
    always @(posedge i)
    begin
        if (counter == (DIV / 2 - 1)) begin
            o <= ~o;
            counter <= 0;
        end
        else
            counter <= counter + 1'b1;
    end
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Module Name:    control
// Project Name:   VerilogBoy
// Description: 
//   The control unit of Game Boy CPU.
// Dependencies: 
// 
// Additional Comments: 
//   
//////////////////////////////////////////////////////////////////////////////////

module control(
    input        clk,
    input        rst,
    input  [7:0] opcode_early,
    /* verilator lint_off UNUSED */
    input  [7:0] imm,
    /* verilator lint_on UNUSED */
    input  [7:0] cb,
    input  [2:0] m_cycle_early,
    input  [1:0] ct_state,
    input        f_z,
    input        f_c,
    output reg [1:0] alu_src_a,
    output reg [2:0] alu_src_b,
    output reg       alu_src_xchg,
    output reg [1:0] alu_op_prefix,
    output reg [1:0] alu_op_src,
    output reg       alu_op_signed,
    output reg [1:0] alu_dst,
    output reg [1:0] pc_src,
    output reg       pc_we,
    output reg       pc_b_sel,
    output reg       pc_jr,
    output reg       pc_revert,
    output reg [2:0] rf_wr_sel,
    output reg [2:0] rf_rd_sel,
    output reg [1:0] rf_rdw_sel,
    output reg       temp_redir,
    output reg       opcode_redir,
    output reg [1:0] bus_op,
    output reg [1:0] db_src,
    output reg [1:0] ab_src,
    output reg [1:0] ct_op,
    output reg       flags_we,
    output reg [1:0] flags_pattern,
    output reg       high_mask,
    output           int_master_en,
    input            int_dispatch,
    output reg       int_ack,
    output reg       next,
    output reg       stop,
    output reg       halt,
    input            wake,
    output reg       fault
    );

    // Comb signal generated by control logic
    reg ime_clear;
    reg ime_set;
    reg ime_delay_set;
    // FF
    reg ime_delay_set_ff;
    reg ime;
    assign int_master_en = ime;

    wire [7:0] opcode = opcode_early;
    wire [2:0] m_cycle = m_cycle_early;

    always @(posedge clk)
        if (ct_state == 2'd2)
            ime_delay_set_ff <= ime_delay_set;

    always @(posedge clk, posedge rst) begin
        if (rst)
            ime <= 1'b0;
        else if (ime_clear)
            ime <= 1'b0;
        else if (ime_set)
            ime <= 1'b1;
        else if (ime_delay_set_ff)
            ime <= 1'b1;
    end

    reg halt_last;
    reg stop_last;
    reg fault_last;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            halt_last <= 1'b0;
            stop_last <= 1'b0;
            fault_last <= 1'b0;
        end
        else begin
            halt_last <= halt;
            stop_last <= stop;
            fault_last <= fault;
        end
    end

    reg wake_by_int;
    always @(posedge clk, posedge rst) begin
        if (rst)
            wake_by_int <= 1'b0;
        else begin
            if (int_dispatch && (m_cycle == 0)) begin
                wake_by_int <= wake;
            end
        end
    end

    // Combinational control signal
    reg [1:0] comb_alu_src_a;
    reg [2:0] comb_alu_src_b;
    reg       comb_alu_src_xchg;
    reg [1:0] comb_alu_op_prefix;
    reg [1:0] comb_alu_op_src;
    reg       comb_alu_op_signed;
    reg [1:0] comb_alu_dst;
    reg [1:0] comb_pc_src;
    reg       comb_pc_we;
    reg       comb_pc_b_sel;
    reg       comb_pc_jr;
    reg       comb_pc_revert;
    reg [2:0] comb_rf_wr_sel;
    reg [2:0] comb_rf_rd_sel;
    reg [1:0] comb_rf_rdw_sel;
    reg       comb_temp_redir;
    reg       comb_opcode_redir;
    reg [1:0] comb_bus_op;
    reg [1:0] comb_db_src;
    reg [1:0] comb_ab_src;
    reg [1:0] comb_ct_op;
    reg       comb_flags_we;
    reg [1:0] comb_flags_pattern;
    reg       comb_high_mask;
    reg       comb_int_ack;
    reg       comb_next;
    reg       comb_stop;
    reg       comb_halt;
    reg       comb_fault;

    // All these nonsense will be replaced by a vector decoding ROM... 
    // in the future
    always @(*) begin
        // Set default output
        // ACC = ACC + 0
        comb_alu_src_a = `ALU_SRC_A_ACC;
        comb_alu_src_b = `ALU_SRC_B_ZERO;
        comb_alu_op_prefix = `ALU_OP_PREFIX_NORMAL;
        comb_alu_op_src = `ALU_OP_SRC_ADD_FTOR;
        comb_alu_dst = `ALU_DST_ACC;
        comb_pc_we = 0;
        comb_rf_wr_sel = `RF_SEL_B; // Doesn't matter
        comb_rf_rd_sel = `RF_SEL_B; // Doesn't matter
        comb_bus_op = `BUS_OP_IF; // Fetch comb_next instruction
        comb_db_src = `DB_SRC_DB; // Should != ACC
        comb_ab_src = `AB_SRC_PC; // Output PC
        comb_ct_op = `CT_OP_PC_INC; // PC = PC + 1
        comb_flags_we = 0;
        comb_next = 0;
        comb_alu_src_xchg = 0;
        comb_rf_rdw_sel = 2'b10; // Select HL
        comb_pc_src = 2'b00;
        comb_pc_b_sel = m_cycle[0];
        comb_pc_jr = 1'b0;
        comb_pc_revert = 1'b0;
        comb_stop = 1'b0;
        comb_halt = 1'b0;
        comb_fault = 1'b0;
        comb_high_mask = 1'b0;
        comb_alu_op_signed = 1'b0;
        comb_temp_redir = 1'b0;
        comb_opcode_redir = 1'b0;
        ime_set = 1'b0;
        ime_delay_set = 1'b0;
        ime_clear = 1'b0;
        comb_int_ack = 1'b0;
        comb_flags_pattern = 2'b00;
        // Though the idea behind the original GB is that when in comb_halt or comb_stop
        // mode, the clock can be comb_stopped, thus lower the power consumption and
        // save the battery. On FPGA, this is hard to achieve since clocking in
        // FPGA works very differently than on ASIC. So here, when comb_halted, CPU
        // would executing NOP in place as if it was comb_halted.
        if (halt_last || stop_last || fault_last) begin
            if (wake) begin
                comb_halt = 1'b0;
                comb_stop = 1'b0;
                // Fault could not be waked up 
            end
            else begin
                // Keep sleeping
                comb_bus_op = `BUS_OP_IDLE;
                comb_ct_op = `CT_OP_IDLE;
                comb_halt = halt_last;
                comb_stop = stop_last;
            end
            // Fault cannot be waken up
            comb_fault = fault_last;
        end
        else if (int_dispatch) begin
            // Interrupt dispatch process
            case (m_cycle)
            0: begin
                // Revert PC
                comb_pc_revert = 1'b1;
                comb_bus_op = `BUS_OP_IDLE;
                comb_ct_op = `CT_OP_SP_DEC;
                comb_next = 1'b1;
            end
            1: begin
                // Save PCh
                comb_alu_src_a = `ALU_SRC_A_PC;
                comb_alu_dst = `ALU_DST_DB;
                comb_bus_op = `BUS_OP_WRITE;
                comb_ab_src = `AB_SRC_SP;
                comb_db_src = `DB_SRC_DB;
                comb_ct_op = `CT_OP_SP_DEC;
                comb_next = 1'b1;
            end
            2: begin
                // Save PCl
                comb_alu_src_a = `ALU_SRC_A_PC;
                comb_alu_dst = `ALU_DST_DB;
                comb_bus_op = `BUS_OP_WRITE;
                comb_ab_src = `AB_SRC_SP;
                comb_db_src = `DB_SRC_DB;
                comb_ct_op = `CT_OP_IDLE;
                comb_pc_we = 1;
                comb_next = 1'b1;
            end
            3: begin
                // Delay
                if (wake_by_int) begin
                    ime_clear = 1'b1;
                    comb_int_ack = 1'b1;
                end
                else begin
                    comb_bus_op = `BUS_OP_IDLE;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1'b1;
                end
            end
            4: begin
                // Normal instruction fetch process
                ime_clear = 1'b1;
                comb_int_ack = 1'b1;
            end
            endcase
        end
        //else begin
        // If waken up
        if (!comb_halt && !comb_stop && !comb_fault && !int_dispatch) begin
            if (opcode == 8'h00) begin // NOP
                // Default behavior is enough
            end
            else if (opcode == 8'h10) begin // STOP
                comb_stop = 1;
            end
            else if (opcode == 8'h76) begin // HALT
                comb_halt = 1;
            end
            else if (opcode == 8'hF3) begin // DI
                ime_clear = 1'b1;
            end
            else if (opcode == 8'hFB) begin // EI
                // EI here need to be delayed for 1 clock?
                ime_delay_set = 1'b1;
            end
            // 16-bit IMM to register LD instructions
            else if ((opcode[7:6] == 2'b00) && (opcode[3:0] == 4'b0001)) begin
                comb_alu_src_a = `ALU_SRC_A_DB; // Load from databus
                comb_alu_dst = `ALU_DST_REG; // Load to register
                comb_db_src = `DB_SRC_DB; // DB destination to databus buffer
                if ((m_cycle == 0) || (m_cycle == 1)) begin
                    comb_rf_wr_sel = {opcode[5:4], 1'b1}; // Register no based on opcode
                    comb_bus_op = `BUS_OP_READ; // Read from databus
                    comb_next = 1;
                end
                else begin
                    comb_rf_wr_sel = {opcode[5:4], 1'b0};
                    comb_next = 0;
                end
            end
            // LD (nn), SP
            else if (opcode == 8'h08) begin 
                if ((m_cycle == 0) || (m_cycle == 1)) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_ab_src = `AB_SRC_PC;
                    comb_ct_op = `CT_OP_PC_INC;
                    comb_next = 1;
                end
                else if (m_cycle == 2) begin
                    comb_ab_src = `AB_SRC_TEMP;
                    comb_db_src = `DB_SRC_REG;
                    comb_rf_rd_sel = `RF_SEL_SP_L;
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_ct_op = `CT_OP_SP_INC;
                    comb_temp_redir = 1'b1;
                    comb_next = 1'b1;
                end
                else if (m_cycle == 3) begin
                    comb_ab_src = `AB_SRC_TEMP;
                    comb_db_src = `DB_SRC_REG;
                    comb_rf_rd_sel = `RF_SEL_SP_H;
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1'b1;
                end
                else begin
                    // Default behaviour is enough.
                end
            end
            // 8 bit reg-to-reg, mem-to-reg, or reg-to-mem LD instructions
            else if (opcode[7:6] == 2'b01) begin
                if (opcode[2:0] == 3'b110)
                    comb_alu_src_a = `ALU_SRC_A_DB; // Src A from data bus
                else if (opcode[2:0] == 3'b111)
                    comb_alu_src_a = `ALU_SRC_A_ACC; // Src A from accumulator
                else
                    comb_alu_src_a = `ALU_SRC_A_REG; // Src A from register file

                if (opcode[5:3] == 3'b110)
                    comb_alu_dst = `ALU_DST_DB; // Destination is (HL)
                else if (opcode[5:3] == 3'b111) 
                    comb_alu_dst = `ALU_DST_ACC; // Destination is A
                else
                    comb_alu_dst = `ALU_DST_REG; // Destination is register
                
                comb_rf_wr_sel = opcode[5:3];
                comb_rf_rd_sel = opcode[2:0];

                if (opcode[5:3] == 3'b110) begin // Register to Memory
                    if (m_cycle == 0) begin
                        comb_bus_op = `BUS_OP_WRITE;
                        comb_db_src = `DB_SRC_ALU;
                        comb_ab_src = `AB_SRC_REG;
                        comb_ct_op = `CT_OP_IDLE;
                        comb_next = 1;
                    end
                end
                else if (opcode[2:0] == 3'b110) begin // Memory to Register
                    if (m_cycle == 0) begin
                        comb_bus_op = `BUS_OP_READ;
                        comb_db_src = `DB_SRC_DB;
                        comb_ab_src = `AB_SRC_REG;
                        comb_ct_op = `CT_OP_IDLE;
                        comb_next = 1;
                    end
                end
            end
            // 8 bit imm-to-reg, imm-to-mem LD instructions
            else if ((opcode[7:6] == 2'b00) && (opcode[2:0] == 3'b110)) begin
                comb_alu_src_a = `ALU_SRC_A_DB;
                
                if (opcode[5:3] == 3'b110) begin // imm to mem
                    comb_alu_dst = `ALU_DST_DB;
                    comb_rf_rd_sel = `RF_SEL_HL;
                end
                else if (opcode[5:3] == 3'b111) begin
                    comb_alu_dst = `ALU_DST_ACC;
                end
                else begin
                    comb_alu_dst = `ALU_DST_REG;
                    comb_rf_wr_sel = opcode[5:3];
                end

                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_next = 1;
                end
                else if (m_cycle == 1) begin
                    if (opcode[5:3] == 3'b110) begin
                        comb_bus_op = `BUS_OP_WRITE;
                        comb_db_src = `DB_SRC_DB;
                        comb_ab_src = `AB_SRC_REG;
                        comb_ct_op = `CT_OP_IDLE;
                        comb_next = 1;
                    end
                end
            end
            // LD (BC)/(DE), A
            else if ((opcode == 8'h02) || (opcode == 8'h12)) begin
                comb_alu_dst = `ALU_DST_DB;
                if (opcode == 8'h02)
                    comb_rf_rdw_sel = 2'b00; // Select BC
                else
                    comb_rf_rdw_sel = 2'b01; // Select DE
                if (m_cycle == 0) begin
                    comb_next = 1;
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_ab_src = `AB_SRC_REG;
                    comb_ct_op = `CT_OP_IDLE;
                end
            end
            // LD (HL+)/(HL-), A
            else if ((opcode == 8'h22) || (opcode == 8'h32)) begin
                comb_alu_src_a = `ALU_SRC_A_REG;
                comb_alu_dst = `ALU_DST_REG;
                if (opcode == 8'h22)
                    comb_alu_op_src = `ALU_OP_SRC_ADD_FTOR;
                else
                    comb_alu_op_src = `ALU_OP_SRC_SUB_ATOF;
                if (m_cycle == 0) begin
                    // A being written to the memory, calculate L +/- 1
                    comb_alu_src_b = `ALU_SRC_B_ONE;
                    comb_rf_rd_sel = `RF_SEL_L;
                    comb_rf_wr_sel = `RF_SEL_L;
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_db_src = `DB_SRC_ACC;
                    comb_ab_src = `AB_SRC_REG;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
                else begin
                    // calculate H +/- carry
                    comb_alu_src_b = `ALU_SRC_B_CARRY;
                    comb_rf_rd_sel = `RF_SEL_H;
                    comb_rf_wr_sel = `RF_SEL_H;
                end
            end
            // LD A, (BC)/(DE)
            else if ((opcode == 8'h0A) || (opcode == 8'h1A)) begin
                comb_alu_src_a = `ALU_SRC_A_DB;
                if (opcode == 8'h0A) begin
                    comb_rf_rdw_sel = 2'b00; // Select BC
                end
                else begin
                    comb_rf_rdw_sel = 2'b01; // Select DE
                end

                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_ab_src = `AB_SRC_REG;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
            end
            // LD A, (HL+)/(HL-)
            else if ((opcode == 8'h2A) || (opcode == 8'h3A)) begin
                comb_alu_src_a = `ALU_SRC_A_REG;
                comb_alu_src_b = `ALU_SRC_B_ONE;
                if (opcode == 8'h2A)
                    comb_alu_op_src = `ALU_OP_SRC_ADD_FTOR;
                else
                    comb_alu_op_src = `ALU_OP_SRC_SUB_ATOF;
                comb_alu_dst = `ALU_DST_REG;
                if (m_cycle == 0) begin
                    comb_alu_src_b = `ALU_SRC_B_ONE;
                    comb_rf_rd_sel = `RF_SEL_L;
                    comb_rf_wr_sel = `RF_SEL_L;
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_ACC;
                    comb_ab_src = `AB_SRC_REG;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
                else begin
                    comb_alu_src_b = `ALU_SRC_B_CARRY;
                    comb_rf_rd_sel = `RF_SEL_H;
                    comb_rf_wr_sel = `RF_SEL_H;
                end
            end
            // 16-bit INC/DEC
            else if ((opcode[7:6] == 2'b00) && (opcode[2:0] == 3'b011)) begin
                comb_alu_src_a = `ALU_SRC_A_REG;
                comb_alu_dst = `ALU_DST_REG;
                if (opcode[3] == 1) begin
                    comb_alu_op_src = `ALU_OP_SRC_SUB_ATOF;
                end
                if (m_cycle == 0) begin
                    comb_alu_src_b = `ALU_SRC_B_ONE;
                    comb_rf_rd_sel = {opcode[5:4], 1'b1};
                    comb_rf_wr_sel = {opcode[5:4], 1'b1};
                    comb_bus_op = `BUS_OP_IDLE;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_db_src = `DB_SRC_DB;
                    comb_next = 1;
                end
                else begin
                    comb_alu_src_b = `ALU_SRC_B_CARRY;
                    comb_rf_rd_sel = {opcode[5:4], 1'b0};
                    comb_rf_wr_sel = {opcode[5:4], 1'b0};
                end
            end
            // 8-bit INC/DEC
            else if ((opcode[7:6] == 2'b00) && (opcode[2:1] == 2'b10)) begin
                comb_alu_src_b = `ALU_SRC_B_ONE;
                comb_flags_pattern = `FLAGS_ZNHx;
                comb_flags_we = 1'b1;

                // INC or DEC
                if (opcode[0])
                    comb_alu_op_src = `ALU_OP_SRC_SUB_ATOF;
                else
                    comb_alu_op_src = `ALU_OP_SRC_ADD_FTOR;

                if (opcode[5:3] == 3'b110) begin
                    // INC/DEC (HL)
                    comb_alu_src_a = `ALU_SRC_A_DB;
                    comb_alu_dst = `ALU_DST_DB;
                    if (m_cycle == 0) begin
                        comb_bus_op = `BUS_OP_READ;
                        comb_db_src = `DB_SRC_REG;
                        comb_ab_src = `AB_SRC_REG;
                        comb_ct_op = `CT_OP_IDLE;
                        comb_next = 1;
                    end
                    else if (m_cycle == 1) begin
                        comb_bus_op = `BUS_OP_WRITE;
                        comb_ab_src = `AB_SRC_REG;
                        comb_ct_op = `CT_OP_IDLE;
                        comb_next = 1;
                    end
                    else begin
                        // End cycle
                        comb_flags_we = 0;
                    end
                end
                else if (opcode[5:3] == 3'b111) begin
                    // INC/DEC A
                    comb_alu_src_a = `ALU_SRC_A_ACC;
                    comb_alu_dst = `ALU_DST_ACC;
                end
                else begin
                    comb_alu_src_a = `ALU_SRC_A_REG;
                    comb_alu_dst = `ALU_DST_REG;
                    comb_rf_rd_sel = opcode[5:3];
                    comb_rf_wr_sel = opcode[5:3];
                end
            end
            // ADD HL, r16
            else if ((opcode[7:6] == 2'b00) && (opcode[3:0] == 4'b1001)) begin
                comb_alu_dst = `ALU_DST_REG;
                comb_flags_we = 1'b1;
                comb_flags_pattern = `FLAGS_x0HC;
                if (m_cycle == 0) begin
                    comb_alu_src_a = `ALU_SRC_A_REG;
                    comb_alu_src_b = `ALU_SRC_B_L;
                    comb_rf_wr_sel = `RF_SEL_L;
                    comb_rf_rd_sel = {opcode[5:4], 1'b1};
                    comb_bus_op = `BUS_OP_IDLE;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
                else begin
                    comb_alu_src_a = `ALU_SRC_A_REG;
                    comb_alu_src_b = `ALU_SRC_B_H;
                    comb_rf_wr_sel = `RF_SEL_H;
                    comb_rf_rd_sel = {opcode[5:4], 1'b0};
                    comb_alu_op_signed = 1'b1;
                end
            end
            // 8 bit reg-to-reg, mem-to-reg ALU operation
            else if (opcode[7:6] == 2'b10) begin
                comb_alu_src_b = `ALU_SRC_B_ACC;
                comb_alu_op_src = `ALU_OP_SRC_INSTR_5TO3;
                comb_rf_rd_sel = opcode[2:0];
                comb_flags_we = 1'b1;
                if ((opcode[5:4] == 2'b01) || (opcode[5:3] == 3'b111)) begin
                    // Sub or CP
                    comb_alu_src_xchg = 1'b1;
                end
                if (opcode[2:0] == 3'b110) begin // Source from HL
                    comb_alu_src_a = `ALU_SRC_A_DB;
                    if (m_cycle == 0) begin 
                        comb_bus_op = `BUS_OP_READ;
                        comb_ab_src = `AB_SRC_REG;
                        // Do not writeback in the first cycle
                        comb_alu_dst = `ALU_DST_DB;
                        comb_flags_we = 1'b0;
                        comb_ct_op = `CT_OP_IDLE;
                        comb_next = 1;
                    end
                end
                else if (opcode[2:0] == 3'b111) begin // Source from A
                    comb_alu_src_a = `ALU_SRC_A_ACC;
                end
                else begin
                    comb_alu_src_a = `ALU_SRC_A_REG;
                end
            end
            // 8 bit imm-to-reg ALU operation
            else if ((opcode[7:6] == 2'b11) && (opcode[2:0] == 3'b110)) begin
                if (m_cycle == 0) begin 
                    comb_bus_op = `BUS_OP_READ;
                    comb_next = 1;
                end
                else begin
                    if ((opcode[5:4] == 2'b01) || (opcode[5:3] == 3'b111)) begin
                        // Sub or CP
                        comb_alu_src_xchg = 1'b1;
                    end
                    comb_alu_src_a = `ALU_SRC_A_DB;
                    comb_alu_src_b = `ALU_SRC_B_ACC;
                    comb_alu_op_src = `ALU_OP_SRC_INSTR_5TO3;
                    comb_flags_we = 1'b1;
                end
            end
            // 16-bit PUSH
            else if ((opcode[7:6] == 2'b11) && (opcode[3:0] == 4'b0101)) begin
                if (opcode[5:4] == 2'b11) begin
                    // AF
                    comb_alu_op_prefix = `ALU_OP_PREFIX_SPECIAL;
                    comb_db_src = `DB_SRC_ACC;
                end
                else begin
                    comb_db_src = `DB_SRC_DB;
                end
                comb_alu_src_a = `ALU_SRC_A_REG;
                comb_alu_dst = `ALU_DST_DB;

                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_IDLE;
                    comb_ab_src = `AB_SRC_SP;
                    comb_ct_op = `CT_OP_SP_DEC;
                    comb_next = 1;
                end
                else if (m_cycle == 1) begin
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_ab_src = `AB_SRC_SP;
                    comb_ct_op = `CT_OP_SP_DEC;
                    comb_rf_rd_sel = {opcode[5:4], 1'b0};
                    comb_next = 1;
                end
                else if (m_cycle == 2) begin
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_ab_src = `AB_SRC_SP;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_rf_rd_sel = {opcode[5:4], 1'b1};
                    if (opcode[5:4] == 2'b11) begin
                        comb_db_src = `DB_SRC_ALU;
                    end
                    comb_next = 1;
                end
            end
            // 16-bit POP
            else if ((opcode[7:6] == 2'b11) && (opcode[3:0] == 4'b0001)) begin
                if ((m_cycle == 1) || (m_cycle == 2)) begin
                    comb_alu_src_a = `ALU_SRC_A_DB;
                    if (opcode[5:4] == 2'b11) begin
                        comb_alu_dst = `ALU_DST_ACC;
                    end
                    else begin 
                        comb_alu_dst = `ALU_DST_REG;
                    end
                end

                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_ab_src = `AB_SRC_SP;
                    comb_ct_op = `CT_OP_SP_INC;
                    comb_next = 1;
                end
                else if (m_cycle == 1) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_ab_src = `AB_SRC_SP;
                    comb_ct_op = `CT_OP_SP_INC;
                    comb_rf_wr_sel = {opcode[5:4], 1'b1};
                    comb_next = 1;
                end
                else if (m_cycle == 2) begin
                    comb_rf_wr_sel = {opcode[5:4], 1'b0};
                    if (opcode[5:4] == 2'b11) begin
                        // Copy from memory to flags
                        comb_alu_op_prefix = `ALU_OP_PREFIX_SPECIAL;
                        comb_alu_op_src = `ALU_OP_SRC_SUB_ATOF;
                        comb_alu_src_b = `ALU_SRC_B_ACC;
                        comb_flags_we = 1'b1;
                    end
                end
            end
            // LD (C), A
            else if (opcode == 8'he2) begin
                comb_rf_rdw_sel = 2'b00; // Select BC
                comb_high_mask = 1'b1; // Select C only
                comb_alu_src_a = `ALU_SRC_A_ACC;
                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_db_src = `DB_SRC_ACC;
                    comb_ab_src = `AB_SRC_REG;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
            end
            // LD A, (C)
            else if (opcode == 8'hf2) begin
                comb_rf_rdw_sel = 2'b00; // Select BC
                comb_high_mask = 1'b1; // Select C only
                comb_alu_src_a = `ALU_SRC_A_DB;
                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_ab_src = `AB_SRC_REG;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1'b1;
                end
            end
            // ADD SP, r8
            else if (opcode == 8'he8) begin
                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_next = 1;
                end
                else if (m_cycle == 1) begin
                    comb_alu_src_a = `ALU_SRC_A_REG;
                    comb_alu_src_b = `ALU_SRC_B_IMM;
                    comb_alu_dst = `ALU_DST_REG;
                    comb_rf_rd_sel = `RF_SEL_SP_L;
                    comb_rf_wr_sel = `RF_SEL_SP_L;
                    comb_bus_op = `BUS_OP_IDLE;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_flags_pattern = `FLAGS_00HC;
                    comb_flags_we = 1'b1;
                    comb_next = 1;
                end
                else if (m_cycle == 2) begin
                    comb_alu_src_a = `ALU_SRC_A_REG;
                    comb_alu_src_b = `ALU_SRC_B_IMM;
                    comb_alu_dst = `ALU_DST_REG;
                    comb_alu_op_signed = 1'b1;
                    comb_rf_rd_sel = `RF_SEL_SP_H;
                    comb_rf_wr_sel = `RF_SEL_SP_H;
                    comb_bus_op = `BUS_OP_IDLE;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
            end
            // LD HL, SP+r8
            else if (opcode == 8'hf8) begin
                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_next = 1;
                end
                else if (m_cycle == 1) begin
                    comb_alu_src_a = `ALU_SRC_A_REG;
                    comb_alu_src_b = `ALU_SRC_B_IMM;
                    comb_alu_dst = `ALU_DST_REG;
                    comb_rf_rd_sel = `RF_SEL_SP_L;
                    comb_rf_wr_sel = `RF_SEL_L;
                    comb_bus_op = `BUS_OP_IDLE;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_flags_pattern = `FLAGS_00HC;
                    comb_flags_we = 1'b1;
                    comb_next = 1;
                end
                else begin
                    comb_alu_op_signed = 1'b1;
                    comb_alu_src_a = `ALU_SRC_A_REG;
                    comb_alu_src_b = `ALU_SRC_B_IMM;
                    comb_alu_dst = `ALU_DST_REG;
                    comb_rf_rd_sel = `RF_SEL_SP_H;
                    comb_rf_wr_sel = `RF_SEL_H;
                end
            end
            // LD SP, HL
            else if (opcode == 8'hf9) begin
                comb_alu_src_a = `ALU_SRC_A_REG;
                comb_alu_dst = `ALU_DST_REG;
                
                if (m_cycle == 0) begin
                    comb_rf_wr_sel = `RF_SEL_SP_H;
                    comb_rf_rd_sel = `RF_SEL_H;
                    comb_bus_op = `BUS_OP_IDLE;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
                else begin
                    comb_rf_wr_sel = `RF_SEL_SP_L;
                    comb_rf_rd_sel = `RF_SEL_L;
                end
            end
            // LDH (a8), A
            else if (opcode == 8'hE0) begin
                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_next = 1;
                end
                else if (m_cycle == 1) begin
                    comb_alu_src_a = `ALU_SRC_A_ACC;
                    comb_alu_dst = `ALU_DST_DB;
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_db_src = `DB_SRC_ACC;
                    comb_ab_src = `AB_SRC_TEMP;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_high_mask = 1;
                    comb_next = 1;
                end
            end
            // LDH A, (a8)
            else if (opcode == 8'hF0) begin
                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_next = 1;
                end
                else if (m_cycle == 1) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_ab_src = `AB_SRC_TEMP;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_high_mask = 1;
                    comb_next = 1;
                end
                else begin
                    comb_alu_src_a = `ALU_SRC_A_DB;
                    comb_alu_dst = `ALU_DST_ACC;
                end
            end
            // LD (a16), A
            else if (opcode == 8'hEA) begin
                if ((m_cycle == 0) || (m_cycle == 1)) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_next = 1;
                end
                else if (m_cycle == 2) begin
                    comb_alu_src_a = `ALU_SRC_A_ACC;
                    comb_alu_dst = `ALU_DST_DB;
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_db_src = `DB_SRC_ACC;
                    comb_ab_src = `AB_SRC_TEMP;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
            end
            // LDH A, (a16)
            else if (opcode == 8'hFA) begin
                if ((m_cycle == 0) || (m_cycle == 1)) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_next = 1;
                end
                else if (m_cycle == 2) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_ab_src = `AB_SRC_TEMP;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
                else begin
                    comb_alu_src_a = `ALU_SRC_A_DB;
                    comb_alu_dst = `ALU_DST_ACC;
                end
            end
            // JP HL
            else if (opcode == 8'hE9) begin
                comb_rf_rd_sel = `RF_SEL_H;
                comb_ab_src = `AB_SRC_REG;
                comb_pc_we = 1;
            end
            // JP CC, a16
            else if ((opcode == 8'hC3) || (opcode == 8'hC2) || (opcode == 8'hD2)
                    || (opcode == 8'hCA) || (opcode == 8'hDA)) begin
                if ((m_cycle == 0) || (m_cycle == 1)) begin
                    // Read 16 bit imm
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_next = 1;
                end
                else if (m_cycle == 2) begin
                    if (((opcode == 8'hC2) && (!f_z)) ||     // JP NZ
                        ((opcode == 8'hD2) && (!f_c)) ||     // JP NC
                        ((opcode == 8'hC3)) ||               // JP
                        ((opcode == 8'hCA) && (f_z)) ||      // JP Z
                        ((opcode == 8'hDA) && (f_c))) begin  // JP C
                        // Branch taken
                        comb_pc_src = `PC_SRC_TEMP;
                        comb_bus_op = `BUS_OP_IDLE;
                        comb_ct_op = `CT_OP_IDLE;
                        comb_pc_we = 1;
                        comb_next = 1;
                    end
                    // Branch not taken
                end
            end
            // CALL CC, a16
            else if ((opcode == 8'hCD) || (opcode == 8'hCC) || (opcode == 8'hDC)
                    || (opcode == 8'hC4) || (opcode == 8'hD4)) begin
                if ((m_cycle == 0) || (m_cycle == 1)) begin
                    // Read 16 bit imm
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_next = 1;
                end
                else if (m_cycle == 2) begin
                    if (((opcode == 8'hC4) && (!f_z)) ||     // CALL NZ
                        ((opcode == 8'hD4) && (!f_c)) ||     // CALL NC
                        ((opcode == 8'hCD)) ||               // CALL
                        ((opcode == 8'hCC) && (f_z)) ||      // CALL Z
                        ((opcode == 8'hDC) && (f_c))) begin  // CALL C
                        // Call taken
                        comb_bus_op = `BUS_OP_IDLE;
                        comb_ct_op = `CT_OP_SP_DEC;
                        comb_next = 1;
                    end
                end
                else if (m_cycle == 3) begin
                    comb_alu_src_a = `ALU_SRC_A_PC;
                    comb_alu_dst = `ALU_DST_DB;
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_ab_src = `AB_SRC_SP;
                    comb_db_src = `DB_SRC_DB;
                    comb_ct_op = `CT_OP_SP_DEC;
                    comb_next = 1;
                end
                else if (m_cycle == 4) begin
                    comb_alu_src_a = `ALU_SRC_A_PC;
                    comb_alu_dst = `ALU_DST_DB;
                    comb_pc_src = `PC_SRC_TEMP;
                    comb_pc_we = 1;
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_ab_src = `AB_SRC_SP;
                    comb_db_src = `DB_SRC_DB;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
            end
            // JR CC, imm8
            else if ((opcode == 8'h20) || (opcode == 8'h30) || (opcode == 8'h18)
                    || (opcode == 8'h28) || (opcode == 8'h38)) begin
                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_next = 1;
                end
                else if (m_cycle == 1) begin
                    if (((opcode == 8'h20) && (!f_z)) ||     // JR NZ
                        ((opcode == 8'h30) && (!f_c)) ||     // JR NC
                        ((opcode == 8'h18)) ||               // JR
                        ((opcode == 8'h28) && (f_z)) ||      // JR Z
                        ((opcode == 8'h38) && (f_c))) begin  // JR C
                        comb_bus_op = `BUS_OP_IDLE;
                        comb_pc_jr = 1;
                        comb_next = 1;
                    end
                end
            end
            // RET, RETI
            else if ((opcode == 8'hC9) || (opcode == 8'hD9)) begin
                if (m_cycle == 0) begin
                    if (opcode == 8'hD9) begin
                        ime_set = 1;
                    end
                    comb_ab_src = `AB_SRC_SP;
                    comb_db_src = `DB_SRC_DB;
                    comb_bus_op = `BUS_OP_READ;
                    comb_ct_op = `CT_OP_SP_INC;
                    comb_next = 1;
                end
                else if (m_cycle == 1) begin
                    comb_ab_src = `AB_SRC_SP;
                    comb_db_src = `DB_SRC_DB;
                    comb_bus_op = `BUS_OP_READ;
                    comb_ct_op = `CT_OP_SP_INC;
                    comb_alu_src_a = `ALU_SRC_A_DB;
                    comb_alu_dst = `ALU_DST_PC;
                    comb_pc_b_sel = 0;
                    comb_next = 1;
                end
                else if (m_cycle == 2) begin
                    comb_alu_src_a = `ALU_SRC_A_DB;
                    comb_alu_dst = `ALU_DST_PC;
                    comb_pc_b_sel = 1;
                    comb_bus_op = `BUS_OP_IDLE;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
            end
            // RET CC
            else if ((opcode[7:5] == 3'b110) && (opcode[2:0] == 3'b000)) begin
                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_IDLE;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
                else if (m_cycle == 1) begin
                    if (((opcode == 8'hC0) && (!f_z)) ||     // RET NZ
                        ((opcode == 8'hD0) && (!f_c)) ||     // RET NC
                        ((opcode == 8'hC8) && (f_z)) ||      // RET Z
                        ((opcode == 8'hD8) && (f_c))) begin  // RET C
                        comb_ab_src = `AB_SRC_SP;
                        comb_db_src = `DB_SRC_DB;
                        comb_bus_op = `BUS_OP_READ;
                        comb_ct_op = `CT_OP_SP_INC;
                        comb_next = 1;
                    end
                end
                else if (m_cycle == 2) begin
                    comb_ab_src = `AB_SRC_SP;
                    comb_db_src = `DB_SRC_DB;
                    comb_bus_op = `BUS_OP_READ;
                    comb_ct_op = `CT_OP_SP_INC;
                    comb_alu_src_a = `ALU_SRC_A_DB;
                    comb_alu_dst = `ALU_DST_PC;
                    comb_pc_b_sel = 0;
                    comb_next = 1;
                end
                else if (m_cycle == 3) begin
                    comb_alu_src_a = `ALU_SRC_A_DB;
                    comb_alu_dst = `ALU_DST_PC;
                    comb_pc_b_sel = 1;
                    comb_bus_op = `BUS_OP_IDLE;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
            end
            // RST
            else if ((opcode[7:6] == 2'b11) && (opcode[2:0] == 3'b111)) begin
                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_IDLE;
                    comb_ct_op = `CT_OP_SP_DEC;
                    comb_next = 1;
                end
                else if (m_cycle == 1) begin
                    comb_alu_src_a = `ALU_SRC_A_PC;
                    comb_alu_dst = `ALU_DST_DB;
                    comb_db_src = `DB_SRC_DB;
                    comb_ab_src = `AB_SRC_SP;
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_ct_op = `CT_OP_SP_DEC;
                    comb_next = 1;
                end
                else if (m_cycle == 2) begin
                    comb_alu_src_a = `ALU_SRC_A_PC;
                    comb_alu_dst = `ALU_DST_DB;
                    comb_db_src = `DB_SRC_DB;
                    comb_ab_src = `AB_SRC_SP;
                    comb_pc_src = `PC_SRC_RST;
                    comb_pc_we = 1;
                    comb_bus_op = `BUS_OP_WRITE;
                    comb_ct_op = `CT_OP_IDLE;
                    comb_next = 1;
                end
            end
            // RLCA, RRCA, RLA, RRA
            else if ((opcode[7:5] == 3'b000) && (opcode[2:0] == 3'b111)) begin
                comb_alu_src_b = `ALU_SRC_B_ACC;
                comb_alu_op_prefix = `ALU_OP_PREFIX_SHIFT_ROTATE;
                comb_alu_op_src = `ALU_OP_SRC_INSTR_5TO3;
                comb_flags_pattern = `FLAGS_00HC;
                comb_flags_we = 1;
            end
            // DAA, CPL, SCF, CCF
            else if ((opcode[7:5] == 3'b001) && (opcode[2:0] == 3'b111)) begin
                comb_alu_src_b = `ALU_SRC_B_ACC;
                comb_alu_op_prefix = `ALU_OP_PREFIX_SPECIAL;
                comb_alu_op_src = `ALU_OP_SRC_INSTR_5TO3;
                comb_flags_we = 1;
            end
            // CB prefix
            else if (opcode == 8'hCB) begin
                if (m_cycle == 0) begin
                    comb_bus_op = `BUS_OP_READ;
                    comb_db_src = `DB_SRC_DB;
                    comb_next = 1;
                end
                else if (m_cycle == 1) begin
                    comb_opcode_redir = 1'b1;
                    if (cb[2:0] == 3'b110) begin
                        comb_alu_src_a = `ALU_SRC_A_DB;
                        comb_alu_dst = `ALU_DST_DB;
                        comb_ct_op = `CT_OP_IDLE;
                        comb_ab_src = `AB_SRC_REG;
                        comb_bus_op = `BUS_OP_READ;
                        comb_flags_we = 0;
                        comb_next = 1;
                    end
                    else if (cb[2:0] == 3'b111) begin
                        comb_alu_src_a = `ALU_SRC_A_ACC;
                        comb_alu_dst = `ALU_DST_ACC;
                        comb_flags_we = !cb[7];
                    end
                    else begin
                        comb_alu_src_a = `ALU_SRC_A_REG;
                        comb_alu_dst = `ALU_DST_REG;
                        comb_rf_rd_sel = cb[2:0];
                        comb_rf_wr_sel = cb[2:0];
                        comb_flags_we = !cb[7];
                    end
                    if (cb[7:6] == 2'b00) begin
                        comb_alu_op_prefix = `ALU_OP_PREFIX_SHIFT_ROTATE;
                        comb_alu_op_src = `ALU_OP_SRC_INSTR_5TO3;
                    end
                    else begin
                        comb_alu_op_prefix = `ALU_OP_PREFIX_CB;
                        comb_alu_op_src = `ALU_OP_SRC_INSTR_7TO6;
                    end
                    if (cb[7:6] == 2'b01) begin
                        // Only affects flags
                        comb_alu_dst = `ALU_DST_DB;
                    end
                end
                else if (m_cycle == 2) begin
                    comb_opcode_redir = 1'b1;
                    comb_alu_src_a = `ALU_SRC_A_DB;
                    comb_alu_dst = `ALU_DST_DB;
                    if (cb[7:6] == 2'b00) begin
                        comb_alu_op_prefix = `ALU_OP_PREFIX_SHIFT_ROTATE;
                        comb_alu_op_src = `ALU_OP_SRC_INSTR_5TO3;
                    end
                    else begin
                        comb_alu_op_prefix = `ALU_OP_PREFIX_CB;
                        comb_alu_op_src = `ALU_OP_SRC_INSTR_7TO6;
                    end
                    if (cb[7:6] != 2'b01) begin
                        // Write-back cycle required.
                        comb_bus_op = `BUS_OP_WRITE;
                        comb_db_src = `DB_SRC_ALU;
                        comb_ab_src = `AB_SRC_REG;
                        comb_ct_op = `CT_OP_IDLE;
                        comb_next = 1;
                    end
                    comb_flags_we = !cb[7];
                end
            end
        end
    end

    always @(posedge clk) begin
        if ((ct_state == 2'd3) || (rst == 1'b1)) begin
            alu_src_a <= comb_alu_src_a;
            alu_src_b <= comb_alu_src_b;
            alu_src_xchg <= comb_alu_src_xchg;
            alu_op_prefix <= comb_alu_op_prefix;
            alu_op_src <= comb_alu_op_src;
            alu_op_signed <= comb_alu_op_signed;
            alu_dst <= comb_alu_dst;
            pc_src <= comb_pc_src;
            pc_we <= comb_pc_we;
            pc_b_sel <= comb_pc_b_sel;
            pc_jr <= comb_pc_jr;
            pc_revert <= comb_pc_revert;
            rf_wr_sel <= comb_rf_wr_sel;
            rf_rd_sel <= comb_rf_rd_sel;
            rf_rdw_sel <= comb_rf_rdw_sel;
            temp_redir <= comb_temp_redir;
            opcode_redir <= comb_opcode_redir;
            bus_op <= comb_bus_op;
            db_src <= comb_db_src;
            ab_src <= comb_ab_src;
            ct_op <= comb_ct_op;
            flags_we <= comb_flags_we;
            flags_pattern <= comb_flags_pattern;
            high_mask <= comb_high_mask;
            int_ack <= comb_int_ack;
            next <= comb_next;
            stop <= comb_stop;
            halt <= comb_halt;
            fault <= comb_fault;
        end
    end

endmodule


////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    17:30:26 02/08/2018 
// Module Name:    cpu
// Project Name:   VerilogBoy
// Description: 
//   The Game Boy CPU.
// Dependencies: 
// 
// Additional Comments: 
//   See doc/cpu_internal.md for signal definitions
////////////////////////////////////////////////////////////////////////////////

module cpu(
    input clk,
    input rst,
    output reg phi,
    output wire [1:0] ct,
    output reg [15:0] a,
    output reg [7:0] dout,
    input [7:0] din,
    output reg rd,
    output reg wr,
    input [4:0] int_en,
    input [4:0] int_flags_in,
    output wire [4:0] int_flags_out,
    input [7:0] key_in,
    output reg done,
    output wire fault
    );

    reg  [7:0]  opcode;
    reg  [7:0]  cb;
    wire [2:0]  m_cycle;
    reg  [2:0]  m_cycle_early;
    wire [1:0]  alu_src_a;
    wire [2:0]  alu_src_b;
    wire        alu_src_xchg;
    wire [1:0]  alu_op_prefix;
    wire [1:0]  alu_op_src;
    wire [1:0]  alu_dst;
    wire [1:0]  pc_src;
    wire        pc_we;
    wire [2:0]  rf_wr_sel;
    wire [2:0]  rf_rd_sel;
    wire [1:0]  rf_rdw_sel;
    wire [1:0]  bus_op;
    wire [1:0]  db_src;
    wire [1:0]  ab_src;
    wire [1:0]  ct_op;
    wire        flags_we;
    wire [1:0]  flags_pattern;
    wire        high_mask;
    wire        next;
    wire        stop;
    wire        halt;
    reg         wake;
    //wire        fault;
    reg         int_dispatch;
    wire        int_master_en;
    wire        int_ack;

    wire [2:0]  rf_rdn;
    wire [7:0]  rf_rd;
    reg  [7:0]  rf_rd_ex; // Buffer Rd selected during EX stage
    wire [1:0]  rf_rdwn;
    wire [15:0] rf_rdw;
    wire [7:0]  rf_h;
    wire [7:0]  rf_l;
    wire [15:0] rf_sp;
    wire [2:0]  rf_wrn;
    wire [7:0]  rf_wr;
    wire        rf_we;

    wire [7:0]  alu_a;
    wire [7:0]  alu_b;
    wire [7:0]  alu_result;
    reg  [7:0]  alu_result_buffer;
    wire [3:0]  alu_flags_in;
    wire [3:0]  alu_flags_out;
    wire [4:0]  alu_op;
    wire        alu_op_signed;
    wire        alu_carry_out;
    reg         alu_carry_out_ex;
    reg         alu_carry_out_ct;

    wire [7:0]  acc_wr;
    wire        acc_we;
    wire [7:0]  acc_rd;

    wire [15:0] pc_rd;
    wire [7:0]  pc_rd_b;
    wire        pc_b_sel; // byte select
    wire [15:0] pc_wr;
    wire [7:0]  pc_wr_b;
    wire        pc_we_h;
    wire        pc_we_l;

    wire [15:0] temp_rd; // temp value for 16bit imm

    wire [3:0]  flags_rd;
    wire [3:0]  flags_wr;
        
    wire [7:0]  db_wr; // Data into buffer
    wire [7:0]  db_rd; // Data out from buffer
    wire        db_we;

    wire [7:0]  imm_abs;
    wire [7:0]  imm_low;
    wire [7:0]  imm_ext;

    reg  [1:0]  ct_state;

    // Control Logic
    // Control Logic is only used in EX stage
    // Signals are gated.
    wire [1:0] alu_src_a_ex;
    wire [2:0] alu_src_b_ex;
    wire [1:0] alu_op_prefix_ex;
    wire [1:0] alu_op_src_ex;
    wire       alu_op_signed_ex;
    wire [1:0] alu_dst_ex;
    wire [2:0] rf_wr_sel_ex;
    wire [2:0] rf_rd_sel_ex;
    wire       flags_we_ex;
    wire       pc_b_sel_ex;
    wire       pc_jr;
    wire       pc_we_ex;
    wire       pc_revert;
    wire       temp_redir; // redirect regfile operation to temp register
    wire       opcode_redir;

    control control(
        .clk(clk),
        .rst(rst),
        .opcode_early(opcode),
        .cb(cb),
        .imm(imm_low),
        .m_cycle_early(m_cycle_early),
        .ct_state(ct_state),
        .f_z(flags_rd[3]),
        .f_c(flags_rd[0]),
        .alu_src_a(alu_src_a_ex),
        .alu_src_b(alu_src_b_ex),
        .alu_src_xchg(alu_src_xchg),
        .alu_op_prefix(alu_op_prefix_ex),
        .alu_op_src(alu_op_src_ex),
        .alu_op_signed(alu_op_signed_ex),
        .alu_dst(alu_dst_ex),
        .pc_src(pc_src),
        .pc_we(pc_we_ex),
        .pc_b_sel(pc_b_sel_ex),
        .pc_jr(pc_jr),
        .pc_revert(pc_revert),
        .rf_wr_sel(rf_wr_sel_ex),
        .rf_rd_sel(rf_rd_sel_ex),
        .rf_rdw_sel(rf_rdw_sel),
        .temp_redir(temp_redir),
        .opcode_redir(opcode_redir),
        .bus_op(bus_op),
        .db_src(db_src),
        .ab_src(ab_src),
        .ct_op(ct_op),
        .flags_we(flags_we_ex),
        .flags_pattern(flags_pattern),
        .high_mask(high_mask),
        .int_master_en(int_master_en),
        .int_dispatch(int_dispatch),
        .int_ack(int_ack),
        .next(next),
        .stop(stop),
        .halt(halt),
        .wake(wake),
        .fault(fault)
    );
    
    always @(posedge clk) begin
        done <= stop | halt | fault; 
        // only used to stop simulation if needed
        // and delay 1 clk
    end

    wire wake_comb = 
        // Any enabled interrupt can wake up halted CPU, IME doesn't matter
        (halt) ? ((int_flags_in & int_en) != 0) : (
        // Any enabled interrupt and any keypress can wake up stopped CPU
        // IME doesn't matter. Though the typical usage is clear the IE before
        // entering STOP mode, so only keypad can wake up the CPU.
        (stop) ? (((int_flags_in & int_en) != 0) || (key_in != 0)) : 
        (1'b0));
    reg wake_delay; // Wake should be delayed for 1 Mcycle
    always @(posedge clk) begin
        if (ct_state == 2'b10) begin
            wake_delay <= wake_comb;
            wake <= wake_delay;
        end
    end

    wire [7:3] current_opcode;

    // Data Bus Buffer
    reg [7:0] db_wr_buffer;
    reg [7:0] db_rd_buffer;
    
    // Logic: if buffer is selected, use the data in the buffer,
    // otherwise the buffer is overrided.
    always @(posedge clk) begin
        if (db_we)
            db_wr_buffer <= alu_result;
    end
    assign db_rd = db_rd_buffer;
    assign db_wr = (
        (db_src == 2'b00) ? (acc_rd) : (
        (db_src == 2'b01) ? (alu_result_buffer) : (
        (db_src == 2'b10) ? (rf_rd_ex) : (
        (db_src == 2'b11) ? (db_wr_buffer) : (8'b0)))));
    assign db_we = (alu_dst == 2'b11);

    // Address Bus Buffer
    wire [15:0] ab_wr;
    assign ab_wr = (
        (ab_src == 2'b00) ? (pc_rd) : (
        (ab_src == 2'b01) ? ((high_mask) ? ({8'hFF, temp_rd[7:0]}) : (temp_rd)) : (
        (ab_src == 2'b10) ? ((high_mask) ? ({8'hFF, rf_rdw[7:0]}) : (rf_rdw)) : (
        (ab_src == 2'b11) ? (rf_sp) : (16'b0)))));

    // Interrupt
    wire [4:0] int_flags_masked = int_flags_in & int_en & {5{int_master_en}};
    wire [4:0] int_flags_out_cleared = 
        (int_flags_masked[0]) ? (int_flags_in & 5'b11110) : (
        (int_flags_masked[1]) ? (int_flags_in & 5'b11101) : (
        (int_flags_masked[2]) ? (int_flags_in & 5'b11011) : (
        (int_flags_masked[3]) ? (int_flags_in & 5'b10111) : (
        (int_flags_masked[4]) ? (int_flags_in & 5'b01111) : (
            int_flags_in
        )))));

    assign int_flags_out = 
        ((int_dispatch)&&(pc_we)) ? (int_flags_out_cleared) : (int_flags_in);

    // Regisiter file
    wire [7:0] rf_rd_raw;
    regfile regfile(
        .clk(clk),
        .rst(rst),
        .rdn(rf_rdn),
        .rd(rf_rd_raw),
        .rdwn(rf_rdwn),
        .rdw(rf_rdw),
        .h(rf_h),
        .l(rf_l),
        .sp(rf_sp),
        .wrn(rf_wrn),
        .wr(rf_wr),
        .we(rf_we)
    );
    assign rf_wr = alu_result;
    assign rf_we = (alu_dst == 2'b10) && (!temp_redir);
    assign rf_wrn = rf_wr_sel;
    assign rf_rdn = rf_rd_sel;
    assign rf_rdwn = rf_rdw_sel;
    assign rf_rd = (!temp_redir) ? (rf_rd_raw) : ((rf_rd_sel[0]) ? (temp_rd[7:0]) : (temp_rd[15:8]));
    always@(posedge clk, posedge rst) begin
        if (rst)
            rf_rd_ex <= 8'b0;
        else
            if (ct_state == 2'b00)
                rf_rd_ex <= rf_rd_raw;
    end

    // Register A
    reg [15:0] imm_reg;
    singlereg #(8) acc(
        .clk(clk),
        .rst(rst),
        .wr(acc_wr),
        .we(acc_we),
        .rd(acc_rd)
    );
    assign acc_wr = ((db_src == 2'b00) && (bus_op == 2'b11)) ? (imm_reg[7:0]) : (alu_result); 
    assign acc_we = ((alu_dst == 2'b00) || ((db_src == 2'b00) && (bus_op == 2'b11)));
    
    // Register PC
    reg [15:0] pc;
    reg [15:0] last_pc;
    assign pc_rd = pc;
    assign pc_rd_b = (pc_b_sel == 1'b0) ? (pc[7:0]) : (pc[15:8]);
    assign pc_wr_b = alu_result;
    assign pc_wr = (
        (pc_src == 2'b00) ? (rf_rdw) : (
        (pc_src == 2'b01) ? ({10'b00, opcode[5:3], 3'b000}) : (
        (pc_src == 2'b10) ? (temp_rd) : (
        (pc_src == 2'b11) ? (16'b0) : (16'b0)))));
    wire [15:0] pc_int = 
        (int_flags_masked[0]) ? (16'h0040) : (
        (int_flags_masked[1]) ? (16'h0048) : (
        (int_flags_masked[2]) ? (16'h0050) : (
        (int_flags_masked[3]) ? (16'h0058) : (
        (int_flags_masked[4]) ? (16'h0060) : (
            // no interrupts anymore, dispatching is cancelled.
            // jump to 0000 instead
            // this behavior is tested by acceptence/interrupts/ie_push
            16'h0000
        )))));
    assign pc_we_l = ((alu_dst == 2'b01) && (pc_b_sel == 1'b0)) ? (1'b1) : (1'b0);
    assign pc_we_h = ((alu_dst == 2'b01) && (pc_b_sel == 1'b1)) ? (1'b1) : (1'b0);
    always @(posedge clk, posedge rst) begin
        if (rst)
            pc <= 16'b0;
        else begin
            if (pc_we_l) begin
                pc[7:0] <= pc_wr_b;
                last_pc[7:0] <= pc[7:0];
            end
            else if (pc_we_h) begin
                pc[15:8] <= pc_wr_b;
                last_pc[15:8] <= pc[15:8];
            end
            else if (pc_revert)
                pc <= last_pc;
            else if (pc_we)
                if (int_dispatch)
                    // this might need to be deffered
                    pc <= pc_int;
                else begin
                    pc <= pc_wr;
                    last_pc <= pc;
                end
        end
    end

    // Register F
    /*singlereg #(4) flags(
        .clk(clk),
        .rst(rst),
        .wr(flags_wr),
        .we((flags_we != 2'b00) ? 1'b1 : 1'b0),
        .rd(flags_rd)
    );*/
    reg [3:0] flags;
    always @(posedge clk, posedge rst) begin
        if (rst)
            flags <= 4'b0;
        else if (flags_we)
            if (flags_pattern == 2'b00)
                flags[3:0] <= flags_wr[3:0];
            else if (flags_pattern == 2'b01)
                flags[2:0] <= {1'b0, flags_wr[1:0]};
            else if (flags_pattern == 2'b10)
                flags[3:0] <= {2'b0, flags_wr[1:0]};
            else if (flags_pattern == 2'b11)
                flags[3:1] <= flags_wr[3:1];
    end
    assign flags_rd = flags;
    assign flags_wr = alu_flags_out;
    

    // ALU
    wire [2:0] alu_op_mux;
    wire [7:0] alu_a_pre;
    wire [7:0] alu_b_pre;

    alu alu(
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_bit_index(imm_reg[5:3]),
        .alu_result(alu_result),
        .alu_flags_in(alu_flags_in),
        .alu_flags_out(alu_flags_out),
        .alu_op(alu_op)
    );

    assign alu_a_pre = (
        (alu_src_a == 2'b00) ? (acc_rd) : (
        (alu_src_a == 2'b01) ? (pc_rd_b) : (
        (alu_src_a == 2'b10) ? (rf_rd) : (
        (alu_src_a == 2'b11) ? (db_rd) : (8'b0)))));

    assign alu_b_pre = (
        (alu_src_b == 3'b000) ? (acc_rd) : (
        (alu_src_b == 3'b001) ? ({7'b0, alu_carry_out}) : (
        (alu_src_b == 3'b010) ? (8'd0) : (
        (alu_src_b == 3'b011) ? (8'd1) : (
        (alu_src_b == 3'b100) ? (rf_h) : (
        (alu_src_b == 3'b101) ? (rf_l) : (
        (alu_src_b == 3'b110) ? (imm_abs) : (
        (alu_src_b == 3'b111) ? ((pc_b_sel) ? (imm_low) : (imm_ext)) : (8'b0))))))))); // cursed

    assign alu_a = (alu_src_xchg) ? (alu_b_pre) : (alu_a_pre);
    assign alu_b = (alu_src_xchg) ? (alu_a_pre) : (alu_b_pre);

    assign alu_op_mux = (
        (alu_op_src == 2'b00) ? (current_opcode[5:3]) : (
        (alu_op_src == 2'b01) ? ({1'b1, current_opcode[7:6]}) : (
        (alu_op_src == 2'b10) ? ((alu_op_signed) ? (3'b001) : (3'b000)) : (
        (alu_op_src == 2'b11) ? ((alu_op_signed) ? (3'b011) : (3'b010)) : (3'b0)))));

    assign alu_flags_in = flags_rd;
    assign alu_op = {alu_op_prefix, alu_op_mux};

    assign current_opcode[7:3] = (opcode_redir) ? (imm_reg[7:3]) : (opcode[7:3]);

    // CT FSM
    wire [1:0] ct_next_state;

    assign ct_next_state = ct_state + 2'b01;
    always @(posedge clk, posedge rst) begin
        if (rst)
            ct_state <= 2'b00;
        else
            ct_state <= ct_next_state;
    end

    assign ct = ct_state;

    //reg [15:0] imm_reg; decleared before
    assign temp_rd = imm_reg;
    assign imm_low = imm_reg[7:0];
    assign imm_ext = {8{imm_reg[7]}};
    assign imm_abs = (imm_reg[7]) ? (~imm_reg[7:0] + 1'b1) : (imm_reg[7:0]);

    // CT - FSM / Bus Operation 
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            a <= 16'b0;
            rd <= 1'b0;
            wr <= 1'b0;
            phi <= 1;
            opcode <= 8'b0;
            imm_reg <= 16'b0;
            db_rd_buffer <= 8'b0;
            dout <= 8'b0;
            int_dispatch <= 1'b0;
            alu_result_buffer <= 8'b0;
        end
        else begin
            if ((alu_dst == 2'b10) && temp_redir && !(ct_state == 2'b10 && bus_op == 2'b11))
                if (rf_wr_sel[0]) imm_reg[7:0] <= rf_wr;
                else imm_reg[15:8] <= rf_wr;

            case (ct_state)
            2'b00: begin
                // Setup Address
                a <= ab_wr;
                rd <= ((bus_op == 2'b01)||(bus_op == 2'b11)) ? (1'b1) : (1'b0);
                wr <= 0;
                phi <= 1;
                // Backup ALU results
                alu_result_buffer <= alu_result;
            end
            2'b01: begin
                // Read in progress

                // Interrupt dispatch happens here
                // Guarenteed if it is at instruction fetch cycle,
                // It is at instruction boundaries,
                // and m_cycle will start from 0.
                if ((!int_dispatch) && (int_flags_masked != 0) && (int_master_en))
                    int_dispatch <= 1'b1;
                else if ((int_dispatch) && (int_ack)) begin
                    int_dispatch <= 1'b0;
                end
            end
            2'b10: begin
                if (bus_op == 2'b10) begin
                    // Write cycle
                    wr <= 1;
                    dout <= db_wr;
                end
                else if (bus_op == 2'b01) begin
                    // Instruction Fetch Cycle
                    wr <= 0;
                    opcode <= din;
                end
                else if (bus_op == 2'b11) begin
                    // Data Read cycle
                    wr <= 0;
                    db_rd_buffer <= din;
                    if ((opcode == 8'hCB) && (m_cycle == 0)) cb <= din[7:0];
                    // mcycle is slower
                    if (m_cycle == 3'd0) imm_reg[7:0] <= din;
                    else if (m_cycle == 3'd1) imm_reg[15:8] <= din; 
                end
                else begin
                    wr <= 0;
                end
                rd <= 0;
                phi <= 0;
            end
            2'b11: begin
                // Bus Idle
                rd <= 0;
                wr <= 0;
                dout <= 8'b0;
            end
            endcase
        end
    end

    // CT - FSM / Instruction Execution
    reg  [1:0] alu_src_a_ct;
    reg  [2:0] alu_src_b_ct;
    wire [1:0] alu_op_prefix_ct = 2'b00;
    reg  [1:0] alu_op_src_ct;
    reg  [1:0] alu_dst_ct;
    reg  [2:0] rf_wr_sel_ct;
    reg  [2:0] rf_rd_sel_ct;
    reg        pc_b_sel_ct; 
      
 
    always @(*) begin
        // Do nothing by default
        alu_src_a_ct = 2'b00;  // From A
        alu_src_b_ct = 3'b010; // Constant 0
        alu_op_src_ct = 2'b10; // Add
        alu_dst_ct = 2'b00;    // To A
        rf_wr_sel_ct = 3'b000;
        rf_rd_sel_ct = 3'b000;
        pc_b_sel_ct = 1'b0;
        case (ct_state)
        2'b00: begin
            // Decoding and Execution
            // Actually cannot control anything
        end
        2'b01: begin
            // CT_OP first clock
            case (ct_op)
            2'b00: begin
                // Do nothing
            end
            2'b01: begin
                // Calculate PC low + 1
                pc_b_sel_ct = 1'b0;
                alu_src_a_ct = 2'b01;  // From PC byte
                alu_src_b_ct = (pc_jr) ? (3'b110) : (3'b011); // Imm Abs or Constant 1
                alu_op_src_ct = (pc_jr) ? (imm_low[7] ? 2'b11 : 2'b10) : 2'b10; // Add
                alu_dst_ct = 2'b01;    // To PC byte
            end
            2'b10: begin
                // Calculate SP low - 1
                rf_rd_sel_ct = 3'b111; // Read from SP low
                rf_wr_sel_ct = 3'b111; // Write to SP low
                alu_src_a_ct = 2'b10;  // From register file
                alu_src_b_ct = 3'b011; // Constant 1
                alu_op_src_ct = 2'b11; // Sub
                alu_dst_ct = 2'b10;    // To register file
            end
            2'b11: begin
                // Calculate SP low + 1
                rf_rd_sel_ct = 3'b111; // Read from SP low
                rf_wr_sel_ct = 3'b111; // Write to SP low
                alu_src_a_ct = 2'b10;  // From register file
                alu_src_b_ct = 3'b011; // Constant 1
                alu_op_src_ct = 2'b10; // Add
                alu_dst_ct = 2'b10;    // To register file
            end
            endcase
        end
        2'b10: begin
            // CT_OP second clock
            case (ct_op)
            2'b00: begin
                // Do nothing
            end
            2'b01: begin
                // Calculate PC high + carry
                pc_b_sel_ct = 1'b1;
                alu_src_a_ct = 2'b01;  // From PC byte
                alu_src_b_ct = 3'b001; // Carry
                alu_op_src_ct = (pc_jr) ? (imm_low[7] ? 2'b11 : 2'b10) : 2'b10; // Add
                alu_dst_ct = 2'b01;    // To PC byte
            end
            2'b10: begin
                // Calculate SP high - carry
                rf_rd_sel_ct = 3'b110; // Read from SP high
                rf_wr_sel_ct = 3'b110; // Write to SP high
                alu_src_a_ct = 2'b10;  // From register file
                alu_src_b_ct = 3'b001; // Carry
                alu_op_src_ct = 2'b11; // Sub
                alu_dst_ct = 2'b10;    // To register file
            end
            2'b11: begin
                // Calculate SP high + carry
                rf_rd_sel_ct = 3'b110; // Read from SP high
                rf_wr_sel_ct = 3'b110; // Write to SP high
                alu_src_a_ct = 2'b10;  // From register file
                alu_src_b_ct = 3'b001; // Carry
                alu_op_src_ct = 2'b10; // Add
                alu_dst_ct = 2'b10;    // To register file
            end
            endcase
        end
        2'b11: begin
            // End, it is safe to overwrite DB as doing nothing
            alu_dst_ct = 2'b11;
        end
        endcase
    end

    assign alu_src_a = (ct_state == 2'b00) ? (alu_src_a_ex) : (alu_src_a_ct);
    assign alu_src_b = (ct_state == 2'b00) ? (alu_src_b_ex) : (alu_src_b_ct);
    assign alu_op_prefix = (ct_state == 2'b00) ? (alu_op_prefix_ex) : (alu_op_prefix_ct);
    assign alu_op_src = (ct_state == 2'b00) ? (alu_op_src_ex) : (alu_op_src_ct);
    assign alu_op_signed = (ct_state == 2'b00) ? (alu_op_signed_ex) : (1'b0);
    assign alu_dst = (ct_state == 2'b00) ? (alu_dst_ex) : (alu_dst_ct);
    assign rf_wr_sel = (ct_state == 2'b00) ? (rf_wr_sel_ex) : (rf_wr_sel_ct);
    assign rf_rd_sel = (ct_state == 2'b00) ? (rf_rd_sel_ex) : (rf_rd_sel_ct);
    assign flags_we = (ct_state == 2'b00) ? (flags_we_ex) : (1'b0);
    assign pc_b_sel = (ct_state == 2'b00) ? (pc_b_sel_ex) : (pc_b_sel_ct);
    assign pc_we = (ct_state == 2'b00) ? (pc_we_ex) : (1'b0);
    assign alu_carry_out = (ct_state == 2'b00) ? (alu_carry_out_ex) : (alu_carry_out_ct);

    // EX - FSM / Mutli-M-cycle Instruction Handling
    reg  [2:0] ex_state;
    wire [2:0] ex_next_state;

    assign ex_next_state = (next) ? (ex_state + 3'd1) : (3'd0);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            ex_state <= 3'd0;
            m_cycle_early <= 3'd0;
            alu_carry_out_ex <= 1'b0;
            alu_carry_out_ct <= 1'b0;
        end
        else begin
            alu_carry_out_ct <= alu_flags_out[0];
            if (ct_state == 2'b11) begin
                ex_state <= ex_next_state;
            end
            else if (ct_state == 2'b10) begin
                m_cycle_early <= ex_next_state;
            end
            else if (ct_state == 2'b00) begin
                // Backup flag output
                alu_carry_out_ex <= alu_flags_out[0];
            end
        end
    end

    assign m_cycle = ex_state;

endmodule


/**
 * Block transfer unit for the GB80 CPU.
 * 
 * Author: Joseph Carlos (jdcarlos1@gmail.com)
 */

/**
 * The DMA unit.
 * 
 * Contains the DMA register and performs DMA transfers when the register is
 * written to. Each transfer takes 320 cycles rather than the canon 640, this
 * is because there's no reason to take 640.
 * 
 * @inout addr_ext The address bus.
 * @inout data_ext The data bus.
 * @output dma_transfer 1 if a transfer is occurring, 0 otherwise.
 * @input mem_re 1 if the processor is reading from memory.
 * @input mem_we 1 if the processor is writing to memory.
 * @input clock The CPU clock.
 * @input reset The CPU reset.
 */
module dma(
    input  wire        clk,
    input  wire        phi,
    input  wire        rst,
    output reg         dma_rd,
    output reg         dma_wr,
    //output wire        dma_rd_comb,
    //output wire        dma_wr_comb,
    output reg  [15:0] dma_a,
    input  wire [7:0]  dma_din,
    output reg  [7:0]  dma_dout,
    input  wire        mmio_wr,
    input  wire [7:0]  mmio_din,
    output wire [7:0]  mmio_dout,
    output wire        dma_occupy_extbus,
    output wire        dma_occupy_vidbus,
    output wire        dma_occupy_oambus
    );

    // DMA data blocks /////////////////////////////////////////////////////////

    reg [7:0]    dma_start_addr;
    reg [7:0]    count;

    assign mmio_dout = dma_start_addr;

    reg cpu_mem_disable;

    assign dma_occupy_extbus = cpu_mem_disable & 
            ((dma_start_addr <= 8'h7f) || (dma_start_addr >= 8'ha0));
    assign dma_occupy_vidbus = cpu_mem_disable &
            ((dma_start_addr >= 8'h80) && (dma_start_addr <= 8'h9f));
    assign dma_occupy_oambus = cpu_mem_disable;

   // DMA transfer logic //////////////////////////////////////////////////////
   
    localparam DMA_IDLE = 'd0;
    localparam DMA_TRANSFER_READ_ADDR  = 'd1;
    localparam DMA_TRANSFER_READ_DATA  = 'd2;
    localparam DMA_TRANSFER_WRITE_DATA = 'd3;
    localparam DMA_TRANSFER_WRITE_WAIT = 'd4;
    localparam DMA_DELAY = 'd5;
    
    reg [2:0] state;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            dma_start_addr <= 8'h00;
        end
        else begin
            if (mmio_wr) begin
                // Writing is always valid regardless of the state
                dma_start_addr <= mmio_din;
            end
        end
    end

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= DMA_IDLE;
            count <= 8'd0;
            dma_wr <= 1'b0;
            dma_rd <= 1'b0;
            cpu_mem_disable <= 1'b0;
        end
        else begin
            case (state)
            DMA_IDLE: begin
                dma_wr <= 1'b0;
                dma_rd <= 1'b0;
                cpu_mem_disable <= 1'b0;
                if (mmio_wr) begin
                    // Transfer starts on next cycle
                    state <= DMA_DELAY;
                    count <= 8'd3; // Delay before start
                end
                else
                    count <= 8'd0;
            end
            DMA_DELAY: begin
                if (count != 8'd0) begin
                    count <= count - 1;
                end
                else begin
                    state <= DMA_TRANSFER_READ_ADDR;
                end
            end
            DMA_TRANSFER_READ_ADDR: begin
                dma_wr <= 1'b0;
                cpu_mem_disable <= 1'b1;
                // Load the temp register with data from memory
                dma_a <= {dma_start_addr, count}; // Output read address
                dma_rd <= 1'b1;
                if (mmio_wr) begin // Allow re-triggering
                    state <= DMA_DELAY;
                    count <= 8'd3; // Delay before start
                end
                else
                    state <= DMA_TRANSFER_READ_DATA;
            end
            DMA_TRANSFER_READ_DATA: begin
                state <= DMA_TRANSFER_WRITE_DATA;
                // Basically wait
            end
            DMA_TRANSFER_WRITE_DATA: begin
                // Read data
                dma_dout <= dma_din;
                dma_rd <= 1'b0;
                // Write the temp register to memory
                dma_a <= {8'hfe, count}; // Output write address
                dma_wr <= 1'b1;
                if (mmio_wr) begin // Allow re-triggering
                    state <= DMA_DELAY;
                    count <= 8'd3; // Delay before start
                end
                else
                    state <= DMA_TRANSFER_WRITE_WAIT;
            end
            DMA_TRANSFER_WRITE_WAIT: begin
                // Wait
                if (mmio_wr) begin // Allow re-triggering
                    state <= DMA_DELAY;
                    count <= 8'd3; // Delay before start
                end
                else
                if (count == 8'h9f) begin
                    state <= DMA_IDLE;
                    count <= 8'd0;
                end
                else begin
                    state <= DMA_TRANSFER_READ_ADDR;
                    count <= count + 8'd1;
                end
            end
            default: begin
            end
            endcase
        end
    end
   
endmodule // dma


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    23:34:43 03/15/2018 
// Design Name: 
// Module Name:    mbc5 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mbc5(
    input vb_clk,
    input [15:12] vb_a,
    input [7:0] vb_d,
    input vb_wr,
    input vb_rd,
    input vb_rst,
    output [22:14] rom_a,
    output [16:13] ram_a,
    output rom_cs_n,
    output ram_cs_n
    );

    reg [8:0] rom_bank;
    reg [3:0] ram_bank;
    reg ram_en = 1'b0; // RAM Access Enable

    wire rom_addr_en; // RW Address in ROM range
    wire ram_addr_en; // RW Address in RAM range
    wire rom_addr_lo; // RW Address in LoROM range

    wire [15:0] vb_addr;

    assign vb_addr[15:12] = vb_a[15:12];
    assign vb_addr[11:0] = 12'b0;

    assign rom_addr_en =  (vb_addr >= 16'h0000)&(vb_addr <= 16'h7FFF); //Request Addr in ROM range
    assign ram_addr_en =  (vb_addr >= 16'hA000)&(vb_addr <= 16'hBFFF); //Request Addr in RAM range
    assign rom_addr_lo =  (vb_addr >= 16'h0000)&(vb_addr <= 16'h3FFF); //Request Addr in LoROM range

    assign rom_cs_n = ((rom_addr_en) & (vb_rst == 0)) ? 1'b0 : 1'b1; //ROM output enable
    assign ram_cs_n = ((ram_addr_en) & (ram_en) & (vb_rst == 0)) ? 1'b0 : 1'b1; //RAM output enable

    assign rom_a[22:14] = rom_addr_lo ? 9'b0 : rom_bank[8:0];
    assign ram_a[16:13] = ram_bank[3:0];
    
    reg vb_wr_last;
    
    always@(posedge vb_clk, posedge vb_rst)
    begin
        if (vb_rst) begin
            vb_wr_last <= 1'b0;
            rom_bank[8:0] <= 9'b000000001;
            ram_bank[3:0] <= 4'b0000;
            ram_en <= 1'b0;
        end
        else begin
            vb_wr_last <= vb_wr;
            if ((vb_wr_last == 0)&&(vb_wr == 1)) begin
                case (vb_addr)
                    16'h0000: ram_en <= (vb_d[3:0] == 4'hA) ? 1'b1 : 1'b0;
                    16'h1000: ram_en <= (vb_d[3:0] == 4'hA) ? 1'b1 : 1'b0;
                    16'h2000: rom_bank[7:0] <= vb_d[7:0];
                    16'h3000: rom_bank[8] <= vb_d[0];
                    16'h4000: ram_bank[3:0] <= vb_d[3:0];
                    16'h5000: ram_bank[3:0] <= vb_d[3:0];
                endcase
            end
        end
    end

endmodule


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    18:48:36 02/14/2018 
// Design Name: 
// Module Name:    ppu 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//   GameBoy PPU
// Additional Comments: 
//   There are three hardware layers in the GameBoy PPU: Background, Window, and 
//   Object (or sprites).
//
//   Window will render above the background and the object can render above the
//   background or under the background. Each object have a priority bit to
//   indicate where it should be rendered.
//
//   Background, Window, and Object can be individually turned on or off. When 
//   nothing is turned on, it displays white.
//
//   The whole render logic does NOT require a scanline buffer to work, and it
//   runs at 4MHz (VRAM runs at 2MHz)
//
//   There are two main parts of the logic, implemented in a big FSM. The first
//   one is the fetch unit, and the other is the pixel FIFO.
//
//   The pixel FIFO shifts out one pixel when it contains more than 8 pixels, the 
//   fetch unit would generally render 8 pixels in 6 cycles (so 2 wait cycles are
//   inserted so they are in sync generally). When there is no enough pixels,
//   the FIFO would stop and wait for the fetch unit.
//
//   Windows Trigger is handled in the next state logic, there is a distinct state
//   for the PPU to switch from background rendering to window rendering (flush 
//   the fifo and add wait cycles.)
//
//   Object Trigger is handled in the state change block, in order to backup the 
//   previous state. Current RAM address is also backed up during the handling of
//   object rendering. Once all the objects at this position has been rendered,
//   the render state machine could be restored to its previous state.
//
//   The output pixel clock is the inverted main clock, which is the same as the
//   real Game Boy Pixel data would be put on the pixel bus on the negedge of 
//   clock, so the LCD would latch the data on the posedge. The original Game Boy
//   used a gated clock to control if output is valid. Since gated clock is not
//   recommend, I used a valid signal to indicate is output should be considered
//   valid.
//////////////////////////////////////////////////////////////////////////////////
`default_nettype wire
module ppu(
    input clk,
    input rst,
    // MMIO Bus, 0xFF40 - 0xFF4B, always visible to CPU
    input wire [15:0] mmio_a,
    output reg [7:0]  mmio_dout,
    input wire [7:0]  mmio_din,
    input wire        mmio_rd,
    input wire        mmio_wr,
    // VRAM Bus, 0x8000 - 0x9FFF
    input wire [15:0] vram_a,
    output wire [7:0] vram_dout,
    input wire [7:0]  vram_din,
    input wire        vram_rd,
    input wire        vram_wr,
    // OAM Bus,  0xFE00 - 0xFE9F
    input wire [15:0] oam_a,
    output wire [7:0] oam_dout,
    input wire [7:0]  oam_din,
    input wire        oam_rd,
    input wire        oam_wr,
    // Interrupt interface
    output reg int_vblank_req,
    output reg int_lcdc_req,
    input int_vblank_ack,
    input int_lcdc_ack,
    // Pixel output
    output cpl, // Pixel Clock, = ~clk
    output reg [1:0] pixel, // Pixel Output
    output reg valid, // Pixel Valid
    output reg hs, // Horizontal Sync, High Valid
    output reg vs, // Vertical Sync, High Valid
    //Debug output
    output [7:0] scx,
    output [7:0] scy,
    output [4:0] state
    );
    
    // Global Wires ?
    integer i;
    
    // PPU registers
    reg [7:0] reg_lcdc; //$FF40 LCD Control (R/W)
    reg [7:0] reg_stat; //$FF41 LCDC Status (R/W)
    reg [7:0] reg_scy;  //$FF42 Scroll Y (R/W)
    reg [7:0] reg_scx;  //$FF43 Scroll X (R/W)
    reg [7:0] reg_ly;   //$FF44 LCDC Y-Coordinate (R) Write will reset the counter
    reg [7:0] reg_dma;  //$FF46 DMA, actually handled outside of PPU for now
    reg [7:0] reg_lyc;  //$FF45 LY Compare (R/W)
    reg [7:0] reg_bgp;  //$FF47 BG Palette Data (R/W) Non-CGB mode only
    reg [7:0] reg_obp0; //$FF48 Object Palette 0 Data (R/W) Non-CGB mode only
    reg [7:0] reg_obp1; //$FF49 Object Palette 1 Data (R/W) Non-CGB mode only
    reg [7:0] reg_wy;   //$FF4A Window Y Position (R/W)
    reg [7:0] reg_wx;   //$FF4B Window X Position (R/W)
    
    // Some interrupt related register
    reg [7:0] reg_ly_last;
    reg [1:0] reg_mode_last; // Next mode based on next state
    
    wire reg_lcd_en = reg_lcdc[7];          //0=Off, 1=On
    wire reg_win_disp_sel = reg_lcdc[6];    //0=9800-9BFF, 1=9C00-9FFF
    wire reg_win_en = reg_lcdc[5];          //0=Off, 1=On
    wire reg_bg_win_data_sel = reg_lcdc[4]; //0=8800-97FF, 1=8000-8FFF
    wire reg_bg_disp_sel = reg_lcdc[3];     //0=9800-9BFF, 1=9C00-9FFF
    wire reg_obj_size = reg_lcdc[2];        //0=8x8, 1=8x16
    wire reg_obj_en = reg_lcdc[1];          //0=Off, 1=On
    wire reg_bg_disp = reg_lcdc[0];         //0=Off, 1=On
    wire reg_lyc_int = reg_stat[6];
    wire reg_oam_int = reg_stat[5];
    wire reg_vblank_int = reg_stat[4];
    wire reg_hblank_int = reg_stat[3];
    wire reg_coin_flag = reg_stat[2];
    wire [1:0] reg_mode = reg_stat[1:0];
    
    localparam PPU_MODE_H_BLANK    = 2'b00;
    localparam PPU_MODE_V_BLANK    = 2'b01;
    localparam PPU_MODE_OAM_SEARCH = 2'b10;
    localparam PPU_MODE_PIX_TRANS  = 2'b11;
    
    localparam PPU_PAL_BG  = 2'b00;
    localparam PPU_PAL_OB0 = 2'b01;
    localparam PPU_PAL_OB1 = 2'b10;
    
    reg [12:0] vram_addr_bg;
    reg [12:0] vram_addr_obj;
    wire [12:0] vram_addr_int;
    wire [12:0] vram_addr_ext;
    wire vram_addr_int_sel; // 0 - BG, 1 - OBJ
    
    assign vram_addr_int = (vram_addr_int_sel == 1'b1) ? (vram_addr_obj) : (vram_addr_bg);
    
    wire vram_access_ext = ((reg_mode == PPU_MODE_H_BLANK)||
                            (reg_mode == PPU_MODE_V_BLANK)||
                            (reg_mode == PPU_MODE_OAM_SEARCH));
    wire vram_access_int = ~vram_access_ext;
    wire oam_access_ext = ((reg_mode == PPU_MODE_H_BLANK)||
                           (reg_mode == PPU_MODE_V_BLANK));
    
    wire [12:0] window_map_addr = (reg_win_disp_sel) ? (13'h1C00) : (13'h1800);
    wire [12:0] bg_map_addr = (reg_bg_disp_sel) ? (13'h1C00) : (13'h1800);
    wire [12:0] bg_window_tile_addr = (reg_bg_win_data_sel) ? (13'h0000) : (13'h0800);
    
    // PPU Memories
    
    // 8 bit WR, 16 bit RD, 160Bytes OAM
    reg [7:0] oam_u [0: 79];
    reg [7:0] oam_l [0: 79];
    reg [7:0] oam_rd_addr_int;
    wire [7:0] oam_rd_addr;
    wire [7:0] oam_wr_addr;
    reg [15:0] oam_data_out;
    wire [7:0] oam_data_out_byte;
    wire [7:0] oam_data_in;
    wire oam_we;
    
    always @ (negedge clk)
    begin
        if (oam_we) begin
            if (oam_wr_addr[0])
                oam_u[oam_wr_addr[7:1]] <= oam_data_in;
            else
                oam_l[oam_wr_addr[7:1]] <= oam_data_in;
        end
        else begin
            oam_data_out <= {oam_u[oam_rd_addr[7:1]], oam_l[oam_rd_addr[7:1]]};
        end
    end
    
    assign oam_wr_addr = oam_a[7:0];
    assign oam_rd_addr = (oam_access_ext) ? (oam_a[7:0]) : (oam_rd_addr_int); 
    assign oam_data_in = oam_din;
    assign oam_data_out_byte = (oam_rd_addr[0]) ? oam_data_out[15:8] : oam_data_out[7:0];
    //assign oam_we = (wr)&(oam_access_ext);
    assign oam_we = oam_wr; // What if always allow OAM access?
    assign oam_dout = (oam_access_ext) ? (oam_data_out_byte) : (8'hFF);

    // 8 bit WR, 8 bit RD, 8KB VRAM
    wire        vram_we;
    wire [12:0] vram_addr;
    wire [7:0]  vram_data_in;
    wire [7:0]  vram_data_out;
    
    singleport_ram #(
        .WORDS(8192)
    ) br_vram (
        .clka(~clk),
        .wea(vram_we),
        .addra(vram_addr[12:0]),
        .dina(vram_data_in),
        .douta(vram_data_out));
        
    assign vram_addr_ext = vram_a[12:0];
    assign vram_addr = (vram_access_ext) ? (vram_addr_ext) : (vram_addr_int);
    assign vram_data_in = vram_din;
    assign vram_we = (vram_wr)&(vram_access_ext);
    assign vram_dout = (vram_access_ext) ? (vram_data_out) : (8'hFF);
    
    // Pixel Pipeline
    
    // The pixel FIFO: 16 pixels, 4 bits each (2 bits color index, 2 bits palette index)
    // Since in and out are 8 pixels aligned, it can be modeled as a ping-pong buffer
    // of two 32 bits (8 pixels * 4 bits) group
    reg [63:0] pf_data; // Pixel FIFO Data
    wire [1:0] pf_output_pixel;
    wire [7:0] pf_output_palette;
    wire [1:0] pf_output_pixel_id;
    wire [1:0] pf_output_palette_id;
    assign {pf_output_pixel_id, pf_output_palette_id} = pf_data[63:60];
    assign pf_output_palette = (pf_output_palette_id == PPU_PAL_BG)  ? (reg_bgp)  :
                               (pf_output_palette_id == PPU_PAL_OB0) ? (reg_obp0) :
                               (pf_output_palette_id == PPU_PAL_OB1) ? (reg_obp1) : (8'hFF);
    assign pf_output_pixel = (pf_output_pixel_id == 2'b11) ? (pf_output_palette[7:6]) :
                             (pf_output_pixel_id == 2'b10) ? (pf_output_palette[5:4]) :
                             (pf_output_pixel_id == 2'b01) ? (pf_output_palette[3:2]) :
                             (pf_output_pixel_id == 2'b00) ? (pf_output_palette[1:0]) : (2'b00);
    reg [2:0] pf_empty; // Indicate if the Pixel FIFO is empty. 
    localparam PF_INITA = 3'd5; // When a line start...
    localparam PF_INITB = 3'd4; // Line start, 2 pixels out, 8 rendered
    localparam PF_EMPTY = 3'd3; // When the pipeline get flushed
    localparam PF_HALF  = 3'd2; // After flushed, 8 pixels in
    localparam PF_FIN   = 3'd1; // 16 pixels in, but still no wait cycles
    localparam PF_FULL  = 3'd0; // Normal

    assign cpl = ~clk;
    //assign pixel = pf_output_pixel;
    
    // HV Timing
    localparam PPU_H_FRONT  = 9'd76;
    localparam PPU_H_SYNC   = 9'd4;    // So front porch + sync = OAM search
    localparam PPU_H_TOTAL  = 9'd456;
    localparam PPU_H_PIXEL  = 9'd160;
    // 8 null pixels in the front for objects which have x < 8, 8 bit counter
    localparam PPU_H_OUTPUT = 8'd168;
    localparam PPU_V_ACTIVE = 8'd144;
    localparam PPU_V_BACK   = 8'd9;
    localparam PPU_V_SYNC   = 8'd1;  
    localparam PPU_V_BLANK  = 8'd10;
    localparam PPU_V_TOTAL  = 8'd154;
   
    // Raw timing counter
    reg [8:0] h_count;
    reg [7:0] v_count;
    
    // HV counter
    always @(posedge clk, posedge rst)
    begin
        if (rst) begin
            h_count <= 0;
            hs <= 0;
            v_count <= 0;
            vs <= 0;
        end
        else begin
            if(h_count < PPU_H_TOTAL - 1)
                h_count <= h_count + 1'b1;
            else begin
                h_count <= 0;
                if(v_count < PPU_V_TOTAL - 1)
                    v_count <= v_count + 1'b1;
                else
                    v_count <= 0;
                if(v_count == PPU_V_ACTIVE + PPU_V_BACK - 1)
                    vs <= 1;
                if(v_count == PPU_V_ACTIVE + PPU_V_BACK + PPU_V_SYNC - 1)
                    vs <= 0;
            end
            if(h_count == PPU_H_FRONT - 1)
                hs <= 1;
            if(h_count == PPU_H_FRONT + PPU_H_SYNC - 1)
                hs <= 0;
        end 
    end
    
    // Render FSM
    localparam S_IDLE     = 5'd0; 
    localparam S_BLANK    = 5'd1;  // H Blank and V Blank
    localparam S_OAMX     = 5'd2;  // OAM Search X check
    localparam S_OAMY     = 5'd3;  // OAM Search Y check
    localparam S_FTIDA    = 5'd4;  // Fetch Read Tile ID Stage A (Address Setup)
    localparam S_FTIDB    = 5'd5;  // Fetch Read Tile ID Stage B (Data Read)
    localparam S_FRD0A    = 5'd6;  // Fetch Read Data 0 Stage A
    localparam S_FRD0B    = 5'd7;  // Fetch Read Data 0 Stage B
    localparam S_FRD1A    = 5'd8;  // Fetch Read Data 1 Stage A
    localparam S_FRD1B    = 5'd9;  // Fetch Read Data 1 Stage B
    localparam S_FWAITA   = 5'd10; // Fetch Wait Stage A (Idle)
    localparam S_FWAITB   = 5'd11; // Fetch Wait Stage B (Load to FIFO?)
    localparam S_SWW      = 5'd12; // Fetch Switch to Window
    localparam S_OAMRDA   = 5'd13; // OAM Read Stage A
    localparam S_OAMRDB   = 5'd14; // OAM Read Stage B
    localparam S_OFRD0A   = 5'd15; // Object Fetch Read Data 0 Stage A
    localparam S_OFRD0B   = 5'd16; // Object Fetch Read Data 0 Stage B
    localparam S_OFRD1A   = 5'd17; // Object Fetch Read Data 1 Stage A
    localparam S_OFRD1B   = 5'd18; // Object Fetch Read Data 1 Stage B
    localparam S_OWB      = 5'd19; // Object Write Back
    
    localparam PPU_OAM_SEARCH_LENGTH = 6'd40;

    reg [2:0] h_drop; //Drop pixels when SCX % 8 != 0
    wire [2:0] h_extra = reg_scx[2:0]; //Extra line length when SCX % 8 != 0
    reg [7:0] h_pix_render; // Horizontal Render Pixel pointer
    reg [7:0] h_pix_output; // Horizontal Output Pixel counter
    wire [7:0] h_pix_obj = h_pix_output + 1'b1; // Coordinate used to trigger the object rendering
    wire [7:0] v_pix = v_count;
    wire [7:0] v_pix_in_map = v_pix + reg_scy;
    wire [7:0] v_pix_in_win = v_pix - reg_wy;

    reg [4:0] r_state = 0;
    reg [4:0] r_next_backup;
    reg [4:0] r_next_state;
    wire is_in_v_blank = ((v_count >= PPU_V_ACTIVE) && (v_count < PPU_V_ACTIVE + PPU_V_BLANK));
    
    reg window_triggered; // Indicate whether window has been triggered, should be replaced by a edge detector
    wire render_window_or_bg = window_triggered;
    wire window_trigger = (((h_pix_output) == (reg_wx))&&(v_pix >= reg_wy)&&(reg_win_en)&&(~window_triggered)) ? 1 : 0;
    
    wire [2:0] line_to_tile_v_offset_bg = v_pix_in_map[2:0]; // Current line in a tile being rendered
    wire [4:0] line_in_tile_v_bg = v_pix_in_map[7:3]; // Current tile Y coordinate being rendered
    wire [2:0] line_to_tile_v_offset_win = v_pix_in_win[2:0];
    wire [4:0] line_in_tile_v_win = v_pix_in_win[7:3];
    wire [2:0] line_to_tile_v_offset = (render_window_or_bg) ? (line_to_tile_v_offset_win) : (line_to_tile_v_offset_bg);
    wire [4:0] line_in_tile_v = (render_window_or_bg) ? (line_in_tile_v_win) : (line_in_tile_v_bg);
    
    wire [4:0] h_tile_bg = h_pix_render[7:3] + reg_scx[7:3]; // Current tile X coordinate being rendered
    wire [4:0] h_tile_win = h_pix_render[7:3];
    wire [4:0] h_tile = (render_window_or_bg) ? (h_tile_win) : (h_tile_bg);  
    
    wire [12:0] current_map_address = (((render_window_or_bg) ? (window_map_addr) : (bg_map_addr)) + (line_in_tile_v) * 32 + {8'd0, h_tile}); //Background address
    reg [7:0] current_tile_id;
    wire [7:0] current_tile_id_adj = {~((reg_bg_win_data_sel)^(current_tile_id[7])), current_tile_id[6:0]}; // Adjust for 8800 Adressing mode
    wire [12:0] current_tile_address_0 = (bg_window_tile_addr) + current_tile_id_adj * 16 + (line_to_tile_v_offset * 2);
    wire [12:0] current_tile_address_1 = (current_tile_address_0) | 13'h0001;
    reg [7:0] current_tile_data_0;
    reg [7:0] current_tile_data_1;
   
    // Data that will be pushed into pixel FIFO
    // Organized in pixels
    reg [31:0] current_fetch_result;
    always@(current_tile_data_1, current_tile_data_0) begin
        for (i = 0; i < 8; i = i + 1) begin
            current_fetch_result[i*4+3] = current_tile_data_1[i];
            current_fetch_result[i*4+2] = current_tile_data_0[i];
            current_fetch_result[i*4+1] = PPU_PAL_BG[1]; // Fetch could only fetch BG
            current_fetch_result[i*4+0] = PPU_PAL_BG[0];
        end
    end
    
    reg [5:0] oam_search_count; // Counter during OAM search stage
    reg [5:0] obj_visible_list [0:9]; // Total visible list
    reg [7:0] obj_trigger_list [0:9]; // Where the obj should be triggered
    reg [7:0] obj_y_list [0:9]; // Where the obj is
    reg obj_valid_list [0:9]; // Is obj visible entry valid
    reg [3:0] oam_visible_count; // ???
    
    wire [7:0] oam_search_x;
    wire [7:0] oam_search_y;
    wire [7:0] obj_size_h = (reg_obj_size == 1'b1) ? (8'd16) : (8'd8);
    wire [7:0] obj_h_upper_boundary = (v_pix + 8'd16);
    wire [7:0] obj_h_lower_boundary = obj_h_upper_boundary - obj_size_h;

    reg [3:0] obj_trigger_id; // The object currently being/ or have been rendered, in the visible list
        
    localparam OBJ_TRIGGER_NOT_FOUND = 4'd15; 
    
    // Cascade mux used to implement the searching of next id would be triggered
    reg [3:0] obj_trigger_id_from[0:10];
    reg [3:0] obj_trigger_id_next;
    always@(h_pix_obj, obj_trigger_id) begin
        obj_trigger_id_from[10] = OBJ_TRIGGER_NOT_FOUND; // There is no more after the 10th
        for (i = 9; i >= 0; i = i - 1) begin
            /* verilator lint_off WIDTH */
            obj_trigger_id_from[i] = 
                ((h_pix_obj == obj_trigger_list[i])&&(obj_valid_list[i])) ? (i) : (obj_trigger_id_from[i+1]);
                // See if this one match, if not, cascade down.
            /* verilator lint_on WIDTH */
        end
        if (obj_trigger_id == OBJ_TRIGGER_NOT_FOUND) // currently not triggered yet
            obj_trigger_id_next = obj_trigger_id_from[0]; // Search from start
        else
            obj_trigger_id_next = obj_trigger_id_from[obj_trigger_id + 1]; // Search start from next one
    end
    
    //!-- DEBUG --
    //wire [3:0] obj_trigger_id_next = ((h_pix_obj == obj_trigger_list[4'd0])&&(obj_valid_list[4'd0])) ? (4'd0) : (4'd15);
    
    wire obj_trigger = ((reg_obj_en)&&(obj_trigger_id_next != OBJ_TRIGGER_NOT_FOUND)) ? 1 : 0;
    //wire obj_trigger = 0;
    
    wire [5:0] obj_triggered = obj_visible_list[obj_trigger_id]; // The global id of object being rendered
    wire [7:0] current_obj_y = obj_y_list[obj_trigger_id];
    wire [7:0] current_obj_x = obj_trigger_list[obj_trigger_id]; //h_pix gets incremented before render
    reg [7:0] current_obj_tile_id_raw; // Tile ID without considering the object size
    reg [7:0] current_obj_flags; // Flags
    wire current_obj_to_bg_priority = current_obj_flags[7];
    wire current_obj_y_flip = current_obj_flags[6];
    wire current_obj_x_flip = current_obj_flags[5];
    wire current_obj_pal_id = current_obj_flags[4];
    wire [1:0] current_obj_pal= (current_obj_pal_id) ? (PPU_PAL_OB1) : (PPU_PAL_OB0);
    /* verilator lint_off WIDTH */
    wire [3:0] line_to_obj_v_offset_raw = (v_pix + 8'd16 - current_obj_y); // Compensate 16 pixel offset and truncate to 4 bits
    /* verilator lint_on WIDTH */
    wire [7:0] current_obj_tile_id = (reg_obj_size == 1'b1) ? 
        ({current_obj_tile_id_raw[7:1], (((line_to_obj_v_offset_raw[3])^(current_obj_y_flip)) ? 1'b1 : 1'b0)}) : // Select Hi or Lo tile
        (current_obj_tile_id_raw); // Use tile ID directly
    wire [2:0] line_to_obj_v_offset = (current_obj_y_flip) ? (~line_to_obj_v_offset_raw[2:0]) : (line_to_obj_v_offset_raw[2:0]);
    
    wire [12:0] current_obj_address_0 = current_obj_tile_id * 16 + line_to_obj_v_offset * 2;
    wire [12:0] current_obj_address_1 = current_obj_address_0 | 13'h0001;
    reg [7:0] current_obj_tile_data_0;
    reg [7:0] current_obj_tile_data_1;
    // Data that will be merged into pixel FIFO
    // Organized in pixels 
    reg [31:0] merge_result;
    always@(*) begin
        for (i = 0; i < 8; i = i + 1) begin
            if (
                    ((current_obj_tile_data_1[i] != 1'b0)||(current_obj_tile_data_0[i] != 1'b0))&&
                    ((pf_data[32+i*4+1] == PPU_PAL_BG[1])&&(pf_data[32+i*4+0] == PPU_PAL_BG[0]))&&
                    (
                        ((current_obj_to_bg_priority)&&(pf_data[32+i*4+3] == 1'b0)&&(pf_data[32+i*4+2] == 1'b0))|| 
                        (~current_obj_to_bg_priority)
                    )
                ) //(OBJ is not transparent) and ((BG priority and BG is transparent) or (OBJ priority))
            begin 
                merge_result[i*4+3] = current_obj_tile_data_1[i];
                merge_result[i*4+2] = current_obj_tile_data_0[i];
                merge_result[i*4+1] = current_obj_pal[1];
                merge_result[i*4+0] = current_obj_pal[0];
            end
            else begin
                merge_result[i*4+3] = pf_data[32+i*4+3];
                merge_result[i*4+2] = pf_data[32+i*4+2];
                merge_result[i*4+1] = pf_data[32+i*4+1];
                merge_result[i*4+0] = pf_data[32+i*4+0];
            end
        end
    end
    
    assign vram_addr_int_sel = 
        ((r_state == S_OAMRDB) || (r_state == S_OFRD0A) || (r_state == S_OFRD0B)
            || (r_state == S_OFRD1A) || (r_state == S_OFRD1B)) ? 1'b1 : 1'b0;
        
    
    // Current mode logic, based on current state
    always @ (posedge clk, posedge rst)
    begin
        if (rst) begin
            reg_stat[1:0] <= PPU_MODE_V_BLANK;
        end
        else begin
            case (r_state)
            S_IDLE: reg_stat[1:0] <= PPU_MODE_V_BLANK;
            S_BLANK: reg_stat[1:0] <= (is_in_v_blank) ? (PPU_MODE_V_BLANK) : (PPU_MODE_H_BLANK);
            S_OAMX: reg_stat[1:0] <= PPU_MODE_OAM_SEARCH;
            S_OAMY: reg_stat[1:0] <= PPU_MODE_OAM_SEARCH;
            S_FTIDA: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_FTIDB: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_FRD0A: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_FRD0B: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_FRD1A: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_FRD1B: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_FWAITA: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_FWAITB: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_SWW: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_OAMRDA: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_OAMRDB: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_OFRD0A: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_OFRD0B: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_OFRD1A: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_OFRD1B: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            S_OWB: reg_stat[1:0] <= PPU_MODE_PIX_TRANS;
            default: reg_stat[1:0] <= PPU_MODE_V_BLANK;
            endcase
        end
    end

    assign oam_search_y = oam_data_out[7:0];
    assign oam_search_x = oam_data_out[15:8];

    // Render logic
    always @(posedge clk)
    begin
        reg_ly <= v_pix[7:0];
        
        case (r_state)
            // nothing to do for S_IDLE
            S_IDLE: begin end
            S_BLANK: begin
                h_pix_render <= 8'd0; // Render pointer
                oam_search_count <= 6'd0;
                oam_visible_count <= 4'd0;
                for (i = 0; i < 10; i = i + 1) begin
                    obj_valid_list[i] <= 1'b0;
                end
                oam_rd_addr_int <= 8'b0;
                window_triggered <= 1'b0;
                // Line start, need to render 16 pixels in 12 clocks
                // and output 8 null pixels starting from the 4th clock
            end
            S_OAMX: begin
                oam_rd_addr_int <= oam_search_count * 4;
            end
            S_OAMY: begin
                if ((oam_search_y <= obj_h_upper_boundary)&&
                    (oam_search_y >  obj_h_lower_boundary)&&
                    (oam_search_x != 8'd0)&&
                    (oam_visible_count < 4'd10)) begin
                    obj_visible_list[oam_visible_count] <= oam_search_count;
                    obj_trigger_list[oam_visible_count] <= oam_search_x;
                    obj_y_list[oam_visible_count] <= oam_search_y;
                    obj_valid_list[oam_visible_count] <= 1'b1;
                    oam_visible_count <= oam_visible_count + 1'b1;
                end
                oam_search_count <= oam_search_count + 1'b1;
            end
            S_FTIDA: vram_addr_bg <= current_map_address;
            S_FTIDB: current_tile_id <= vram_data_out;
            S_FRD0A: vram_addr_bg <= current_tile_address_0;
            S_FRD0B: current_tile_data_0 <= vram_data_out;
            S_FRD1A: vram_addr_bg <= current_tile_address_1;
            S_FRD1B: begin
                current_tile_data_1 <= vram_data_out;
                h_pix_render <= h_pix_render + 8'd8;
            end
            // nothing to do for S_FWAITA, S_FWAITB
            S_FWAITA: begin end
            S_FWAITB: begin end
            S_SWW: begin
                h_pix_render <= 8'd0;
                window_triggered <= 1'b1;
            end
            S_OAMRDA: oam_rd_addr_int <= obj_triggered * 4 + 8'd2;
            S_OAMRDB: begin
                current_obj_tile_id_raw <= oam_data_out[7:0];
                current_obj_flags <= oam_data_out[15:8];
            end
            S_OFRD0A: vram_addr_obj <= current_obj_address_0;
            S_OFRD0B:
                if (current_obj_x_flip == 1'b1)
                    current_obj_tile_data_0[7:0] <= {
                        vram_data_out[0], vram_data_out[1], vram_data_out[2], vram_data_out[3], 
                        vram_data_out[4], vram_data_out[5], vram_data_out[6], vram_data_out[7]
                    };
                else
                    current_obj_tile_data_0 <= vram_data_out;
            S_OFRD1A: vram_addr_obj <= current_obj_address_1;
            S_OFRD1B:
                if (current_obj_x_flip == 1'b1)
                    current_obj_tile_data_1[7:0] <= {
                        vram_data_out[0], vram_data_out[1], vram_data_out[2], vram_data_out[3], 
                        vram_data_out[4], vram_data_out[5], vram_data_out[6], vram_data_out[7]
                    };
                else
                    current_obj_tile_data_1 <= vram_data_out;
            // nothing to do for S_OWB
            S_OWB: begin end
            default: begin
                $display("Invalid state!");
            end
        endcase
    end
    
    reg [31:0] half_merge_result;
    always @(current_fetch_result, pf_data) begin
        for (i = 0; i < 8; i = i + 1) begin
            if ((pf_data[32+i*4+1] == PPU_PAL_BG[1])&&(pf_data[32+i*4+0] == PPU_PAL_BG[0])) begin
                half_merge_result[i*4+3] = current_fetch_result[i*4+3];
                half_merge_result[i*4+2] = current_fetch_result[i*4+2];
                half_merge_result[i*4+1] = current_fetch_result[i*4+1];
                half_merge_result[i*4+0] = current_fetch_result[i*4+0];
            end
            else begin
                half_merge_result[i*4+3] = pf_data[32+i*4+3];
                half_merge_result[i*4+2] = pf_data[32+i*4+2];
                half_merge_result[i*4+1] = pf_data[32+i*4+1];
                half_merge_result[i*4+0] = pf_data[32+i*4+0];
            end
        end
    end
    
    // Output logic
    always @(posedge clk)
    begin
        if (r_state == S_BLANK) begin
            valid <= 1'b0;
            h_pix_output <= 8'd0; // Output pointer
            h_drop <= reg_scx[2:0];
            pf_empty <= PF_INITA; 
        end
        else if ((r_state == S_FTIDA) || (r_state == S_FTIDB) || (r_state == S_FRD0A) || (r_state == S_FRD0B) ||
            (r_state == S_FRD1A) || (r_state == S_FRD1B) || (r_state == S_FWAITA) || (r_state == S_FWAITB))
        begin
        
            if (r_state == S_FRD1B) begin
                if (pf_empty == PF_INITA) pf_empty <= PF_INITB;
                if (pf_empty == PF_INITB) pf_empty <= PF_FIN;
                if (pf_empty == PF_EMPTY) pf_empty <= PF_HALF;
                if (pf_empty == PF_HALF) pf_empty <= PF_FIN;
            end else
                if (pf_empty == PF_FIN) pf_empty <= PF_FULL; // should NOT wait through end
            
            // If it is in one of the output stages
            if (pf_empty == PF_EMPTY) begin
                // Just started, no data available
                valid <= 1'b0;
            end
            else if (pf_empty == PF_HALF) begin
                valid <= 1'b0;
                if (r_state == S_FTIDA) begin
                // One batch done, and they can be push into pipeline, but could not be output yet
                // We need to be careful not to overwrite the sprites...
                    pf_data[63:32] <= half_merge_result[31:0];
                end
            end
            else if (((pf_empty == PF_INITA)&&((r_state == S_FRD1A)||(r_state == S_FRD1B)))
                    ||(pf_empty == PF_INITB)||(pf_empty == PF_FULL)||(pf_empty == PF_FIN)) begin 
                if (r_state == S_FTIDA) begin // reload and shift
                    if (pf_empty == PF_INITB) begin
                        pf_data[63:0] <= {20'b0, current_fetch_result[31:0], 12'b0};
                    end
                    else begin // PF_FULL or PF_FIN
                        pf_data[63:0] <= {pf_data[59:32], current_fetch_result[31:0], 4'b0};
                    end
                end
                else begin // just shift
                    pf_data <= {pf_data[59:0], 4'b0};
                end
                
                if (h_drop != 3'd0) begin
                    h_drop <= h_drop - 1'd1;
                    valid <= 0;
                end
                else begin
                    if (h_pix_output >= 8)
                        valid <= 1;
                    else
                        valid <= 0;
                    pixel <= pf_output_pixel;
                    h_pix_output <= h_pix_output + 1'b1;
                end
            end
        end
        else if (r_state == S_OAMRDA) begin
            h_pix_output <= h_pix_output - 1'b1; //revert adding
            valid <= 1'b0;
        end
        else if (r_state == S_OWB) begin
            h_pix_output <= h_pix_output + 1'b1; //restore adding
            pf_data <= {merge_result[31:0], pf_data[31:0]};
            valid <= 1'b0;
        end
        else if (r_state == S_SWW) begin
            pf_empty <= PF_EMPTY;  // Flush the pipeline 
            valid <= 1'b0;
        end
        else begin
            // Not even in output stages
            valid <= 1'b0;
        end
    end

    // Enter Next State
    // and handle object interrupt
    // (sorry but I need to backup next state so I could not handle these in the next state logic)
    always @(posedge clk, posedge rst)
    begin
        if (rst) begin
            //h_pix_obj <= 8'b0;
            r_state <= 0;
            r_next_backup <= 0;
            obj_trigger_id <= OBJ_TRIGGER_NOT_FOUND;//not triggered
        end
        else
        begin
            if (obj_trigger && (reg_mode == PPU_MODE_PIX_TRANS)) begin
                // If already in object rendering stages
                if ((r_state == S_OFRD0A)||(r_state == S_OFRD0B)||
                    (r_state == S_OFRD1A)||(r_state == S_OFRD1B)||
                    (r_state == S_OAMRDA)||(r_state == S_OAMRDB)) begin
                    r_state <= r_next_state;
                end 
                // Finished one object, but there is more
                else if (r_state == S_OWB) begin
                    r_state <= S_OAMRDA;
                    obj_trigger_id <= obj_trigger_id_next;
                end
                // Not rendering object before, start now
                else begin
                    r_next_backup <= r_next_state;
                    r_state <= S_OAMRDA;
                    obj_trigger_id <= obj_trigger_id_next;
                end
            end
            else begin
                //h_pix_obj <= h_pix_output + 8'd2;
                r_state <= r_next_state;
                // Finished one object, and there is no more currently
                if (r_state == S_OWB) begin
                    obj_trigger_id <= OBJ_TRIGGER_NOT_FOUND;
                end
            end
        end
    end
    
    // Next State Logic
    // Since new state get updated during posedge
    always @(*)
    begin
        case (r_state)
            S_IDLE: r_next_state = ((reg_lcd_en)&(is_in_v_blank)) ? (S_BLANK) : (S_IDLE);
            S_BLANK: r_next_state = 
                (reg_lcd_en) ? (
                    (is_in_v_blank) ? 
                        (((v_count == (PPU_V_TOTAL - 1))&&(h_count == (PPU_H_TOTAL - 1))) ?
                            (S_OAMX) : (S_BLANK)
                        ) :
                        ((h_count == (PPU_H_TOTAL - 1)) ? 
                            ((v_count == (PPU_V_ACTIVE - 1)) ? 
                                (S_BLANK) : (S_OAMX)):
                            (S_BLANK)
                        )
                ) : (S_IDLE);
            S_OAMX: r_next_state = (reg_lcd_en) ? (S_OAMY) : (S_IDLE);
            S_OAMY: r_next_state = (reg_lcd_en) ? ((oam_search_count == (PPU_OAM_SEARCH_LENGTH - 1'b1)) ? (S_FTIDA) : (S_OAMX)) : (S_IDLE);
            S_FTIDA: r_next_state = (reg_lcd_en) ? ((h_pix_output == (PPU_H_OUTPUT - 1'b1)) ? (S_BLANK) : ((window_trigger) ? (S_SWW) : (S_FTIDB))) : (S_IDLE);
            S_FTIDB: r_next_state = (reg_lcd_en) ? ((h_pix_output == (PPU_H_OUTPUT - 1'b1)) ? (S_BLANK) : ((window_trigger) ? (S_SWW) : (S_FRD0A))) : (S_IDLE);
            S_FRD0A: r_next_state = (reg_lcd_en) ? ((h_pix_output == (PPU_H_OUTPUT - 1'b1)) ? (S_BLANK) : ((window_trigger) ? (S_SWW) : (S_FRD0B))) : (S_IDLE);
            S_FRD0B: r_next_state = (reg_lcd_en) ? ((h_pix_output == (PPU_H_OUTPUT - 1'b1)) ? (S_BLANK) : ((window_trigger) ? (S_SWW) : (S_FRD1A))) : (S_IDLE);
            S_FRD1A: r_next_state = (reg_lcd_en) ? ((h_pix_output == (PPU_H_OUTPUT - 1'b1)) ? (S_BLANK) : ((window_trigger) ? (S_SWW) : (S_FRD1B))) : (S_IDLE);
            S_FRD1B: r_next_state = (reg_lcd_en) ? ((h_pix_output == (PPU_H_OUTPUT - 1'b1)) ? (S_BLANK) : ((window_trigger) ? (S_SWW) : ((pf_empty != PF_FULL) ? (S_FTIDA) : (S_FWAITA)))) : (S_IDLE); // If fifo not full, no wait state is needed
            S_FWAITA: r_next_state = (reg_lcd_en) ? ((h_pix_output == (PPU_H_OUTPUT - 1'b1)) ? (S_BLANK) : ((window_trigger) ? (S_SWW) : (S_FWAITB))) : (S_IDLE);
            S_FWAITB: r_next_state = (reg_lcd_en) ? ((h_pix_output == (PPU_H_OUTPUT - 1'b1)) ? (S_BLANK) : ((window_trigger) ? (S_SWW) : (S_FTIDA))) : (S_IDLE);
            S_SWW: r_next_state = (reg_lcd_en) ? ((h_pix_output == (PPU_H_OUTPUT - 1'b1)) ? (S_BLANK) : (S_FTIDA)) : (S_IDLE);
            S_OAMRDA: r_next_state = (reg_lcd_en) ? (S_OAMRDB) : (S_IDLE);
            S_OAMRDB: r_next_state = (reg_lcd_en) ? (S_OFRD0A) : (S_IDLE);
            S_OFRD0A: r_next_state = (reg_lcd_en) ? (S_OFRD0B) : (S_IDLE);
            S_OFRD0B: r_next_state = (reg_lcd_en) ? (S_OFRD1A) : (S_IDLE);
            S_OFRD1A: r_next_state = (reg_lcd_en) ? (S_OFRD1B) : (S_IDLE);
            S_OFRD1B: r_next_state = (reg_lcd_en) ? (S_OWB) : (S_IDLE);
            S_OWB: r_next_state = (reg_lcd_en) ? (r_next_backup) : (S_IDLE);
            default: r_next_state = S_IDLE;
        endcase
    end
    
    // Interrupt
    always @(posedge clk, posedge rst)
        if (rst)
            reg_stat[2] <= 0;
        else
            // TODO: what's the timing for this?
            reg_stat[2] <= (reg_ly == reg_lyc) ? 1 : 0;
            
    always @(posedge clk, posedge rst)
    begin
        if (rst) begin
            int_vblank_req <= 0;
            int_lcdc_req <= 0;
            reg_ly_last[7:0] <= 0;
            //reg_stat[1:0] <= PPU_MODE_V_BLANK;
        end
        else
        begin
            if ((reg_mode == PPU_MODE_V_BLANK)&&(reg_mode_last != PPU_MODE_V_BLANK))
                int_vblank_req <= 1;
            else if (int_vblank_ack)
                int_vblank_req <= 0;
            if (((reg_lyc_int == 1'b1)&&(reg_ly == reg_lyc)&&(reg_ly_last != reg_lyc))||
                ((reg_oam_int == 1'b1)&&(reg_mode == PPU_MODE_OAM_SEARCH)&&(reg_mode_last != PPU_MODE_OAM_SEARCH))||
                ((reg_vblank_int == 1'b1)&&(reg_mode == PPU_MODE_V_BLANK)&&(reg_mode_last != PPU_MODE_V_BLANK))||
                ((reg_hblank_int == 1'b1)&&(reg_mode == PPU_MODE_H_BLANK)&&(reg_mode_last != PPU_MODE_H_BLANK)))
                int_lcdc_req <= 1;
            else if (int_lcdc_ack)
                int_lcdc_req <= 0;
            reg_ly_last <= reg_ly;
            reg_mode_last <= reg_mode;
        end
    end
    
    // Bus RW
    // Bus RW - Combinational Read
    always @(*)
    begin
        // MMIO Bus
        mmio_dout = 8'hFF;
        case (mmio_a)
            16'hFF40: mmio_dout = reg_lcdc;
            16'hFF41: mmio_dout = reg_stat;
            16'hFF42: mmio_dout = reg_scy;
            16'hFF43: mmio_dout = reg_scx;
            16'hFF44: mmio_dout = reg_ly;
            16'hFF45: mmio_dout = reg_lyc;
            16'hFF46: mmio_dout = reg_dma;
            16'hFF47: mmio_dout = reg_bgp;
            16'hFF48: mmio_dout = reg_obp0;
            16'hFF49: mmio_dout = reg_obp1;
            16'hFF4A: mmio_dout = reg_wy;
            16'hFF4B: mmio_dout = reg_wx;
        endcase
    end
    
    // Bus RW - Sequential Write
    always @(posedge clk, posedge rst)
    begin
        if (rst) begin
            reg_lcdc <= 8'h00;
            reg_stat[7:3] <= 5'h00;
            reg_scy  <= 8'h00;
            reg_scx  <= 8'h00;
            reg_lyc  <= 8'h00;
            reg_dma  <= 8'h00;
            reg_bgp  <= 8'hFC;
            reg_obp0 <= 8'h00;
            reg_obp1 <= 8'h00;
            reg_wy   <= 8'h00;
            reg_wx   <= 8'h00;
        end
        else
        begin
            if (mmio_wr) begin
                case (mmio_a)
                    16'hFF40: reg_lcdc <= mmio_din;
                    16'hFF41: reg_stat[7:3] <= mmio_din[7:3];
                    16'hFF42: reg_scy <= mmio_din;
                    16'hFF43: reg_scx <= mmio_din;
                    //16'hFF44: reg_ly <= mmio_din;
                    16'hFF45: reg_lyc <= mmio_din;
                    16'hFF46: reg_dma <= mmio_din;
                    16'hFF47: reg_bgp <= mmio_din;
                    16'hFF48: reg_obp0 <= mmio_din;
                    16'hFF49: reg_obp1 <= mmio_din;
                    16'hFF4A: reg_wy <= mmio_din;
                    16'hFF4B: reg_wx <= mmio_din;
                endcase
                // VRAM and OAM access are not handled here
            end
        end
    end
    
    // Debug Outputs
    assign scx = reg_scx;
    assign scy = reg_scy;
    assign state = r_state;

endmodule


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Module Name:    regfile
// Project Name:   VerilogBoy
// Description: 
//   The register file of Game Boy CPU.
// Dependencies: 
// 
// Additional Comments: 
//   Only BCDEHLSP are in the register file
//////////////////////////////////////////////////////////////////////////////////

module regfile(
    input clk,
    input rst,
    input [2:0] rdn,
    output [7:0] rd,
    input [1:0] rdwn,
    output [15:0] rdw,
    output [7:0] h, // H, L output for 16bit addition
    output [7:0] l, 
    output [15:0] sp, // SP output for addressing
    input [2:0] wrn,
    input [7:0] wr,
    input we
    );

    reg [7:0] regs [0:7];

    wire [7:0] rdhigh = regs[{rdwn, 1'b0}];
    wire [7:0] rdlow  = regs[{rdwn, 1'b1}];
    assign rdw = {rdhigh, rdlow};
    assign rd = regs[rdn];
    assign h = regs[3'd4];
    assign l = regs[3'd5];
    assign sp = {regs[3'd6], regs[3'd7]};

    integer i;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                regs[i] <= 8'b0;
        end
        else begin
            if (we)
                regs[wrn] <= wr;
        end
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    13:13:04 04/13/2018 
// Module Name:    serial
// Project Name:   VerilogBoy
// Description: 
//   Dummy serial interface
// Dependencies: 
//
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module serial(
    input clk,
    input rst,
    input wire [15:0] a,
    output reg [7:0] dout,
    input wire [7:0] din,
    input wire rd,
    input wire wr,
    output reg int_serial_req,
    input wire int_serial_ack
    );
    
    reg clk_spi; //8kHz SPI Clock
    
    /*clk_div #(.WIDTH(10), .DIV(512)) spi_div(
        .i(clk),
        .o(clk_spi)
    );*/

    reg [8:0] counter;
    
    always @(posedge clk, posedge rst)
    begin
        if (rst) begin
            counter <= 9'h72;
            clk_spi <= 1'b0;
        end 
        else begin
            if (counter == (512 / 2 - 1)) begin
                clk_spi <= ~clk_spi;
                counter <= 0;
            end
            else
                counter <= counter + 1'b1;
        end
    end
	 
    //reg [7:0] reg_sb;
    reg reg_sc_start;
    reg reg_sc_int;
    
    always @(*) begin
        dout = 8'hff;
        if (a == 16'hff01) dout = 8'hff; else
        if (a == 16'hff02) dout = {reg_sc_start, 6'b111111, reg_sc_int};
    end
    
    reg [3:0] count;
    reg last_clk;
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            //reg_sb <= 8'h00;
            reg_sc_start <= 1'b0;
            reg_sc_int <= 1'b0;
            int_serial_req <= 1'b0;
            count <= 4'd0;
            last_clk <= 1'b0;
        end
        else begin
            last_clk <= clk_spi;
            //if      (wr && (a == 16'hff01)) reg_sb <= din;
            if (wr && (a == 16'hff02)) begin
                reg_sc_start <= din[7];
                reg_sc_int <= din[0];
                if (din[7] && din[0]) count <= 4'd8;
                else count <= 4'd0;
            end
            else begin
                // Dummy serial interface
                if (count != 4'd0) begin
                    if (!last_clk && clk_spi) begin
                        count <= count - 4'd1;
                        if ((count - 4'd1) == 0) begin
                            int_serial_req <= 1'b1;
                        end
                    end
                end
                else begin
                    if ((int_serial_req)&&(int_serial_ack)) begin
                        int_serial_req <= 1'b0;
                    end
                end
            end
        end
    end
    
	 
endmodule


module singleport_ram #(
    parameter integer WORDS = 8192,
    parameter ABITS = 13
)(
    input clka,
    input wea,
    input [ABITS - 1:0] addra,
    input [7:0] dina,
    output reg [7:0] douta
);

    reg [7:0] ram [0:WORDS-1];
    
    always@(posedge clka) begin
        if (wea)
            ram[addra] <= dina;
    end
    
    always@(posedge clka) begin
        douta <= ram[addra];
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Module Name:    reg
// Project Name:   VerilogBoy
// Description: 
//   The register file of Game Boy CPU.
// Dependencies: 
// 
// Additional Comments: 
//  Single 8-bit register
//////////////////////////////////////////////////////////////////////////////////

module singlereg(clk, rst, wr, rd, we);
    parameter WIDTH = 8;

    input clk;
    input rst;
    input [WIDTH-1:0] wr;
    output [WIDTH-1:0] rd;
    input we;

    reg [WIDTH-1:0] data;

    assign rd = data;

    always @(posedge clk, posedge rst) begin
        if (rst)
            data <= 0;
        else
            if (we)
                data <= wr;
    end

endmodule


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    12:29:37 04/07/2018 
// Module Name:    sound
// Project Name:   VerilogBoy
// Description: 
//   GameBoy sound unit main file
// Dependencies: 
//
// Additional Comments: 
//   On a real gameboy, audio mixing is done with an OpAmp (I am not sure, but
//   this makes most sense according to the documents we have). I am using adder
//   here to make that happen. Also, audio volume control is probably done with a
//   PGA on a real gameboy, and I am using multiplication to implement that here.
//   So this would synthesis some additional adders and multipliers which should
//   not be part of a Game Boy.
//////////////////////////////////////////////////////////////////////////////////
module sound(
    input wire clk,
    input wire rst,
    input wire [15:0] a,
    output reg [7:0] dout,
    input wire [7:0] din,
    input wire rd,
    input wire wr,
    output wire [15:0] left,
    output wire [15:0] right,
    // debug
    output wire [3:0] ch1_level,
    output wire [3:0] ch2_level,
    output wire [3:0] ch3_level,
    output wire [3:0] ch4_level
    );

    // Sound registers
    reg [7:0] regs [0:31]; 
    
    /* verilator lint_off UNUSED */
    wire [7:0] reg_nr10 = regs[00]; // $FF10 Channel 1 Sweep register (RW)
    wire [7:0] reg_nr11 = regs[01]; // $FF11 Channel 1 Sound length/wave patternduty (RW)
    wire [7:0] reg_nr12 = regs[02]; // $FF12 Channel 1 Volume envelope (RW)
    wire [7:0] reg_nr13 = regs[03]; // $FF13 Channel 1 Freqency lo (W)
    wire [7:0] reg_nr14 = regs[04]; // $FF14 Channel 1 Freqency hi (RW)
    wire [7:0] reg_nr21 = regs[06]; // $FF16 Channel 2 Sound length/wave patternduty (RW)
    wire [7:0] reg_nr22 = regs[07]; // $FF17 Channel 2 Volume envelope (RW)
    wire [7:0] reg_nr23 = regs[08]; // $FF18 Channel 2 Freqency lo (W)
    wire [7:0] reg_nr24 = regs[09]; // $FF19 Channel 2 Freqency hi (RW)
    wire [7:0] reg_nr30 = regs[10]; // $FF1A Channel 3 Sound on/off (RW)
    wire [7:0] reg_nr31 = regs[11]; // $FF1B Channel 3 Sound length (?)
    wire [7:0] reg_nr32 = regs[12]; // $FF1C Channel 3 Select output level (RW)
    wire [7:0] reg_nr33 = regs[13]; // $FF1D Channel 3 Frequency lo (W)
    wire [7:0] reg_nr34 = regs[14]; // $FF1E Channel 3 Frequency hi (RW)
    wire [7:0] reg_nr41 = regs[16]; // $FF20 Channel 4 Sound length (RW)
    wire [7:0] reg_nr42 = regs[17]; // $FF21 Channel 4 Volume envelope (RW)
    wire [7:0] reg_nr43 = regs[18]; // $FF22 Channel 4 Polynomial counter (RW)
    wire [7:0] reg_nr44 = regs[19]; // $FF23 Channel 4 Counter/consecutive; Initial(RW)
    wire [7:0] reg_nr50 = regs[20]; // $FF24 Channel contorl / ON-OFF / Volume (RW)
    wire [7:0] reg_nr51 = regs[21]; // $FF25 Selection of Sound output terminal (RW)
    wire [7:0] reg_nr52 = regs[22]; // $FF26 Sound on/off
    /* verilator lint_on UNUSED */
    wire [4:0] reg_addr = {~a[4], a[3:0]}; // Convert 10-20 to 00-10
    
    wire [2:0]  ch1_sweep_time = reg_nr10[6:4];
    wire        ch1_sweep_decreasing = reg_nr10[3];
    wire [2:0]  ch1_num_sweep_shifts = reg_nr10[2:0];
    wire [1:0]  ch1_wave_duty = reg_nr11[7:6];
    wire [5:0]  ch1_length = reg_nr11[5:0];
    wire [3:0]  ch1_initial_volume = reg_nr12[7:4];
    wire        ch1_envelope_increasing = reg_nr12[3];
    wire [2:0]  ch1_num_envelope_sweeps = reg_nr12[2:0];
    reg         ch1_start;
    wire        ch1_single = reg_nr14[6];
    wire [10:0] ch1_frequency = {reg_nr14[2:0], reg_nr13[7:0]};
    wire [1:0]  ch2_wave_duty = reg_nr21[7:6];
    wire [5:0]  ch2_length = reg_nr21[5:0];
    wire [3:0]  ch2_initial_volume = reg_nr22[7:4];
    wire        ch2_envelope_increasing = reg_nr22[3];
    wire [2:0]  ch2_num_envelope_sweeps = reg_nr22[2:0];
    reg         ch2_start;
    wire        ch2_single = reg_nr24[6];
    wire [10:0] ch2_frequency = {reg_nr24[2:0], reg_nr23[7:0]};
    wire [7:0]  ch3_length = reg_nr31[7:0];
    wire        ch3_on = reg_nr30[7];
    wire [1:0]  ch3_volume = reg_nr32[6:5];
    reg         ch3_start;
    wire        ch3_single = reg_nr34[6];
    wire [10:0] ch3_frequency = {reg_nr34[2:0], reg_nr33[7:0]};
    wire [5:0]  ch4_length = reg_nr41[5:0];
    wire [3:0]  ch4_initial_volume = reg_nr42[7:4];
    wire        ch4_envelope_increasing = reg_nr42[3];
    wire [2:0]  ch4_num_envelope_sweeps = reg_nr42[2:0];
    wire [3:0]  ch4_shift_clock_freq = reg_nr43[7:4];
    wire        ch4_counter_width = reg_nr43[3]; // 0 = 15 bits, 1 = 7 bits
    wire [2:0]  ch4_freq_dividing_ratio = reg_nr43[2:0];
    reg         ch4_start;
    wire        ch4_single = reg_nr44[6];
    wire        s02_vin = reg_nr50[7];
    wire [2:0]  s02_output_level = reg_nr50[6:4];
    wire        s01_vin = reg_nr50[3];
    wire [2:0]  s01_output_level = reg_nr50[2:0];
    wire        s02_ch4_enable = reg_nr51[7];
    wire        s02_ch3_enable = reg_nr51[6];
    wire        s02_ch2_enable = reg_nr51[5];
    wire        s02_ch1_enable = reg_nr51[4];
    wire        s01_ch4_enable = reg_nr51[3];
    wire        s01_ch3_enable = reg_nr51[2];
    wire        s01_ch2_enable = reg_nr51[1];
    wire        s01_ch1_enable = reg_nr51[0];
    wire        sound_enable = reg_nr52[7];
    wire        ch4_on_flag; 
    wire        ch3_on_flag;
    wire        ch2_on_flag;
    wire        ch1_on_flag;
    
    reg [7:0] wave [0:15];
    wire [3:0] wave_addr_ext = a[3:0];
    wire [3:0] wave_addr_int;
    wire [3:0] wave_addr = (ch3_on) ? (wave_addr_int) : (wave_addr_ext);
    wire [7:0] wave_data = wave[wave_addr];
    
    wire addr_in_regs = (a >= 16'hFF10 && a <= 16'hFF2F);
    wire addr_in_wave = (a >= 16'hFF30 && a <= 16'hFF3F);
    
    // Bus RW
    // Bus RW - Combinational Read
    // This is a drawback of ISE XST, one can not use always@(*) and reg array together,
    // so one have to write something (does not need to make sense, just as a place holder)
    // and let the synthesizer to determine the correct sensitvity list. (Or one would have
    // to enumerate EACH item in an array, otherwise it will give an error.
    always @(a)
    begin
        dout = 8'hFF;
        if (addr_in_regs) begin
            if (a == 16'hFF26)
                dout = {sound_enable, 3'b0, ch4_on_flag, ch3_on_flag, ch2_on_flag, ch1_on_flag};
            else
                dout = regs[reg_addr];
        end
        else
        if (addr_in_wave) begin
            dout = wave[wave_addr];
        end
    end
    
    // Bus RW - Sequential Write
    integer i;
    
    always @(posedge clk, posedge rst)
    begin
        if (rst) begin
            for (i = 0; i < 32; i = i+1) begin
                regs[i] <= 8'b0;
            end
            // wave pattern should not be initialized
        end
        else begin
            if (wr) begin
                if (addr_in_regs) begin
                    if (a == 16'hFF26) begin
                        if (din[7] == 0) begin
                            for (i = 0; i < 32; i = i+1) begin
                                regs[i] <= 8'b0;
                            end
                        end
                        else
                            regs[reg_addr] <= din;
                    end
                    else if (sound_enable) begin
                        regs[reg_addr] <= din;
                    end
                end
                else if (addr_in_wave)
                    //wave[wave_addr_ext] <= din; //what if we allow Write any way?
                    wave[wave_addr] <= din; // This is what happens trying to write to wave sample while it is on
            end
            // Initialize signal, should be triggered whenever a 1 is written
            if ((wr)&&(a == 16'hFF14)) ch1_start <= din[7];
                else ch1_start <= 0;
            if ((wr)&&(a == 16'hFF19)) ch2_start <= din[7];
                else ch2_start <= 0;
            if ((wr)&&(a == 16'hFF1E)) ch3_start <= din[7];
                else ch3_start <= 0;
            if ((wr)&&(a == 16'hFF23)) ch4_start <= din[7];
                else ch4_start <= 0;
        end
    end
    
    // Clocks
    wire clk_frame; // 512Hz Base Clock
    wire clk_length_ctr; // 256Hz Length Control Clock
    wire clk_vol_env; // 64Hz Volume Enevelope Clock
    wire clk_sweep; // 128Hz Sweep Clock
    wire clk_freq_div; // 1048576Hz Frequency Division Clock
    
    clk_div #(.WIDTH(15), .DIV(8192)) frame_div(
        .i(clk),
        .o(clk_frame)
    );
    
    reg [2:0] sequencer_state = 3'b0;
    always@(posedge clk_frame)
    begin
        sequencer_state <= sequencer_state + 1'b1;
    end
    
    assign clk_length_ctr = (sequencer_state[0]) ? 1'b0 : 1'b1;
    assign clk_vol_env = (sequencer_state == 3'd7) ? 1'b1 : 1'b0;
    assign clk_sweep = ((sequencer_state == 3'd2) || (sequencer_state == 3'd6)) ? 1'b1 : 1'b0;

    clk_div #(.WIDTH(2), .DIV(2)) freq_div(
        .i(clk),
        .o(clk_freq_div)
    );

    // Channels
    wire [3:0] ch1;
    wire [3:0] ch2;
    wire [3:0] ch3;
    wire [3:0] ch4;
    
    sound_square sound_ch1(
        .rst(~sound_enable),
        .clk(clk),
        .clk_length_ctr(clk_length_ctr),
        .clk_vol_env(clk_vol_env),
        .clk_sweep(clk_sweep),
        .clk_freq_div(clk_freq_div),
        .sweep_time(ch1_sweep_time),
        .sweep_decreasing(ch1_sweep_decreasing),
        .num_sweep_shifts(ch1_num_sweep_shifts),
        .wave_duty(ch1_wave_duty),
        .length(ch1_length),
        .initial_volume(ch1_initial_volume),
        .envelope_increasing(ch1_envelope_increasing),
        .num_envelope_sweeps(ch1_num_envelope_sweeps),
        .start(ch1_start),
        .single(ch1_single),
        .frequency(ch1_frequency),
        .level(ch1),
        .enable(ch1_on_flag)
    );
    
    sound_square sound_ch2(
        .rst(~sound_enable),
        .clk(clk),
        .clk_length_ctr(clk_length_ctr),
        .clk_vol_env(clk_vol_env),
        .clk_sweep(clk_sweep),
        .clk_freq_div(clk_freq_div),
        .sweep_time(3'b0),
        .sweep_decreasing(1'b0),
        .num_sweep_shifts(3'b0),
        .wave_duty(ch2_wave_duty),
        .length(ch2_length),
        .initial_volume(ch2_initial_volume),
        .envelope_increasing(ch2_envelope_increasing),
        .num_envelope_sweeps(ch2_num_envelope_sweeps),
        .start(ch2_start),
        .single(ch2_single),
        .frequency(ch2_frequency),
        .level(ch2),
        .enable(ch2_on_flag)
    );
        
    sound_wave sound_ch3(
        .rst(~sound_enable),
        .clk(clk),
        .clk_length_ctr(clk_length_ctr),
        .length(ch3_length),
        .volume(ch3_volume),
        .on(ch3_on),
        .single(ch3_single),
        .start(ch3_start),
        .frequency(ch3_frequency),
        .wave_a(wave_addr_int),
        .wave_d(wave_data),
        .level(ch3),
        .enable(ch3_on_flag)
    );
    
    sound_noise sound_ch4(
        .rst(~sound_enable),
        .clk(clk),
        .clk_length_ctr(clk_length_ctr),
        .clk_vol_env(clk_vol_env),
        .length(ch4_length),
        .initial_volume(ch4_initial_volume), 
        .envelope_increasing(ch4_envelope_increasing),
        .num_envelope_sweeps(ch4_num_envelope_sweeps),
        .shift_clock_freq(ch4_shift_clock_freq), 
        .counter_width(ch4_counter_width), 
        .freq_dividing_ratio(ch4_freq_dividing_ratio), 
        .start(ch4_start), 
        .single(ch4_single), 
        .level(ch4),
        .enable(ch4_on_flag)
    );
    
    // Mixer
    
    /*
    // Signed mixer
    wire [5:0] sign_extend_ch1 = {{3{ch1[3]}}, ch1[2:0]};
    wire [5:0] sign_extend_ch2 = {{3{ch2[3]}}, ch2[2:0]};
    wire [5:0] sign_extend_ch3 = {{3{ch3[3]}}, ch3[2:0]};
    wire [5:0] sign_extend_ch4 = {{3{ch4[3]}}, ch4[2:0]};
    reg [5:0] mixed_s01;
    reg [5:0] mixed_s02;

    always @(*)
    begin
        mixed_s01 = 6'd0;
        mixed_s02 = 6'd0;
        if (s01_ch1_enable) mixed_s01 = mixed_s01 + sign_extend_ch1;
        if (s01_ch2_enable) mixed_s01 = mixed_s01 + sign_extend_ch2;
        if (s01_ch3_enable) mixed_s01 = mixed_s01 + sign_extend_ch3;
        if (s01_ch4_enable) mixed_s01 = mixed_s01 + sign_extend_ch4;
        if (s02_ch1_enable) mixed_s02 = mixed_s02 + sign_extend_ch1;
        if (s02_ch2_enable) mixed_s02 = mixed_s02 + sign_extend_ch2;
        if (s02_ch3_enable) mixed_s02 = mixed_s02 + sign_extend_ch3;
        if (s02_ch4_enable) mixed_s02 = mixed_s02 + sign_extend_ch4;
    end
    
    assign left  = (sound_enable) ? {mixed_s01[5:0], 14'b0} : 20'b0;
    assign right = (sound_enable) ? {mixed_s02[5:0], 14'b0} : 20'b0; 
    */
    
    // Unsigned mixer
    reg [5:0] added_s01;
    reg [5:0] added_s02;
    always @(*)
    begin
        added_s01 = 6'd0;
        added_s02 = 6'd0;
        if (s01_ch1_enable) added_s01 = added_s01 + {2'b0, ch1};
        if (s01_ch2_enable) added_s01 = added_s01 + {2'b0, ch2};
        if (s01_ch3_enable) added_s01 = added_s01 + {2'b0, ch3};
        if (s01_ch4_enable) added_s01 = added_s01 + {2'b0, ch4};
        if (s02_ch1_enable) added_s02 = added_s02 + {2'b0, ch1};
        if (s02_ch2_enable) added_s02 = added_s02 + {2'b0, ch2};
        if (s02_ch3_enable) added_s02 = added_s02 + {2'b0, ch3};
        if (s02_ch4_enable) added_s02 = added_s02 + {2'b0, ch4};
    end
    
    wire [8:0] mixed_s01 = added_s01 * s01_output_level;
    wire [8:0] mixed_s02 = added_s02 * s02_output_level;
    
    assign left  = (sound_enable) ? {1'b0, mixed_s01[8:0], 6'b0} : 16'b0;
    assign right = (sound_enable) ? {1'b0, mixed_s02[8:0], 6'b0} : 16'b0; 
    
    // Debug Output
    assign ch1_level = ch1;
    assign ch2_level = ch2;
    assign ch3_level = ch3;
    assign ch4_level = ch4;

endmodule


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:29:14 04/08/2018 
// Design Name: 
// Module Name:    sound_channel_mix 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module sound_channel_mix(
    input enable,
    input modulate,
    input [3:0] target_vol,
    output [3:0] level
    );

    /*// Converting Volume envelope to 2s compliment number
    reg [3:0] target_vol_low;
    wire [3:0] target_vol_high;
    always@(target_vol)
    begin
        case (target_vol)
            4'b0000: target_vol_low = 4'b0000;
            4'b0001: target_vol_low = 4'b1111;
            4'b0010: target_vol_low = 4'b1111;
            4'b0011: target_vol_low = 4'b1110;
            4'b0100: target_vol_low = 4'b1110;
            4'b0101: target_vol_low = 4'b1101;
            4'b0110: target_vol_low = 4'b1101;
            4'b0111: target_vol_low = 4'b1100;
            4'b1000: target_vol_low = 4'b1100;
            4'b1001: target_vol_low = 4'b1011;
            4'b1010: target_vol_low = 4'b1011;
            4'b1011: target_vol_low = 4'b1010;
            4'b1100: target_vol_low = 4'b1010;
            4'b1101: target_vol_low = 4'b1001;
            4'b1110: target_vol_low = 4'b1001;
            4'b1111: target_vol_low = 4'b1000;
        endcase
    end
    assign target_vol_high = {1'b0, target_vol[3:1]};
                                
    assign level = (enable) ? ((modulate) ? (target_vol_high) : (target_vol_low)) : (4'b0000);*/
    
    assign level = (enable) ? ((modulate) ? (target_vol) : (4'b0000)) : (4'b0000);
    
endmodule


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    22:24:55 04/08/2018 
// Module Name:    sound_length_ctr 
// Project Name:   VerilogBoy
// Description: 
//   Sound length control for all channels 
// Dependencies: 
//   none
// Additional Comments: 
//   Channel 3 has a different length
//////////////////////////////////////////////////////////////////////////////////
module sound_length_ctr(rst, clk_length_ctr, start, single, length, enable);
    parameter WIDTH = 6; // 6bit for Ch124, 8bit for Ch3
    
    input rst;
    input clk_length_ctr;
    input start;
    input single;
    input [WIDTH-1:0] length;
    output reg enable = 0;
    
    reg [WIDTH-1:0] length_left = {WIDTH{1'b1}}; // Upcounter from length to 255

    // Length Control
    always @(posedge clk_length_ctr, posedge start, posedge rst)
    begin
        if (rst) begin
            enable <= 1'b0;
            length_left <= 0;
        end
        else if (start) begin
            enable <= 1'b1;
            length_left <= (length == 0) ? ({WIDTH{1'b1}}) : (length);
        end
        else begin
            if (single) begin
                if (length_left != {WIDTH{1'b1}})
                    length_left <= length_left + 1'b1;
                else
                    enable <= 1'b0;
            end
        end
    end

endmodule



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    21:19:04 04/08/2018 
// Module Name:    sound_noise 
// Project Name:   VerilogBoy
// Description: 
//
// Dependencies: 
//
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module sound_noise(
    input rst, // Async reset
    input clk, // CPU Clock
    input clk_length_ctr, // Length control clock
    input clk_vol_env, // Volume Envelope clock
    input [5:0] length, // Length = (64-t1)*(1/256) second, used iff single is set
    input [3:0] initial_volume, // Initial volume of envelope 0 = no sound
    input envelope_increasing, // 0 = decrease, 1 = increase
    input [2:0] num_envelope_sweeps, // number of envelope sweep 0 = stop
    input [3:0] shift_clock_freq, // shift clock prescaler (s)
    input counter_width, // 0 = 15 bits, 1 = 7 bits
    input [2:0] freq_dividing_ratio, // shift clock divider 0 -> 1MHz, 1 -> 512kHz (r)
    input start, // Restart sound
    input single, // If set, output would stop upon reaching the length specified
    output [3:0] level,
    output enable
    );
    
    // Dividing ratio from 4MHz is (r * 8), for the divier to work, the comparator shoud
    // compare with (dividing_factor / 2 - 1), so it becomes (r * 4 - 1)
    reg [4:0] adjusted_freq_dividing_ratio;
    reg [3:0] latched_shift_clock_freq;
    
    wire [3:0] target_vol;
    
    reg clk_div = 0;
    wire clk_shift;
    
    reg [4:0] clk_divider = 5'b0; // First stage
    always @(posedge clk)
    begin
        if (clk_divider == adjusted_freq_dividing_ratio) begin
            clk_div <= ~clk_div;
            clk_divider <= 0;
        end
        else
            clk_divider <= clk_divider + 1'b1;
    end
    
    reg [13:0] clk_shifter = 14'b0; // Second stage
    always @(posedge clk_div)
    begin
        clk_shifter <= clk_shifter + 1'b1;
    end
    
    assign clk_shift = clk_shifter[latched_shift_clock_freq];
    
    reg [14:0] lfsr = {15{1'b1}};
    wire target_freq_out = ~lfsr[0];
    
    wire [14:0] lfsr_next =
        (counter_width == 0) ? ({(lfsr[0] ^ lfsr[1]), lfsr[14:1]}) :
                               ({8'b0, (lfsr[0] ^ lfsr[1]), lfsr[6:1]});
    
    always@(posedge start)
    begin
        adjusted_freq_dividing_ratio <=
                (freq_dividing_ratio == 3'b0) ? (5'd1) : ((freq_dividing_ratio * 4) - 1);
        latched_shift_clock_freq <= shift_clock_freq;
    end
    
    always@(posedge clk_shift, posedge start)
    begin
        if (start) begin
            lfsr <= {15{1'b1}};
        end
        else begin
            lfsr <= lfsr_next;
        end    
    end
    
    sound_vol_env sound_vol_env(
        .clk_vol_env(clk_vol_env),
        .start(start),
        .initial_volume(initial_volume),
        .envelope_increasing(envelope_increasing),
        .num_envelope_sweeps(num_envelope_sweeps),
        .target_vol(target_vol)
    );

    sound_length_ctr #(6) sound_length_ctr(
        .rst(rst),
        .clk_length_ctr(clk_length_ctr),
        .start(start),
        .single(single),
        .length(length),
        .enable(enable)
    );
    
    sound_channel_mix sound_channel_mix(
        .enable(enable),
        .modulate(target_freq_out),
        .target_vol(target_vol),
        .level(level)
    );
    
endmodule


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    16:51:12 04/07/2018 
// Module Name:    sound_square 
// Project Name:   VerilogBoy
// Description: 
//   Square wave generator for channel 1 and 2
// Dependencies: 
//   sound_vol_env, sound_length_ctr, sound_channel_mix
// Additional Comments: 
//   First, synthesize a frequency with 8X of specified frequency with any percent
//   of duty cycle, then use a small FSM to synthesis it into desired duty cycle.
//
//   Note: the original GameBoy process all the sound internally as unsigned
//   number, and use a bypass capacitor to remove all the DC component. One drawback
//   is that it do not have a constant "zero" reference: when a channel is off, the
//   voltage is, naturually 0V. But when it is working, it will alter between 0 and
//   Vmax(volume), means the zero becomes the half of current volume. This is also
//   the design I am using here.
//////////////////////////////////////////////////////////////////////////////////
module sound_square(
    input rst, // Async reset
    input clk, // CPU Clock
    input clk_length_ctr, // Length control clock
    input clk_vol_env, // Volume Envelope clock
    input clk_sweep, // Sweep clock
    input clk_freq_div, // Base frequency for divider (should be 16x131072=2097152Hz)
    input [2:0] sweep_time, // From 0 to 7/128Hz
    input sweep_decreasing, // 0: Addition (Freq+) 1: Subtraction (Freq-)
    input [2:0] num_sweep_shifts, // Number of sweep shift (n=0-7)
    input [1:0] wave_duty, // 00: 87.5% HIGH 01: 75% HIGH 10: 50% HIGH 11: 25% HIGH
    input [5:0] length, // Length = (64-t1)*(1/256) second, used iff single is set
    input [3:0] initial_volume, // Initial volume of envelope 0 = no sound
    input envelope_increasing, // 0 = decrease, 1 = increase
    input [2:0] num_envelope_sweeps, // number of envelope sweep 0 = stop
    input start, // Restart sound
    input single, // If set, output would stop upon reaching the length specified
    input [10:0] frequency, // Output frequency = 131072/(2048-x) Hz
    output [3:0] level, // Sound output
    output enable // Internal enable flag
    );
    
    //Sweep: X(t) = X(t-1) +/- X(t-1)/2^n
    
    reg [10:0] divider = 11'b0;
    reg [10:0] target_freq;
    reg octo_freq_out = 0; // 8 x target frequency with arbitrary duty cycle
    wire target_freq_out; // Traget frequency with specified duty cycle
    wire [3:0] target_vol;
    reg [2:0] sweep_left; // Number of sweeps need to be done

    always @(posedge clk_freq_div, posedge start)
    begin
        if (start) begin
            divider <= target_freq;
        end
        else begin
            if (divider == 11'd2047) begin
                octo_freq_out <= ~octo_freq_out;
                divider <= target_freq;
            end
            else begin
                divider <= divider + 1'b1;
            end
        end
    end
    
    reg [2:0] duty_counter = 3'b0;
    always @(posedge octo_freq_out)
    begin
        duty_counter <= duty_counter + 1'b1;
    end
    
    assign target_freq_out =
        (wave_duty == 2'b00) ? ((duty_counter != 3'b111) ? 1'b1 : 1'b0) : ( // 87.5% HIGH
        (wave_duty == 2'b01) ? ((duty_counter[2:1] != 2'b11) ? 1'b1 : 1'b0) : ( // 75% HIGH
        (wave_duty == 2'b10) ? ((duty_counter[2]) ? 1'b1 : 1'b0) : ( // 50% HIGH
                               ((duty_counter[2:1] == 2'b00) ? 1'b1 : 1'b0)))); // 25% HIGH
           
    // Frequency Sweep
    reg overflow;
    always @(posedge clk_sweep, posedge start)
    begin
        if (start) begin
            target_freq <= frequency;
            sweep_left <= sweep_time;
            overflow <= 0;
        end
        else begin
            if (sweep_left != 3'b0) begin
                sweep_left <= sweep_left - 1'b1;
                if (sweep_decreasing) 
                    target_freq <= target_freq - (target_freq << num_sweep_shifts);
                else
                    {overflow, target_freq} <= {1'b0, target_freq} + ({1'b0, target_freq} << num_sweep_shifts);
            end
            else begin
                target_freq <= frequency;
            end
        end
    end 
    /*always@(posedge start)
    begin
        target_freq <= frequency;
    end*/

    sound_vol_env sound_vol_env(
        .clk_vol_env(clk_vol_env),
        .start(start),
        .initial_volume(initial_volume),
        .envelope_increasing(envelope_increasing),
        .num_envelope_sweeps(num_envelope_sweeps),
        .target_vol(target_vol)
    );
    
    wire enable_length;

    sound_length_ctr #(6) sound_length_ctr(
        .rst(rst),
        .clk_length_ctr(clk_length_ctr),
        .start(start),
        .single(single),
        .length(length),
        .enable(enable_length)
    );
    
    assign enable = enable_length & ~overflow;
    
    sound_channel_mix sound_channel_mix(
        .enable(enable),
        .modulate(target_freq_out),
        .target_vol(target_vol),
        .level(level)
    );

endmodule


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    22:21:41 04/08/2018 
// Module Name:    sound_vol_env 
// Project Name:   VerilogBoy
// Description: 
//   Sound volume envelope control for channel 1 2 4
// Dependencies: 
//   none
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module sound_vol_env(
    input clk_vol_env,
    input start,
    input [3:0] initial_volume,
    input envelope_increasing,
    input [2:0] num_envelope_sweeps,
    output reg [3:0] target_vol
    );
    
    reg [2:0] enve_left; // Number of cycles before next sweep
    wire enve_enabled = (num_envelope_sweeps == 3'd0) ? 0 : 1;
    
    // Volume Envelope
    always @(posedge clk_vol_env, posedge start)
    begin
        if (start) begin
            target_vol <= initial_volume;
            enve_left <= num_envelope_sweeps;
        end
        else begin
            if (enve_left != 3'b0) begin
                enve_left <= enve_left - 1'b1;
            end
            else begin
                if (enve_enabled) begin
                    if (envelope_increasing) begin
                        if (target_vol != 4'b1111)
                            target_vol <= target_vol + 1;
                    end
                    else begin
                        if (target_vol != 4'b0000)
                            target_vol <= target_vol - 1;
                    end
                    enve_left <= num_envelope_sweeps;
                end
            end
        end
    end


endmodule


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    15:06:53 04/09/2018 
// Module Name:    sound_wave 
// Project Name:   VerilogBoy
// Description: 
//   Sound wave player for channel 3
// Dependencies: 
//   clk_div, sound_length_ctr
// Additional Comments: 
//   If Ch3 bugs are to be implemented, they should be probably implemented
//   outside of this file. This file does not handle of RW to wave RAM
//////////////////////////////////////////////////////////////////////////////////
module sound_wave(
    input rst, // Async reset 
    input clk, // Main CPU clock
    input clk_length_ctr, // Length control clock
    input [7:0] length, // Length = (256-t1)*(1/256) second, used iff single is set
    input [1:0] volume,
    input on,
    input single,
    input start,
    input [10:0] frequency,
    output [3:0] wave_a,
    input [7:0] wave_d,
    output [3:0] level,
    output enable
    );
    
    // Freq = 64kHz / (2048 - frequency)
    // Why????????
    
    wire [3:0] current_sample;
    
    reg [4:0] current_pointer = 5'b0;
    
    assign wave_a[3:0] = current_pointer[4:1];
    assign current_sample[3:0] = (current_pointer[0]) ?
        (wave_d[3:0]) : (wave_d[7:4]);
    
    wire clk_wave_base = clk; // base clock
    /*clk_div #(.WIDTH(6), .DIV(32)) freq_div(
        .i(clk),
        .o(clk_wave_base)
    );*/
    
    
    reg clk_pointer_inc = 1'b0; // Clock for pointer to increment
    reg [10:0] divider = 11'b0;
    always @(posedge clk_wave_base, posedge start)
    begin
        if (start) begin
            divider <= frequency;
        end
        else begin
            if (divider == 11'd2047) begin
                clk_pointer_inc <= ~clk_pointer_inc;
                divider <= frequency;
            end
            else begin
                divider <= divider + 1'b1;
            end
        end
    end
        
    always @(posedge clk_pointer_inc, posedge start)
    begin
        if (start) begin
            current_pointer <= 5'b0;
        end
        else begin
            if (on)
                current_pointer <= current_pointer + 1'b1;
        end
    end
    
    sound_length_ctr #(8) sound_length_ctr(
        .rst(rst),
        .clk_length_ctr(clk_length_ctr),
        .start(start),
        .single(single),
        .length(length),
        .enable(enable)
    );
    
    assign level = (on) ? (
        (volume == 2'b00) ? (4'b0000) : (
        (volume == 2'b01) ? (current_sample[3:0]) : (
        (volume == 2'b10) ? ({1'b0, current_sample[3:1]}) : (
                            ({2'b0, current_sample[3:2]}))))) : 4'b0000;


endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Wenting Zhang
// 
// Create Date:    17:12:01 04/13/2018 
// Module Name:    timer 
// Project Name:   VerilogBoy
// Description: 
//   GameBoy internal timer
// Dependencies: 
//
// Additional Comments: 
//   This should probably run at 1MHz domain, but currently at 4MHz.
//////////////////////////////////////////////////////////////////////////////////
module timer(
    input wire clk,
    input wire [1:0] ct, // certain things can only happen at 1MHz rate
    input wire rst,
    input wire [15:0] a,
    output reg [7:0] dout,
    input wire [7:0] din,
    input wire rd,
    input wire wr,
    output reg int_tim_req,
    input wire int_tim_ack
    );
    
    wire [7:0] reg_div; // Divider Register
    reg [7:0] reg_tima; // Timer counter
    reg [7:0] reg_tma; // Timer modulo
    reg [7:0] reg_tac; // Timer control
    
    wire addr_in_timer = ((a == 16'hFF04) ||
                          (a == 16'hFF05) ||
                          (a == 16'hFF06) ||
                          (a == 16'hFF07)) ? 1'b1 : 1'b0;
    
    reg [15:0] div;
    
    wire reg_timer_enable = reg_tac[2];
    wire [1:0] reg_clock_sel = reg_tac[1:0];
    
    assign reg_div[7:0] = div[15:8];
    wire clk_4khz = div[9];
    wire clk_256khz = div[3];
    wire clk_64khz = div[5];
    wire clk_16khz = div[7];
    wire clk_tim;
    assign clk_tim = (reg_timer_enable) ? (
        (reg_clock_sel == 2'b00) ? (clk_4khz) : (
        (reg_clock_sel == 2'b01) ? (clk_256khz) : (
        (reg_clock_sel == 2'b10) ? (clk_64khz) : 
                                   (clk_16khz)))) : (1'b0);
    
    reg last_clk_tim;
    reg write_block;
    
    // Bus RW
    // Bus RW - Combinational Read
    always @(*)
    begin
        dout = 8'hFF;
        if (a == 16'hFF04) dout = reg_div; else
        if (a == 16'hFF05) dout = reg_tima; else
        if (a == 16'hFF06) dout = reg_tma; else
        if (a == 16'hFF07) dout = reg_tac;
    end
    
    // Bus RW - Sequential Write
    always @(posedge clk) begin
        last_clk_tim <= clk_tim;
    end
    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            //reg_div <= 0;
            reg_tima <= 0;
            reg_tma <= 0;
            reg_tac <= 0;
            div <= 0;
            int_tim_req <= 0;
            write_block <= 0;
        end
        else begin
            div <= div + 1'b1;
            if ((wr) && (a == 16'hFF04)) div <= 4; // compensate 1 cycle delay
            else if ((wr) && (a == 16'hFF06)) begin
                // test acceptance/timer/tma_write_reloading seems to imply
                // that the reloading is done using a latch rather a FF
                // writing to tma in the same cycle will fall through to tima
                // as well.
                reg_tma <= din;
                if (write_block)
                    reg_tima <= din;
            end
            else if ((wr) && (a == 16'hFF07)) reg_tac <= din;
            else if ((wr) && (a == 16'hFF05) && (!write_block)) reg_tima <= din;
            else begin
                if ((last_clk_tim == 1'b1)&&(clk_tim == 1'b0)) begin
                    reg_tima <= reg_tima + 1'b1;
                    if (reg_tima == 8'hFF) begin
                        int_tim_req <= 1'b1; // interrupt doesn't get delayed.
                    end
                end
                else begin
                    if ((int_tim_req)&&(int_tim_ack)) begin
                        int_tim_req <= 1'b0;
                    end 
                    if ((ct == 2'b00)&&(reg_timer_enable)) begin
                        if (reg_tima == 8'd0) begin
                            reg_tima <= reg_tma;
                            //int_tim_req <= 1'b1;
                            write_block <= 1'b1;
                        end
                        else begin
                            write_block <= 1'b0;
                        end
                    end
                end
            end
        end
    end

endmodule




