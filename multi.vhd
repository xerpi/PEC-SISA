library ieee;
USE ieee.std_logic_1164.all;

use work.constants.all;

entity multi is
    port(clk         : IN  STD_LOGIC;
         boot        : IN  STD_LOGIC;
	   --Interrupts enabled
	   inten       : IN STD_LOGIC;
	   --Interrupt request
	   intr        : IN STD_LOGIC;
         --Input signals to filter
         ldpc_in     : IN  STD_LOGIC;
         wrd_gen_in  : IN  STD_LOGIC;
         wrd_sys_in  : IN  STD_LOGIC;
         wr_m_in     : IN  STD_LOGIC;
         w_b         : IN  STD_LOGIC;
         wr_out_in   : IN  STD_LOGIC;
         special_in  : IN  STD_LOGIC_VECTOR(2 downto 0);
	   a_sys_in    : IN STD_LOGIC;
	   in_d_in     : IN STD_LOGIC_VECTOR(2 downto 0);
	   addr_a_in   : IN STD_LOGIC_VECTOR(2 downto 0);
	   addr_d_in   : IN STD_LOGIC_VECTOR(2 downto 0);
	   tkn_jmp_in  : IN STD_LOGIC_VECTOR(1 downto 0);
         --Output signals filtered
         ldpc_out    : OUT STD_LOGIC;
         wrd_gen_out : OUT STD_LOGIC;
         wrd_sys_out : OUT STD_LOGIC;
         wrd         : OUT STD_LOGIC;
         wr_m        : OUT STD_LOGIC;
         ldir        : OUT STD_LOGIC;
         ins_dad     : OUT STD_LOGIC;
         word_byte   : OUT STD_LOGIC;
         wr_out      : OUT STD_LOGIC;
         special_out : OUT STD_LOGIC_VECTOR(2 downto 0);
	   a_sys_out   : OUT STD_LOGIC;
	   in_d_out    : OUT STD_LOGIC_VECTOR(2 downto 0);
	   addr_a_out  : OUT STD_LOGIC_VECTOR(2 downto 0);
	   addr_d_out  : OUT STD_LOGIC_VECTOR(2 downto 0);
	   tkn_jmp_out : OUT STD_LOGIC_VECTOR(1 downto 0));
end entity;

architecture Structure of multi is
	signal agregate_in_demw: std_logic_vector(5 downto 0);
	signal agregate_in_system: std_logic_vector(5 downto 0);
	signal agregate_out: std_logic_vector(5 downto 0);

	-- Build an enumerated type for the state machine
	type state_type is (FETCH, DEMW, SYSTEM);

	-- Register to hold the current state
	signal state   : state_type;

begin

	-- Aqui iria la maquina de estados del modelos de Moore que gestiona el multiciclo
	-- Aqui irian la generacion de las senales de control que su valor depende del ciclo en que se esta.

	process(clk)
	begin
		if rising_edge(clk) then
			if boot = '1' then
				state <= FETCH;
			else
				if state = FETCH then
					state <= DEMW;
				-- if we are in DEMW, enabled inter. and have a request
				-- go to SYSTEM
				elsif state = DEMW and intr = '1' and inten = '1' then
					state <= SYSTEM;
				else
					state <= FETCH;
				end if;
			end if;
		end if;
	end process;

	with state select
		ldir <= -- load same IR or mem
			'1' when FETCH,
			'0' when others;

	with state select
		ins_dad <= -- selects @ for mem controller (pc, alu0_w)
			'1' when DEMW,
			'0' when others;

	agregate_in_demw   <= wr_out_in & wrd_sys_in & wrd_gen_in & wr_m_in & w_b & ldpc_in;
	-- w_b doesn't matter, force ldpc
	agregate_in_system <=    '0'    &     '1'    &     '0'    &   '0'   & w_b & ldpc_continue;

	with state select
		agregate_out <=
			agregate_in_demw when DEMW,
			agregate_in_system when SYSTEM,
			(others => '0') when others;

	wr_out <= agregate_out(5);
	wrd_sys_out <= agregate_out(4);
	wrd_gen_out <= agregate_out(3);
	wr_m <= agregate_out(2);
	word_byte <= agregate_out(1);
	ldpc_out <= agregate_out(0);

	with state select
		a_sys_out <=
			'1' when SYSTEM, -- force select reg_sys_a
			a_sys_in when others;
	with state select
		addr_a_out <=
			"101" when SYSTEM, -- force select reg_sys_a S5
			addr_a_in when others;

	with state select
		addr_d_out <=
			"001" when SYSTEM, -- force S1 = Pcup
			addr_d_in when others;

	with state select
		in_d_out <=
			in_d_cur_pc when SYSTEM, --Need for S1 = Pcup
			in_d_in when others;

	with state select
		tkn_jmp_out <=
			tkn_jmp_ja when SYSTEM, -- PC = reg_a = S5
			tkn_jmp_in when others;


	with state select
		special_out <=
			special_in when DEMW,
			special_start_int when SYSTEM,
			special_none when others;


end Structure;
