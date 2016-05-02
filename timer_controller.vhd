LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY timer_controller IS
	PORT (boot   : IN STD_LOGIC;
		clk       : IN STD_LOGIC;
		inta      : IN STD_LOGIC;
		intr      : OUT STD_LOGIC);
END timer_controller;

ARCHITECTURE Structure OF timer_controller IS

	COMPONENT clock_t IS
		GENERIC(limits : integer := 25000000);
		PORT(CLOCK_IN : IN std_logic;
			CLOCK_OUT : OUT std_logic);
	END COMPONENT;

	signal clock_20hz_signal: std_logic;
	signal intr_pending: std_logic := '0';
BEGIN

	clock_20hz: clock_t
		generic map(limits => 1250000)
		port map(
			CLOCK_IN => clk,
			CLOCK_OUT => clock_20hz_signal
		);

	process(clk)
	begin
		if rising_edge(clock_20hz_signal) then
			intr_pending <= '1';
		end if;
		
		if intr_pending = '1' and inta = '1' then
				intr_pending <= '0';
		end if;
	end process;

	intr <= intr_pending;
	
END Structure;
