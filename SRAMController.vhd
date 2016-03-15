library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SRAMController is
    port (clk         : in    std_logic;
          -- señales para la placa de desarrollo
          SRAM_ADDR   : out   std_logic_vector(17 downto 0);
          SRAM_DQ     : inout std_logic_vector(15 downto 0);
          SRAM_UB_N   : out   std_logic;
          SRAM_LB_N   : out   std_logic;
          SRAM_CE_N   : out   std_logic := '1';
          SRAM_OE_N   : out   std_logic := '1';
          SRAM_WE_N   : out   std_logic := '1';
          -- señales internas del procesador
          address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
          dataReaded  : out   std_logic_vector(15 downto 0);
          dataToWrite : in    std_logic_vector(15 downto 0);
          WR          : in    std_logic;
          byte_m      : in    std_logic := '0');
end SRAMController;

architecture comportament of SRAMController is
begin

end comportament;
