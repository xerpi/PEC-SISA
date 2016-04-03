LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY alu IS
    PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          op   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
          func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END alu;


ARCHITECTURE Structure OF alu IS
	signal op_out: std_logic_vector(15 downto 0);
	signal sum: std_logic_vector(15 downto 0);
BEGIN

	sum <= std_logic_vector(unsigned(x) + unsigned(y));

	-- Aqui iria la definicion del comportamiento de la ALU
	with op select
		w <=
			y when "00",
			y(7 downto 0) & x(7 downto 0) when "01",
			sum when "10",
			(others => '0') when others;


END Structure;
