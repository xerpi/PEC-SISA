LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Work is a default library
use work.opcodes.all;
use work.constants.all;

ENTITY control_l_special IS
	    PORT (ir              : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		  ldpc_in         : IN STD_LOGIC;
		  ldpc_out        : OUT STD_LOGIC;
		  -- falta para cuando es un RDS | wrd_gen         : INOUT STD_LOGIC;
		  wrd_sys         : OUT STD_LOGIC;
		  sys_reg_special : OUT STD_LOGIC_VECTOR(2 downto 0));
END control_l_special;

ARCHITECTURE Structure OF control_l_special IS

	constant F_EI:     std_logic_vector(4 downto 0) := "00000";
	constant F_DI:     std_logic_vector(4 downto 0) := "00001";
	constant F_RETI:   std_logic_vector(4 downto 0) := "00100";
	constant F_GETIID: std_logic_vector(4 downto 0) := "01000";
	constant F_RDS:    std_logic_vector(4 downto 0) := "01100";
	constant F_WRS:    std_logic_vector(4 downto 0) := "10000";
	constant F_HALT:   std_logic_vector(4 downto 0) := "11111";

	signal func: std_logic_vector(4 downto 0);
	signal opcode: std_logic_vector(3 downto 0);


BEGIN
	-- Get func from instruction
	func <= ir(4 downto 0);
	-- Get opcode from instruction
	opcode <= ir(15 downto 12);

	ldpc_out <=
		ldpc_stop when func = F_HALT and opcode = SPECIAL else
		ldpc_in;

	with func select
		wrd_sys <=
			'1' when F_WRS,  --Only write to the system regile when WRS
			'0' when others;

	sys_reg_special <=
		special_ei when func = F_EI and opcode = SPECIAL else
		special_di when func = F_DI and opcode = SPECIAL else
		special_reti when func = F_RETI and opcode = SPECIAL else
		special_none;

END Structure;
