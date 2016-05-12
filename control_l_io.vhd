LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- Work is a default library
use work.opcodes.all;
use work.constants.all;

-- It modifies wrd when IN
ENTITY control_l_io IS
    PORT (ir         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	wrd_gen_in     : IN STD_LOGIC;
	wrd_gen_out    : OUT STD_LOGIC;
	wr_out     : OUT STD_LOGIC;
	rd_in      : OUT STD_LOGIC;
		  	--Protected I/O instruction
			protected_io_instr: OUT STD_LOGIC);
END control_l_io;

ARCHITECTURE Structure OF control_l_io IS

	signal opcode_f_aggregate: std_logic_vector(4 downto 0);

BEGIN

	opcode_f_aggregate <= ir(15 downto 12) & ir(8);

	with opcode_f_aggregate select
		wrd_gen_out <=
			'1' when IN_OUT & '0', --IN escribe en Rd
			wrd_gen_in when others;    --OUT

	with opcode_f_aggregate select
		wr_out <=
			'1' when IN_OUT & '1', --OUT escribe en los puertos I/O
			'0' when others;       --IN

	rd_in <= '0'; --PDF: "indica si estamos leyendo un puerto (... que por ahora no implementaremos)"

	protected_io_instr <=
		'1' when ir(15 downto 12) = IN_OUT else
		'0';
	
END Structure;
