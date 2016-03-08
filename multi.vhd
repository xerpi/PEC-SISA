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
	constant FETCH: std_logic := '0';
	constant DEMW: std_logic := '1';
	signal state: std_logic;
	-- Aqui iria la declaracion de las los estados de la maquina de estados

begin

	-- Aqui iria la maquina de estados del modelos de Moore que gestiona el multiciclo
	-- Aqui irian la generacion de las senales de control que su valor depende del ciclo en que se esta.

	process(clk)
	begin
		if rising_edge(clk) then
			if boot = '1' then
				state <= FETCH;
			else
				state <= not state;
			end if;
		end if;
	end process;
	
end Structure;
