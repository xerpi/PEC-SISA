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
          word_byte : OUT STD_LOGIC;
		  -- ALU signals
          alu_immed : OUT STD_LOGIC;
		  alu_z     : IN STD_LOGIC;
		  -- Jump signals
		  rel_jmp_tkn : OUT STD_LOGIC;
		  abs_jmp_tkn : OUT STD_LOGIC);
END control_l;

ARCHITECTURE Structure OF control_l IS
	constant addr_a_11_dt_9      : std_logic := '1';
	constant addr_a_8_dt_6       : std_logic := '0';

	constant addr_b_2_dt_0       : std_logic := '1';
	constant addr_b_11_dt_9      : std_logic := '0';

	constant op_al_unit          : std_logic_vector(1 downto 0) := B"00"; --use ALU AL unit
	constant op_cmp_unit         : std_logic_vector(1 downto 0) := B"01"; --use ALU CMP unit
	constant op_misc_unit        : std_logic_vector(1 downto 0) := B"10"; --use ALU MISC unit
	constant op_muldiv_unit      : std_logic_vector(1 downto 0) := B"11"; --use ALU muldiv unit

	constant func_dec_mov        : std_logic_vector(2 downto 0) := B"000"; --MOVI
	constant func_dec_movh       : std_logic_vector(2 downto 0) := B"001"; --MOVHI
	constant func_dec_sum        : std_logic_vector(2 downto 0) := B"100"; --ALU ADD when memory instruction
	                                                                       -- or ADDI

	constant func_sel_dec        : std_logic_vector(1 downto 0) := B"00"; -- selects func decoded
	constant func_sel_5_dt_3     : std_logic_vector(1 downto 0) := B"01";
	constant func_sel_2_dt_0     : std_logic_vector(1 downto 0) := B"10";

	constant immed_sel_se_six      : std_logic_vector(1 downto 0) := B"00";
	constant immed_sel_se_eight    : std_logic_vector(1 downto 0) := B"01";
	constant immed_sel_se_six_x2   : std_logic_vector(1 downto 0) := B"10";
	constant immed_sel_se_eight_x2 : std_logic_vector(1 downto 0) := B"11";


	constant wrd_allow           : std_logic := '1';
	constant wrd_deny            : std_logic := '0';

	constant wr_m_allow         : std_logic := '1';
	constant wr_m_deny          : std_logic := '0';

	constant ldpc_continue       : std_logic := '1';
	constant ldpc_stop           : std_logic := '0';

	constant in_d_alu            : std_logic_vector(1 downto 0) := B"00"; --coming from ALU
	constant in_d_mem            : std_logic_vector(1 downto 0) := B"01"; --coming from MEM
	constant in_d_new_pc         : std_logic_vector(1 downto 0) := B"10"; --coming from new PC (only JAL)

	constant word_byte_b         : std_logic := '1'; -- when LDB/STB
	constant word_byte_w         : std_logic := '0'; -- when others

	constant alu_immed_immed     : std_logic := '1'; --select immed
	constant alu_immed_alu       : std_logic := '0'; -- select alu output

	-- immed sign extension
	signal se_six                : std_logic_vector(15 downto 0);
	signal se_eight              : std_logic_vector(15 downto 0);
	signal se_six_x2             : std_logic_vector(15 downto 0);
	signal se_eight_x2       : std_logic_vector(15 downto 0);

	signal decoder_out           : std_logic_vector(17 downto 0);

	signal opcode: std_logic_vector(3 downto 0);

	signal instr_rel_jmp: std_logic;
	signal instr_abs_jmp: std_logic;
	signal jal_selector : std_logic_vector(1 downto 0);

	function boolean_to_std_logic(bool: boolean) return std_logic is
	begin
		if bool then
			return '1';
		else
			return '0';
		end if;
	end function boolean_to_std_logic;

-- decoder_out format: name(num_bits)
-- addr_a_sel(1) - addr_b_sel(1) - op(2) - func_dec(3) - func_sel(2) - immed_sel(2) - wrd(1) - wr_m(1) - ldpc(1) - in_d(2) - word_byte(1) - alu_immed(1)


	signal agregate_in : std_logic_vector(4 downto 0);
