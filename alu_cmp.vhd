LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY alu_cmp IS
    PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END alu_cmp;


ARCHITECTURE Structure OF alu_cmp IS

	constant F_CMPLT: std_logic_vector(2 downto 0) := "000";
	constant F_CMPLE: std_logic_vector(2 downto 0) := "001";
	constant F_CMPEQ: std_logic_vector(2 downto 0) := "011";
	constant F_CMPLTU: std_logic_vector(2 downto 0) := "100";
	constant F_CMPLEU: std_logic_vector(2 downto 0) := "101";

	signal cmplt_w:  std_logic;
	signal cmple_w:  std_logic;
	signal cmpeq_w:  std_logic;
	signal cmpltu_w: std_logic;
	signal cmpleu_w: std_logic;

	function boolean_to_std_logic(bool: boolean) return std_logic is
	begin
		if bool then
			return '1';
		else
			return '0';
		end if;
	end function boolean_to_std_logic;

BEGIN

	cmplt_w  <= boolean_to_std_logic(signed(x) < signed(y));
	cmple_w  <= boolean_to_std_logic(signed(x) <= signed(y));
	cmpeq_w  <= boolean_to_std_logic(signed(x) = signed(y));
	cmpltu_w <= boolean_to_std_logic(unsigned(x) < unsigned(y));
	cmpleu_w <= boolean_to_std_logic(unsigned(x) <= unsigned(y));

	with func select
		w <=
			(15 downto 1 => '0') & cmplt_w  when F_CMPLT,
			(15 downto 1 => '0') & cmple_w  when F_CMPLE,
			(15 downto 1 => '0') & cmpeq_w  when F_CMPEQ,
			(15 downto 1 => '0') & cmpltu_w when F_CMPLTU,
			(15 downto 1 => '0') & cmpleu_w when F_CMPLEU,
			(others => 'X') when others;

END Structure;
