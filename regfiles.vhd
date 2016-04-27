LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY regfiles IS
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
END regfiles;

ARCHITECTURE Structure OF regfiles IS

	COMPONENT regfile_general IS
	    PORT (clk    : IN  STD_LOGIC;
		  wrd    : IN  STD_LOGIC;
		  d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		  addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		  addr_b : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		  addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		  a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		  b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;

	COMPONENT regfile_system IS
	    PORT (clk     : IN  STD_LOGIC;
		  wrd     : IN  STD_LOGIC;
		  d       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		  addr_a  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		  addr_d  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		  a       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		  special : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		  --Interrupts enabled
		  inten   : OUT STD_LOGIC);
	END COMPONENT;

	signal reg_general0_a : std_logic_vector(15 downto 0);
	signal reg_system0_a  : std_logic_vector(15 downto 0);

BEGIN

	reg_general0: regfile_general port map(
		clk    => clk,
		wrd    => wrd_gen,
		d      => d,
		addr_a => addr_a,
		addr_b => addr_b,
		addr_d => addr_d,
		a      => reg_general0_a,
		b      => b
	);

	reg_system0: regfile_system port map(
		clk     => clk,
		wrd     => wrd_sys,
		d       => d,
		addr_a  => addr_a,
		addr_d  => addr_d,
		a       => reg_system0_a,
		special => special,
		inten   => inten
	);

	with a_sys select
		a <=
			reg_general0_a when '0',
			reg_system0_a when others;

END Structure;
