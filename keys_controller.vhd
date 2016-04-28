LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY keys_controller IS
	PORT (boot   : IN STD_LOGIC;
		clk       : IN STD_LOGIC;
		inta      : IN STD_LOGIC;
		intr      : OUT STD_LOGIC;
		keys      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		read_keys : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END keys_controller;

ARCHITECTURE Structure OF keys_controller IS
	signal keys_buffer: std_logic_vector(3 downto 0) := (others => '0');
	signal intr_pending: std_logic := '0';
BEGIN

	process(clk)
	begin
		if rising_edge(clk) then
			if intr_pending = '1' and inta = '1' then
				intr_pending <= '0';
			end if;
			
			if keys /= keys_buffer and intr_pending = '0' then
				intr_pending <= '1';
				keys_buffer <= keys;
			end if;
		end if;
	end process;

	read_keys <= keys_buffer;
	intr <= intr_pending;
	
END Structure;
