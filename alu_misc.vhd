LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY alu_misc IS
    PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END alu_misc;

ARCHITECTURE Structure OF alu_misc IS
BEGIN
	-- Aqui iria la definicion del comportamiento de la ALU
	with func select
		w <=
			y when "000",
			y(7 downto 0) & x(7 downto 0) when "001",
			(others => '0') when others;
END Structure;
