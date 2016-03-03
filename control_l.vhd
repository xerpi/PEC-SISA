LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY control_l IS
    PORT (ir     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op     : OUT STD_LOGIC;
          ldpc   : OUT STD_LOGIC;
          wrd    : OUT STD_LOGIC;
          addr_a : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END control_l;


ARCHITECTURE Structure OF control_l IS
BEGIN

	-- Aqui iria la generacion de las senales de control del datapath

	op <= ir(8);
	
	with ir(15 downto 12) select
		ldpc <=
			'0' when "1111",
			'1' when others;
			
	wrd <= '1';
	addr_a <= ir(11 downto 9);
	addr_d <= ir(11 downto 9);
	
	with ir(7) select
		immed <=
			"00000000" & ir(7 downto 0) when '0',
			"11111111" & ir(7 downto 0) when '1',
			(others => '0') when others;
	 
END Structure;