---------------------------------------------------------------------------------
-- Bagman - Dar - Feb 2014
-- See README for explanation about sram loading or vhdl rom files.
-- port to papilio
--
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all,ieee.numeric_std.all;

entity bagman is
port(
  CLK_IN  : in std_logic;
  I_RESET        : in std_logic;  -- active high reset
  
  O_AUDIO_L : out std_logic;
  O_AUDIO_R : out std_logic;
  
  --ps2_clk      : in std_logic;
  --ps2_dat      : in std_logic;
  
  -- SRAM
 sram_addr		: out		std_logic_vector(20 downto 0);	-- SRAM address bus
 sram_data		: inout	std_logic_vector(7 downto 0);	-- SRAM data bus
 SRAM_nCS		: out		std_logic;								-- SRAM chip select active low
 SRAM_nWE		: out		std_logic;								-- SRAM write enable active low
 SRAM_nOE		: out		std_logic;								-- SRAM output enable active low
  
  vga_r      : out std_logic_vector(3 downto 0);
  vga_g      : out std_logic_vector(3 downto 0);
  vga_b      : out std_logic_vector(3 downto 0);
  
  
  video_hs     : out std_logic;
  video_vs     : out std_logic;
  
  JOYSTICK1_1 : in std_logic;
  JOYSTICK1_2 : in std_logic;
  JOYSTICK1_3 : in std_logic;
  JOYSTICK1_4 : in std_logic;
  JOYSTICK1_6 : in std_logic;
  
  SW_LEFT  : in std_logic;
  SW_RIGHT : in std_logic
  
);
end bagman;

architecture struct of bagman is

-- clocks
signal clock_12mhz  : std_logic := '0';
signal clock_1mhz   : std_logic := '0';
signal div3_clk     : unsigned(1 downto 0) := "00";
signal div35_clk    : unsigned(5 downto 0) := "000000";

signal sound_string : std_logic_vector(12 downto 0);
--signal sram_addr    : std_logic_vector(16 downto 0);
signal sram_we      : std_logic;
--signal sram_data    : std_logic_vector(7 downto 0);
signal tv15Khz_mode : std_logic := '0';

signal video_clk    : std_logic;
signal video_r      : std_logic_vector(2 downto 0);
signal video_g      : std_logic_vector(2 downto 0);
signal video_b      : std_logic_vector(1 downto 0);

-- video syncs
signal hsync       : std_logic;
signal vsync       : std_logic;
signal csync       : std_logic;
signal blank       : std_logic;

-- global synchronisation
signal addr_state : std_logic_vector(3 downto 0);
signal is_sprite  : std_logic;
signal sprite     : std_logic_vector(2 downto 0);
signal x_tile     : std_logic_vector(4 downto 0);
signal y_tile     : std_logic_vector(4 downto 0);
signal x_pixel    : std_logic_vector(2 downto 0);
signal y_pixel    : std_logic_vector(2 downto 0);
signal y_line     : std_logic_vector(7 downto 0);

-- background and sprite tiles and graphics
signal tile_code   : std_logic_vector(12 downto 0);
signal tile_color  : std_logic_vector(3 downto 0);
signal tile_graph1 : std_logic_vector(7 downto 0);
signal tile_graph2 : std_logic_vector(7 downto 0);
signal x_sprite    : std_logic_vector(7 downto 0);
signal y_sprite    : std_logic_vector(7 downto 0);
signal inv_sprite  : std_logic_vector(1 downto 0);
signal keep_sprite : std_logic;

signal tile_color_r  : std_logic_vector(3 downto 0);
signal tile_graph1_r : std_logic_vector(7 downto 0);
signal tile_graph2_r : std_logic_vector(7 downto 0);

signal pixel_color   : std_logic_vector(5 downto 0);
signal pixel_color_r : std_logic_vector(5 downto 0);

signal y_diff_sprite      : std_logic_vector (7 downto 0);
signal sprite_pixel_color : std_logic_vector(5 downto 0);
signal do_palette         : std_logic_vector(7 downto 0);

signal addr_ram_sprite : std_logic_vector(8 downto 0);
signal is_sprite_r     : std_logic;

type ram_256x6 is array(0 to 255) of std_logic_vector(5 downto 0);
signal ram_sprite : ram_256x6;

