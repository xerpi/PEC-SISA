LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY proc IS
    PORT (clk       : IN  STD_LOGIC;
          boot      : IN  STD_LOGIC;
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          data_wr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC);
END proc;

ARCHITECTURE Structure OF proc IS

	-- Aqui iria la declaracion de las entidades que vamos a usar
	-- Usaremos la palabra reservada COMPONENT ...
	-- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades

	COMPONENT unidad_control IS
		 PORT (boot      : IN  STD_LOGIC;
				clk       : IN  STD_LOGIC;
				datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				op        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
				func      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				wrd       : OUT STD_LOGIC;
				addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				pc        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				ins_dad   : OUT STD_LOGIC;
				in_d      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
				immed_x2  : OUT STD_LOGIC;
				wr_m      : OUT STD_LOGIC;
				word_byte : OUT STD_LOGIC;
				alu_immed : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT datapath IS
		 PORT (clk      : IN  STD_LOGIC;
				op       : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
				func     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				wrd      : IN  STD_LOGIC;
				addr_a   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_b   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_d   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				immed    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				immed_x2 : IN  STD_LOGIC;
				datard_m : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				ins_dad  : IN  STD_LOGIC;
				pc       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				in_d     : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
				alu_immed: IN  STD_LOGIC;
				addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				data_wr  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;

	signal uc0_op: std_logic_vector(1 downto 0);
	signal uc0_func: std_logic_vector(2 downto 0);
	signal uc0_wrd: std_logic;
	signal uc0_addr_a: std_logic_vector(2 downto 0);
	signal uc0_addr_b: std_logic_vector(2 downto 0);
	signal uc0_addr_d: std_logic_vector(2 downto 0);
	signal uc0_immed: std_logic_vector(15 downto 0);
	signal uc0_pc: std_logic_vector(15 downto 0);
	signal uc0_ins_dad: std_logic;
	signal uc0_in_d: std_logic_vector(1 downto 0);
	signal uc0_immed_x2: std_logic;
	signal uc0_alu_immed: std_logic;

BEGIN

	-- Aqui iria la declaracion del "mapeo" (PORT MAP) de los nombres de las entradas/salidas de los componentes
	-- En los esquemas de la documentacion a la instancia del DATAPATH le hemos llamado e0 y a la de la unidad de control le hemos llamado c0

	uc0: unidad_control port map(
		boot => boot,
		clk => clk,
		datard_m => datard_m,
		op => uc0_op,
		func => uc0_func,
		wrd => uc0_wrd,
		addr_a => uc0_addr_a,
		addr_b => uc0_addr_b,
		addr_d => uc0_addr_d,
		immed => uc0_immed,
		pc => uc0_pc,
		ins_dad => uc0_ins_dad,
		in_d => uc0_in_d,
		immed_x2 => uc0_immed_x2,
		wr_m => wr_m,
		word_byte => word_byte,
		alu_immed => uc0_alu_immed
	);

	dp0: datapath port map(
		clk => clk,
		op => uc0_op,
		func => uc0_func,
		wrd => uc0_wrd,
		addr_a => uc0_addr_a,
		addr_b => uc0_addr_b,
		addr_d => uc0_addr_d,
		immed => uc0_immed,
		immed_x2 => uc0_immed_x2,
		datard_m => datard_m,
		ins_dad => uc0_ins_dad,
		pc => uc0_pc,
		in_d => uc0_in_d,
		addr_m => addr_m,
		data_wr => data_wr,
		alu_immed => uc0_alu_immed
	);

END Structure;
