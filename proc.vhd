LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY proc IS
    PORT (clk      : IN  STD_LOGIC;
			boot      : IN  STD_LOGIC;
			datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			addr_m    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			data_wr   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			wr_m      : OUT STD_LOGIC;
			word_byte : OUT STD_LOGIC;
			addr_io   : OUT STD_LOGIC_VECTOR(7 downto 0);
			wr_io     : OUT STD_LOGIC_VECTOR(15 downto 0);
			rd_io     : IN STD_LOGIC_VECTOR(15 downto 0);
			wr_out    : OUT STD_LOGIC;
			rd_in     : OUT STD_LOGIC);
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
			wrd_gen   : OUT STD_LOGIC;
			wrd_sys   : OUT STD_LOGIC;
			addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			pc        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			ins_dad   : OUT STD_LOGIC;
			in_d      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			wr_m      : OUT STD_LOGIC;
			word_byte : OUT STD_LOGIC;
			alu_immed : OUT STD_LOGIC;
			alu_z     : IN STD_LOGIC;
			reg_a     : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			wr_out    : OUT STD_LOGIC;
			rd_in     : OUT STD_LOGIC;
			a_sys     : OUT STD_LOGIC;
			special   : OUT STD_LOGIC_VECTOR(2 downto 0);
			--Interrupts enabled
			inten     : IN STD_LOGIC);
	END COMPONENT;

	COMPONENT datapath IS
		PORT (clk      : IN  STD_LOGIC;
				op       : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
				func     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				wrd_gen  : IN  STD_LOGIC;
				wrd_sys  : IN  STD_LOGIC;
				addr_a   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_b   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				addr_d   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
				immed    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				datard_m : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				ins_dad  : IN  STD_LOGIC;
				pc       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
				in_d     : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
				alu_immed: IN  STD_LOGIC;
				addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				data_wr  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				alu_z    : OUT STD_LOGIC;
				reg_a    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				wr_io    : OUT STD_LOGIC_VECTOR(15 downto 0);
				rd_io    : IN  STD_LOGIC_VECTOR(15 downto 0);
				--Selects general or system regfile
				a_sys    : IN  STD_LOGIC;
				--Special operation to perform in the system regfile
				special  : IN STD_LOGIC_VECTOR(2 downto 0);
				--Interrupts enabled
				inten    : OUT STD_LOGIC);
	END COMPONENT;

	signal uc0_op: std_logic_vector(1 downto 0);
	signal uc0_func: std_logic_vector(2 downto 0);
	signal uc0_wrd_gen: std_logic;
	signal uc0_wrd_sys: std_logic;
	signal uc0_addr_a: std_logic_vector(2 downto 0);
	signal uc0_addr_b: std_logic_vector(2 downto 0);
	signal uc0_addr_d: std_logic_vector(2 downto 0);
	signal uc0_immed: std_logic_vector(15 downto 0);
	signal uc0_pc: std_logic_vector(15 downto 0);
	signal uc0_ins_dad: std_logic;
	signal uc0_in_d: std_logic_vector(1 downto 0);
	signal uc0_alu_immed: std_logic;
	signal uc0_a_sys: std_logic;
	signal uc0_special: std_logic_vector(2 downto 0);

	signal dp0_alu_z: std_logic;
	signal dp0_reg_a: std_logic_vector(15 downto 0);
	signal dp0_inten: std_logic;

BEGIN

	-- Aqui iria la declaracion del "mapeo" (PORT MAP) de los nombres de las entradas/salidas de los componentes
	-- En los esquemas de la documentacion a la instancia del DATAPATH le hemos llamado e0 y a la de la unidad de control le hemos llamado c0

	uc0: unidad_control port map(
		boot => boot,
		clk => clk,
		datard_m => datard_m,
		op => uc0_op,
		func => uc0_func,
		wrd_gen => uc0_wrd_gen,
		wrd_sys => uc0_wrd_sys,
		addr_a => uc0_addr_a,
		addr_b => uc0_addr_b,
		addr_d => uc0_addr_d,
		immed => uc0_immed,
		pc => uc0_pc,
		ins_dad => uc0_ins_dad,
		in_d => uc0_in_d,
		wr_m => wr_m,
		word_byte => word_byte,
		alu_immed => uc0_alu_immed,
		alu_z => dp0_alu_z,
		reg_a => dp0_reg_a,
		wr_out => wr_out,
		rd_in => rd_in,
		a_sys => uc0_a_sys,
		special => uc0_special,
		inten => dp0_inten
	);

	dp0: datapath port map(
		clk => clk,
		op => uc0_op,
		func => uc0_func,
		wrd_gen => uc0_wrd_gen,
		wrd_sys => uc0_wrd_sys,
		addr_a => uc0_addr_a,
		addr_b => uc0_addr_b,
		addr_d => uc0_addr_d,
		immed => uc0_immed,
		datard_m => datard_m,
		ins_dad => uc0_ins_dad,
		pc => uc0_pc,
		in_d => uc0_in_d,
		addr_m => addr_m,
		data_wr => data_wr,
		alu_immed => uc0_alu_immed,
		alu_z => dp0_alu_z,
		reg_a => dp0_reg_a,
		wr_io => wr_io,
		rd_io => rd_io,
		a_sys => uc0_a_sys,
		special => uc0_special,
		inten => dp0_inten
	);

	addr_io <= uc0_immed(7 downto 0);

END Structure;