-- (s)ram loader
signal load_addr : std_logic_vector(16 downto 0);
signal load_data : std_logic_vector(7 downto 0);
signal load_we   : std_logic;
signal loading   : std_logic;

-- Z80 interface
signal cpu_clock  : std_logic;
signal cpu_wr_n   : std_logic;
signal cpu_addr   : std_logic_vector(15 downto 0);
signal cpu_data   : std_logic_vector(7 downto 0);
signal cpu_di     : std_logic_vector(7 downto 0);
signal cpu_mreq_n : std_logic;
signal cpu_int_n  : std_logic;
signal cpu_iorq_n : std_logic;
signal cpu_di_mem : std_logic_vector(7 downto 0);

signal misc_we_n   : std_logic;
signal raz_int_n   : std_logic;
signal sound_cs_n  : std_logic;
signal speech_we_n : std_logic;

-- data bus from sram when read by cpu
signal sram_data_to_cpu : std_logic_vector(7 downto 0);

-- data bus from AY-3-8910
signal ym_8910_data : std_logic_vector(7 downto 0);

-- audio
signal ym_8910_audio : std_logic_vector(7 downto 0);
signal music         : unsigned(12 downto 0);
signal speech        : unsigned(12 downto 0);
signal speech_sample : integer range -512 to 511;
--
-- keyboard to joystick
signal kbd_int       : std_logic;
signal kbd_scan_code : unsigned(7 downto 0);
signal joy_pcfrldu   : std_logic_vector(6 downto 0);

-- random generator
signal pal16r6_data : std_logic_vector(5 downto 0);

-- line doubler I/O
signal video_i : std_logic_vector (7 downto 0);
signal video_o : std_logic_vector (7 downto 0);
signal hsync_o : std_logic;
signal vsync_o : std_logic;

signal RESET2 : std_logic := '0';
signal LOCKED : std_logic;

signal dac_o  : std_logic := '0';
signal reset : std_logic := '0';
begin



m_clock : entity work.clock
port map
   (-- Clock in ports
    CLK_IN1 => CLK_IN,
    -- Clock out ports
    CLK_OUT1 => clock_12mhz,
	 CLK_OUT2 => clock_1mhz,
    -- Status and control signals
    RESET  => RESET2,
    LOCKED => LOCKED);

m_dac : entity work.dac
generic map(msbi_g  => 12)
port map(
		clk_i => clock_12mhz,
		res_n_i => reset,
		dac_i   => sound_string,
		dac_o   => dac_o);
------------------
-- video output
------------------
video_i     <= do_palette when blank = '0' else (others => '0');
video_r     <= video_o(2 downto 0) when tv15Khz_mode = '0' else video_i(2 downto 0);
video_g     <= video_o(5 downto 3) when tv15Khz_mode = '0' else video_i(5 downto 3);
video_b     <= video_o(7 downto 6) when tv15Khz_mode = '0' else video_i(7 downto 6);
video_clk   <= clock_12mhz;

video_hs    <= hsync_o;
video_vs    <= vsync_o;
reset <= not I_RESET;
SRAM_nCS <= '0';
SRAM_nWE <= not sram_we;
SRAM_nOE <= sram_we; 

O_AUDIO_L <= dac_o;
O_AUDIO_R <= dac_o;


joy_pcfrldu(0) <= not JOYSTICK1_1;
joy_pcfrldu(1) <= not JOYSTICK1_2;
joy_pcfrldu(2) <= not JOYSTICK1_3;
joy_pcfrldu(3) <= not JOYSTICK1_4;
joy_pcfrldu(4) <= not JOYSTICK1_6;  -- jump
joy_pcfrldu(5) <=  SW_LEFT;
joy_pcfrldu(6) <=  SW_RIGHT;



vga_r <= (std_logic_vector(video_r) & '0');
vga_g <= (std_logic_vector(video_g) & '0');
vga_b <= (std_logic_vector(video_b) & "00");
-----------------------
-- cpu write addressing
-----------------------
speech_we_n <= '0' when cpu_mreq_n = '0' and cpu_wr_n = '0' and cpu_addr(15 downto 11) = "10101" else '1';
misc_we_n   <= '0' when cpu_mreq_n = '0' and cpu_wr_n = '0' and cpu_addr(15 downto 11) = "10100" else '1';

