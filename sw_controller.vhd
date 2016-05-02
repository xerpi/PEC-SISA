LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY sw_controller IS
	PORT (boot   : IN STD_LOGIC;
		clk       : IN STD_LOGIC;
		inta      : IN STD_LOGIC;
		intr      : OUT STD_LOGIC;
		switches  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		rd_switch : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END sw_controller;

ARCHITECTURE Structure OF sw_controller IS
	signal sw_buffer: std_logic_vector(7 downto 0) := (others => '0');
	signal intr_pending: std_logic := '0';
BEGIN

	process(clk)
	begin
		if rising_edge(clk) then
			if intr_pending = '1' and inta = '1' then
				intr_pending <= '0';
			end if;
			
			if switches /= sw_buffer and intr_pending = '0' then
				intr_pending <= '1';
				sw_buffer <= switches;
			end if;
		end if;
	end process;

	rd_switch <= sw_buffer;
	intr <= intr_pending;
	
END Structure;
