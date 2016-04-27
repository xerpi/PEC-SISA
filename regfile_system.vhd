LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

use work.constants.all;

ENTITY regfile_system IS
    PORT (clk     : IN  STD_LOGIC;
          wrd     : IN  STD_LOGIC;
          d       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          special : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          --Interrupts enabled
          inten   : OUT STD_LOGIC);
END regfile_system;

ARCHITECTURE Structure OF regfile_system IS
	type REGISTERS_T is array (7 downto 0) of std_logic_vector(15 downto 0);
	--signal registers: REGISTERS_T := (others => X"C000"); use this to do a loop in gtkwave
	signal registers: REGISTERS_T := (others => (others => '0'));
BEGIN
	process(clk)
	begin
		if rising_edge(clk) then
			if wrd = '1' then
				registers(to_integer(unsigned(addr_d))) <= d;
			end if;
			if special = special_ei then
				registers(7)(1) <= '1';
			elsif special = special_di then
				registers(7)(1) <= '0';
			elsif special = special_reti then
				--wrd_sys should be 1
				--addr_a should be 1 (PC <- S1)
				registers(7) <= registers(0);
			elsif special = special_start_int then
				--wrd should be 0,
				--PCup will be passed in d,
				--addr_a should be 5 (PC <- S5)
				registers(0) <= registers(7); --restore status (S0 <- S7)
				registers(1) <= d;            --S1 <- PCup
				registers(2) <= X"000F";      --event is an interrupt (S2 <- 0x000F)
				registers(7)(1) <= '0';       --disable interrupts (S7<1> <- 0)
			end if;
		end if;
	end process;

	a <= registers(to_integer(unsigned(addr_a)));
	inten <= registers(7)(1);
END Structure;