-------------------------------
-- latch interrupt at last line 
-------------------------------
process(clock_12mhz, raz_int_n)
begin
	if raz_int_n = '0' then
		cpu_int_n <= '1';
	else
		if rising_edge(clock_12mhz) then
			if y_tile = "11100" and y_pixel = "000" then
				cpu_int_n <= '0';
			end if;
		end if;
	end if;
end process;

---------------------------
-- enable/disable interrupt
-- chip select sound
---------------------------
process (cpu_clock)
begin
	if falling_edge(cpu_clock) then
		if misc_we_n = '0' then
		
			if cpu_addr(2 downto 0) = "000" then
				raz_int_n <= cpu_data(0);
			end if;

			if cpu_addr(2 downto 0) = "111" then
				sound_cs_n <= cpu_data(0);
			end if;

			end if;
	end if;
end process;

------------------------------------
-- mux cpu memory data read 
------------------------------------
with cpu_addr(15 downto 11) select 
	cpu_di_mem <=
		"00000000"          when "10110", -- dip switch
		"00" & pal16r6_data when "10100", -- rd4, random generator
		sram_data_to_cpu    when others;

------------------------------------
-- mux cpu memory and io data read
------------------------------------
with cpu_iorq_n select   
	cpu_di <=
		ym_8910_data when '0',
		cpu_di_mem   when others ;

-----------------------
-- mux sound and music
-----------------------
speech       <= "0" & to_unsigned((speech_sample+512),10) & "00";
music        <= "0000" & unsigned(ym_8910_audio) & '0';
sound_string <= std_logic_vector(music + speech);



------------------------------------
-- sram addressing scheme : 16 slots
------------------------------------
process(clock_12mhz)
begin
	if rising_edge(clock_12mhz) then
		sram_addr <= (others => '1');
		sram_we <= '0';
		sram_data <= (others => 'Z');
		if loading = '1' then
			sram_addr <= "0000" & load_addr;
			sram_we <= load_we;
			sram_data <= load_data;
		else
		------------------------------------------------- x sprite
		if addr_state = "0000" then
				sram_addr <= "00000" & X"98" & "000" & sprite & "11";
		------------------------------------------------- y sprite
		elsif addr_state ="0001" then
				sram_addr <= "00000" & X"98" & "000" & sprite & "10";
		------------------------------------------------- cpu
		elsif addr_state ="0010" then
			sram_addr <= "00000" & cpu_addr;
			if cpu_wr_n = '0' and cpu_mreq_n = '0' then
				sram_data <= cpu_data;
				sram_we <= '1';
			end if;
		------------------------------------------------- background/sprite tile code
			elsif addr_state ="0011" then
			if is_sprite = '1' then
				sram_addr <= "00000" & X"98" & "000" & sprite & "00";
			else
				sram_addr <= "00000" & X"9" & "00" & y_tile & x_tile;
			end if;
		------------------------------------------------- background/sprite color
			elsif addr_state ="0100" then
			if is_sprite = '1' then
				sram_addr <= "00000" & X"98" & "000" & sprite & "01";
			else
				sram_addr <= "00000" & X"9" & "10" & y_tile & x_tile;
			end if;
		------------------------------------------------- cpu
		elsif addr_state ="0110" then
			sram_addr <= "00000" & cpu_addr;
			if cpu_wr_n = '0' and cpu_mreq_n = '0' then
				sram_data <= cpu_data;
				sram_we <= '1';
			end if;
		------------------------------------------------- background/sprite graph 1 0x10000
		elsif addr_state ="0111" then
			sram_addr <= "00001000" & tile_code;
		------------------------------------------------- background/sprite graph 2 0x12000
		elsif addr_state ="1000" then
			sram_addr <= "00001001" & tile_code;
		------------------------------------------------- cpu
		elsif addr_state ="1010" then
			sram_addr <= "00000" & cpu_addr;
			if cpu_wr_n = '0' and cpu_mreq_n = '0' then
				sram_data <= cpu_data;
				sram_we <= '1';
			end if;
		------------------------------------------------- cpu
		elsif addr_state ="1110" then
			sram_addr <= "00000" & cpu_addr;
			if cpu_wr_n = '0' and cpu_mreq_n = '0' then
				sram_data <= cpu_data;
				sram_we <= '1';
			end if;
		end if;
		end if;
	end if;
end process;

