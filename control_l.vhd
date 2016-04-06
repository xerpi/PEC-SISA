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
          in_d      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          immed_x2  : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
          alu_immed : OUT STD_LOGIC);
END control_l;

ARCHITECTURE Structure OF control_l IS
	constant F_JAL:   std_logic_vector(2 downto 0) := "100";

	signal opcode: std_logic_vector(3 downto 0);
	signal func_out: std_logic_vector(2 downto 0);

	signal agregate_in: std_logic_vector(4 downto 0);
	signal func_mov: std_logic_vector(2 downto 0);
	signal wrd_0: std_logic;
	signal opcode_func: std_logic_vector(6 downto 0);

BEGIN

	-- Aqui iria la generacion de las senales de control del datapath

	opcode <= ir(15 downto 12);

	with opcode select
		op <=
			"00" when ARIT_LOGIC | LOAD | LOAD_BYTE | STORE | STORE_BYTE,
			"01" when COMPARE,
			"10" when MOV,
			"11" when others; --MULT_DIV

	-- cambiar op

	agregate_in <= opcode & ir(8);

	with agregate_in select
		func_mov <=
			"000" when MOV & '0',
			"001" when MOV & '1',
			"000" when others;

	with opcode select
		func_out <=
			func_mov when MOV, --MOV and MOVHI
			"100" when LOAD | LOAD_BYTE | STORE | STORE_BYTE, --ALU ADD when memory instruction
			ir(2 downto 0) when ABSOLUTE_JUMP,
			ir(5 downto 3) when others;

	with opcode select
		ldpc <=
			'0' when SPECIAL, -- For now only HALT
			'1' when others;

	with opcode select
		wrd_0 <=
			'0' when
				STORE | STORE_BYTE | RELATIVE_JUMP | ABSOLUTE_JUMP | SPECIAL, --Only HALT of special
			'1' when
				others;

	opcode_func <= opcode & func_out;

	with opcode_func select
		wrd <=
			'1' when ABSOLUTE_JUMP & F_JAL, --enable regfile write permission when JAL
			wrd_0 when others;

	with opcode select
		addr_a <=
			ir(8 downto 6) when
				ARIT_LOGIC | COMPARE | ADDI | LOAD | STORE | MULT_DIV | ABSOLUTE_JUMP | LOAD_BYTE | STORE_BYTE | SPECIAL,
			ir(11 downto 9) when
				MOV,
			ir(11 downto 9) when others;

	with opcode select
		addr_b <=
			ir(2 downto 0) when
				ARIT_LOGIC | COMPARE | MULT_DIV,
			ir(11 downto 9) when
				STORE | RELATIVE_JUMP | IN_OUT | ABSOLUTE_JUMP | STORE_BYTE | SPECIAL,
			ir(11 downto 9) when others;

	addr_d <= ir(11 downto 9);

	with opcode select
		immed <=
			std_logic_vector(resize(signed(ir(7 downto 0)), immed'length)) when MOV,
			std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when LOAD,
			std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when STORE,
			std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when LOAD_BYTE,
			std_logic_vector(resize(signed(ir(5 downto 0)), immed'length)) when STORE_BYTE,
			(others => '0') when others;

	--immed <= std_logic_vector(resize(signed(ir(7 downto 0)), immed'length));

	with opcode select
		wr_m <=
			'1' when STORE,
			'1' when STORE_BYTE,
			'0' when others;

	with opcode select
		in_d <=
			"10" when ABSOLUTE_JUMP, --coming from new PC (only JAL)
			"01" when LOAD | LOAD_BYTE, --coming from MEM
			"00" when others; --coming from ALU

	with opcode select
		immed_x2 <=
			'1' when LOAD,
			'1' when STORE,
			'0' when others;

	with opcode select
		word_byte <=
			'1' when LOAD_BYTE,
			'1' when STORE_BYTE,
			'0' when others;

	with opcode select
		alu_immed <=
			'1' when
				ADDI | LOAD | STORE | MOV | LOAD_BYTE | STORE_BYTE | RELATIVE_JUMP,
			'0' when
				others;

	func <= func_out;

END Structure;
