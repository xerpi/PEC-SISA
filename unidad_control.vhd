LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY unidad_control IS
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
          in_d      : OUT STD_LOGIC;
          immed_x2  : OUT STD_LOGIC;
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC);
END unidad_control;

ARCHITECTURE Structure OF unidad_control IS

	 -- Aqui iria la declaracion de las entidades que vamos a usar
	 -- Usaremos la palabra reservada COMPONENT ...
	 -- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades
	 -- Aqui iria la definicion del program counter

	COMPONENT control_l IS
		 PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				op        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
				func      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				ldpc      : OUT STD_LOGIC;
				wrd       : OUT STD_LOGIC;
				addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
				immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				wr_m      : OUT STD_LOGIC;
				in_d      : OUT STD_LOGIC;
				immed_x2  : OUT STD_LOGIC;
				word_byte : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT multi is
		 port(clk       : IN  STD_LOGIC;
				boot      : IN  STD_LOGIC;
				ldpc_1    : IN  STD_LOGIC;
				wrd_1     : IN  STD_LOGIC;
				wr_m_1    : IN  STD_LOGIC;
				w_b       : IN  STD_LOGIC;
				ldpc      : OUT STD_LOGIC;
				wrd       : OUT STD_LOGIC;
				wr_m      : OUT STD_LOGIC;
				ldir      : OUT STD_LOGIC;
				ins_dad   : OUT STD_LOGIC;
				word_byte : OUT STD_LOGIC);
	end COMPONENT;

	--Registers
	signal new_pc: std_logic_vector(15 downto 0);
	signal ir_reg: std_logic_vector(15 downto 0);

	--Wires
	signal m0_ldpc: std_logic; --MUX selector {pc, pc + 2} HALT
	signal new_pc_out0, new_pc_out1: std_logic_vector(15 downto 0);
	signal ir_reg_out0, ir_reg_out1: std_logic_vector(15 downto 0);
	signal c0_ldpc: std_logic;
	signal c0_wrd: std_logic;
	signal c0_wr_m: std_logic;
	signal c0_word_byte: std_logic;
	signal m0_ldir: std_logic;


BEGIN

	 -- Aqui iria la declaracion del "mapeo" (PORT MAP) de los nombres de las entradas/salidas de los componentes
	 -- En los esquemas de la documentacion a la instancia de la logica de control le hemos llamado c0
	 -- Aqui iria la definicion del comportamiento de la unidad de control y la gestion del PC

	with m0_ldir select
		ir_reg_out0 <=
			ir_reg when '0',
			datard_m when '1',
			(others => '0') when others;

	with boot select
		ir_reg_out1 <=
			ir_reg_out0 when '0',
			(others => '0') when '1', -- NOP
			(others => '0') when others;

	with m0_ldpc select
		new_pc_out0 <=
			new_pc + 2 when '1',
			new_pc when '0',
			(others => '0') when others;

	with boot select
		new_pc_out1 <=
			new_pc_out0 when '0',
			X"C000" when '1',
			(others => '0') when others;

	process(clk)
	begin
		if rising_edge(clk) then
			new_pc <= new_pc_out1;
			ir_reg <= ir_reg_out1;
		end if;
	end process;

	c0: control_l port map(
		ir => ir_reg,
		op => op,
		func => func,
		ldpc => c0_ldpc,
		wrd => c0_wrd,
		addr_a => addr_a,
		addr_b => addr_b,
		addr_d => addr_d,
		immed => immed,
		wr_m => c0_wr_m,
		in_d => in_d,
		immed_x2 => immed_x2,
		word_byte => c0_word_byte
	);

	m0: multi port map(
		clk => clk,
		boot => boot,
		ldpc_1 => c0_ldpc,
		wrd_1 => c0_wrd,
		wr_m_1 => c0_wr_m,
		w_b => c0_word_byte,
		ldpc => m0_ldpc,
		wrd => wrd,
		wr_m => wr_m,
		ldir => m0_ldir,
		ins_dad => ins_dad,
		word_byte => word_byte
	);

	pc <= new_pc;

END Structure;