--------------------------------------
-- sram reading background/sprite data
--------------------------------------
process(clock_12mhz)
begin
	if rising_edge(clock_12mhz) then
		if    addr_state = "0001" then
			if x_tile(0) = '0' then
				x_sprite <= sram_data;
			end if;
		elsif addr_state = "0010" then
			y_sprite <= sram_data;
		elsif addr_state = "0011" then
			sram_data_to_cpu <= sram_data;
		elsif addr_state = "0100" then
			if is_sprite = '1' then
				if sram_data(7) = '1' then
					tile_code(10 downto 0) <= sram_data(5 downto 0) & not (y_diff_sprite(3)) & x_tile(0) & not(y_diff_sprite(2 downto 0));
				else
					tile_code(10 downto 0) <= sram_data(5 downto 0) & y_diff_sprite(3) & x_tile(0) & y_diff_sprite(2 downto 0);
				end if;
				inv_sprite <= sram_data(7 downto 6);
			else
				tile_code(10 downto 0) <= sram_data & y_pixel;
			end if;
		elsif addr_state = "0101" then
			tile_code(12 downto 11) <= sram_data(4 ) & sram_data(5);
			tile_color <= sram_data(3 downto 0);
		elsif addr_state = "0111" then
			sram_data_to_cpu <= sram_data;
		elsif addr_state = "1000" then
			tile_graph1 <= sram_data;
		elsif addr_state = "1001" then
			tile_graph2 <= sram_data;
		elsif addr_state = "1011" then
			sram_data_to_cpu <= sram_data;
		elsif addr_state = "1111" then
			sram_data_to_cpu <= sram_data;
			tile_color_r <= tile_color;
			tile_graph1_r <= tile_graph1;
			tile_graph2_r <= tile_graph2;
			is_sprite_r <= is_sprite;
			keep_sprite <= '0';
			if (y_diff_sprite(7 downto 4) = "1111") and (x_sprite > "00000000") and (y_sprite > "00000000") then
					keep_sprite <= '1';
			end if;
		end if;
	end if;
end process;

--------------------------------
-- sprite y position
--------------------------------
y_line <= y_tile & y_pixel;
y_diff_sprite <= std_logic_vector(unsigned(y_line) + unsigned(y_sprite) + 1);

------------------------------------------
-- read/write sprite line-memory addresing
------------------------------------------
process (clock_12mhz)
begin 
	if rising_edge(clock_12mhz) then
	
		if addr_state(0) = '1' then
			addr_ram_sprite <= std_logic_vector(unsigned(addr_ram_sprite) + to_unsigned(1,8));
		else
			addr_ram_sprite <= addr_ram_sprite;
		end if;
		
		if is_sprite = '1' and addr_state = "1111" and x_tile(0) = '0' then
			addr_ram_sprite <= '0' & x_sprite;
		end if;

		if is_sprite = '0' and addr_state = "1111" and x_tile = "00000" then
			addr_ram_sprite <= "000000001";
		end if;
		
	end if;
end process;

-------------------------------------
-- read/write sprite line-memory data
-------------------------------------
process (clock_12mhz)
begin
	if rising_edge(clock_12mhz) then
		if addr_state(0) = '0' then
			sprite_pixel_color <= ram_sprite(to_integer(unsigned(addr_ram_sprite)));
		else
			if is_sprite_r = '1' then
				if (keep_sprite = '1') and (addr_ram_sprite(8) = '0') then
						ram_sprite(to_integer(unsigned(addr_ram_sprite))) <= pixel_color_r;
				end if;
			else
				ram_sprite(to_integer(unsigned(addr_ram_sprite))) <= (others => '0');
			end if;
		end if;
	end if;
end process;

-----------------------------------------------------------------
-- serialize background/sprite graph to pixel + concatenate color
-----------------------------------------------------------------
process (clock_12mhz)
begin
	if rising_edge(clock_12mhz) then
pixel_color <=	tile_color_r & 
								tile_graph1_r(to_integer(unsigned(not x_pixel))) &
								tile_graph2_r(to_integer(unsigned(not x_pixel)));
	end if;
end process;

-------------------------------------------------
-- mux sprite color with background/sprite color
-------------------------------------------------
with sprite_pixel_color(1 downto 0) select
pixel_color_r <= pixel_color when "00", sprite_pixel_color when others;

