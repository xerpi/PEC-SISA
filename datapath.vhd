LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY datapath IS
    PORT (clk    : IN STD_LOGIC;
          op     : IN STD_LOGIC;
          wrd    : IN STD_LOGIC;
          addr_a : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed  : IN STD_LOGIC_VECTOR(15 DOWNTO 0));
END datapath;


ARCHITECTURE Structure OF datapath IS

	 -- Aqui iria la declaracion de las entidades que vamos a usar
	 -- Usaremos la palabra reservada COMPONENT ...
	 -- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades

	COMPONENT regfile IS
		 PORT (clk    : IN  STD_LOGIC;
				 wrd    : IN  STD_LOGIC;
				 d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				 addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				 addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				 a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;

	COMPONENT alu IS
		 PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				 y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				 op : IN  STD_LOGIC;
				 w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;

	signal alu_w: std_logic_vector(15 downto 0);
	signal regfile_a: std_logic_vector(15 downto 0);

BEGIN

	 -- Aqui iria la declaracion del "mapeo" (PORT MAP) de los nombres de las entradas/salidas de los componentes
	 -- En los esquemas de la documentacion a la instancia del banco de registros le hemos llamado reg0 y a la de la alu le hemos llamado alu0

	reg0: regfile port map(
		clk    => clk,
		wrd    => wrd,
		d      => alu_w,
		addr_a => addr_a,
		addr_d => addr_d,
		a      => regfile_a
	);

	alu0: alu port map(
		x  => regfile_a,
		y  => immed,
		op => op,
		w  => alu_w
	);

END Structure;
