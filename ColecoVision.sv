//============================================================================
//  ColecoVision
//
//  Port to MiSTer
//  Copyright (C) 2017-2019 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

`default_nettype none

module guest_top
(
	input         CLOCK_27,
`ifdef USE_CLOCK_50
   input         CLOCK_50,
`endif
	output        LED,
	output [VGA_BITS-1:0] VGA_R,
	output [VGA_BITS-1:0] VGA_G,
	output [VGA_BITS-1:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,

`ifdef USE_HDMI
	output        HDMI_RST,
	output  [7:0] HDMI_R,
	output  [7:0] HDMI_G,
	output  [7:0] HDMI_B,
	output        HDMI_HS,
	output        HDMI_VS,
	output        HDMI_PCLK,
	output        HDMI_DE,
	inout         HDMI_SDA,
	inout         HDMI_SCL,
	input         HDMI_INT,
`endif

	input         SPI_SCK,
	inout         SPI_DO,
	input         SPI_DI,
	input         SPI_SS2,    // data_io
	input         SPI_SS3,    // OSD
	input         CONF_DATA0, // SPI_SS for user_io

`ifdef USE_QSPI
	input         QSCK,
	input         QCSn,
	inout   [3:0] QDAT,
`endif
`ifndef NO_DIRECT_UPLOAD
	input         SPI_SS4,
`endif

	output [12:0] SDRAM_A,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nWE,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nCS,
	output  [1:0] SDRAM_BA,
	output        SDRAM_CLK,
	output        SDRAM_CKE,

`ifdef DUAL_SDRAM
	output [12:0] SDRAM2_A,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_DQML,
	output        SDRAM2_DQMH,
	output        SDRAM2_nWE,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nCS,
	output  [1:0] SDRAM2_BA,
	output        SDRAM2_CLK,
	output        SDRAM2_CKE,
`endif

	output        AUDIO_L,
	output        AUDIO_R,
`ifdef I2S_AUDIO
	output        I2S_BCK,
	output        I2S_LRCK,
	output        I2S_DATA,
`endif
`ifdef SPDIF_AUDIO
	output        SPDIF,
`endif
`ifdef USE_AUDIO_IN
	input         AUDIO_IN,
`endif

`ifdef PIN_REFLECTION
	output        joy_clk,
   input         joy_xclk,
	
   output        joy_load,
   input         joy_xload,
   
	input         joy_data,
   output        joy_xdata,	
`endif
	
`ifdef USE_EXTBUS	
	inout [23:0]  BUS_A = 24'b0,
	inout  [15:0]  BUS_D = 16'b0,
	inout         BUS_USER1,
	inout         BUS_USER2,
	inout         BUS_USER3,
	inout         BUS_USER5,
	inout         BUS_USER6,
	inout         BUS_USER7,
	inout         BUS_N41,
	inout         BUS_N42,
	inout         BUS_N43,
	inout         BUS_N44,
	inout         BUS_N45,
	inout         BUS_N46,
	inout         BUS_N47,
	inout         BUS_N48,
	inout         BUS_nRESET,
	inout         BUS_nM1,
	inout         BUS_nMREQ,
	inout         BUS_nIORQ,
	inout         BUS_nRD,
	inout         BUS_nWR,
	inout         BUS_nRFSH,
	inout         BUS_nHALT,
	inout         BUS_nBUSAK,
	inout reg     BUS_CLK,
	inout         BUS_nINT,
	inout         BUS_nWAIT,
	input         BUS_RX,
	output        BUS_TX,
`endif
   input         UART_RX,
	output        UART_TX
);

`ifdef NO_DIRECT_UPLOAD
localparam bit DIRECT_UPLOAD = 0;
wire SPI_SS4 = 1;
`else
localparam bit DIRECT_UPLOAD = 1;
`endif

`ifdef USE_QSPI
localparam bit QSPI = 1;
assign QDAT = 4'hZ;
`else
localparam bit QSPI = 0;
`endif

`ifdef VGA_8BIT
localparam VGA_BITS = 8;
`else
localparam VGA_BITS = 6;
`endif

