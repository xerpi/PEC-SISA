LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

use work.constants.all;

ENTITY datapath IS
	PORT (boot    : IN  STD_LOGIC;
			clk      : IN  STD_LOGIC;
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
			in_d     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
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
			inten   : OUT STD_LOGIC;
			--System mode (user or kernel)
			system_mode    : OUT STD_LOGIC;
			--Interrupt ID
			int_id  : IN STD_LOGIC_VECTOR(3 downto 0);
			div_by_zero: OUT STD_LOGIC;
			reload_addr_mem : IN STD_LOGIC);
END datapath;

ARCHITECTURE Structure OF datapath IS

	COMPONENT regfiles IS
	    PORT (boot    : IN  STD_LOGIC;
		  clk     : IN  STD_LOGIC;
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
		  inten   : OUT STD_LOGIC;
		  --System mode (user or kernel)
		  system_mode    : OUT STD_LOGIC;
		  --Interrupt ID
		  int_id  : IN STD_LOGIC_VECTOR(3 downto 0);
		  --Address to memory. Needed when exception_unaligned_access
		  addr_mem    : IN STD_LOGIC_VECTOR(15 downto 0);
		  reload_addr_mem : IN STD_LOGIC);
	END COMPONENT;

	COMPONENT alu IS
            PORT (
                  x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
                  y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
                  op   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
                  func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
                  w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                  z    : OUT STD_LOGIC;
						div_by_zero: OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT TLB IS
		PORT (
			boot  : IN  STD_LOGIC;
			clk   : IN  STD_LOGIC;
			vpn   : IN  STD_LOGIC_VECTOR(3 downto 0);
			pfn   : OUT STD_LOGIC_VECTOR(3 downto 0);
			v     : OUT STD_LOGIC;
			r     : OUT STD_LOGIC;
			miss  : OUT STD_LOGIC;
			wr    : IN  STD_LOGIC;
			phys  : IN  STD_LOGIC;
			index : IN  STD_LOGIC_VECTOR(2 downto 0);
			entry : IN  STD_LOGIC_VECTOR(5 downto 0);
			flush : IN  STD_LOGIC
		);
	END COMPONENT;

	signal alu0_w: std_logic_vector(15 downto 0);

	signal reg_d_in: std_logic_vector(15 downto 0);
	signal addr_m_out: std_logic_vector(15 downto 0);
	signal alu_y_in: std_logic_vector(15 downto 0);

	signal regfiles0_a: std_logic_vector(15 downto 0);
	signal regfiles0_b: std_logic_vector(15 downto 0);

	signal ITLB0_pfn: std_logic_vector(3 downto 0);
	signal DTLB0_pfn: std_logic_vector(3 downto 0);

BEGIN

	with in_d select
		reg_d_in <=
			alu0_w when in_d_alu,
			datard_m when in_d_mem,
			pc + 2 when in_d_new_pc,
			rd_io when in_d_io,
			pc when in_d_cur_pc,
			(others => '0') when others;

	ITLB0: TLB port map(
		boot  => boot,
		clk   => clk,
		vpn   => pc(15 downto 12),
		pfn   => ITLB0_pfn,
		v     => open,
		r     => open,
		miss  => open,
		wr    => '0',
		phys  => '0',
		index => (others => '0'),
		entry => (others => '0'),
		flush => '0'

	);

	DTLB0: TLB port map(
		boot  => boot,
		clk   => clk,
		vpn   => alu0_w(15 downto 12),
		pfn   => DTLB0_pfn,
		v     => open,
		r     => open,
		miss  => open,
		wr    => '0',
		phys  => '0',
		index => (others => '0'),
		entry => (others => '0'),
		flush => '0'
	);

	with ins_dad select
		addr_m_out <=
			DTLB0_pfn & alu0_w(11 downto 0) when '1',
			ITLB0_pfn & pc(11 downto 0) when '0',
			(others => '0') when others;

	with alu_immed select
		alu_y_in <=
			immed when alu_immed_immed,
			regfiles0_b when others;

	regfiles0: regfiles port map(
		boot    => boot,
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
		inten   => inten,
		system_mode => system_mode,
		int_id  => int_id,
		addr_mem => addr_m_out,
		reload_addr_mem => reload_addr_mem
	);

	alu0: alu port map(
		x    => regfiles0_a,
		y    => alu_y_in,
		op   => op,
		func => func,
		w    => alu0_w,
		z    => alu_z,
		div_by_zero => div_by_zero
	);

	reg_a <= regfiles0_a;
	data_wr <= regfiles0_b;

	addr_m <= addr_m_out;
	wr_io <= regfiles0_b;

END Structure;
