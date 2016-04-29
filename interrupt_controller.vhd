LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY interrupt_controller IS
	PORT (boot     : IN STD_LOGIC;
			clk         : IN STD_LOGIC;
			intr        : OUT STD_LOGIC;
			--Interrupt devices
			key_intr    : IN STD_LOGIC;
			ps2_intr    : IN STD_LOGIC;
			switch_intr : IN STD_LOGIC;
			timer_intr  : IN STD_LOGIC;
			inta        : IN STD_LOGIC;
			key_inta    : OUT STD_LOGIC;
			ps2_inta    : OUT STD_LOGIC;
			switch_inta : OUT STD_LOGIC;
			timer_inta  : OUT STD_LOGIC;
			iid         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END interrupt_controller;

ARCHITECTURE Structure OF interrupt_controller IS
	signal iid_buffer: std_logic_vector(3 downto 0) := (others => '0');
	signal intr_aggregate: std_logic_vector(3 downto 0);
	signal inta_aggregate: std_logic_vector(3 downto 0);
BEGIN

	intr_aggregate <= ps2_intr & switch_intr & key_intr & timer_intr;

	process(clk)
	begin
		if rising_edge(clk) then
			--Only keep the least significant bit set
			iid_buffer <= intr_aggregate and std_logic_vector(unsigned(not(intr_aggregate)) + 1);
		end if;
	end process;

	inta_aggregate <= (3 downto 0 => inta) and iid_buffer;

	timer_inta  <= inta_aggregate(0);
	key_inta    <= inta_aggregate(1);
	switch_inta <= inta_aggregate(2);
	ps2_inta    <= inta_aggregate(3);

	intr <= key_intr or ps2_intr or switch_intr or timer_intr;
	iid <= "0000" & iid_buffer;

END Structure;