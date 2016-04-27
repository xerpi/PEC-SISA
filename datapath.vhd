LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

use work.constants.all;

ENTITY datapath IS
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
			inten   : OUT STD_LOGIC);
END datapath;

ARCHITECTURE Structure OF datapath IS

	COMPONENT regfiles IS
	    PORT (clk     : IN  STD_LOGIC;
		  wrd_gen : IN  STD_LOGIC;
		  wrd_sys : IN  STD_LOGIC;
		  d       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		  addr_a  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		  addr_b  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		  addr_d  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		  a       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		  b       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		  a_sys   : IN  STD_LOGIC;
		  special : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		  --Interrupts enabled
		  inten   : OUT STD_LOGIC);
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

	signal reg_d_in: std_logic_vector(15 downto 0);
	signal addr_m_out: std_logic_vector(15 downto 0);
	signal alu_y_in: std_logic_vector(15 downto 0);

	signal regfiles0_a: std_logic_vector(15 downto 0);
	signal regfiles0_b: std_logic_vector(15 downto 0);

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
			regfiles0_b when others;

	regfiles0: regfiles port map(
		clk     => clk,
		wrd_gen => wrd_gen,
		wrd_sys => wrd_sys,
		d       => reg_d_in,
		addr_a  => addr_a,
		addr_b  => addr_b,
		addr_d  => addr_d,
		a       => regfiles0_a,
		b       => regfiles0_b,
		a_sys   => a_sys,
		special => special,
		inten   => inten
	);

	alu0: alu port map(
		x    => regfiles0_a,
		y    => alu_y_in,
		op   => op,
		func => func,
		w    => alu0_w,
		z    => alu_z
	);

	reg_a <= regfiles0_a;
	data_wr <= regfiles0_b;

	addr_m <= addr_m_out;
	wr_io <= regfiles0_b;

END Structure;