`ifdef USE_HDMI
localparam bit HDMI = 1;
assign HDMI_RST = 1'b1;
`else
localparam bit HDMI = 0;
`endif

`ifdef BIG_OSD
localparam bit BIG_OSD = 1;
`define SEP "-;",
`else
localparam bit BIG_OSD = 0;
`define SEP
`endif

// remove this if the 2nd chip is actually used
`ifdef DUAL_SDRAM
assign SDRAM2_A = 13'hZZZZ;
assign SDRAM2_BA = 0;
assign SDRAM2_DQML = 0;
assign SDRAM2_DQMH = 0;
assign SDRAM2_CKE = 0;
assign SDRAM2_CLK = 0;
assign SDRAM2_nCS = 1;
assign SDRAM2_DQ = 16'hZZZZ;
assign SDRAM2_nCAS = 1;
assign SDRAM2_nRAS = 1;
assign SDRAM2_nWE = 1;
`endif



assign LED   = ioctl_download;



`include "build_id.v" 
parameter CONF_STR = {
	"Coleco;;",
	"F,COLBINROM,Load Cart;",
	"F,SG ,Load SG-1000;",
`ifdef USE_EXTBUS
	"O2,Cartridge ,Internal,External;",
`endif	
	`SEP
	"O79,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%;",
	"O3,Joysticks swap,No,Yes;",
	"O45,RAM Size,1KB,8KB,SGM;",
	`SEP
	"T0,Reset;",
	"V,v",`BUILD_DATE
};

/////////////////  CLOCKS  ////////////////////////

wire clk_sys;
wire pll_locked;
pll pll
(
        .inclk0(CLOCK_50),
        .areset(0),
        .c0(clk_sys),
        .locked(pll_locked)
);
reg ce_10m7 = 0;
reg ce_5m3 = 0;
always @(posedge clk_sys) begin
	reg [2:0] div;
	
	div <= div+1'd1;
	ce_10m7 <= !div[1:0];
	ce_5m3  <= !div[2:0];
end

/////////////////  HPS  ///////////////////////////

wire [31:0] status;
wire  [1:0] buttons;


wire [31:0] joy0, joy1;

wire        ioctl_download;
wire  [7:0] ioctl_index;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
wire        scandoubler_disable;
wire ypbpr;
wire no_csync;
wire  [1:0] switches;
wire        key_pressed;
wire [7:0]  key_code;
wire        key_strobe;
wire        key_extended;

//user_io #(.STRLEN($size(CONF_STR)>>3)) user_io
//(
//	.clk_sys             (clk_sys          ),
//   .clk_sd              (clk_sys          ),
//	.SPI_SS_IO           (CONF_DATA0),
//	.SPI_CLK             (SPI_SCK),
//	.SPI_MOSI            (SPI_DI),
//	.SPI_MISO            (SPI_DO),
//
//	.conf_str            (CONF_STR),
//	.status              (status),
//	.scandoubler_disable (forced_scandoubler),
//	.ypbpr               (ypbpr),
//	.no_csync            (),
//	.buttons             (buttons),
//	
//	.ps2_key             (ps2_key),
//
//
//	.joystick_0          (joy0          ),
//	.joystick_1          (joy1          )
//);
//
//data_io data_io
//(
//	.clk_sys             (clk_sys),
//	.SPI_SCK             (SPI_SCK),
//	.SPI_DI              (SPI_DI),
//	.SPI_SS2             (SPI_SS2),
//
//	.clkref_n            (),
//	.ioctl_fileext       (),
//	.ioctl_wr            (ioctl_wr),
//	.ioctl_addr          (ioctl_addr),
//	.ioctl_dout          (ioctl_dout),
//	.ioctl_download      (ioctl_download),
//	.ioctl_index         (ioctl_index)
//);

