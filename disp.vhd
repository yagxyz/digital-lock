library IEEE;
use IEEE.STD_LOGIC_1164.all;	
use IEEE.STD_LOGIC_ARITH.all;			 
use ieee.std_logic_unsigned.ALL;

entity disp is
	 port(
		 a : in integer range 0 to 10;
		 b : out std_logic_vector(6 downto 0)
	     );
end disp;

architecture display of disp is		  
begin						
p: process(a)
    begin
	 
	case a is
		when 0 => b<="1000000";
		when 1 => b<="1111001";
		when 2 => b<="0100100";
		when 3 => b<="0110000";
		when 4 => b<="0011001";
		when 5 => b<="0010010";
		when 6 => b<="0000010";
		when 7 => b<="1111000";
		when 8 => b<="0000000";
		when 9 => b<="0010000";	 
		when 10 => b<="1000000";
	end case; 
	end process;
end display;