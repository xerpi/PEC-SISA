library ieee;
use ieee.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;

entity MemoryController is
    port (CLOCK_50  : in  std_logic;
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
			vga_byte_m  : out std_logic;
			--Unaligned access
			unaligned_access : out std_logic);
end MemoryController;

architecture comportament of MemoryController is

	COMPONENT SRAMController is
		 port (clk         : in    std_logic;
			-- señales para la placa de desarrollo
			SRAM_ADDR   : out   std_logic_vector(17 downto 0);
			SRAM_DQ     : inout std_logic_vector(15 downto 0);
			SRAM_UB_N   : out   std_logic;
			SRAM_LB_N   : out   std_logic;
			SRAM_CE_N   : out   std_logic := '1';
			SRAM_OE_N   : out   std_logic := '1';
			SRAM_WE_N   : out   std_logic := '1';
			-- señales internas del procesador
			address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
			dataReaded  : out   std_logic_vector(15 downto 0);
			dataToWrite : in    std_logic_vector(15 downto 0);
			WR          : in    std_logic;
			byte_m      : in    std_logic := '0');
	end COMPONENT;

	signal we_sram: std_logic;
	signal sc0_dataReaded : std_logic_vector(15 downto 0);

begin

	sc0: SRAMController port map(
		clk => CLOCK_50,
		-- señales para la placa de desarrollo
		SRAM_ADDR => SRAM_ADDR,
		SRAM_DQ => SRAM_DQ,
		SRAM_UB_N => SRAM_UB_N,
		SRAM_LB_N => SRAM_LB_N,
		SRAM_CE_N => SRAM_CE_N,
		SRAM_OE_N => SRAM_OE_N,
		SRAM_WE_N => SRAM_WE_N,
		-- señales internas del procesador
		address => addr,
		dataReaded => sc0_dataReaded,
		dataToWrite => wr_data,
		WR => we_sram,
		byte_m => byte_m
	);

	we_sram <=
		'0' when addr >= X"C000" else --Disable writes to program code
		'0' when addr >= X"A000" else --VGA RAM
		we;

	vga_we <=
		'1' when addr >= X"A000" and addr < X"C000" and we = '1' else --VGA RAM
		'0';

	rd_data <=
		vga_rd_data when addr >= X"A000" and addr < X"C000" else --VGA RAM
		sc0_dataReaded;

	vga_addr <= addr(12 downto 0);
	vga_wr_data <= wr_data;
	vga_byte_m <= byte_m;

	unaligned_access <= addr(0) and not byte_m;

	--with addr >= X"C000" select
	--	we_sram <= '0' when true,
	--		we when others;

end comportament;
