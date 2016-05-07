library ieee;
USE ieee.std_logic_1164.all;

use work.constants.all;
use work.opcodes.all;

entity multi is
    port(clk         : IN  STD_LOGIC;
         boot        : IN  STD_LOGIC;
	   --Interrupts enabled
	   inten       : IN STD_LOGIC;
	   --div_by_zero enable;
	   div_z_en    : IN STD_LOGIC;
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
	   tkn_jmp_out : OUT STD_LOGIC_VECTOR(1 downto 0);
		 --Interrupt ID
		 int_id      : OUT STD_LOGIC_VECTOR(3 downto 0);
		 --Exception requests
		 exc_illegal_instr : IN STD_LOGIC;
		 --Unaligned access
		 unaligned_access : IN STD_LOGIC;
		 --LOAD or STORE
		 ir : IN STD_LOGIC_VECTOR(15 downto 0);
		 div_by_zero: IN STD_LOGIC);
end entity;

architecture Structure of multi is
	signal agregate_in_demw: std_logic_vector(5 downto 0);
	signal agregate_in_system: std_logic_vector(5 downto 0);
	signal agregate_in_nop: std_logic_vector(5 downto 0);
	signal agregate_out: std_logic_vector(5 downto 0);

	-- Build an enumerated type for the state machine
	type state_type is (FETCH, DEMW, SYSTEM, NOP);

	-- Register to hold the current state
	signal state   : state_type;

	--Unaligned address exception
	signal exc_unaligned_access: std_logic := '0';
	--Division by zero exception
	signal exc_div_by_zero: std_logic := '0';

	--OR of all the exception requests
	signal exc_happened: std_logic := '0';

	signal opcode: std_logic_vector(3 downto 0);

begin
	opcode <= ir(15 downto 12);

	--OR of all the exception requests
	exc_happened <= exc_illegal_instr or exc_unaligned_access or exc_div_by_zero;

	-- If MemCntrl. reports unaligned_access only raise execption
	-- when dewm load/store (word).
	exc_unaligned_access <=
		'1' when state = DEMW and opcode = LOAD and unaligned_access = '1' else
		'1' when state = DEMW and opcode = STORE and unaligned_access = '1' else
		'0';

	-- If Alu reports division by zero test if we are in MULT_DIV instr
	exc_div_by_zero <=
		'1' when opcode = MULT_DIV and div_by_zero = '1' else
		'0';

	process(clk)
	begin
		if rising_edge(clk) then
			if boot = '1' then
				state <= FETCH;
			else
				if state = FETCH then
					if unaligned_access = '1' then
						state <= NOP;
						int_id <= exception_unaligned_access;
					else
						state <= DEMW;
					end if;
				elsif state = DEMW then
					if exc_happened = '1' then
						if exc_unaligned_access = '1' then
							state <= SYSTEM;
							int_id <= exception_unaligned_access;
						elsif exc_illegal_instr = '1' then
							state <= SYSTEM;
							int_id <= exception_illegal_instr;
						elsif exc_div_by_zero = '1' and div_z_en = '1' then
							state <= SYSTEM;
							int_id <= exception_division_by_zero;
						end if;

					elsif intr = '1' and inten = '1' then
						state <= SYSTEM;
						int_id <= exception_interrupt;
					else
						state <= FETCH;
					end if;
				elsif state = NOP then
					state <= SYSTEM;
				elsif state = SYSTEM then
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
	agregate_in_system <=    '0'    &     '1'    &     '0'    &   '0'   & w_b & ldpc_in;
	agregate_in_nop <= (others => '0');

	with state select
		agregate_out <=
			agregate_in_demw when DEMW,
			agregate_in_system when SYSTEM,
			agregate_in_nop when NOP,
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
