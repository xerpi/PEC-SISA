LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY alu_muldiv IS
    PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END alu_muldiv;

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

ARCHITECTURE Structure OF alu_muldiv IS

	constant F_MUL:   std_logic_vector(2 downto 0) := "000";
	constant F_MULH:  std_logic_vector(2 downto 0) := "001";
	constant F_MULHU: std_logic_vector(2 downto 0) := "010";
	constant F_DIV:   std_logic_vector(2 downto 0) := "100";
	constant F_DIVU:  std_logic_vector(2 downto 0) := "101";
	
	signal mul32s: std_logic_vector(31 downto 0);
	signal mul32u: std_logic_vector(31 downto 0);
	signal div_s: std_logic_vector(15 downto 0);
	signal div_u: std_logic_vector(15 downto 0);
BEGIN

	mul32s <= std_logic_vector(signed(x) * signed(y));
	mul32u <= std_logic_vector(unsigned(x) * unsigned(y));
	
	div_s <= std_logic_vector(signed(x) / signed(y));
	div_u <= std_logic_vector(unsigned(x) / unsigned(y));

	with func select
		w <=
			mul32s(15 downto 0)  when F_MUL,
			mul32s(31 downto 16) when F_MULH,
			mul32u(31 downto 16) when F_MULHU,
			div_s when F_DIV,
			div_u when F_DIVU,
			(others => 'X') when others;
END Structure;
