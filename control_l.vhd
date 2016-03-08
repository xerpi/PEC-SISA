LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Work is a default library
use work.opcodes.all;

ENTITY control_l IS
    PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          ldpc      : OUT STD_LOGIC;
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC;
          immed_x2  : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC);
END control_l;

ARCHITECTURE Structure OF control_l IS
BEGIN

	-- Aqui iria la generacion de las senales de control del datapath

	op(0) <= ir(8);
	op(1) <= 
	
	op <= "00" when ir(15 downto 12)="0101" and ir(8)=0 else
			"01" when ir(15 downto 12)="0101" and ir(8)=1 else
			"10";

	with ir(15 downto 12)&ir(8) select
		op <= "00" when "01010",
		      "01" when "01011",
				"10" when others;
				
	with ir(15 downto 12) select
		ldpc <=
			'0' when SPECIAL, -- For now only HALT
			'1' when others;

	wrd <= '1';
	addr_a <= ir(11 downto 9);
	addr_d <= ir(11 downto 9);

      -- I guess this does the same as the below
      immed <= std_logic_vector(resize(signed(ir(7 downto 0)), immed'length));

	--with ir(7) select
	--	immed <=
	--		"00000000" & ir(7 downto 0) when '0',
	--		"11111111" & ir(7 downto 0) when '1',
	--		(others => '0') when others;

END Structure;
