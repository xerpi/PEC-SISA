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
		wrd_gen     : OUT STD_LOGIC;
		wrd_sys     : OUT STD_LOGIC;
		addr_a      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr_b      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr_d      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		immed       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		wr_m        : OUT STD_LOGIC;
		in_d        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		word_byte   : OUT STD_LOGIC;
		-- ALU signals
		alu_immed   : OUT STD_LOGIC;
		alu_z       : IN STD_LOGIC;
		-- Jump signals
		rel_jmp_tkn : OUT STD_LOGIC;
		abs_jmp_tkn : OUT STD_LOGIC;
		-- I/O signals
		wr_out      : OUT STD_LOGIC;
		rd_in       : OUT STD_LOGIC;
		-- Selects General/System regfile
		a_sys       : OUT STD_LOGIC;
		--Special operation to perform in the system regfile
		special     : OUT STD_LOGIC_VECTOR(2 downto 0);
		--Interrupt ack
		inta      : OUT STD_LOGIC;
		--Exception requests
		exc_illegal_instr : OUT STD_LOGIC;
		--Protected instruction
		protected_instr: OUT STD_LOGIC;
		calls_instr : OUT STD_LOGIC;
		TLB_flush   : OUT STD_LOGIC;
		ITLB_wr   : OUT STD_LOGIC;
		DTLB_wr   : OUT STD_LOGIC;
		TLB_phys  : OUT STD_LOGIC);
END control_l;

