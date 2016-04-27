LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY regfile_general IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END regfile_general;

ARCHITECTURE Structure OF regfile_general IS
	type REGISTERS_T is array (7 downto 0) of std_logic_vector(15 downto 0);
	signal registers: REGISTERS_T := (others => (others => '0'));
BEGIN
	process(clk)
	begin
		if rising_edge(clk) then
			if wrd = '1' then
				registers(to_integer(unsigned(addr_d))) <= d;
			end if;
		end if;
	end process;

	a <= registers(to_integer(unsigned(addr_a)));
	b <= registers(to_integer(unsigned(addr_b)));
END Structure;
