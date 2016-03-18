LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY sisa IS
    PORT (CLOCK_50  : IN    STD_LOGIC;
          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic := '1';
          SRAM_OE_N : out   std_logic := '1';
          SRAM_WE_N : out   std_logic := '1';
          SW        : in std_logic_vector(9 downto 9));
END sisa;

ARCHITECTURE Structure OF sisa IS

	COMPONENT clock_t IS	
		GENERIC ( limits : integer := 25000000
				  );
		PORT(CLOCK_IN : IN std_logic;
			  CLOCK_OUT : OUT std_logic
				);
	END COMPONENT;

	COMPONENT proc IS
		 PORT (clk       : IN  STD_LOGIC;
				 boot      : IN  STD_LOGIC;
				 datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				 addr_m    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				 data_wr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				 wr_m      : OUT STD_LOGIC;
				 word_byte : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT MemoryController is
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
				 SRAM_WE_N : out   std_logic := '1');
	end COMPONENT;

	signal proc0_word_byte: std_logic;
	signal proc0_wr_m: std_logic;
	signal proc0_addr_m: std_logic_vector(15 downto 0);
	signal proc0_data_wr: std_logic_vector(15 downto 0);
	
	signal MemoryController0_rd_data: std_logic_vector(15 downto 0);
	
	signal clock_625Mhz_signal: std_logic;
	
	signal boot: std_logic;

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
		datard_m => MemoryController0_rd_data,
		addr_m => proc0_addr_m,
		data_wr => proc0_data_wr,
		wr_m => proc0_wr_m,
		word_byte => proc0_word_byte
	);

	MemoryController0: MemoryController port map(
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
		rd_data => MemoryController0_rd_data,
		we => proc0_wr_m,
		byte_m => proc0_word_byte
	);


END Structure;