ARCHITECTURE Structure OF control_l IS

	signal c0_g_op            : std_logic_vector(1 DOWNTO 0);
	signal c0_g_func          : std_logic_vector(2 DOWNTO 0);
	signal c0_g_ldpc          : std_logic;
	signal c0_g_wrd_gen       : std_logic;
	signal c0_g_addr_a        : std_logic_vector(2 DOWNTO 0);
	signal c0_g_addr_b        : std_logic_vector(2 DOWNTO 0);
	signal c0_g_addr_d        : std_logic_vector(2 DOWNTO 0);
	signal c0_g_immed         : std_logic_vector(15 DOWNTO 0);
	signal c0_g_wr_m          : std_logic;
	signal c0_g_in_d          : std_logic_vector(2 DOWNTO 0);
	signal c0_g_word_byte     : std_logic;
	signal c0_g_alu_immed     : std_logic;

	signal c0_mov_func        : std_logic_vector(2 DOWNTO 0);

	signal c0_jmp_wrd_gen     : std_logic;
	signal c0_jmp_rel_jmp_tkn : std_logic;
	signal c0_jmp_abs_jmp_tkn : std_logic;
	signal c0_jmp_func        : std_logic_vector(2 DOWNTO 0);
	signal c0_jmp_in_d        : std_logic_vector(2 DOWNTO 0);

	signal c0_io_wrd_gen      : std_logic;
	signal c0_io_wr_out       : std_logic;
	signal c0_io_rd_in        : std_logic;
	signal c0_io_protected_io_instr : std_logic;

	signal c0_special_ldpc    : std_logic;
	signal c0_special_wrd_sys : std_logic;
	signal c0_special_special : std_logic_vector(2 downto 0);
	signal c0_special_addr_a  : std_logic_vector(2 downto 0);
	signal c0_special_abs_jmp_tkn : std_logic;
	signal c0_special_wrd_gen : std_logic;
	signal c0_special_in_d    : std_logic_vector(2 downto 0);
	signal c0_special_protected_special_instr : std_logic;

	signal opcode             : std_logic_vector(3 downto 0);

	COMPONENT control_l_generic IS
		PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			op        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			func      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			ldpc      : OUT STD_LOGIC;
			wrd_gen   : OUT STD_LOGIC;
			addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			wr_m      : OUT STD_LOGIC;
			in_d      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			word_byte : OUT STD_LOGIC;
			alu_immed : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT control_l_mov IS
		PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			func_in   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			func_out  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
	END COMPONENT;

	COMPONENT control_l_jmp IS
	    PORT (
		ir         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		alu_z      : IN STD_LOGIC;
		wrd_gen_in     : IN STD_LOGIC;
		wrd_gen_out    : OUT STD_LOGIC;
		rel_jmp_tkn: OUT STD_LOGIC;
		abs_jmp_tkn: OUT STD_LOGIC;
		calls_instr : OUT STD_LOGIC;
		func_in   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		func_out  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		in_d_in         : IN STD_LOGIC_VECTOR(2 downto 0);
		in_d_out        : OUT STD_LOGIC_VECTOR(2 downto 0));
	END COMPONENT;

	COMPONENT control_l_io IS
	    PORT (ir         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		  wrd_gen_in     : IN STD_LOGIC;
		  wrd_gen_out    : OUT STD_LOGIC;
		  wr_out     : OUT STD_LOGIC;
		  rd_in      : OUT STD_LOGIC;
		  	--Protected I/O instruction
			protected_io_instr: OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT control_l_special IS
	    PORT (ir              : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		  ldpc_in         : IN STD_LOGIC;
		  ldpc_out        : OUT STD_LOGIC;
		  addr_a_in       : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		  addr_a_out      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		  abs_jmp_tkn_in  : IN STD_LOGIC;
		  abs_jmp_tkn_out : OUT STD_LOGIC;
		  wrd_gen_in         : IN STD_LOGIC;
		  wrd_gen_out         : OUT STD_LOGIC;
		  wrd_sys         : OUT STD_LOGIC;
		  sys_reg_special : OUT STD_LOGIC_VECTOR(2 downto 0);
		  a_sys           : OUT STD_LOGIC;
		  in_d_in         : IN STD_LOGIC_VECTOR(2 downto 0);
		  in_d_out        : OUT STD_LOGIC_VECTOR(2 downto 0);
		   --Interrupt ack
		   inta      : OUT STD_LOGIC;
			--Protected special instruction
			protected_special_instr: OUT STD_LOGIC;
			TLB_flush : OUT STD_LOGIC;
			ITLB_wr   : OUT STD_LOGIC;
			DTLB_wr   : OUT STD_LOGIC;
			TLB_phys  : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT illegal_dec IS
		PORT (ir                : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			--Exception requests
			exc_illegal_instr : OUT STD_LOGIC);
	END COMPONENT;


BEGIN
	opcode <= ir(15 downto 12);

	c0_g: control_l_generic port map(
		ir => ir,
		op => c0_g_op,
		func => c0_g_func,
		ldpc => c0_g_ldpc,
		wrd_gen => c0_g_wrd_gen,
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
		wrd_gen_in => c0_g_wrd_gen,
		alu_z => alu_z,
		wrd_gen_out => c0_jmp_wrd_gen,
		rel_jmp_tkn => c0_jmp_rel_jmp_tkn,
		abs_jmp_tkn => c0_jmp_abs_jmp_tkn,
		calls_instr => calls_instr,
		func_in     => c0_mov_func,
		func_out    => c0_jmp_func,
		in_d_in     => c0_g_in_d,
		in_d_out    => c0_jmp_in_d
	);

	c0_io: control_l_io port map(
		ir => ir,
		wrd_gen_in => c0_jmp_wrd_gen,
		wrd_gen_out => c0_io_wrd_gen,
		wr_out => c0_io_wr_out,
		rd_in => c0_io_rd_in,
		protected_io_instr => c0_io_protected_io_instr
	);

	c0_special: control_l_special port map(
		ir => ir,
		ldpc_in => c0_g_ldpc,
		ldpc_out => c0_special_ldpc,
		addr_a_in => c0_g_addr_a,
		addr_a_out => c0_special_addr_a,
		abs_jmp_tkn_in => c0_jmp_abs_jmp_tkn,
		abs_jmp_tkn_out => c0_special_abs_jmp_tkn,
		wrd_gen_in => c0_io_wrd_gen,
		wrd_gen_out => c0_special_wrd_gen,
		wrd_sys => c0_special_wrd_sys,
		sys_reg_special => c0_special_special,
		a_sys => a_sys,
		in_d_in => c0_jmp_in_d,
		in_d_out => c0_special_in_d,
		inta => inta,
		protected_special_instr => c0_special_protected_special_instr,
		TLB_flush => TLB_flush,
		ITLB_wr   => ITLB_wr,
		DTLB_wr   => DTLB_wr,
		TLB_phys  => TLB_phys
	);

	il_d0: illegal_dec port map(
		ir => ir,
		exc_illegal_instr => exc_illegal_instr
	);

	op <= c0_g_op;

	ldpc <= c0_special_ldpc;

	addr_a <= c0_special_addr_a;
	addr_b <= c0_g_addr_b;
	addr_d <= c0_g_addr_d;
	immed <= c0_g_immed;
	wr_m <= c0_g_wr_m;
	in_d <= c0_special_in_d;
	word_byte <= c0_g_word_byte;
	alu_immed <= c0_g_alu_immed;

	func <= c0_jmp_func;

	wrd_gen <= c0_special_wrd_gen;
	wrd_sys <= c0_special_wrd_sys;
	special <= c0_special_special;
	rel_jmp_tkn <= c0_jmp_rel_jmp_tkn;
	abs_jmp_tkn <= c0_special_abs_jmp_tkn;

	wr_out <= c0_io_wr_out;
	rd_in <= c0_io_rd_in;

	protected_instr <=
		'1' when c0_special_protected_special_instr = '1' else
		--'1' when c0_io_protected_io_instr = '1' else
		'0';

END Structure;
