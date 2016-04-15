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
		led_rojos  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		HEX0       : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX1       : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX2       : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX3       : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		SW         : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		KEY        : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		ps2_clk    : inout std_logic;
		ps2_data   : inout std_logic);
END controladores_IO;

ARCHITECTURE Structure OF controladores_IO IS
	--type IO_PORTS_T is array (255 downto 0) of std_logic_vector(15 downto 0);
	type IO_PORTS_T is array (21 downto 0) of std_logic_vector(15 downto 0);
	signal io_ports: IO_PORTS_T := (others => (others => '0'));
	signal wr_out_new: std_logic;
	
	COMPONENT driver7Segmentos IS
		PORT( codigoCaracter : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			bitsCaracter : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			enable : in std_logic);
	END COMPONENT;
	
	COMPONENT keyboard_controller IS
		 PORT (clk        : in    STD_LOGIC;
				 reset      : in    STD_LOGIC;
				 ps2_clk    : inout STD_LOGIC;
				 ps2_data   : inout STD_LOGIC;
				 read_char  : out   STD_LOGIC_VECTOR (7 downto 0);
				 clear_char : in    STD_LOGIC;
				 data_ready : out   STD_LOGIC);
	END COMPONENT;
	
	signal kc0_read_char: std_logic_vector(7 downto 0);
	signal kc0_clear_char: std_logic;
	signal kc0_data_ready: std_logic;
	
BEGIN

	d0: driver7Segmentos port map(
		codigoCaracter => io_ports(10)(3 downto 0),
		bitsCaracter => HEX0,
		enable => io_ports(9)(0)
	);
	
	d1: driver7Segmentos port map(
		codigoCaracter => io_ports(10)(7 downto 4),
		bitsCaracter => HEX1,
		enable => io_ports(9)(1)
	);
	
	d2: driver7Segmentos port map(
		codigoCaracter => io_ports(10)(11 downto 8),
		bitsCaracter => HEX2,
		enable => io_ports(9)(2)
	);
	
	d3: driver7Segmentos port map(
		codigoCaracter => io_ports(10)(15 downto 12),
		bitsCaracter => HEX3,
		enable => io_ports(9)(3)
	);
	
	kc0: keyboard_controller port map(
		clk => CLOCK_50,
		reset => boot,
		ps2_clk => ps2_clk,
		ps2_data => ps2_data,
		read_char => kc0_read_char,
		clear_char => kc0_clear_char,
		data_ready => kc0_data_ready
	);
	
	with addr_io select
		wr_out_new <=
			'0' when X"07", --Prohibir escritura puerto 7
			wr_out when others;
	
	process(CLOCK_50)
	begin
		if rising_edge(CLOCK_50) then
			if wr_out_new = '1' then
				io_ports(to_integer(unsigned(addr_io))) <= wr_io;
			end if;
			--Inputs hardcoded
			io_ports(7)(3 downto 0) <= KEY;
			io_ports(8)(7 downto 0) <= SW(7 downto 0);
		end if;
	end process;

	with addr_io select
		rd_io <=
			"00000000" & kc0_read_char when X"0F",
			"000000000000000" & kc0_data_ready when X"10",
			io_ports(to_integer(unsigned(addr_io))) when others;

	kc0_clear_char <=
		'1' when addr_io = X"10" and wr_out_new = '1' else
		'0';

	--Outputs
	led_verdes <= io_ports(5)(7 downto 0);
	led_rojos <= io_ports(6)(7 downto 0);

END Structure;
