LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY alu_al IS
    PORT (x    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          y    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
          func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END alu_al;

ARCHITECTURE Structure OF alu_al IS

	constant F_AND: std_logic_vector(2 downto 0) := "000";
	constant F_OR:  std_logic_vector(2 downto 0) := "001";
	constant F_XOR: std_logic_vector(2 downto 0) := "010";
	constant F_NOT: std_logic_vector(2 downto 0) := "011";
	constant F_ADD: std_logic_vector(2 downto 0) := "100";
	constant F_SUB: std_logic_vector(2 downto 0) := "101";
	constant F_SHA: std_logic_vector(2 downto 0) := "110";
	constant F_SHL: std_logic_vector(2 downto 0) := "111";

	signal and_w: std_logic_vector(15 downto 0);
	signal or_w: std_logic_vector(15 downto 0);
	signal xor_w: std_logic_vector(15 downto 0);
	signal not_w: std_logic_vector(15 downto 0);
	signal add_w: std_logic_vector(15 downto 0);
	signal sub_w: std_logic_vector(15 downto 0);
	signal sha_w: std_logic_vector(15 downto 0);
	signal shl_w: std_logic_vector(15 downto 0);

	signal sh_l_w: std_logic_vector(15 downto 0);
	signal sh_ra_w: std_logic_vector(15 downto 0);
	signal sh_rl_w: std_logic_vector(15 downto 0);

	signal y_4_dt_0 : std_logic_vector(4 downto 0);
BEGIN
	y_4_dt_0 <= y(4 downto 0);

	and_w <= x and y;
	or_w <= x or y;
	xor_w <= x xor y;
	not_w <= not x;
	add_w <= std_logic_vector(unsigned(x) + unsigned(y));
	sub_w <= std_logic_vector(unsigned(x) - unsigned(y));

	sh_l_w <= std_logic_vector(shift_left(unsigned(x), to_integer(abs(signed(y_4_dt_0)))));
	sh_ra_w <= std_logic_vector(shift_right(signed(x), to_integer(abs(signed(y_4_dt_0)))));
	sh_rl_w <= std_logic_vector(shift_right(unsigned(x), to_integer(abs(signed(y_4_dt_0)))));

	with signed(y_4_dt_0) >= 0 select
		sha_w <=
			sh_l_w when true,
			sh_ra_w when others;

	with signed(y_4_dt_0) >= 0 select
		shl_w <=
			sh_l_w when true,
			sh_rl_w when others;

	with func select
		w <=
			and_w when F_AND,
			or_w  when F_OR,
			xor_w when F_XOR,
			not_w when F_NOT,
			add_w when F_ADD,
			sub_w when F_SUB,
			sha_w when F_SHA,
			shl_w when F_SHL,
			(others => 'X') when others;

END Structure;
