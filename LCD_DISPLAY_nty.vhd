
LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY LCD_DISPLAY_nty IS

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

-- Declarações

END LCD_DISPLAY_nty ;

--
ARCHITECTURE LCD_DISPLAY_arch OF LCD_DISPLAY_nty IS
  type character_string is array ( 0 to 31 ) of STD_LOGIC_VECTOR( 7 downto 0 );
  
  type state_type is (hold, func_set, display_on, mode_set, print_string,
                      line2, return_home, drop_lcd_e, reset1, reset2,
                       reset3, display_off, display_clear);
                       
  signal state, next_command         : state_type;
  
  
  signal lcd_display_string_01       : character_string;
  signal lcd_display_string_00       : character_string;
  
  signal data_bus_value, next_char   : STD_LOGIC_VECTOR(7 downto 0);
  signal clk_count_400hz             : STD_LOGIC_VECTOR(19 downto 0);
  
  signal char_count                  : STD_LOGIC_VECTOR(4 downto 0);
  signal clk_400hz_enable,lcd_rw_int : std_logic;
  
  signal Hex_Data            : STD_LOGIC_VECTOR(7 DOWNTO 0); 
  signal data_bus                    : STD_LOGIC_VECTOR(7 downto 0);	
  signal LCD_CHAR_ARRAY              : STD_LOGIC;
  
  
BEGIN
  


--===================================================--  
-- SIGNAL STD_LOGIC_VECTORS assigned to OUTPUT PORTS 
--===================================================--    

data_bus_0 <= data_bus(0);
data_bus_1 <= data_bus(1);
data_bus_2 <= data_bus(2);
data_bus_3 <= data_bus(3);
data_bus_4 <= data_bus(4);
data_bus_5 <= data_bus(5);
data_bus_6 <= data_bus(6);
data_bus_7 <= data_bus(7);
    
LCD_CHAR_ARRAY <= MAQ_ARRAY;

  lcd_display_string_01 <= 
  (
-- Line 1    M     e    n     s    a      g     e     m     :  
          x"4D",x"65",x"6E",x"73",x"61",x"67",x"65",x"6D",x"3A",x"20",x"20",x"20",x"20",x"20",x"20",x"20",
   
-- Line 2   T     r     a     b     a     l     h     o          e     m           V     H     D     L  
          x"54",x"72",x"61",x"62",x"61",x"6C",x"68",x"6F",x"20",x"65",x"6D",x"20",x"56",x"48",x"44",x"4C" 
   );

 
   lcd_display_string_00 <= 
       (
-- Line 1    I    n     s      e    r     i     r           c     h     a     v     e           e
          x"49",x"6E",x"73",x"65",x"72",x"69",x"72",x"20",x"63",x"68",x"61",x"76",x"65",x"20",x"65",x"20",
   
-- Line 2    p     r     e     c     i     o    n     a     r           b      o    t     a     o
          x"70",x"72",x"65",x"63",x"69",x"6F",x"6E",x"61",x"72",x"20",x"62",x"6F",x"74",x"61",x"6F",x"20" 
   );

-------------------------------------------------------------------------------------------------------
-- BUS BIDIRECTIONAL TRI ESTADO DE DADOS LCD
   data_bus <= data_bus_value when lcd_rw_int = '0' else "ZZZZZZZZ";
   
-- LCD_RW PORT é atribuído ao correspondente SINAL
 lcd_rw <= lcd_rw_int;
 
-------------------------- MÁQUINA DE ESTADO PARA SELEÇÃO DE MENSAGEM DE TELA LCD -----------------------------
---------------------------------------------------------------------------------------------------------------
PROCESS (LCD_CHAR_ARRAY)
BEGIN
  
-- obtém o próximo caractere na seqüência de exibição com base no LCD_CHAR_ARRAY (comutadores ou Multiplexador)

     CASE (LCD_CHAR_ARRAY) IS
          
          -- Chave
       WHEN '1' =>
            next_char <= lcd_display_string_01(CONV_INTEGER(char_count));
                                                                
       WHEN OTHERS =>              
               next_char <= lcd_display_string_00(CONV_INTEGER(char_count));
                                                     
       END CASE;
END PROCESS;
     
  
--=====================================================================-- 
--======================= CLOCK #1 SIGNAis============================--  
--=====================================================================-- 
process(clock_50)
begin
      if (rising_edge(clock_50)) then
         if (reset = '0') then
            clk_count_400hz <= x"00000";
            clk_400hz_enable <= '0';
         else
            if (clk_count_400hz <= x"0F424") then             
                   clk_count_400hz <= clk_count_400hz + 1;                                   
                   clk_400hz_enable <= '0';                
            else
                   clk_count_400hz <= x"00000";
                   clk_400hz_enable <= '1';
            end if;
         end if;
      end if;
