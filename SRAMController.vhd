library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity SRAMController is
    port (clk         : in    std_logic;
          SRAM_ADDR   : out   std_logic_vector(17 downto 0);
          SRAM_DQ     : inout std_logic_vector(15 downto 0);
          SRAM_UB_N   : out   std_logic;
          SRAM_LB_N   : out   std_logic;
          SRAM_CE_N   : out   std_logic := '1';
          SRAM_OE_N   : out   std_logic := '1';
          SRAM_WE_N   : out   std_logic := '1';
          address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
          dataReaded  : out   std_logic_vector(15 downto 0);
          dataToWrite : in    std_logic_vector(15 downto 0);
          WR          : in    std_logic;
          byte_m      : in    std_logic := '0');
end SRAMController;

architecture comportament of SRAMController is

	COMPONENT SM1 IS
		 PORT (
			  reset : IN STD_LOGIC := '0';
			  clk : IN STD_LOGIC;
			  WR : IN STD_LOGIC := '0';
			  byte_m : IN STD_LOGIC := '0';
			  lsb : IN STD_LOGIC := '0';
			  cont : IN STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
			  SRAM_UB_N : OUT STD_LOGIC;
			  SRAM_LB_N : OUT STD_LOGIC;
			  SRAM_CE_N : OUT STD_LOGIC;
			  SRAM_OE_N : OUT STD_LOGIC;
			  SRAM_WE_N : OUT STD_LOGIC
		 );
	END COMPONENT;

	signal byte_m_conc_address_0: std_logic_vector(1 downto 0);
	signal WR_conc_byte_m_conc_address_0: std_logic_vector(2 downto 0);
	--signal cont: std_logic_vector(2 downto 0) := (others => '0');
	signal cont: std_logic_vector(2 downto 0) := "100";

begin

	process(clk)
	begin
		if rising_edge(clk) then
			cont <= cont + 1;
		end if;
	end process;


	sm1_0: SM1 port map(
		reset => '0',
		clk => clk,
		WR => WR,
		byte_m => byte_m,
		lsb => address(0),
		cont => cont,
		SRAM_UB_N => SRAM_UB_N,
		SRAM_LB_N => SRAM_LB_N,
		SRAM_CE_N => SRAM_CE_N,
		SRAM_OE_N => SRAM_OE_N,
		SRAM_WE_N => SRAM_WE_N
	);

	SRAM_ADDR <= "000" & address(15 downto 1);

	WR_conc_byte_m_conc_address_0 <= WR & byte_m & address(0);

	with WR_conc_byte_m_conc_address_0 select
		SRAM_DQ <=
			"ZZZZZZZZ" & dataToWrite(7 downto 0) when "110",
			dataToWrite(7 downto 0) & "ZZZZZZZZ" when "111",
			dataToWrite when "100",
			dataToWrite when "101", --unaligned store!
			(others => 'Z') when others;


	byte_m_conc_address_0 <= byte_m & address(0);

	with byte_m_conc_address_0 select
		dataReaded <=
			std_logic_vector(resize(signed(SRAM_DQ(7 downto 0)), dataReaded'length)) when "10",
			std_logic_vector(resize(signed(SRAM_DQ(15 downto 8)), dataReaded'length)) when "11",
			SRAM_DQ when others;

end comportament;
