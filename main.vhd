
library IEEE;
use IEEE.STD_LOGIC_1164.all;	
use IEEE.STD_LOGIC_ARITH.all;			 
use ieee.std_logic_unsigned.ALL;

entity main is
	 port(
	    CLOCK_27     : in std_logic; --clock 27 MHz
		 CLOCK_50     : in std_logic; --clock 50 MHz
		 EXT_CLOCK    : in std_logic; --clock externo MHz
		 SW : in std_logic_vector(17 downto 0); --chaves
		 KEY : in std_logic_vector(3 downto 0); --clics
		 LEDR : out std_logic_vector(17 downto 0); -- leds vermelhos
		 LEDG : out std_logic_vector(8 downto 0):="000000000"; -- leds verde
		 --Displays 7 sementos
		 HEX0: out std_logic_vector(6 downto 0); 
		 HEX1: out std_logic_vector(6 downto 0);
		 HEX2: out std_logic_vector(6 downto 0);
		 HEX3: out std_logic_vector(6 downto 0);
		 HEX4: out std_logic_vector(6 downto 0);
		 HEX5: out std_logic_vector(6 downto 0);
		 HEX6: out std_logic_vector(6 downto 0);
		 HEX7: out std_logic_vector(6 downto 0);
		 --Diplay LCD
		 LCD_DATA : inout std_logic_vector(7 downto 0);
 		 LCD_RW,LCD_EN,LCD_RS,LCD_ON,LCD_BLON : OUT std_logic
		 );
		 
end main;


architecture arch_dispyy of main is	
		
component disp
	 port(
		 a : in integer range 0 to 9;
		 b : out std_logic_vector(6 downto 0)
	     );
end component;

component LCD_DISPLAY_nty

   PORT( 
      reset              : IN     std_logic; --Resetar
      clock_50           : IN     std_logic; --Clock
      
		--Diplay lcd
      lcd_rs             : OUT    std_logic;
      lcd_e              : OUT    std_logic;
      lcd_rw             : OUT    std_logic;
      lcd_on             : OUT    std_logic;
      lcd_blon           : OUT    std_logic;
      
      data_bus_0         : INOUT  STD_LOGIC;
      data_bus_1         : INOUT  STD_LOGIC;
      data_bus_2         : INOUT  STD_LOGIC;
      data_bus_3         : INOUT  STD_LOGIC;
      data_bus_4         : INOUT  STD_LOGIC;
      data_bus_5         : INOUT  STD_LOGIC;
      data_bus_6         : INOUT  STD_LOGIC;
      data_bus_7         : INOUT  STD_LOGIC;
      
      MAQ_ARRAY    : IN     STD_LOGIC
      
   );
end component;

signal int : integer range 0 to 9;
signal int1 : integer range 0 to 9;
signal int2 : integer range 0 to 9;
signal int3 : integer range 0 to 9;

signal maq_chaves : std_logic:='0';
signal saa : std_logic:='0';


signal sCount_Pulses    : integer range 0 to 27000000 := 0; -- Contador de Pulsos de 27MHz
signal sSelect          : integer range 0 to 27000000 := 13499999; -- 13499999
signal sSlow_Clock      : std_logic := '0';                 -- Clock de saída

--
begin