BEGIN
	-- Get opcode from instruction
	opcode <= ir(15 downto 12);

	-- immed sign extension
	se_eight <= std_logic_vector(resize(signed(ir(7 downto 0)), se_eight'length));
	se_six <= std_logic_vector(resize(signed(ir(5 downto 0)), se_six'length));
	se_six_x2 <= se_six(14 downto 0) & '0';
	se_eight_x2 <= se_eight(14 downto 0) & '0';

	agregate_in <= opcode & ir(8);
	with agregate_in select
		decoder_out <=
			addr_a_8_dt_6  & addr_b_2_dt_0  & op_al_unit     & "XXX"         & func_sel_5_dt_3 & "XX"                 & wrd_allow & wr_m_deny  & ldpc_continue & in_d_alu    & 'X'         & alu_immed_alu when ARIT_LOGIC & '0' | ARIT_LOGIC & '1',
			addr_a_8_dt_6  & addr_b_2_dt_0  & op_cmp_unit    & "XXX"         & func_sel_5_dt_3 & "XX"                 & wrd_allow & wr_m_deny  & ldpc_continue & in_d_alu    & 'X'         & alu_immed_alu when COMPARE & '0' | COMPARE & '1',
			addr_a_8_dt_6  &      'X'       & op_al_unit     & func_dec_sum  & func_sel_dec    & immed_sel_se_six     & wrd_allow & wr_m_deny  & ldpc_continue & in_d_alu    & 'X'         & alu_immed_immed when ADDI & '0' | ADDI & '1',
			addr_a_8_dt_6  & 'X'            & op_al_unit     & func_dec_sum  & func_sel_dec    & immed_sel_se_six_x2  & wrd_allow & wr_m_deny  & ldpc_continue & in_d_mem    & word_byte_w & alu_immed_immed when LOAD & '0' | LOAD & '1',
			addr_a_8_dt_6  & addr_b_11_dt_9 & op_al_unit     & func_dec_sum  & func_sel_dec    & immed_sel_se_six_x2  & wrd_deny  & wr_m_allow & ldpc_continue & "XX"        & word_byte_w & alu_immed_immed when STORE & '0' | STORE & '1',
			'X'            & 'X'            & op_misc_unit   & func_dec_mov  & func_sel_dec    & immed_sel_se_eight   & wrd_allow & wr_m_deny  & ldpc_continue & in_d_alu    & 'X'         & alu_immed_immed when MOV & '0', --MOVI
			addr_a_11_dt_9 & 'X'            & op_misc_unit   & func_dec_movh & func_sel_dec    & immed_sel_se_eight   & wrd_allow & wr_m_deny  & ldpc_continue & in_d_alu    & 'X'         & alu_immed_immed when MOV & '1', --MOVHI
			addr_a_8_dt_6  & addr_b_2_dt_0  & op_muldiv_unit & "XXX"         & func_sel_5_dt_3 & "XX"                 & wrd_allow & wr_m_deny  & ldpc_continue & in_d_alu    & 'X'         & alu_immed_alu when MULT_DIV & '0' | MULT_DIV & '1',
			addr_a_8_dt_6  & 'X'            & op_al_unit     & func_dec_sum  & func_sel_dec    & immed_sel_se_six_x2  & wrd_allow & wr_m_deny  & ldpc_continue & in_d_mem    & word_byte_b & alu_immed_immed when LOAD_BYTE & '0' | LOAD_BYTE & '1',
			addr_a_8_dt_6  & addr_b_11_dt_9 & op_al_unit     & func_dec_sum  & func_sel_dec    & immed_sel_se_six_x2  & wrd_deny  & wr_m_allow & ldpc_continue & "XX"        & word_byte_b & alu_immed_immed when STORE_BYTE & '0' | STORE_BYTE & '1',


			'X'            & addr_b_11_dt_9 & op_misc_unit   & func_dec_mov  & func_sel_dec    & immed_sel_se_eight_x2 & wrd_deny & wr_m_deny  & ldpc_continue & "XX"        & 'X'         & alu_immed_alu when RELATIVE_JUMP & '0' | RELATIVE_JUMP & '1',
			addr_a_8_dt_6  & addr_b_11_dt_9 & op_misc_unit   & func_dec_mov  & func_sel_dec    & "XX"                  & wrd_deny & wr_m_deny  & ldpc_continue & in_d_new_pc & 'X'         & alu_immed_alu when ABSOLUTE_JUMP & '0' | ABSOLUTE_JUMP & '1',



			(others => 'X')  when others;



	op <= decoder_out(15 downto 14);

	with decoder_out(10 downto 9) select
		func <=
			ir(5 downto 3) when func_sel_5_dt_3,
			ir(2 downto 0) when func_sel_2_dt_0,
			decoder_out(13 downto 11) when func_sel_dec,
			(others => 'X') when others;
	ldpc <= decoder_out(4);
	--wrd <= decoder_out(6);

	with decoder_out(17) select
		addr_a <=
			ir(11 downto 9) when addr_a_11_dt_9,
			ir(8 downto 6) when addr_a_8_dt_6,
			(others => 'X') when others;

	with decoder_out(16) select
		addr_b <=
			ir(11 downto 9) when addr_b_11_dt_9,
			ir(2 downto 0) when addr_b_2_dt_0,
			(others => 'X') when others;

	addr_d <= ir(11 downto 9);

	with decoder_out(8 downto 7) select
		immed <=
			se_six when immed_sel_se_six,
			se_eight when immed_sel_se_eight,
			se_six_x2 when immed_sel_se_six_x2,
			se_eight_x2 when immed_sel_se_eight_x2,
			(others => 'X') when others;

	wr_m <= decoder_out(5);
	in_d <= decoder_out(3 downto 2);
	word_byte <= decoder_out(1);
	alu_immed <= decoder_out(0);


	instr_rel_jmp <= boolean_to_std_logic(opcode = RELATIVE_JUMP);
	instr_abs_jmp <= boolean_to_std_logic(opcode = ABSOLUTE_JUMP);

	jal_selector <= instr_abs_jmp & ir(2);
	with jal_selector select -- JAL
		wrd <=
			wrd_allow when "11",
			decoder_out(6) when others;


	rel_jmp_tkn <= instr_rel_jmp and (not (ir(8) xor alu_z));
	abs_jmp_tkn <= instr_abs_jmp and ((not (ir(0) xor alu_z)) or ir(1) or ir(2));

END Structure;
