library ieee;
USE ieee.std_logic_1164.all;

entity multi is
    port(clk       : IN  STD_LOGIC;
         boot      : IN  STD_LOGIC;
         ldpc_1    : IN  STD_LOGIC;
         wrd_1     : IN  STD_LOGIC;
         wr_m_1    : IN  STD_LOGIC;
         w_b       : IN  STD_LOGIC;
         ldpc      : OUT STD_LOGIC;
         wrd       : OUT STD_LOGIC;
         wr_m      : OUT STD_LOGIC;
         ldir      : OUT STD_LOGIC;
         ins_dad   : OUT STD_LOGIC;
         word_byte : OUT STD_LOGIC);
end entity;

architecture Structure of multi is
	--constant FETCH: std_logic := '0';
	--constant DEMW: std_logic := '1';
	--signal state: std_logic;

      signal agregate_in: std_logic_vector(3 downto 0);
      signal agregate_out: std_logic_vector(3 downto 0);
	-- Aqui iria la declaracion de las los estados de la maquina de estados

-- Build an enumerated type for the state machine
	type state_type is (FETCH, DEMW);

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
				else
					state <= FETCH;
				end if;
			end if;
		end if;
	end process;

	with state select
			ldir <=
					'1' when FETCH,
					'0' when others;
						
	with state select
		ins_dad <=
				'1' when DEMW,
				'0' when others;

      agregate_in <= wrd_1 & wr_m_1 & w_b & ldpc_1;

      with state select
            agregate_out <=
                  agregate_in when DEMW,
                  (others => '0') when others;

      wrd <= agregate_out(3);
      wr_m <= agregate_out(2);
      word_byte <= agregate_out(1);
      ldpc <= agregate_out(0);

end Structure;
