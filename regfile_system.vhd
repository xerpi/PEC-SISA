LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

use work.constants.all;

ENTITY regfile_system IS
    PORT (boot    : IN  STD_LOGIC;
			 clk     : IN  STD_LOGIC;
          wrd     : IN  STD_LOGIC;
          d       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          special : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          --Interrupts enabled
          inten   : OUT STD_LOGIC;
          --System mode (user or kernel)
          system_mode    : OUT STD_LOGIC;
          --Interrupt ID
          int_id  : IN STD_LOGIC_VECTOR(3 downto 0);
          --Address to memory. Needed when exception_unaligned_access
          addr_mem: IN STD_LOGIC_VECTOR(15 downto 0);
			 reload_addr_mem : IN STD_LOGIC);
END regfile_system;

ARCHITECTURE Structure OF regfile_system IS
	type REGISTERS_T is array (7 downto 0) of std_logic_vector(15 downto 0);
	signal registers: REGISTERS_T := (others => (others => '0'));

	-- Needed to store previous cycle alu output
	signal addr_mem_reg: std_logic_vector(15 downto 0);
BEGIN


	process(clk, boot)
	begin
		if boot = '1' then
			registers(7)(0) <= system_mode_kernel;
		elsif rising_edge(clk) then
			if reload_addr_mem = '1' then
				addr_mem_reg <= addr_mem;
			end if;

			if wrd = '1' then
				registers(to_integer(unsigned(addr_d))) <= d;
			end if;
			if special = special_ei then
				registers(7)(1) <= '1';
			elsif special = special_di then
				registers(7)(1) <= '0';
			elsif special = special_reti then
				--addr_a should be 1 (PC <- S1)
				registers(7) <= registers(0);
			elsif special = special_start_int then
				--wrd should be 0,
				--PCup will be passed in d,
				--addr_a should be 5 (PC <- S5)
				registers(0) <= registers(7); --restore status (S0 <- S7)
				registers(1) <= d;            --S1 <- PCup
				registers(2) <= (15 downto 4 => '0') & int_id;
				--If CALLS, don't overwrite service ID
				if int_id /= X"E" then
					registers(3) <= addr_mem_reg;
				end if;
				registers(7)(0) <= system_mode_kernel; --enter kernel mode
				registers(7)(1) <= '0';       --disable interrupts (S7<1> <- 0)
			end if;
		end if;
	end process;

	a <= registers(to_integer(unsigned(addr_a)));
	inten <= registers(7)(1);
	system_mode <= registers(7)(0);
END Structure;
