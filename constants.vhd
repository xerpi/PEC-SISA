library IEEE;
use IEEE.std_logic_1164.all;

package constants is
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
	constant in_d_io             : std_logic_vector(1 downto 0) := B"11"; --coming from I/O port IN

	constant word_byte_b         : std_logic := '1'; -- when LDB/STB
	constant word_byte_w         : std_logic := '0'; -- when others

	constant alu_immed_immed     : std_logic := '1'; --select immed
	constant alu_immed_alu       : std_logic := '0'; -- select alu output

end constants;
