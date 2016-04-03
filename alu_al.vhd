LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY alu_al IS
    PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END alu_al;

ARCHITECTURE Structure OF alu_al IS
	signal sum: std_logic_vector(15 downto 0);
BEGIN
	sum <= std_logic_vector(unsigned(x) + unsigned(y));

	w <= sum;
END Structure;
