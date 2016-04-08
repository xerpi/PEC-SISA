LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Work is a default library
use work.opcodes.all;
use work.constants.all;

ENTITY control_l IS
    PORT (ir            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		op          : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		func        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		ldpc        : OUT STD_LOGIC;
		wrd         : OUT STD_LOGIC;
		addr_a      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr_b      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr_d      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		immed       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		wr_m        : OUT STD_LOGIC;
		in_d        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		word_byte   : OUT STD_LOGIC;
		-- ALU signals
		alu_immed   : OUT STD_LOGIC;
		alu_z       : IN STD_LOGIC;
		-- Jump signals
		rel_jmp_tkn : OUT STD_LOGIC;
		abs_jmp_tkn : OUT STD_LOGIC);
END control_l;

ARCHITECTURE Structure OF control_l IS

	signal c0_g_op            : std_logic_vector(1 DOWNTO 0);
	signal c0_g_func          : std_logic_vector(2 DOWNTO 0);
	signal c0_g_ldpc          : std_logic;
	signal c0_g_wrd           : std_logic;
	signal c0_g_addr_a        : std_logic_vector(2 DOWNTO 0);
	signal c0_g_addr_b        : std_logic_vector(2 DOWNTO 0);
	signal c0_g_addr_d        : std_logic_vector(2 DOWNTO 0);
	signal c0_g_immed         : std_logic_vector(15 DOWNTO 0);
	signal c0_g_wr_m          : std_logic;
	signal c0_g_in_d          : std_logic_vector(1 DOWNTO 0);
	signal c0_g_word_byte     : std_logic;
	signal c0_g_alu_immed     : std_logic;

	signal c0_mov_func        : std_logic_vector(2 DOWNTO 0);

	signal c0_jmp_wrd         : std_logic;
	signal c0_jmp_rel_jmp_tkn : std_logic;
	signal c0_jmp_abs_jmp_tkn : std_logic;

	signal opcode             : std_logic_vector(3 downto 0);

	COMPONENT control_l_generic IS
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
			word_byte : OUT STD_LOGIC;
			alu_immed : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT control_l_mov IS
		PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			func_in   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			func_out  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
	END COMPONENT;

	COMPONENT control_l_jmp IS
		PORT (ir         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			alu_z      : IN STD_LOGIC;
			wrd_in     : IN STD_LOGIC;
			wrd_out    : OUT STD_LOGIC;
			rel_jmp_tkn: OUT STD_LOGIC;
			abs_jmp_tkn: OUT STD_LOGIC);
	END COMPONENT;


BEGIN
	opcode <= ir(15 downto 12);

	c0_g: control_l_generic port map(
		ir => ir,
		op => c0_g_op,
		func => c0_g_func,
		ldpc => c0_g_ldpc,
		wrd => c0_g_wrd,
		addr_a => c0_g_addr_a,
		addr_b => c0_g_addr_b,
		addr_d => c0_g_addr_d,
		immed => c0_g_immed,
		wr_m => c0_g_wr_m,
		in_d => c0_g_in_d,
		word_byte => c0_g_word_byte,
		alu_immed => c0_g_alu_immed
	);

	c0_mov: control_l_mov port map(
		ir => ir,
		func_in => c0_g_func,
		func_out => c0_mov_func
	);

	c0_jmp: control_l_jmp port map(
		ir => ir,
		wrd_in => c0_g_wrd,
		alu_z => alu_z,
		wrd_out => c0_jmp_wrd,
		rel_jmp_tkn => c0_jmp_rel_jmp_tkn,
		abs_jmp_tkn => c0_jmp_abs_jmp_tkn
	);


	op <= c0_g_op;
	ldpc <= c0_g_ldpc;
	addr_a <= c0_g_addr_a;
	addr_b <= c0_g_addr_b;
	addr_d <= c0_g_addr_d;
	immed <= c0_g_immed;
	wr_m <= c0_g_wr_m;
	in_d <= c0_g_in_d;
	word_byte <= c0_g_word_byte;
	alu_immed <= c0_g_alu_immed;

	func <= c0_mov_func;

	wrd <= c0_jmp_wrd;
	rel_jmp_tkn <= c0_jmp_rel_jmp_tkn;
	abs_jmp_tkn <= c0_jmp_abs_jmp_tkn;

END Structure;
