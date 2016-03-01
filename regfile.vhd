LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY regfile IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END regfile;


ARCHITECTURE Structure OF regfile IS
    -- Aqui iria la definicion de los registros
	type REGISTERS_T is array (7 downto 0) of std_logic_vector(15 downto 0);
	signal registers: REGISTERS_T := (others => (others => '0'));
BEGIN
    -- Aqui iria la definicion del comportamiento del banco de registros
    -- Os puede ser util usar la funcion "conv_integer" o "to_integer"
    -- Una buena (y limpia) implementacion no deberia ocupar más de 7 o 8 lineas
	 
	process(clk)
	begin
		if rising_edge(clk) then
			if wrd = '1' then
				registers(conv_integer(addr_d)) <= d;
			end if;
		end if;
	end process;
	
	a <= registers(conv_integer(addr_a));

END Structure;