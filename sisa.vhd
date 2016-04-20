LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY sisa IS
    PORT (CLOCK_50  : IN    STD_LOGIC;
			 --SRAM
          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic := '1';
          SRAM_OE_N : out   std_logic := '1';
          SRAM_WE_N : out   std_logic := '1';
			 --I/O
          LEDG      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
          LEDR      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
          HEX0      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
          HEX1      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
          HEX2      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
          HEX3      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
          SW        : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
          KEY       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			 PS2_CLK   : inout std_logic; 
			 PS2_DAT  : inout std_logic;
			 --VGA
			 VGA_R		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			 VGA_G		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			 VGA_B		: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			 VGA_HS		: OUT STD_LOGIC;
			 VGA_VS		: OUT STD_LOGIC);
END sisa;

ARCHITECTURE Structure OF sisa IS

	COMPONENT clock_t IS
		GENERIC(limits : integer := 25000000);
		PORT(CLOCK_IN : IN std_logic;
			CLOCK_OUT : OUT std_logic);
	END COMPONENT;

	COMPONENT proc IS
	PORT (clk       : IN  STD_LOGIC;
		boot      : IN  STD_LOGIC;
		datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		addr_m    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		data_wr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		wr_m      : OUT STD_LOGIC;
		word_byte : OUT STD_LOGIC;
		addr_io   : OUT STD_LOGIC_VECTOR(7 downto 0);
		wr_io     : OUT STD_LOGIC_VECTOR(15 downto 0);
		rd_io     : IN STD_LOGIC_VECTOR(15 downto 0);
		wr_out    : OUT STD_LOGIC;
		rd_in     : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT controladores_IO IS
	PORT (boot       : IN STD_LOGIC;
		CLOCK_50   : IN STD_LOGIC;
		addr_io    : IN STD_LOGIC_VECTOR(7 downto 0);
		wr_io      : IN STD_LOGIC_VECTOR(15 downto 0);
		rd_io      : OUT STD_LOGIC_VECTOR(15 downto 0);
		wr_out     : IN STD_LOGIC;
		rd_in      : IN STD_LOGIC;
		led_verdes : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		led_rojos  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		HEX0      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX1      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX2      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX3      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		SW        : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		KEY       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		ps2_clk : inout std_logic;
		ps2_data : inout std_logic;
		vga_cursor : out std_logic_vector(15 downto 0);
		vga_cursor_enable : out std_logic);
	END COMPONENT;

	COMPONENT MemoryController is
	PORT (CLOCK_50  : in  std_logic;
		addr      : in  std_logic_vector(15 downto 0);
		wr_data   : in  std_logic_vector(15 downto 0);
		rd_data   : out std_logic_vector(15 downto 0);
		we        : in  std_logic;
		byte_m    : in  std_logic;
		-- señales para la placa de desarrollo
		SRAM_ADDR : out   std_logic_vector(17 downto 0);
		SRAM_DQ   : inout std_logic_vector(15 downto 0);
		SRAM_UB_N : out   std_logic;
		SRAM_LB_N : out   std_logic;
		SRAM_CE_N : out   std_logic := '1';
		SRAM_OE_N : out   std_logic := '1';
		SRAM_WE_N : out   std_logic := '1';
		--VGA 
		vga_addr    : out std_logic_vector(12 downto 0);
		vga_we      : out std_logic;
		vga_wr_data : out std_logic_vector(15 downto 0);
		vga_rd_data : in std_logic_vector(15 downto 0);
		vga_byte_m  : out std_logic);
	END COMPONENT;

	COMPONENT vga_controller IS
	PORT(clk_50mhz      : in  std_logic; -- system clock signal
         reset          : in  std_logic; -- system reset
         blank_out      : out std_logic; -- vga control signal
         csync_out      : out std_logic; -- vga control signal
         red_out        : out std_logic_vector(7 downto 0); -- vga red pixel value
         green_out      : out std_logic_vector(7 downto 0); -- vga green pixel value
         blue_out       : out std_logic_vector(7 downto 0); -- vga blue pixel value
         horiz_sync_out : out std_logic; -- vga control signal
         vert_sync_out  : out std_logic; -- vga control signal
         --
         addr_vga          : in std_logic_vector(12 downto 0);
         we                : in std_logic;
         wr_data           : in std_logic_vector(15 downto 0);
         rd_data           : out std_logic_vector(15 downto 0);
         byte_m            : in std_logic;
         vga_cursor        : in std_logic_vector(15 downto 0);  -- simplemente lo ignoramos, este controlador no lo tiene implementado
         vga_cursor_enable : in std_logic);                    -- simplemente lo ignoramos, este controlador no lo tiene implementado
	end COMPONENT;

	signal proc0_word_byte: std_logic;
	signal proc0_wr_m: std_logic;
	signal proc0_addr_m: std_logic_vector(15 downto 0);
	signal proc0_data_wr: std_logic_vector(15 downto 0);

	signal proc0_addr_io: std_logic_vector(7 downto 0);
	signal proc0_wr_io: std_logic_vector(15 downto 0);
	signal proc0_rd_io: std_logic_vector(15 downto 0);
	signal proc0_rd_in: std_logic;
	signal proc0_wr_out: std_logic;

	signal mc0_rd_data     : std_logic_vector(15 downto 0);
	signal mc0_vga_addr    : std_logic_vector(12 downto 0);
	signal mc0_vga_we      : std_logic;
	signal mc0_vga_wr_data : std_logic_vector(15 downto 0);
	signal mc0_vga_byte_m  : std_logic;

	signal vc0_vga_rd_data : std_logic_vector(15 downto 0);

	signal clock_625Mhz_signal: std_logic;

	signal boot: std_logic;

	signal vc0_red_out: std_logic_vector(7 downto 0);
	signal vc0_blue_out: std_logic_vector(7 downto 0);
	signal vc0_green_out: std_logic_vector(7 downto 0);

	signal io0_vga_cursor_enable: std_logic;
	signal io0_vga_cursor : std_logic_vector(15 downto 0);

BEGIN

	boot <= SW(9);

	clock_625Mhz: clock_t
		generic map(limits => 4)
		port map(
			CLOCK_IN => CLOCK_50,
			CLOCK_OUT => clock_625Mhz_signal
		);

	proc0: proc port map(
		clk => clock_625Mhz_signal,
		boot => boot,
		datard_m => mc0_rd_data,
		addr_m => proc0_addr_m,
		data_wr => proc0_data_wr,
		wr_m => proc0_wr_m,
		word_byte => proc0_word_byte,
		addr_io => proc0_addr_io,
		wr_io => proc0_wr_io,
		rd_io => proc0_rd_io,
		wr_out => proc0_wr_out,
		rd_in => proc0_rd_in
	);

	io0: controladores_IO port map(
		boot => boot,
		CLOCK_50 => CLOCK_50,
		addr_io => proc0_addr_io,
		wr_io => proc0_wr_io,
		rd_io => proc0_rd_io,
		wr_out => proc0_wr_out,
		rd_in => proc0_rd_in,
		led_verdes => LEDG,
		led_rojos => LEDR,
		HEX0 => HEX0,
		HEX1 => HEX1,
		HEX2 => HEX2,
		HEX3 => HEX3,
		SW => SW,
		KEY => KEY,
		ps2_clk => PS2_CLK,
		ps2_data => PS2_DAT,
		vga_cursor => io0_vga_cursor,
		vga_cursor_enable => io0_vga_cursor_enable
	);

	mc0: MemoryController port map(
		CLOCK_50 => CLOCK_50,
		-- señales para la placa de desarrollo
		SRAM_ADDR => SRAM_ADDR,
		SRAM_DQ => SRAM_DQ,
		SRAM_UB_N => SRAM_UB_N,
		SRAM_LB_N => SRAM_LB_N,
		SRAM_CE_N => SRAM_CE_N,
		SRAM_OE_N => SRAM_OE_N,
		SRAM_WE_N => SRAM_WE_N,
		-- señales internas del procesador
		addr => proc0_addr_m,
		wr_data => proc0_data_wr,
		rd_data => mc0_rd_data,
		we => proc0_wr_m,
		byte_m => proc0_word_byte,
		--VGA 
		vga_addr => mc0_vga_addr,
		vga_we => mc0_vga_we,
		vga_wr_data => mc0_vga_wr_data,
		vga_rd_data => vc0_vga_rd_data,
		vga_byte_m => mc0_vga_byte_m
	);
	
	vc0: vga_controller port map(
			clk_50mhz => CLOCK_50,
         reset => boot,
         red_out => vc0_red_out,
         green_out => vc0_green_out,
         blue_out => vc0_blue_out,
         horiz_sync_out => VGA_HS,
         vert_sync_out => VGA_VS,
         --
         addr_vga => mc0_vga_addr,
         we => mc0_vga_we,
         wr_data => mc0_vga_wr_data,
         rd_data => vc0_vga_rd_data,
         byte_m => mc0_vga_byte_m,
         vga_cursor => io0_vga_cursor,
         vga_cursor_enable => io0_vga_cursor_enable
	);

	VGA_R <= vc0_red_out(3 downto 0);
	VGA_G <= vc0_green_out(3 downto 0);
	VGA_B <= vc0_blue_out(3 downto 0);

END Structure;