-------------------------------------------------
video : entity work.video_gen
port map (
	clock_12mhz => clock_12mhz,
	hsync   => hsync,
	vsync   => vsync,
	csync   => csync,
	blank   => blank,

	addr_state => addr_state,
	is_sprite  => is_sprite,
	sprite     => sprite,
	x_tile     => x_tile,
	y_tile     => y_tile,
	x_pixel    => x_pixel,
	y_pixel    => y_pixel,

	cpu_clock  => cpu_clock
);

line_doubler : entity work.line_doubler
port map(
	clock_12mhz => clock_12mhz,
	video_i     => video_i,
	hsync_i     => hsync,
	vsync_i     => vsync,
	video_o     => video_o,
	hsync_o     => hsync_o,
	vsync_o     => vsync_o
);

palette : entity work.bagman_palette
port map (
	addr => pixel_color_r,
	clk  => clock_12mhz,
	data => do_palette 
);

Z80 : entity work.T80s
generic map(Mode => 0, T2Write => 1, IOWait => 1)
port map(
	RESET_n => not loading,
	CLK_n   => cpu_clock,
	WAIT_n  => '1',
	INT_n   => cpu_int_n,
	NMI_n   => '1',
	BUSRQ_n => '1',
	M1_n    => open,
	MREQ_n  => cpu_mreq_n,
	IORQ_n  => cpu_iorq_n,
	RD_n    => open,
	WR_n    => cpu_wr_n,
	RFSH_n  => open,
	HALT_n  => open,
	BUSAK_n => open,
	A       => cpu_addr,
	DI      => cpu_di,
	DO      => cpu_data
);

ym2149 : entity work.ym2149
port map (
-- data bus
	I_DA        => cpu_data,
	O_DA        => ym_8910_data,
	O_DA_OE_L   => open,
-- control
	I_A9_L      => sound_cs_n,
	I_A8        =>     cpu_iorq_n or cpu_addr(3),
	I_BDIR      => not(cpu_iorq_n or cpu_addr(2)),
	I_BC2       => not(cpu_iorq_n or cpu_addr(1)),
	I_BC1       => not(cpu_iorq_n or cpu_addr(0)),
	I_SEL_L     => '1',
	O_AUDIO     => ym_8910_audio,
-- port a
	I_IOA       => not(joy_pcfrldu(4) & joy_pcfrldu(1) & joy_pcfrldu(0) & joy_pcfrldu(3) & joy_pcfrldu(2) & joy_pcfrldu(5) & '0' & joy_pcfrldu(6)),
	O_IOA       => open,
	O_IOA_OE_L  => open,
-- port b
	I_IOB       => "11111111",
	O_IOB       => open,
	O_IOB_OE_L  => open,

	ENA         => '1',
	RESET_L     => '1',
	CLK         => x_pixel(1) -- note 6 Mhz!
);

--kdb : entity work.io_ps2_keyboard
--port map (
--	clk       => clock_12mhz,
--	kbd_clk   => ps2_clk,
--	kbd_dat   => ps2_dat,
--	interrupt => kbd_int,
--	scanCode  => kbd_scan_code
--);
--
--joystick : entity work.kbd_joystick
--port map (
--	clk           => clock_12mhz,
--	kbd_int       => kbd_int,
--	kbd_scan_code => std_logic_vector(kbd_scan_code), 
--	joy_pcfrldu   => joy_pcfrldu
--);

bagman_speech : entity work.bagman_speech
port map(
	Clk1MHz      => clock_1mhz,
	hclkn        => cpu_clock,
	adrCpu       => cpu_addr(2 downto 0),
	doCpu        => cpu_data(0),
	weSelSpeech  => speech_we_n,
	SpeechSample => speech_sample
); 

pal16r6 : entity work.bagman_pal16r6
port map(
	clk  => vsync,
	addr => cpu_addr(6 downto 0),
	data => pal16r6_data
);

-------------------------------------------
-- Uncomment only one of the two part below
------------------------------------------- use internal sram loader
ram_loader : entity work.ram_loader
port map(
clock    => clock_12mhz,
reset    => reset,
	address  => load_addr,
	data     => load_data,
	we       => load_we,
	loading  => loading
);
------------------------------------------- use external sram loader
--	load_addr <= '0'& X"0000";
--	load_data <= X"00";
--	load_we   <= '0';
--	loading   <= not reset;
------------------------------------------


end architecture;