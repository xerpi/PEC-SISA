LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

ENTITY clock_t IS	
	GENERIC ( limits : integer := 25_000_000
	        );
	PORT(CLOCK_IN : IN std_logic;
		  CLOCK_OUT : OUT std_logic
			);
END clock_t;

ARCHITECTURE Structure OF clock_t IS
	signal cont: integer := 1;
	signal tmp_out: std_logic := '0';
BEGIN

	process(CLOCK_IN)
	begin
		if rising_edge(CLOCK_IN) then
			if cont < limits then
				cont <= cont + 1;
			else
				cont <= 1;
				tmp_out <= not tmp_out;
			end if;
		end if;
	end process;
	
	CLOCK_OUT <= tmp_out;


END Structure; 