-- Processo: Gera Clock
Clock:  process (CLOCK_27)
        begin
        if rising_edge (CLOCK_27) then

            if (sCount_Pulses = sSelect) then
                sSlow_Clock <= not (sSlow_Clock);
                sCount_Pulses <= 0;
            else
                sCount_Pulses <= sCount_Pulses + 1;
            end if;
				
        end if;
		  
    end process;
	 
	 process(CLOCK_27)
	 begin
	 	 if(SW(0)='1')then LEDR(0)<='1'; else LEDR(0)<='0'; end if;
		 if(SW(1)='1')then LEDR(1)<='1'; else LEDR(1)<='0'; end if;
		 if(SW(2)='1')then LEDR(2)<='1'; else LEDR(2)<='0'; end if;
		 if(SW(3)='1')then LEDR(3)<='1'; else LEDR(3)<='0'; end if;
		 if(SW(4)='1')then LEDR(4)<='1'; else LEDR(4)<='0'; end if;
		 if(SW(5)='1')then LEDR(5)<='1'; else LEDR(5)<='0'; end if;
		 if(SW(6)='1')then LEDR(6)<='1'; else LEDR(6)<='0'; end if;
		 if(SW(7)='1')then LEDR(7)<='1'; else LEDR(7)<='0'; end if;
		 if(SW(8)='1')then LEDR(8)<='1'; else LEDR(8)<='0'; end if;
		 if(SW(9)='1')then LEDR(9)<='1'; else LEDR(9)<='0'; end if;
		 if(SW(10)='1')then LEDR(10)<='1'; else LEDR(10)<='0'; end if;
		 if(SW(11)='1')then LEDR(11)<='1'; else LEDR(11)<='0'; end if;
		 if(SW(12)='1')then LEDR(12)<='1'; else LEDR(12)<='0'; end if;
		 if(SW(13)='1')then LEDR(13)<='1'; else LEDR(13)<='0'; end if;
		 if(SW(14)='1')then LEDR(14)<='1'; else LEDR(14)<='0'; end if;
		 if(SW(15)='1')then LEDR(15)<='1'; else LEDR(15)<='0'; end if;
		 if(SW(16)='1')then LEDR(16)<='1'; else LEDR(16)<='0'; end if;
		 if(SW(17)='1')then LEDR(17)<='1'; else LEDR(17)<='0'; end if;
		 
	 end process;

process (SW)
variable aa : std_logic :=	'1';
variable ii : std_logic :=	'0';
begin
-- 

 if(aa = '0') then
		 case SW is
			when "100110000000000000" =>
			if(KEY(0)='0')then 
					ii := '1';
					aa := '1';
					LEDG <= "111111111";
					else ii := '0'; LEDG <= "000000000";
			end if;
			when others => 		
			      ii := '0'; LEDG <= "000000000";
		  end case;	
 end if;
 
 if(aa = '1') then
    if(KEY(1)='0')then 
			ii := '0';
			aa := '0';
			LEDG <= "000000000";
     end if;
 else aa:='0';
 end if;
 
saa <= aa;
maq_chaves <= ii;
end process;
	 
process(sSlow_Clock)

variable estado0 : integer range 0 to 10;
variable estado1 : integer range 0 to 10;
variable estado2 : integer range 0 to 10;
variable estado3 : integer range 0 to 10;
begin

if(saa = '0') then
if (sSlow_Clock = '1') then
if (estado0 <= 10) then
estado0 := estado0 + 1;
end if;
if (estado0 = 10) then
estado1 := estado1 + 1;
estado0 :=0;
end if;
if (estado1 = 6) then
estado2 := estado2 + 1;
estado1 :=0;
end if;
if (estado2 = 10) then
estado3 := estado3 + 1;
estado2 := 0;
end if;
if (estado3 = 6) then
estado0 := 0;
estado1 := 0;
estado2 := 0;
estado3 := 0;
end if;
end if;
int <= estado0;
int1 <= estado1;
int2 <= estado2;
int3 <= estado3;
else 
end if;

if(saa = '1') then
estado0 :=0;
estado1 :=0;
estado2 :=0;
estado3 :=0;
end if;

end process;

a0 : disp port map (int, HEX0);
a1 : disp port map (int1, HEX1);
a2 : disp port map (int2, HEX2);
a3 : disp port map (int3, HEX3);
a4 : disp port map (0, HEX4);
a5 : disp port map (0, HEX5);
a6 : disp port map (0, HEX6);
a7 : disp port map (0, HEX7);

a8 : LCD_DISPLAY_nty port map (KEY(3),CLOCK_50,LCD_RS,LCD_EN,LCD_RW,LCD_ON,LCD_BLON,
LCD_DATA(0),LCD_DATA(1),LCD_DATA(2),LCD_DATA(3),LCD_DATA(4),LCD_DATA(5),LCD_DATA(6),
LCD_DATA(7),maq_chaves);

end arch_dispyy;