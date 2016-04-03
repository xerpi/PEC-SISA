LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY alu IS
    PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          op   : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
          func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END alu;


-- F          OP = 11       OP = 10                OP = 01                  OP = 00
-------- ------------ ------------- ---------------------- ------------------------
-- 000         MUL           Y             CMPLT(X, Y)             AND(X, Y)
-- 001         MULH   MOVHI = Y & LOW(X)   CMPLE(X, Y)             OR(X, Y)
-- 010         MULHU        ---               ---                  XOR(X,Y)
-- 011         ---          ---            CMPEQ(X, Y)             NOT(X)
-- 100         DIV          ---            CMPLTU(X, Y)            ADD(X, Y)
-- 101         DIVU         ---            CMPLEU(X, Y)            SUB(X, Y)
-- 110         ---          ---            ---                     SHA(X ,Y)
-- 111         ---          ---            ---                     SHL(X, Y)

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

	signal misc0_w: std_logic_vector(15 downto 0);
	signal cmp0_w : std_logic_vector(15 downto 0);
	signal al0_w  : std_logic_vector(15 downto 0);

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

	with op select
		w <=
			al0_w when "00",
			cmp0_w when "01",
			misc0_w when others;

END Structure;
