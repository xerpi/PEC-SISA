LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Work is a default library
use work.opcodes.all;
use work.constants.all;

-- It forces func to MOVHI only when ir(8) is '1'
-- control_l_generic by default have MOV
ENTITY control_l_mov IS
    PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    	    func_in   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          func_out  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END control_l_mov;

ARCHITECTURE Structure OF control_l_mov IS
	signal opcode: std_logic_vector(3 downto 0);
	signal agregate_in: std_logic_vector(4 downto 0);

BEGIN
	-- Get opcode from instruction
	opcode <= ir(15 downto 12);
	agregate_in <= opcode & ir(8);

	with agregate_in select
		func_out <=
			func_dec_movh when MOV & '1', -- MOVHI
			func_in when others;

END Structure;
