LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

use work.constants.all;

ENTITY datapath IS
	PORT (clk      : IN  STD_LOGIC;
			op       : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
			func     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			wrd      : IN  STD_LOGIC;
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
			a_sys    : IN  STD_LOGIC);
END datapath;

ARCHITECTURE Structure OF datapath IS

	 -- Aqui iria la declaracion de las entidades que vamos a usar
	 -- Usaremos la palabra reservada COMPONENT ...
	 -- Tambien crearemos los cables/buses (signals) necesarios para unir las entidades

	COMPONENT regfile IS
		 PORT (
                  clk    : IN STD_LOGIC;
                  wrd    : IN STD_LOGIC;
                  d      : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
                  addr_a : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
                  addr_b : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
                  addr_d : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
                  a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                  b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;

	COMPONENT alu IS
            PORT (
                  x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
                  y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
                  op   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
                  func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
                  w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                  z    : OUT STD_LOGIC);
	END COMPONENT;

	signal alu0_w: std_logic_vector(15 downto 0);
	signal reg_general0_a: std_logic_vector(15 downto 0);
	signal reg_general0_b: std_logic_vector(15 downto 0);

	signal reg_d_in: std_logic_vector(15 downto 0);
	signal addr_m_out: std_logic_vector(15 downto 0);
	signal alu_y_in: std_logic_vector(15 downto 0);

	signal reg_system0_a: std_logic_vector(15 downto 0);

	signal wrd_in_reg_general0: std_logic;
	signal wrd_in_reg_system0: std_logic;

BEGIN

	with in_d select
		reg_d_in <=
			alu0_w when in_d_alu,
			datard_m when in_d_mem,
			pc + 2 when in_d_new_pc,
			rd_io when in_d_io,
			(others => '0') when others;

	with ins_dad select
		addr_m_out <=
			alu0_w when '1',
			pc when '0',
			(others => '0') when others;


	with alu_immed select
		alu_y_in <=
			immed when alu_immed_immed,
			reg_general0_b when others;


	 -- Aqui iria la declaracion del "mapeo" (PORT MAP) de los nombres de las entradas/salidas de los componentes
	 -- En los esquemas de la documentacion a la instancia del banco de registros le hemos llamado reg0 y a la de la alu le hemos llamado alu0

	wrd_in_reg_general0 <= wrd and not a_sys;
	wrd_in_reg_system0 <= wrd and a_sys;

	reg_general0: regfile port map(
		clk    => clk,
		wrd    => wrd_in_reg_general0, --a_sys = 0: general regfile
		d      => reg_d_in,
		addr_a => addr_a,
		addr_b => addr_b,
		addr_d => addr_d,
		a      => reg_general0_a,
		b      => reg_general0_b
	);

	reg_system0: regfile port map(
		clk    => clk,
		wrd    => wrd_in_reg_system0, --a_sys = 1: system regfile
		d      => reg_d_in,
		addr_a => addr_a,
		addr_b => (others => '0'),
		addr_d => addr_d,
		a      => reg_system0_a,
		b      => open
	);

	data_wr <= reg_general0_b;

	alu0: alu port map(
		x    => reg_general0_a,
		y    => alu_y_in,
		op   => op,
		func => func,
		w    => alu0_w,
		z    => alu_z
	);

	addr_m <= addr_m_out;
	wr_io <= reg_general0_b;

	with a_sys select
		reg_a <=
			reg_general0_a when '0', --a_sys = 0: general regfile
			reg_system0_a when '1', --a_sys = 1: system regfile
			(others => '0') when others;

END Structure;
