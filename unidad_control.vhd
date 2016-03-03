LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY unidad_control IS
    PORT (boot   : IN  STD_LOGIC;
          clk    : IN  STD_LOGIC;
          ir     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op     : OUT STD_LOGIC;
          wrd    : OUT STD_LOGIC;
          addr_a : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          pc     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END unidad_control;

ARCHITECTURE Structure OF unidad_control IS

	 -- Aqui iria la declaracion de las entidades que vamos a usar
	 -- Usaremos la palabra reservada COMPONENT ...
	 -- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades
	 -- Aqui iria la definicion del program counter

	COMPONENT control_l IS
		 PORT (ir     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				 op     : OUT STD_LOGIC;
				 ldpc   : OUT STD_LOGIC;
				 wrd    : OUT STD_LOGIC;
				 addr_a : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				 addr_d : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				 immed  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;
	
	signal new_pc: std_logic_vector(15 downto 0);
	signal sel0: std_logic; --MUX selector {pc, pc + 2} HALT
	signal out0, out1: std_logic_vector(15 downto 0);
	 
BEGIN

	 -- Aqui iria la declaracion del "mapeo" (PORT MAP) de los nombres de las entradas/salidas de los componentes
	 -- En los esquemas de la documentacion a la instancia de la logica de control le hemos llamado c0
	 -- Aqui iria la definicion del comportamiento de la unidad de control y la gestion del PC
	 
	c0: control_l port map(
		ir => ir,
		op => op,
		ldpc => sel0,
		wrd => wrd,
		addr_a => addr_a,
		addr_d => addr_d,
		immed => immed
	);
	
	with not sel0 select
		out0 <=
			new_pc + 2 when '0',
			new_pc when '1',
			(others => '0') when others;
			
	with boot select
		out1 <=
			out0 when '0',
			X"C000" when '1',
			(others => '0') when others;
			
	process(clk)
	begin
		if rising_edge(clk) then
			new_pc <= out1;
		end if;
	end process;
	
	pc <= new_pc;

END Structure;