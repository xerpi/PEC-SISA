LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY controladores_IO IS
	PORT (boot       : IN STD_LOGIC;
		CLOCK_50   : IN STD_LOGIC;
		addr_io    : IN STD_LOGIC_VECTOR(7 downto 0);
		wr_io      : IN STD_LOGIC_VECTOR(15 downto 0);
		rd_io      : OUT STD_LOGIC_VECTOR(15 downto 0);
		wr_out     : IN STD_LOGIC;
		rd_in      : IN STD_LOGIC;
		led_verdes : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		led_rojos  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END controladores_IO;

ARCHITECTURE Structure OF controladores_IO IS
BEGIN

END Structure;
