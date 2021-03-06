LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY TLB IS
	PORT (
		boot  : IN  STD_LOGIC;
		clk   : IN  STD_LOGIC;
		vpn   : IN  STD_LOGIC_VECTOR(3 downto 0);
		pfn   : OUT STD_LOGIC_VECTOR(3 downto 0);
		v     : OUT STD_LOGIC;
		r     : OUT STD_LOGIC;
		p     : OUT STD_LOGIC;
		miss  : OUT STD_LOGIC;
		wr    : IN  STD_LOGIC;
		phys  : IN  STD_LOGIC;
		index : IN  STD_LOGIC_VECTOR(2 downto 0);
		entry : IN  STD_LOGIC_VECTOR(6 downto 0);
		flush : IN  STD_LOGIC
	);
END TLB;

ARCHITECTURE Structure OF TLB IS

	function log2(v : std_logic_vector) return integer is
	begin
		for i in v'range loop
			if v(i) = '1' then
				return i;
			end if;
		end loop;
		return 0;
	end;

	type TLB_entry is record
		vpn : std_logic_vector(3 downto 0);
		pfn : std_logic_vector(3 downto 0);
		r   : std_logic;
		v   : std_logic;
		p   : std_logic;
	end record;

	type TLB_entries is array(7 downto 0) of TLB_entry;

	constant TLB_entry_status_invalid : std_logic := '0';
	constant TLB_entry_status_valid   : std_logic := '1';

	constant TLB_entry_access_rw : std_logic := '0';
	constant TLB_entry_access_ro : std_logic := '1';

	constant TLB_entry_protection_off : std_logic := '0';
	constant TLB_entry_protection_on  : std_logic := '1';

	signal entries: TLB_entries;

	signal match       : std_logic_vector(7 downto 0);
	signal first_match : std_logic_vector(7 downto 0);
	signal match_entry : integer range 0 to 7;

	signal miss_tmp : std_logic;
BEGIN


	process(clk, boot)
	begin
		if boot = '1' then
			--Setup user pages(0x0000 to 0x2FFF)
			for i in 0 to 2 loop
				entries(i) <= (
					vpn => std_logic_vector(to_unsigned(i, entries(i).vpn'length)),
					pfn => std_logic_vector(to_unsigned(i, entries(i).pfn'length)),
					r   => TLB_entry_access_rw,
					v   => TLB_entry_status_valid,
					p   => TLB_entry_protection_off
				);
			end loop;
			--Setup kernel pages(0x8000 to 0x8FFF)
			entries(3) <= (
				vpn => X"8",
				pfn => X"8",
				r   => TLB_entry_access_rw,
				v   => TLB_entry_status_valid,
				p   => TLB_entry_protection_on
			);
			--Setup kernel pages(0xC000 to 0xFFFF)
			for i in 0 to 3 loop
				entries(i + 4) <= (
					vpn => std_logic_vector(to_unsigned(i + 16#C#, entries(i).vpn'length)),
					pfn => std_logic_vector(to_unsigned(i + 16#C#, entries(i).pfn'length)),
					r   => TLB_entry_access_ro,
					v   => TLB_entry_status_valid,
					p   => TLB_entry_protection_on
				);
			end loop;
		elsif rising_edge(clk) then
			if flush = '1' then
				for i in entries'range loop
					entries(i).v <= TLB_entry_status_invalid;
				end loop;
			elsif wr = '1' then
				if phys = '1' then
					entries(to_integer(unsigned(index))).pfn <= entry(3 downto 0);
					entries(to_integer(unsigned(index))).r <= entry(4);
					entries(to_integer(unsigned(index))).v <= entry(5);
					entries(to_integer(unsigned(index))).p <= entry(6);
				else
					entries(to_integer(unsigned(index))).vpn <= entry(3 downto 0);
				end if;
			end if;
		end if;
	end process;

	entry_match: for i in entries'range generate
		match(i) <=
			'1' when entries(i).vpn = vpn else
			'0';
	end generate;

	first_match <= match and std_logic_vector(unsigned(not(match)) + 1);

	match_entry <= log2(first_match);

	--pfn <= entries(match_entry).pfn;
	r <= entries(match_entry).r;
	v <= entries(match_entry).v;
	p <= entries(match_entry).p;

	miss_tmp <= '1' when match = "00000000" else '0';

	-- If TLB misses don't touch anithing
	pfn <=
		entries(match_entry).pfn when miss_tmp = '0' else
		vpn;

	miss <= miss_tmp;

END Structure;
