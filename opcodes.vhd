library IEEE;
use IEEE.std_logic_1164.all;

package opcodes is
      constant ARIT_LOGIC   : std_logic_vector(3 downto 0) := "0000";
      constant COMPARE      : std_logic_vector(3 downto 0) := "0001";
      constant ADDI         : std_logic_vector(3 downto 0) := "0010";
      constant LOAD         : std_logic_vector(3 downto 0) := "0011";
      constant STORE        : std_logic_vector(3 downto 0) := "0100";
      constant MOV          : std_logic_vector(3 downto 0) := "0101";
      constant RELATIVE_JUMP: std_logic_vector(3 downto 0) := "0110";
      constant IN_OUT       : std_logic_vector(3 downto 0) := "0111";
      constant MULT_DIV     : std_logic_vector(3 downto 0) := "1000";
      constant FLOAT_OP     : std_logic_vector(3 downto 0) := "1001";
      constant ABSOLUTE_JUMP: std_logic_vector(3 downto 0) := "1010";
      constant LOAD_F       : std_logic_vector(3 downto 0) := "1011";
      constant STORE_F      : std_logic_vector(3 downto 0) := "1100";
      constant LOAD_BYTE    : std_logic_vector(3 downto 0) := "1101";
      constant STORE_BYTE   : std_logic_vector(3 downto 0) := "1110";
      constant SPECIAL      : std_logic_vector(3 downto 0) := "1111";

      --... exported constant declarations
      --... exported type declarations
      --... exported subprogram declarations
end opcodes;