end process;  
--==================================================================--   


--==================== NÚCLEO DO CONTROLADOR DO LCD ======================--   
--                      MÁQUINA DE ESTADO COM RESET                    -- 
--===================================================-----===============--  
process (clock_50, reset)
begin
 
  
        if reset = '0' then
           state <= reset1;
           data_bus_value <= x"38"; -- RESET
           next_command <= reset2;
           lcd_e <= '1';
           lcd_rs <= '0';
           lcd_rw_int <= '0';  
        
    
    
        elsif rising_edge(clock_50) then
             if clk_400hz_enable = '1' then  
                 
                 
                 
              --========================================================--                 
              -- State Machine to send commands and data to LCD DISPLAY
              --========================================================--
                 case state is
  -- Defina Function para transferência de 8 bits e exibição de 2 linhas com tamanho de fonte 5x8
  --  consulte a folha de dados da família Hitachi HD44780 para obter detalhes sobre o comando e o tempo do LCD
                       
                       
                       
--======================= INITIALIZAÇÃO ============================--
                       when reset1 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38"; -- RESET EXTERNO
                            state <= drop_lcd_e;
                            next_command <= reset2;
                            char_count <= "00000";
  
                       when reset2 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38"; -- RESET EXTERNO
                            state <= drop_lcd_e;
                            next_command <= reset3;
                            
                       when reset3 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38"; -- RESET EXTERNO
                            state <= drop_lcd_e;
                            next_command <= func_set;
            
            
                       -- Função Set
                       --==============--
                       when func_set =>                
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38";  -- Defina Function como transferência de 8 bits, exibição de 2 linhas e tamanho da fonte 5x8
                            state <= drop_lcd_e;
                            next_command <= display_off;
                            
                            
                            
                       -- Turn off Display
                       --==============-- 
                       when display_off =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"08"; -- DESLIGA o Visor, Cursor DESLIGADO e Posição do Cursor Piscando DESLIGADA ....... (0F = Visor LIGADO e Cursor LIGADO, Posição do cursor piscando LIGADA)
                            state <= drop_lcd_e;
                            next_command <= display_clear;
                           
                           
                       -- Limpa Display 
                       --==============--
                       when display_clear =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"01"; -- Limpa Display   
                            state <= drop_lcd_e;
                            next_command <= display_on;
                           
                           
                           
                       -- Ativar a tela e desligar o cursor
                       --===================================--
                       when display_on =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"0C"; -- Liga o display (0E = Display ON, Cursor ON e cursor piscando OFF) 
                            state <= drop_lcd_e;
                            next_command <= mode_set;
                          
                          
                       -- Defina o modo de gravação para aumentar o endereço automaticamente e mover o cursor para a direita
                       --====================================================================--
                       when mode_set =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"06"; -- Incrementar automaticamente o endereço e mover o cursor para a direita
                            state <= drop_lcd_e;
                            next_command <= print_string; 
                            
                                
--======================= INITIALIZAÇAO END ============================--                          
                          
                          
                          
                          
--=======================================================================--                           
--               Gravar dados de caracteres hexadecimais ASCII no LCD
--=======================================================================--
                       when print_string =>          
                            state <= drop_lcd_e;
                            lcd_e <= '1';
                            lcd_rs <= '1';
                            lcd_rw_int <= '0';
                          
                          
                               -- Caractere ASCII para saída
                               if (next_char(7 downto 4) /= x"0") then
                                  data_bus_value <= next_char;
                               else
                             
                                    -- Converter valor de 4 bits em um dígito hexadecimal ASCII
                                    if next_char(3 downto 0) >9 then 
                              
                                    -- ASCII A...F
                                      data_bus_value <= x"4" & (next_char(3 downto 0)-9); 
                                    else 
                                
                                    -- ASCII 0...9
                                      data_bus_value <= x"3" & next_char(3 downto 0);
                                    end if;
                               end if;
                          
                            state <= drop_lcd_e; 
                          
                          
                            -- Loop para enviar 32 caracteres para a tela LCD (16 por 2 linhas)
                               if (char_count < 31) AND (next_char /= x"fe") then
                                   char_count <= char_count +1;                            
                               else
                                   char_count <= "00000";
                               end if;
                  
                  
                  
                            -- Ir para a segunda linha?
                               if char_count = 15 then 
                                  next_command <= line2;
                   
                   
                   
                            -- Retornar à primeira linha?
                               elsif (char_count = 31) or (next_char = x"fe") then
                                     next_command <= return_home;
                               else 
                                     next_command <= print_string; 
                               end if; 
                 
                 
                 
                       -- Defina o endereço de gravação para o caractere 2 da linha 2
                       --======================================--
                       when line2 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"c0";
                            state <= drop_lcd_e;
                            next_command <= print_string;      
                     
                     
                       -- Retorne o endereço de gravação para a posição do primeiro caractere na linha 1
                       --=========================================================--
                       when return_home =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"80";
                            state <= drop_lcd_e;
                            next_command <= print_string; 
                    
