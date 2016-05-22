LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Work is a default library
use work.opcodes.all;
use work.constants.all;

-- It forces func3 to MOVHI only when ir(8) is '1'
-- control_l_generic by default have MOV
ENTITY illegal_dec IS
	PORT (ir                : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		--Exception requests
		exc_illegal_instr : OUT STD_LOGIC);
END illegal_dec;

ARCHITECTURE Structure OF illegal_dec IS
	constant F_CMPLT: std_logic_vector(2 downto 0) := "000";
	constant F_CMPLE: std_logic_vector(2 downto 0) := "001";
	constant F_CMPEQ: std_logic_vector(2 downto 0) := "011";
	constant F_CMPLTU: std_logic_vector(2 downto 0) := "100";
	constant F_CMPLEU: std_logic_vector(2 downto 0) := "101";

	constant F_MUL:   std_logic_vector(2 downto 0) := "000";
	constant F_MULH:  std_logic_vector(2 downto 0) := "001";
	constant F_MULHU: std_logic_vector(2 downto 0) := "010";
	constant F_DIV:   std_logic_vector(2 downto 0) := "100";
	constant F_DIVU:  std_logic_vector(2 downto 0) := "101";

	constant F_JZ   : std_logic_vector(5 downto 0) := "000000";
	constant F_JNZ  : std_logic_vector(5 downto 0) := "000001";
	constant F_JMP  : std_logic_vector(5 downto 0) := "000011";
	constant F_JAL  : std_logic_vector(5 downto 0) := "000100";
	constant F_CALLS: std_logic_vector(5 downto 0) := "000111";


	constant F_EI:     std_logic_vector(5 downto 0) := "100000";
	constant F_DI:     std_logic_vector(5 downto 0) := "100001";
	constant F_RETI:   std_logic_vector(5 downto 0) := "100100";
	constant F_GETIID: std_logic_vector(5 downto 0) := "101000";
	constant F_RDS:    std_logic_vector(5 downto 0) := "101100";
	constant F_WRS:    std_logic_vector(5 downto 0) := "110000";
	constant F_WRPI:   std_logic_vector(5 downto 0) := "110100";
	constant F_WRVI:   std_logic_vector(5 downto 0) := "110101";
	constant F_WRPD:   std_logic_vector(5 downto 0) := "110110";
	constant F_WRVD:   std_logic_vector(5 downto 0) := "110111";
	constant F_FLUSH:  std_logic_vector(5 downto 0) := "111000";
	constant F_HALT:   std_logic_vector(5 downto 0) := "111111";

	signal opcode: std_logic_vector(3 downto 0);
	signal func3: std_logic_vector(2 downto 0);
	signal func6: std_logic_vector(5 downto 0);

BEGIN
	-- Get opcode from instruction
	opcode <= ir(15 downto 12);
	func3  <= ir(5 downto 3);
	func6  <= ir(5 downto 0);

	exc_illegal_instr <=
		'0' when (opcode = ARIT_LOGIC) else
		'0' when (opcode = COMPARE) and ((func3 = F_CMPLT)
	 	                                or (func3 = F_CMPLE)
					              or (func3 = F_CMPEQ)
					              or (func3 = F_CMPLTU)
					              or (func3 = F_CMPLEU)) else
		'0' when (opcode = ADDI) else
		'0' when (opcode = LOAD) else
		'0' when (opcode = STORE) else
		'0' when (opcode = MOV) else
		'0' when (opcode = RELATIVE_JUMP) else
		'0' when (opcode = IN_OUT) else
		'0' when (opcode = MULT_DIV) and ((func3 = F_MUL)
		                                 or (func3 = F_MULH)
							   or (func3 = F_MULHU)
							   or (func3 = F_DIV)
							   or (func3 = F_DIVU)) else
		'0' when (opcode = ABSOLUTE_JUMP) and ((func6 = F_JZ)
		                                      or (func6 = F_JNZ)
								  or (func6 = F_JMP)
								  or (func6 = F_JAL)
								  or (func6 = F_CALLS)) else
		'0' when (opcode = LOAD_BYTE) else
		'0' when (opcode = STORE_BYTE) else
		'0' when (opcode = SPECIAL) and ((func6 = F_EI)
      	                                 or (func6 = F_DI)
							   or (func6 = F_RETI)
							   or (func6 = F_GETIID)
							   or (func6 = F_RDS)
							   or (func6 = F_WRS)
							   or (func6 = F_WRPI)
							   or (func6 = F_WRVI)
							   or (func6 = F_WRPD)
							   or (func6 = F_WRVD)
							   or (func6 = F_FLUSH)
							   or (func6 = F_HALT)) else
		'1';

END Structure;
