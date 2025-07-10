------------------------------------------------------------------------------------
--
-- Definition of an 8-bit swap-nibble process
-- Operation:
--   Y(7 downto 4) <= operand(3 downto 0);
--   Y(3 downto 0) <= operand(7 downto 4);
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity swap is
    Port (operand : in std_logic_vector(7 downto 0);
          Y       : out std_logic_vector(7 downto 0);
          clk     : in std_logic);
end swap;

architecture rtl of swap is
begin
  nibble_loop: for i in 0 to 7 generate
  begin
    process(clk)
    begin
      if rising_edge(clk) then
        if i < 4 then
          Y(i) <= operand(i+4);
        else
          Y(i) <= operand(i-4);
        end if;
      end if;
    end process;
  end generate nibble_loop;
end rtl; 