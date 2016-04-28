LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY alu_misc IS
    PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END alu_misc;

-- F          OP = 11       OP = 10                OP = 01                  OP = 00
-------- ------------ ------------- ---------------------- ------------------------
-- 000         MUL           Y             CMPLT(X, Y)             AND(X, Y)
-- 001         MULH   MOVHI = Y & LOW(X)   CMPLE(X, Y)             OR(X, Y)
-- 010         MULHU         X                ---                  XOR(X,Y)
-- 011         ---          ---            CMPEQ(X, Y)             NOT(X)
-- 100         DIV          ---            CMPLTU(X, Y)            ADD(X, Y)
-- 101         DIVU         ---            CMPLEU(X, Y)            SUB(X, Y)
-- 110         ---          ---            ---                     SHA(X ,Y)
-- 111         ---          ---            ---                     SHL(X, Y)


ARCHITECTURE Structure OF alu_misc IS
BEGIN
	-- Aqui iria la definicion del comportamiento de la ALU
	with func select
		w <=
			y when "000",
			y(7 downto 0) & x(7 downto 0) when "001",
			x when "010",
			(others => '0') when others;
END Structure;
