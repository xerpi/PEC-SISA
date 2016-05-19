library ieee;
USE ieee.std_logic_1164.all;

use work.constants.all;
use work.opcodes.all;

entity multi is
	port(
		clk         : IN  STD_LOGIC;
		boot        : IN  STD_LOGIC;
		--Interrupts enabled
		inten       : IN STD_LOGIC;
		--System mode (user or kernel)
		system_mode    : IN STD_LOGIC;
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
		div_by_zero: IN STD_LOGIC;
		reload_addr_mem : OUT STD_LOGIC;
		--Protected instruction
		protected_instr: IN STD_LOGIC;
		calls_instr : IN STD_LOGIC;
		--TLB
		ITLB_miss : IN STD_LOGIC;
		ITLB_v    : IN STD_LOGIC;
		ITLB_p    : IN STD_LOGIC;
		DTLB_miss : IN STD_LOGIC;
		DTLB_v    : IN STD_LOGIC;
		DTLB_r    : IN STD_LOGIC;
		DTLB_p    : IN STD_LOGIC;
		tlb_flush_in : IN STD_LOGIC;
		ITLB_wr_in   : IN STD_LOGIC;
		DTLB_wr_in   : IN STD_LOGIC;
		tlb_flush_out : OUT STD_LOGIC;
		ITLB_wr_out   : OUT STD_LOGIC;
		DTLB_wr_out   : OUT STD_LOGIC);
end entity;

architecture Structure of multi is
	signal agregate_in_demw: std_logic_vector(8 downto 0);
	signal agregate_in_system: std_logic_vector(8 downto 0);
	signal agregate_in_nop: std_logic_vector(8 downto 0);
	signal agregate_out: std_logic_vector(8 downto 0);

	-- Build an enumerated type for the state machine
	type state_type is (FETCH, DEMW, SYSTEM, NOP);

	-- Register to hold the current state
	signal state   : state_type;

	--Unaligned address exception
	signal exc_unaligned_access: std_logic := '0';
	--Division by zero exception
	signal exc_div_by_zero: std_logic := '0';
	--Protected instr
	signal exc_protected_instr: std_logic := '0';
	--Illegal CALLS (CALLS in system mode)
	signal illegal_calls: std_logic := '0';
	--CALLS instruction
	signal exc_calls: std_logic := '0';
	--ITLB miss
	signal exc_ITLB_miss: std_logic := '0';
	--DTLB miss
	signal exc_DTLB_miss: std_logic := '0';
	--ITLB invalid
	signal exc_ITLB_invalid: std_logic := '0';
	--DTLB invalid
	signal exc_DTLB_invalid: std_logic := '0';
	--ITLB protected
	signal exc_ITLB_protected: std_logic := '0';
	--DTLB protected
	signal exc_DTLB_protected: std_logic := '0';
	--DTLB readonly
	signal exc_DTLB_readonly: std_logic := '0';
	
	--Memory access
	signal memory_access: std_logic := '0';
	
	--OR of all the exception requests
	signal exc_happened: std_logic := '0';

	signal opcode: std_logic_vector(3 downto 0);