`ifdef PIN_REFLECTION
assign joy_clk = joy_xclk;
assign joy_load = joy_xload;
assign joy_xdata = joy_data;
`endif


wire [10:0] ps2_key;
assign ps2_key = {key_strobe,key_pressed,key_extended,key_code}; 


user_io #(
	.STRLEN($size(CONF_STR)>>3),
	.FEATURES(32'h0 | (BIG_OSD << 13) | (HDMI << 14))) 
user_io
( 
    .clk_sys(clk_sys),
    .clk_sd(clk_sys),
    .SPI_SS_IO(CONF_DATA0),
    .SPI_CLK(SPI_SCK),
    .SPI_MOSI(SPI_DI),
    .SPI_MISO(SPI_DO),

    .conf_str(CONF_STR),
    .status(status),
    .scandoubler_disable(scandoubler_disable),
    .ypbpr(ypbpr),
    .no_csync(no_csync),
    .buttons(buttons),
    .joystick_0(joy0),
    .joystick_1(joy1),
    .key_strobe(key_strobe),
    .key_code(key_code),
    .key_pressed(key_pressed),
    .key_extended(key_extended),

	 
`ifdef USE_HDMI
	 .i2c_start      (i2c_start      ),
	 .i2c_read       (i2c_read       ),
	 .i2c_addr       (i2c_addr       ),
	 .i2c_subaddr    (i2c_subaddr    ),
	 .i2c_dout       (i2c_dout       ),
	 .i2c_din        (i2c_din        ),
	 .i2c_ack        (i2c_ack        ),
	 .i2c_end        (i2c_end        ),
	`endif
	 .switches(switches),

);

data_io data_io (
    // SPI interface
    .SPI_SCK        ( SPI_SCK ),
    .SPI_SS2        ( SPI_SS2 ),
    .SPI_DI         ( SPI_DI  ),
    // ram interface
    .clk_sys        ( clk_sys ),
    //.clkref_n       ( ~clk_ref  ),
    .ioctl_download ( ioctl_download ),
    .ioctl_index    ( ioctl_index ),
    .ioctl_wr       ( ioctl_wr ),
    .ioctl_addr     ( ioctl_addr ),
    .ioctl_dout     ( ioctl_dout )
);



/////////////////  RESET  /////////////////////////

wire reset =  status[0] | buttons[1] | ioctl_download | ~BUS_A[15];

/////////////////  Memory  ////////////////////////

wire [12:0] bios_a;
wire  [7:0] bios_d;

spram #(13,8,"../rtl/bios.mif") rom
(
	.clock(clk_sys),
	.address(bios_a),
	.q(bios_d)
);

wire [14:0] cpu_ram_a;
wire        ram_we_n, ram_ce_n;
wire  [7:0] ram_di;
wire  [7:0] ram_do;

wire [14:0] ram_a = (extram)            ? cpu_ram_a       :
                    (status[5:4] == 1)  ? cpu_ram_a[12:0] : // 8k
                    (status[5:4] == 0)  ? cpu_ram_a[9:0]  : // 1k
                    (sg1000)            ? cpu_ram_a[12:0] : // SGM means 8k on SG1000
                                          cpu_ram_a;        // SGM/32k

spram #(15) ram   //14 for SiDi and MiST
(
	.clock(clk_sys),
	.address(ram_a),
	.wren(ce_10m7 & ~(ram_we_n | ram_ce_n)),
	.data(ram_do),
	.q(ram_di)
);

wire [13:0] vram_a;
wire        vram_we;
wire  [7:0] vram_di;
wire  [7:0] vram_do;

spram #(14) vram
(
	.clock(clk_sys),
	.address(vram_a),
	.wren(vram_we),
	.data(vram_do),
	.q(vram_di)
);

wire [19:0] cart_a;
wire  [7:0] cart_d;
wire        cart_rd;


`ifdef USE_EXTBUS
assign BUS_A[11:0] = cart_a[11:0];
assign BUS_nIORQ=cart_a[12];
assign BUS_A[13]=cart_a[13];
assign BUS_A[12]=cart_a[14];
wire ext_cart_d= cart_rd ? BUS_D[7:0] : 8'bZ;
`endif


reg [5:0] cart_pages;
always @(posedge clk_sys) if(ioctl_wr) cart_pages <= ioctl_addr[19:14];

assign SDRAM_CLK = ~clk_sys;

sdram sdram
(
	.*,
	.init(~pll_locked),
	.clk(clk_sys),

   .wtbt(0),
   .addr(ioctl_download ? ioctl_addr : cart_a),
   .rd(cart_rd),
   .dout(cart_d),
   .din(ioctl_dout),
   .we(ioctl_wr),
   .ready()
);

reg sg1000 = 0;
reg extram = 0;
always @(posedge clk_sys) begin
	if(ioctl_wr) begin
		if(!ioctl_addr) begin
			extram <= 0;
			sg1000 <= (ioctl_index[4:0] == 2);
		end
		if(ioctl_addr[24:13] == 1 && sg1000) extram <= (!ioctl_addr[12:0] | extram) & &ioctl_dout; // 2000-3FFF on SG-1000
	end
end


////////////////  Console  ////////////////////////

wire [13:0] audio;
wire [15:0] DAC_L,DAC_R;

assign DAC_L = {1'b0,audio[13:0],1'b0};
assign DAC_R = DAC_L;

`ifdef I2S_AUDIO

wire [31:0] clk_rate =  32'd42_666_000;

i2s i2s (
        .reset(reset),
        .clk(clk_sys),
        .clk_rate(clk_rate),

        .sclk(I2S_BCK),
        .lrclk(I2S_LRCK),
        .sdata(I2S_DATA),

        .left_chan (DAC_L),
        .right_chan(DAC_R)
);
`ifdef I2S_AUDIO_HDMI
assign HDMI_MCLK = 0;
always @(posedge clk_sys) begin
	HDMI_BCK <= I2S_BCK;
	HDMI_LRCK <= I2S_LRCK;
	HDMI_SDATA <= I2S_DATA;
end
`endif
`endif

`ifdef SPDIF_AUDIO
spdif spdif (
	.clk_i(clk_sys),
	.rst_i(1'b0),
	.clk_rate_i(clk_rate),
	.spdif_o(SPDIF),
	.sample_i({DAC_L,DAC_R})
);
`endif

dac #(
   .c_bits	(14))
