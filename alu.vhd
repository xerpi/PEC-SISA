LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY alu IS
    PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          op   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
          func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          z    : OUT STD_LOGIC);
END alu;

ARCHITECTURE Structure OF alu IS
	COMPONENT alu_misc IS
	    PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	          y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	          func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	          w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;

	COMPONENT alu_cmp IS
	    PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	          y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	          func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	          w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;

	COMPONENT alu_al IS
	    PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	          y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	          func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	          w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;

	COMPONENT alu_muldiv IS
		 PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
				 y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
				 func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
				 w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;

	signal misc0_w: std_logic_vector(15 downto 0);
	signal cmp0_w : std_logic_vector(15 downto 0);
	signal al0_w  : std_logic_vector(15 downto 0);
	signal muldiv0_w  : std_logic_vector(15 downto 0);
	signal alu_w : std_logic_vector(15 downto 0);

BEGIN

	misc0: alu_misc port map(
		x    => x,
		y    => y,
		func => func,
		w    => misc0_w
	);

	cmp0: alu_cmp port map(
		x    => x,
		y    => y,
		func => func,
		w    => cmp0_w
	);

	al0: alu_al port map(
		x    => x,
		y    => y,
		func => func,
		w    => al0_w
	);

	muldiv0: alu_muldiv port map(
		x    => x,
		y    => y,
		func => func,
		w    => muldiv0_w
	);

	with op select
		alu_w <=
			al0_w when "00",
			cmp0_w when "01",
			muldiv0_w when "11",
			misc0_w when others;

	with unsigned(alu_w) = 0 select
		z <=
			'1' when true,
			'0' when others;

	w <= alu_w;

END Structure;