--                    
--                       -- lcd_e corresponderá à linha clk_CUSTOM_hz_enable quando for instruído a ficar LOW, no entanto, se o relógio de origem clk_CUSTOM_hz_enable tiver que ser um valor de contagem mais baixo ou será redefinido LOW de qualquer maneira.
--                       -- Os próximos estados ocorrem no final de cada comando ou transferência de dados para o LCD
--            -- Soltar a linha E do LCD - a borda descendente carrega inst / dados no controlador LCD
--              -- ============================================================================--
                       when drop_lcd_e =>
                            lcd_e <= '0';
                            lcd_blon <= '1';
                            lcd_on   <= '1';
                            state <= hold;
                   
                       -- Mantenha inst / dados do LCD válidos após a borda descendente da linha E
                       --====================================================--
                       when hold =>
                            state <= next_command;
                            lcd_blon <= '1';
                            lcd_on   <= '1';
                       end case;




             end if;-- DECLARAÇÃO DE FECHAMENTO PARA "SE clk_400hz_enable = '1' THEN"
             
      end if;-- DECLARAÇÃO DE FECHAMENTO PARA "SE resetar = '0' ENTÃO"
      
end process;                                                            
  
END ARCHITECTURE LCD_DISPLAY_arch;




 
-- ASCII hex valores para o Display LCD 

------------------------------
--| Count=XX |
--| DE2 |
------------------------------


-- Acesso aos interruptores de entrada do visor HEX de 2 dígitos
-------------------------------------------------------------------------
 --   x"0"&Hex_Data(7 downto 4),x"0"&Hex_Data(3 downto 0), 

--   = x"20",
-- ! = x"21",
-- " = x"22",
-- # = x"23",
-- $ = x"24",
-- % = x"25",
-- & = x"26",
-- ' = x"27",
-- ( = x"28",
-- ) = x"29",
-- * = x"2A",
-- + = x"2B",
-- , = x"2C",
-- - = x"2D",
-- . = x"2E",
-- / = x"2F",



-- 0 = x"30",
-- 1 = x"31",
-- 2 = x"32",
-- 3 = x"33",
-- 4 = x"34",
-- 5 = x"35",
-- 6 = x"36",
-- 7 = x"37",
-- 8 = x"38",
-- 9 = x"39",
-- : = x"3A",
-- ; = x"3B",
-- < = x"3C",
-- = = x"3D",
-- > = x"3E",
-- ? = x"3F",




-- Q = x"40",
-- A = x"41",
-- B = x"42",
-- C = x"43",
-- D = x"44",
-- E = x"45",
-- F = x"46",
-- G = x"47",
-- H = x"48",
-- I = x"49",
-- J = x"4A",
-- K = x"4B",
-- L = x"4C",
-- M = x"4D",
-- N = x"4E",
-- O = x"4F",



-- P = x"50",
-- Q = x"51",
-- R = x"52",
-- S = x"53",
-- T = x"54",
-- U = x"55",
-- V = x"56",
-- W = x"57",
-- X = x"58",
-- Y = x"59",
-- Z = x"5A",
-- [ = x"5B",
-- Y! = x"5C",
-- ] = x"5D",
-- ^ = x"5E",
-- _ = x"5F",



-- \ = x"60",
-- a = x"61",
-- b = x"62",
-- c = x"63",
-- d = x"64",
-- e = x"65",
-- f = x"66",
-- g = x"67",
-- h = x"68",
-- i = x"69",
-- j = x"6A",
-- k = x"6B",
-- l = x"6C",
-- m = x"6D",
-- n = x"6E",
-- o = x"6F",



-- p = x"70",
-- q = x"71",
-- r = x"72",
-- s = x"73",
-- t = x"74",
-- u = x"75",
-- v = x"76",
-- w = x"77",
-- x = x"78",
-- y = x"79",
-- z = x"7A",
-- { = x"7B",
-- | = x"7C",
-- } = x"7D",
-- -> = x"7E",
-- <- = x"7F",