audiodac_l(
   .clk_i	(clk_sys	),
   .res_n_i	(1	),
   .dac_i	(audio),
   .dac_o	(AUDIO_L)
  );

dac #(
   .c_bits	(16))
audiodac_r(
   .clk_i	(clk_sys	),
   .res_n_i	(1	),
   .dac_i	(audio),
   .dac_o	(AUDIO_R)
  );

  

wire CLK_VIDEO = clk_sys;

wire [1:0] ctrl_p1;
wire [1:0] ctrl_p2;
wire [1:0] ctrl_p3;
wire [1:0] ctrl_p4;
wire [1:0] ctrl_p5;
wire [1:0] ctrl_p6;
wire [1:0] ctrl_p7 = 2'b11;
wire [1:0] ctrl_p8;
wire [1:0] ctrl_p9 = 2'b11;

wire [7:0] R,G,B;
wire HBlank, VBlank;
wire HSync, VSync;

wire [31:0] joya = status[3] ? joy1 : joy0;
wire [31:0] joyb = status[3] ? joy0 : joy1;

cv_console console
(
	.clk_i(clk_sys),
	.clk_en_10m7_i(ce_10m7),
	.reset_n_i(~reset),
	.por_n_o(),
	.sg1000(sg1000),
	.dahjeeA_i(extram),

	.ctrl_p1_i(ctrl_p1),
	.ctrl_p2_i(ctrl_p2),
	.ctrl_p3_i(ctrl_p3),
	.ctrl_p4_i(ctrl_p4),
	.ctrl_p5_o(ctrl_p5),
	.ctrl_p6_i(ctrl_p6),
	.ctrl_p7_i(ctrl_p7),
	.ctrl_p8_o(ctrl_p8),
	.ctrl_p9_i(ctrl_p9),
	.joy0_i(~{|joya[19:6], 1'b0, joya[5:0]}),
	.joy1_i(~{|joyb[19:6], 1'b0, joyb[5:0]}),

	.bios_rom_a_o(bios_a),
	.bios_rom_d_i(bios_d),

	.cpu_ram_a_o(cpu_ram_a),
	.cpu_ram_we_n_o(ram_we_n),
	.cpu_ram_ce_n_o(ram_ce_n),
	.cpu_ram_d_i(ram_di),
	.cpu_ram_d_o(ram_do),

	.vram_a_o(vram_a),
	.vram_we_o(vram_we),
	.vram_d_o(vram_do),
	.vram_d_i(vram_di),

	.cart_pages_i(cart_pages),
	.cart_a_o(cart_a),
`ifdef USE_EXTBUS
	.cart_d_i(status[2] ? ext_cart_d : cart_d),
`else
   .cart_d_i(cart_d),
`endif
	
	.cart_rd(cart_rd),

`ifdef USE_EXTBUS
  	.cart_en_80_n_o (BUS_A[14]),
   .cart_en_a0_n_o (BUS_nRESET),
   .cart_en_c0_n_o (BUS_CLK),
   .cart_en_e0_n_o (BUS_nRD),
`endif
	
	.rgb_r_o(R),
	.rgb_g_o(G),
	.rgb_b_o(B),
	.hsync_n_o(HSync),
	.vsync_n_o(VSync),
	.hblank_o (HBlank),
	.vblank_o (VBlank),

	.audio_o(audio)
);


//wire [2:0] scale = status[9:7];

reg hs_o, vs_o;
always @(posedge CLK_VIDEO) begin
	hs_o <= ~HSync;
	if(~hs_o & ~HSync) vs_o <= ~VSync;
end


 
mist_video #(
    .COLOR_DEPTH(8),
    .OSD_COLOR(3'd3),
	 .SD_HCNT_WIDTH(10),
	 .OUT_COLOR_DEPTH(VGA_BITS),
	 .BIG_OSD(BIG_OSD),
	 .USE_BLANKS(1'b1)
) 
 mist_video (	
	.clk_sys      (clk_sys    ),
	.SPI_SCK      (SPI_SCK    ),
	.SPI_SS3      (SPI_SS3    ),
	.SPI_DI       (SPI_DI     ),
	.R            (R ),
	.G            (G ),
	.B            (B ),
	.HSync        (hs_o),
	.VSync        (vs_o),
	.HBlank       (HBlank),
	.VBlank       (VBlank),
	.VGA_R        (VGA_R      ),
	.VGA_G        (VGA_G      ),
	.VGA_B        (VGA_B      ),
	.VGA_VS       (VGA_VS     ),
	.VGA_HS       (VGA_HS     ),
	.ce_divider   (3'd0       ),
	.scandoubler_disable(scandoubler_disable),
	.scanlines(scandoubler_disable ? 2'b00 : {status[9:7] == 3, status[9:7] == 2}),
	.no_csync     (no_csync),
	.ypbpr        (ypbpr      )
	);

`ifdef USE_HDMI
i2c_master #(42_666_000) i2c_master (
	.CLK         (clk_hdmi),
	.I2C_START   (i2c_start),
	.I2C_READ    (i2c_read),
	.I2C_ADDR    (i2c_addr),
	.I2C_SUBADDR (i2c_subaddr),
	.I2C_WDATA   (i2c_dout),
	.I2C_RDATA   (i2c_din),
	.I2C_END     (i2c_end),
	.I2C_ACK     (i2c_ack),

	//I2C bus
	.I2C_SCL     (HDMI_SCL),
	.I2C_SDA     (HDMI_SDA)
);	

mist_video #(
	.COLOR_DEPTH(8),
	.OUT_COLOR_DEPTH(8),
	.USE_BLANKS(1),
	.OSD_COLOR(3'b001),
	.BIG_OSD(BIG_OSD),
	.VIDEO_CLEANER(1)
)

hdmi_video (
	.clk_sys     ( clk_sys   ),

	// OSD SPI interface
	.SPI_SCK     ( SPI_SCK    ),
	.SPI_SS3     ( SPI_SS3    ),
	.SPI_DI      ( SPI_DI     ),
	.scanlines   (  ),
	.ce_divider  ( 3'd3       ),
	.scandoubler_disable (1'b1),
	.no_csync    ( 1'b1       ),
	.ypbpr       ( 1'b0       ),
	.rotate      ( 2'b00      ),
	.blend       ( 1'b0       ),
	.R           (R),
	.G           (G),
	.B           (B),
	.HBlank      ( HBlank      ),
	.VBlank      ( VBlank      ),
	.HSync       ( hs_o        ),
	.VSync       ( vs_o        ),
	.VGA_R       ( HDMI_R      ),
	.VGA_G       ( HDMI_G      ),
	.VGA_B       ( HDMI_B      ),
	.VGA_VS      (HDMI_VS      ),
	.VGA_HS      (HDMI_HS      ),
	.VGA_DE      ( HDMI_DE     )
);
assign HDMI_PCLK = clk_sys;
`endif	
//////////////// Keypad emulation (by Alan Steremberg) ///////

wire       pressed = ps2_key[9];
wire [8:0] code    = ps2_key[8:0];
always @(posedge clk_sys) begin
	reg old_state;
	old_state <= ps2_key[10];

	if(old_state != ps2_key[10]) begin
		casex(code)

			'hX16: btn_1     <= pressed; // 1
			'hX1E: btn_2     <= pressed; // 2
			'hX26: btn_3     <= pressed; // 3
			'hX25: btn_4     <= pressed; // 4
			'hX2E: btn_5     <= pressed; // 5
			'hX36: btn_6     <= pressed; // 6
			'hX3D: btn_7     <= pressed; // 7
			'hX3E: btn_8     <= pressed; // 8
			'hX46: btn_9     <= pressed; // 9
			'hX45: btn_0     <= pressed; // 0

			'hX69: btn_1     <= pressed; // 1
			'hX72: btn_2     <= pressed; // 2
			'hX7A: btn_3     <= pressed; // 3
			'hX6B: btn_4     <= pressed; // 4
			'hX73: btn_5     <= pressed; // 5
			'hX74: btn_6     <= pressed; // 6
			'hX6C: btn_7     <= pressed; // 7
			'hX75: btn_8     <= pressed; // 8
			'hX7D: btn_9     <= pressed; // 9
			'hX70: btn_0     <= pressed; // 0

			'hX7C: btn_star  <= pressed; // *
			'hX59: btn_shift <= pressed; // Right Shift
			'hX12: btn_shift <= pressed; // Left Shift
			'hX7B: btn_minus <= pressed; // - on keypad


		endcase
	end
end

reg btn_1 = 0;
reg btn_2 = 0;
reg btn_3 = 0;
reg btn_4 = 0;
reg btn_5 = 0;
reg btn_6 = 0;
reg btn_7 = 0;
reg btn_8 = 0;
reg btn_9 = 0;
reg btn_0 = 0;

reg btn_star = 0;
reg btn_shift = 0;
reg btn_minus = 0;


////////////////  Control  ////////////////////////
//	"J1,dir,dir,dir,dir,Fire 1,Fire 2,*,#,[8]0,1,2,3,4,5,6,7,8,9,Purple Tr,Blue Tr;",
//        0   1   2   3   4      5     6 7 8 9 10 11 12 


wire [0:19] keypad0 = {joya[8],joya[9],joya[10],joya[11],joya[12],joya[13],joya[14],joya[15],joya[16],joya[17],joya[6],joya[7],joya[18],joya[19],joya[3],joya[2],joya[1],joya[0],joya[4],joya[5]};
wire [0:19] keypad1 = {joyb[8],joyb[9],joyb[10],joyb[11],joyb[12],joyb[13],joyb[14],joyb[15],joyb[16],joyb[17],joyb[6],joyb[7],joyb[18],joyb[19],joyb[3],joyb[2],joyb[1],joyb[0],joyb[4],joyb[5]};
wire [0:19] keyboardemu = { btn_0, btn_1, btn_2, btn_3, btn_4, btn_5, btn_6, btn_7, btn_8, btn_9, btn_star | (btn_8&btn_shift), btn_minus | (btn_shift & btn_3), 8'b0};
wire [0:19] keypad[2] = '{keypad0|keyboardemu,keypad1|keyboardemu};

reg [3:0] ctrl1[2] = '{'0,'0};
assign {ctrl_p1[0],ctrl_p2[0],ctrl_p3[0],ctrl_p4[0]} = ctrl1[0];
assign {ctrl_p1[1],ctrl_p2[1],ctrl_p3[1],ctrl_p4[1]} = ctrl1[1];

localparam cv_key_0_c        = 4'b0011;
localparam cv_key_1_c        = 4'b1110;
localparam cv_key_2_c        = 4'b1101;
localparam cv_key_3_c        = 4'b0110;
localparam cv_key_4_c        = 4'b0001;
localparam cv_key_5_c        = 4'b1001;
localparam cv_key_6_c        = 4'b0111;
localparam cv_key_7_c        = 4'b1100;
localparam cv_key_8_c        = 4'b1000;
localparam cv_key_9_c        = 4'b1011;
localparam cv_key_asterisk_c = 4'b1010;
localparam cv_key_number_c   = 4'b0101;
localparam cv_key_pt_c       = 4'b0100;
localparam cv_key_bt_c       = 4'b0010;
localparam cv_key_none_c     = 4'b1111;

generate
        genvar i;
        for (i = 0; i <= 1; i++) begin : ctl
                always_comb begin
                        reg [3:0] ctl1, ctl2;
                        reg p61,p62;

                        ctl1 = 4'b1111;
                        ctl2 = 4'b1111;
                        p61 = 1;
                        p62 = 1;

                        if (~ctrl_p5[i]) begin
                                casex(keypad[i][0:13])
                                        'b1xxxxxxxxxxxxx: ctl1 = cv_key_0_c;
                                        'b01xxxxxxxxxxxx: ctl1 = cv_key_1_c;
                                        'b001xxxxxxxxxxx: ctl1 = cv_key_2_c;
                                        'b0001xxxxxxxxxx: ctl1 = cv_key_3_c;
                                        'b00001xxxxxxxxx: ctl1 = cv_key_4_c;
                                        'b000001xxxxxxxx: ctl1 = cv_key_5_c;
                                        'b0000001xxxxxxx: ctl1 = cv_key_6_c;
                                        'b00000001xxxxxx: ctl1 = cv_key_7_c;
                                        'b000000001xxxxx: ctl1 = cv_key_8_c;
                                        'b0000000001xxxx: ctl1 = cv_key_9_c;
                                        'b00000000001xxx: ctl1 = cv_key_asterisk_c;
                                        'b000000000001xx: ctl1 = cv_key_number_c;
                                        'b0000000000001x: ctl1 = cv_key_pt_c;
                                        'b00000000000001: ctl1 = cv_key_bt_c;
                                        'b00000000000000: ctl1 = cv_key_none_c;
                                endcase
                                p61 = ~keypad[i][19]; // button 2
                        end

                        if (~ctrl_p8[i]) begin
                                ctl2 = ~keypad[i][14:17];
                                p62 = ~keypad[i][18];  // button 1
                        end

                        ctrl1[i] = ctl1 & ctl2;
                        ctrl_p6[i] = p61 & p62;
                end
        end
endgenerate



endmodule
