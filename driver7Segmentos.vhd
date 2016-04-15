LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY driver7Segmentos IS
	PORT( codigoCaracter : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	bitsCaracter : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
	enable : in std_logic);
END driver7Segmentos;

ARCHITECTURE Structure OF driver7Segmentos IS
	signal bits: std_logic_vector(6 downto 0);
BEGIN
		with codigoCaracter select
			bits <=
				B"1000000" when "0000",
				B"1111001" when "0001",
				B"0100100" when "0010",
				B"0110000" when "0011",
				B"0011001" when "0100",
				B"0010010" when "0101",
				B"0000010" when "0110",
				B"1111000" when "0111",
				B"0000000" when "1000",
				B"0011000" when "1001",
				B"0001000" when "1010",
				B"0000011" when "1011",
				B"1000110" when "1100",
				B"0100001" when "1101",
				B"0000110" when "1110",
				B"0001110" when "1111",
				B"0111111" when others;
				
		with enable select
			bitsCaracter <=
				bits when '1',
				(others => '1') when others;
END Structure; 