begin
	opcode <= ir(15 downto 12);

	memory_access <=
		'1' when (opcode = LOAD) or (opcode = STORE) or (opcode = LOAD_BYTE) or (opcode = STORE_BYTE) else
		'0';
	
	--OR of all the exception requests
	exc_happened <=
		'1' when exc_illegal_instr = '1' else
		'1' when exc_unaligned_access = '1' else
		'1' when exc_div_by_zero = '1' else
		'1' when exc_protected_instr = '1' else
		'1' when illegal_calls = '1' else
		'1' when exc_calls = '1' else
		'1' when exc_DTLB_miss = '1' else
		'1' when exc_DTLB_invalid = '1' else
		'1' when exc_DTLB_protected = '1' else
		'1' when exc_DTLB_readonly = '1' else
		'0';
	--exc_happened <= '0';
	-- If MemCntrl. reports unaligned_access only raise execption
	-- when dewm load/store (word).
	exc_unaligned_access <=
		'1' when (state = DEMW) and (opcode = LOAD) and (unaligned_access = '1') else
		'1' when (state = DEMW) and (opcode = STORE) and (unaligned_access = '1') else
		'0';

	exc_protected_instr <=
		'1' when (protected_instr = '1') and (system_mode = system_mode_user) else
		'0';

	illegal_calls <=
		'1' when (calls_instr = '1') and (system_mode = system_mode_kernel) else
		'0';

	exc_calls <=
		'1' when (calls_instr = '1') and (system_mode = system_mode_user) else
		'0';

	-- If Alu reports division by zero test if we are in MULT_DIV instr
	exc_div_by_zero <=
		'1' when (state = DEMW) and (opcode = MULT_DIV) and (div_by_zero = '1') else
		'0';
		
	exc_ITLB_miss <=
		'1' when (state = FETCH) and (ITLB_miss = '1') else
		'0';

	exc_DTLB_miss <=
		'1' when (memory_access = '1') and (state = DEMW) and (DTLB_miss = '1') else
		'0';
		
	exc_ITLB_invalid <=
		'1' when (state = FETCH) and (ITLB_miss = '0') and (ITLB_v = '0') else
		'0';

	exc_DTLB_invalid <=
		'1' when (memory_access = '1') and (state = DEMW) and (DTLB_miss = '0') and (DTLB_v = '0') else
		'0';
		
	exc_ITLB_protected <=
		'1' when (state = FETCH) and (ITLB_miss = '0') and (ITLB_v = '1') and (ITLB_p = '1') and (system_mode = system_mode_user) else
		'0';

	exc_DTLB_protected <=
		'1' when (memory_access = '1') and (state = DEMW) and (DTLB_miss = '0') and (DTLB_v = '1') and (DTLB_p = '1') and (system_mode = system_mode_user) else
		'0';

	exc_DTLB_readonly <=
		'1' when ((opcode = STORE) or (opcode = STORE_BYTE)) and (state = DEMW) and
		         (DTLB_miss = '0') and (DTLB_v = '1') and (DTLB_r = '1') else
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
					elsif exc_ITLB_miss = '1' then
						state <= NOP;
						int_id <= exception_ITLB_miss;
					elsif exc_ITLB_invalid = '1' then
						state <= NOP;
						int_id <= exception_ITLB_invalid;
					elsif exc_ITLB_protected = '1' then
						state <= NOP;
						int_id <= exception_ITLB_protected;
					else
						state <= DEMW;
					end if;
				elsif state = DEMW then
					if exc_happened = '1' then
						if exc_unaligned_access = '1' then
							state <= SYSTEM;
							int_id <= exception_unaligned_access;
						elsif (exc_illegal_instr = '1') or (illegal_calls = '1') then
							state <= SYSTEM;
							int_id <= exception_illegal_instr;
						elsif exc_div_by_zero = '1' then
							state <= SYSTEM;
							int_id <= exception_division_by_zero;
						elsif exc_protected_instr = '1' then
							state <= SYSTEM;
							int_id <= exception_protected_instr;
						elsif exc_calls = '1' then
							state <= SYSTEM;
							int_id <= exception_calls;
						elsif exc_DTLB_miss = '1' then
							state <= SYSTEM;
							int_id <= exception_DTLB_miss;						
						elsif exc_DTLB_invalid = '1' then
							state <= SYSTEM;
							int_id <= exception_DTLB_invalid;						
						elsif exc_DTLB_protected = '1' then
							state <= SYSTEM;
							int_id <= exception_DTLB_protected;						
						elsif exc_DTLB_readonly = '1' then
							state <= SYSTEM;
							int_id <= exception_DTLB_readonly;						
						end if;
					elsif (intr = '1') and (inten = '1') then
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
			
	agregate_in_demw   <=  tlb_flush_in & ITLB_wr_in & DTLB_wr_in & wr_out_in & wrd_sys_in & wrd_gen_in & wr_m_in & w_b & ldpc_in;
	-- w_b doesn't matter, force ldpc
	agregate_in_system <=  '0'          &   '0'        &      '0'   &  '0'       &     '1'    &     '0'    &   '0'   & w_b & ldpc_in;
	agregate_in_nop    <=  '0'          &   '0'        &      '0'   &  '0'       &     '0'    &     '0'    &   '0'   & '0' & ldpc_in;

	agregate_out <=
			--Avoid doing garbage operations
			agregate_in_nop when state = DEMW and exc_happened = '1' else
			agregate_in_demw when state = DEMW else
			agregate_in_system when state = SYSTEM else
			agregate_in_nop when state = NOP else
			(others => '0');
			
			
	tlb_flush_out <= agregate_out(8);
	ITLB_wr_out <= agregate_out(7);
	DTLB_wr_out <= agregate_out(6);
	wr_out <= agregate_out(5);

	wrd_sys_out <=
		'1' when (state = DEMW) and (calls_instr = '1') else -- when CALLS force S3 = Ra
		agregate_out(4);

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

	addr_d_out <=
			"001" when (state = SYSTEM) else -- force S1 = Pcup
			"011" when (state = DEMW) and (calls_instr = '1') else -- when CALLS force S3 = Ra
			addr_d_in;

	with state select
		in_d_out <=
			in_d_cur_pc when SYSTEM, --Need for S1 = Pcup
			in_d_in when others;

	tkn_jmp_out <=
		tkn_jmp_ja when state = SYSTEM else -- PC = reg_a = S5
		--CALLS is seen as JAL (tkn_jmp_ja) but we don't want it to write to the PC
		tkn_jmp_si when (state = DEMW) and (calls_instr = '1') else
		tkn_jmp_in;


	with state select
		special_out <=
			special_in when DEMW,
			special_start_int when SYSTEM,
			special_none when others;

	--Save unaligned access effective address (Unaligned FETCH vs Unaligned LD/ST DEMW)
	with state select
		reload_addr_mem <=
			'1' when FETCH,
			'1' when DEMW,
			'0' when others;

end Structure;
