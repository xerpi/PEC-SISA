LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Work is a default library
use work.opcodes.all;
use work.constants.all;

-- It modifies wrd when JAL. Also does Tkn_jmp mux selection
ENTITY control_l_jmp IS
    PORT (ir         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    	    alu_z      : IN STD_LOGIC;
            wrd_gen_in     : IN STD_LOGIC;
            wrd_gen_out    : OUT STD_LOGIC;
            rel_jmp_tkn: OUT STD_LOGIC;
            abs_jmp_tkn: OUT STD_LOGIC;
				calls_instr : OUT STD_LOGIC);
END control_l_jmp;

ARCHITECTURE Structure OF control_l_jmp IS
	
	constant F_CALLS: std_logic_vector(2 downto 0) := "111";


	signal opcode: std_logic_vector(3 downto 0);
	signal func: std_logic_vector(2 downto 0);

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

BEGIN

	opcode <= ir(15 downto 12);
	func <= ir(2 downto 0);


	instr_rel_jmp <= boolean_to_std_logic(opcode = RELATIVE_JUMP);
	instr_abs_jmp <= boolean_to_std_logic(opcode = ABSOLUTE_JUMP);

	jal_selector <= instr_abs_jmp & ir(2);
	with jal_selector select -- JAL
		wrd_gen_out <=
			wrd_allow when "11",
			wrd_gen_in when others;
			
	
	calls_instr <=
		'1' when (func = F_CALLS) and (opcode = ABSOLUTE_JUMP) else
		'0';

	rel_jmp_tkn <= instr_rel_jmp and (ir(8) xor alu_z);
	abs_jmp_tkn <= instr_abs_jmp and ((ir(0) xor alu_z) or ir(1) or ir(2));

END Structure;
