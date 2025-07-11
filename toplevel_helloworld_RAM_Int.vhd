library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity toplevel is
    Port (   reset : in std_logic;
              clk : in std_logic;
               rx : in std_logic;
              tx : out std_logic;
             LED0 : out std_logic;
             LED1 : out std_logic;
             LED2 : out std_logic;
             LED3 : out std_logic);
end toplevel ;

architecture behavioral of toplevel is
----------------------------------------------------------------
-- declaracion del picoblaze
----------------------------------------------------------------
  component picoblaze
    Port (      address : out std_logic_vector(7 downto 0);
            instruction : in std_logic_vector(15 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
                  reset : in std_logic; 
						  clk : in std_logic);
    end component;

-----------------------------------------------------------------
-- declaraci�n de la ROM de programa
-----------------------------------------------------------------
  component programa_helloworld_int_FLIP 
    Port (      address : in std_logic_vector(7 downto 0);
            		   dout : out std_logic_vector(15 downto 0);
                    clk : in std_logic);
    end component;

-- Insert Clock Wizard component declaration just after the program ROM component declaration
  component clk_wiz_0
    port (
      clk_in1  : in  std_logic;
      reset    : in  std_logic;
      clk50    : out std_logic;
      locked   : out std_logic);
  end component;

-----------------------------------------------------------------
-- Signals usadas para conectar el picoblaze y la ROM de programa
-----------------------------------------------------------------
signal     address : std_logic_vector(7 downto 0);
signal instruction : std_logic_vector(15 downto 0);
		
-----------------------------------------------------------------
-- Signals para debugging 
-----------------------------------------------------------------
signal readstrobe: std_logic;
signal writestrobe: std_logic;
signal portid: std_logic_vector(7 downto 0);
signal inport: std_logic_vector(7 downto 0);
signal outport: std_logic_vector(7 downto 0);
signal picoint: std_logic;

type ram_type is array (0 to 63) of std_logic_vector (7 downto 0);
signal RAM : ram_type := (
x"0A", x"0D", x"2A", x"20", x"48", x"45", x"4C", x"4C",
x"4F", x"20", x"49", x"27", x"4D", x"20", x"41", x"4C",
x"49", x"56", x"45", x"21", x"20", x"3A", x"2D", x"44",
x"20", x"2A", x"0A", x"0D", x"2A", x"20", x"50", x"52",
x"45", x"53", x"53", x"20", x"41", x"4E", x"59", x"20",
x"4B", x"45", x"59", x"20", x"54", x"4F", x"20", x"43",
x"4F", x"4E", x"54", x"49", x"4E", x"55", x"45", x"20",
x"2A", x"0A", x"0D", x"00", x"00", x"00", x"00", x"00" );

signal rxbuff_out,RAM_out: std_logic_vector(7 downto 0);
signal LED_BAR : std_logic_vector(7 downto 0);

-- Add clock divider signals
-- signal clk_50mhz : std_logic := '0';
signal clk_counter : integer range 0 to 2 := 0;
-- Add internal clock signals in the signal section
signal clk_50    : std_logic;
signal clk_locked: std_logic;

begin

    LED0 <= LED_BAR(0);
    LED1 <= LED_BAR(1);
    LED2 <= LED_BAR(2);
    LED3 <= LED_BAR(3);

    -- reset indicator (optional): pulse LED0 on reset
    -- LED0 <= reset;

	-- Debug signals are kept internal; removed external ports
	picoint <= NOT rx;


  processor: picoblaze
    port map(      address => address,
               instruction => instruction,
                   port_id => portid,
              write_strobe => writestrobe,
                  out_port => outport,
               read_strobe => readstrobe,
                   in_port => inport,
                 interrupt => picoint,
                     reset => reset,
                       clk => clk_50);

  program: programa_helloworld_int_FLIP
    port map(     address => address,
               	     dout => instruction,
                      clk => clk_50);

	--registra el bit tx del puerto de salida, por siste cambia
	txbuff:process(reset, clk_50)
	begin
		if (reset='1') then
			tx <= '1';
		elsif rising_edge(clk_50) then
			if (writestrobe = '1' and portid=x"FF") then
				tx <= outport(0);	
			end if;
		end if;
	end process;
	
	--aade 7ceros a rx para meterlos al puerto de entrada cuando se lea
	rxbuff:process(reset, clk_50)
	begin
		if (reset='1') then
			rxbuff_out <= (others=>'1');
		elsif rising_edge(clk_50) then
			if (readstrobe = '1' and portid =x"FF") then
				rxbuff_out <= rx & "0000000";	
			end if;		 
		end if;
	end process;
	
	-- Memoria RAM (escritura sincrona / lectura asincrona)
	process (clk_50)
	begin
		if (clk_50'event and clk_50 = '1') then
            if (writestrobe = '1' and portid = x"01") then
                LED_BAR <= outport;
            elsif (writestrobe = '1' and portid<x"40") then
                RAM(to_integer(unsigned(portid))) <= outport;
            end if;
		end if;
	end process;
	RAM_out <= RAM(to_integer(unsigned(portid)));
	
-- Multiplexor inport
inport <= RAM_out when (readstrobe = '1' and portid<x"40") else
			 rxbuff_out when (readstrobe = '1' and portid=x"FF") else
			 x"00";

-- Instantiate the Clock Wizard right before the PicoBlaze instantiation
  clk_inst : clk_wiz_0
    port map (
      clk_in1  => clk,       -- 125 MHz board clock
      reset    => reset,     -- reuse push-button reset
      clk50    => clk_50,    -- 50 MHz generated clock
      locked   => clk_locked -- not used further
    );

end behavioral;