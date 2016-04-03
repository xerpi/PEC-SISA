LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Work is a default library
use work.opcodes.all;

ENTITY control_l IS
    PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          func      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
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

signal agregate_in: std_logic_vector(4 downto 0);

BEGIN

	-- Aqui iria la generacion de las senales de control del datapath

	-- vhdl no deja hacer with de concatenacion?
	agregate_in <= ir(15 downto 12) & ir(8);
	with agregate_in select
		op <=
			"00" when MOV & '0',
			"01" when MOV & '1',
			"10" when others;

	with ir(15 downto 12) select
		ldpc <=
			'0' when SPECIAL, -- For now only HALT
			'1' when others;

	with ir(15 downto 12) select
		wrd <=
			'1' when LOAD,
			'1' when LOAD_BYTE,
			'1' when MOV,
			'0' when others;

	with ir(15 downto 12) select
		addr_a <=
			ir(8 downto 6) when LOAD,
			ir(8 downto 6) when STORE,
			ir(8 downto 6) when LOAD_BYTE,
			ir(8 downto 6) when STORE_BYTE,
			ir(11 downto 9) when others;

	addr_b <= ir(11 downto 9);
	addr_d <= ir(11 downto 9);


	with ir(15 downto 12) select
		immed <=
			std_logic_vector(resize(signed(ir(7 downto 0)), immed'length)) when MOV,
			std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when LOAD,
			std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when STORE,
			std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when LOAD_BYTE,
			std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when STORE_BYTE,
			(others => '0') when others;

	--immed <= std_logic_vector(resize(signed(ir(7 downto 0)), immed'length));

	with ir(15 downto 12) select
		wr_m <=
			'1' when STORE,
			'1' when STORE_BYTE,
			'0' when others;

	with ir(15 downto 12) select
		in_d <=
			'1' when LOAD,
			'1' when LOAD_BYTE,
			'0' when others;


	with ir(15 downto 12) select
		immed_x2 <=
			'1' when LOAD,
			'1' when STORE,
			'0' when others;

	with ir(15 downto 12) select
		word_byte <=
			'1' when LOAD_BYTE,
			'1' when STORE_BYTE,
			'0' when others;

END Structure;
