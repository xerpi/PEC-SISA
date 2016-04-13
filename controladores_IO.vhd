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
	type IO_PORTS_T is array (255 downto 0) of std_logic_vector(15 downto 0);
	signal io_ports: IO_PORTS_T := (others => (others => '0'));
BEGIN
		io_ports(to_integer(unsigned(addr_io))) <= wr_io when rising_edge(wr_out);

		rd_io <= io_ports(to_integer(unsigned(addr_io)));

		led_verdes <= io_ports(5)(7 downto 0);
		led_rojos <= io_ports(6)(7 downto 0);

END Structure;
