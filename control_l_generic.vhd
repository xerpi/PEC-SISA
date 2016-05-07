LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Work is a default library
use work.opcodes.all;
use work.constants.all;

ENTITY control_l_generic IS
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
          alu_immed : OUT STD_LOGIC;
			--Exception requests
			exc_illegal_instr : OUT STD_LOGIC);
END control_l_generic;

ARCHITECTURE Structure OF control_l_generic IS
	-- immed sign extension
	signal se_six      : std_logic_vector(15 downto 0);
	signal se_eight    : std_logic_vector(15 downto 0);
	signal se_six_x2   : std_logic_vector(15 downto 0);
	signal se_eight_x2 : std_logic_vector(15 downto 0);

	signal decoder_out : std_logic_vector(19 downto 0);

	signal opcode: std_logic_vector(3 downto 0);

-- decoder_out format: name(num_bits)
-- legal_instr - addr_a_sel(1) - addr_b_sel(1) - op(2) - func_dec(3) - func_sel(2) - immed_sel(2) - wrd(1) - wr_m(1) - ldpc(1) - in_d(3) - word_byte(1) - alu_immed(1)

BEGIN
	-- Get opcode from instruction
	opcode <= ir(15 downto 12);

	-- immed sign extension
	se_eight <= std_logic_vector(resize(signed(ir(7 downto 0)), se_eight'length));
	se_six <= std_logic_vector(resize(signed(ir(5 downto 0)), se_six'length));
	se_six_x2 <= se_six(14 downto 0) & '0';
	se_eight_x2 <= se_eight(14 downto 0) & '0';

	with opcode select
		decoder_out <=
			--Arithmetic logic instructions
			legal_instruction & addr_a_8_dt_6  & addr_b_2_dt_0  & op_al_unit     & "XXX"           & func_sel_5_dt_3 & "XX"                 & wrd_allow & wr_m_deny  & ldpc_continue & in_d_alu    & 'X'         & alu_immed_alu   when ARIT_LOGIC,
			legal_instruction & addr_a_8_dt_6  & addr_b_2_dt_0  & op_cmp_unit    & "XXX"           & func_sel_5_dt_3 & "XX"                 & wrd_allow & wr_m_deny  & ldpc_continue & in_d_alu    & 'X'         & alu_immed_alu   when COMPARE,
			legal_instruction & addr_a_8_dt_6  & 'X'            & op_al_unit     & func_dec_sum    & func_sel_dec    & immed_sel_se_six     & wrd_allow & wr_m_deny  & ldpc_continue & in_d_alu    & 'X'         & alu_immed_immed when ADDI,
			legal_instruction & addr_a_8_dt_6  & 'X'            & op_al_unit     & func_dec_sum    & func_sel_dec    & immed_sel_se_six_x2  & wrd_allow & wr_m_deny  & ldpc_continue & in_d_mem    & word_byte_w & alu_immed_immed when LOAD,
			legal_instruction & addr_a_8_dt_6  & addr_b_11_dt_9 & op_al_unit     & func_dec_sum    & func_sel_dec    & immed_sel_se_six_x2  & wrd_deny  & wr_m_allow & ldpc_continue & "XXX"       & word_byte_w & alu_immed_immed when STORE,
			legal_instruction & addr_a_11_dt_9 & 'X'            & op_misc_unit   & func_dec_mov    & func_sel_dec    & immed_sel_se_eight   & wrd_allow & wr_m_deny  & ldpc_continue & in_d_alu    & 'X'         & alu_immed_immed when MOV, --MOVI by default
			legal_instruction & addr_a_8_dt_6  & addr_b_2_dt_0  & op_muldiv_unit & "XXX"           & func_sel_5_dt_3 & "XX"                 & wrd_allow & wr_m_deny  & ldpc_continue & in_d_alu    & 'X'         & alu_immed_alu   when MULT_DIV,

			--Memory instructions
			legal_instruction & addr_a_8_dt_6  & 'X'            & op_al_unit     & func_dec_sum    & func_sel_dec    & immed_sel_se_six     & wrd_allow & wr_m_deny  & ldpc_continue & in_d_mem    & word_byte_b & alu_immed_immed when LOAD_BYTE,
			legal_instruction & addr_a_8_dt_6  & addr_b_11_dt_9 & op_al_unit     & func_dec_sum    & func_sel_dec    & immed_sel_se_six     & wrd_deny  & wr_m_allow & ldpc_continue & "XXX"       & word_byte_b & alu_immed_immed when STORE_BYTE,

			--Jump/branch instructions
			legal_instruction & 'X'            & addr_b_11_dt_9 & op_misc_unit   & func_dec_mov    & func_sel_dec    & immed_sel_se_eight_x2 & wrd_deny & wr_m_deny  & ldpc_continue & "XXX"       & 'X'         & alu_immed_alu   when RELATIVE_JUMP,
			legal_instruction & addr_a_8_dt_6  & addr_b_11_dt_9 & op_misc_unit   & func_dec_mov    & func_sel_dec    & "XX"                  & wrd_deny & wr_m_deny  & ldpc_continue & in_d_new_pc & 'X'         & alu_immed_alu   when ABSOLUTE_JUMP, --not JAL by default (wrd_deny)

			--I/O instructions
			legal_instruction & 'X'            & addr_b_11_dt_9 & "XX"           & "XXX"           & "XX"            & immed_sel_se_eight    & wrd_deny & wr_m_deny  & ldpc_continue & in_d_io     & 'X'         & "X"             when IN_OUT,

			--Special instuctions
			legal_instruction & addr_a_8_dt_6  & 'X'            & op_misc_unit   & func_dec_pass_x & func_sel_dec    & "XX"                  & wrd_deny & wr_m_deny  & ldpc_continue & in_d_alu    & 'X'         & 'X'             when SPECIAL, -- HALT by default

			--Illegal (not implemented) instruction
			illegal_instruction & 'X'          & 'X'            & "XX"           & "XXX"           & "XX"            & "XX"                  & wrd_deny & wr_m_deny  & ldpc_continue & "XXX"       & 'X'         & 'X'             when others;


	op <= decoder_out(16 downto 15);

	with decoder_out(11 downto 10) select
		func <=
			ir(5 downto 3) when func_sel_5_dt_3,
			ir(2 downto 0) when func_sel_2_dt_0,
			decoder_out(14 downto 12) when func_sel_dec,
			(others => 'X') when others;
	ldpc <= decoder_out(5);
	wrd_gen <= decoder_out(7);

	with decoder_out(18) select
		addr_a <=
			ir(11 downto 9) when addr_a_11_dt_9,
			ir(8 downto 6) when addr_a_8_dt_6,
			(others => 'X') when others;

	with decoder_out(17) select
		addr_b <=
			ir(11 downto 9) when addr_b_11_dt_9,
			ir(2 downto 0) when addr_b_2_dt_0,
			(others => 'X') when others;

	addr_d <= ir(11 downto 9);

	with decoder_out(9 downto 8) select
		immed <=
			se_six when immed_sel_se_six,
			se_eight when immed_sel_se_eight,
			se_six_x2 when immed_sel_se_six_x2,
			se_eight_x2 when immed_sel_se_eight_x2,
			(others => 'X') when others;

	wr_m <= decoder_out(6);
	in_d <= decoder_out(4 downto 2);
	word_byte <= decoder_out(1);
	alu_immed <= decoder_out(0);

	exc_illegal_instr <= decoder_out(19);

END Structure;
