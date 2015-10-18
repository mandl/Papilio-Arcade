---------------------------------------------------------------------------------
-- Crazy kong (Falcon) - Dar - Feb 2014
-- See README for explanation about sram loading or vhdl rom files.

-- port to papilio
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all,ieee.numeric_std.all;

entity ckong is
port(
  CLK_IN         : in std_logic;  -- 32 Mhz
  I_RESET        : in std_logic;  -- active high reset
  
  O_AUDIO_L : out std_logic;
  O_AUDIO_R : out std_logic;
   
  
  vga_r      : out std_logic_vector(3 downto 0);
  vga_g      : out std_logic_vector(3 downto 0);
  vga_b      : out std_logic_vector(3 downto 0);
    
  
  video_hs     : out std_logic;
  video_vs     : out std_logic;
 
  
  sram_addr    : out std_logic_vector(20 downto 0);
  
  sram_data    : inout std_logic_vector(7 downto 0);
  SRAM_nCS		: out		std_logic;								-- SRAM chip select active low
  SRAM_nWE		: out		std_logic;								-- SRAM write enable active low
  SRAM_nOE		: out		std_logic;								-- SRAM output enable active low
  
  
  
  JOYSTICK1_1 : in std_logic;
  JOYSTICK1_2 : in std_logic;
  JOYSTICK1_3 : in std_logic;
  JOYSTICK1_4 : in std_logic;
  JOYSTICK1_6 : in std_logic;
  
  SW_LEFT  : in std_logic;
  SW_RIGHT : in std_logic
  
);
end ckong;

architecture struct of ckong is

-- clocks 
signal clock_12mhz : std_logic := '0';
signal CLK_48mhz: std_logic := '0';
signal RESET2 : std_logic := '0';
signal sram_we      : std_logic;
signal video_r      : std_logic_vector(2 downto 0);
signal video_g      : std_logic_vector(2 downto 0);
signal video_b      : std_logic_vector(1 downto 0);



signal sound_string : std_logic_vector(12 downto 0);
signal dac_o        : std_logic := '0';

signal reset        : std_logic;

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

signal pixel_color    : std_logic_vector(5 downto 0);
signal pixel_color_r  : std_logic_vector(5 downto 0);

signal y_add_sprite        : std_logic_vector (7 downto 0);
signal sprite_pixel_color  : std_logic_vector(5 downto 0);
signal do_palette          : std_logic_vector(7 downto 0);

signal addr_ram_sprite : std_logic_vector(8 downto 0);
signal is_sprite_r     : std_logic;

type ram_256x6 is array(0 to 255) of std_logic_vector(5 downto 0);
signal ram_sprite : ram_256x6;

-- big sprite tiles and graphics
signal x_big_sprite         : std_logic_vector(7 downto 0);
signal y_big_sprite         : std_logic_vector(7 downto 0);
signal y_add_big_sprite     : std_logic_vector(7 downto 0);
signal big_sprite_color     : std_logic_vector(5 downto 0);
signal big_sprite_graph1    : std_logic_vector(7 downto 0);
signal big_sprite_graph2    : std_logic_vector(7 downto 0);
signal xy_big_sprite        : std_logic_vector(7 downto 0);
signal big_sprite_tile_code : std_logic_vector(7 downto 0);
signal is_big_sprite_on     : std_logic;
signal x_big_sprite_counter : std_logic_vector(8 downto 0);

signal big_sprite_graph1_r1 : std_logic_vector(7 downto 0);
signal big_sprite_graph2_r1 : std_logic_vector(7 downto 0);
signal big_sprite_graph1_r2 : std_logic_vector(7 downto 0);
signal big_sprite_graph2_r2 : std_logic_vector(7 downto 0);

signal do_big_sprite_palette  : std_logic_vector(7 downto 0);
signal big_sprite_pixel_color : std_logic_vector(4 downto 0);

signal video_mux              : std_logic_vector(7 downto 0);

-- (s)ram loader
signal load_addr : std_logic_vector(16 downto 0):= (others => '0');
signal load_data : std_logic_vector(7 downto 0):= (others => '0');
signal load_we   : std_logic := '0';
signal loading   : std_logic :='1';

-- Z80 interface 
signal cpu_clock  : std_logic;
signal cpu_wr_n   : std_logic;
signal cpu_addr   : std_logic_vector(15 downto 0);
signal cpu_data   : std_logic_vector(7 downto 0);
signal cpu_di     : std_logic_vector(7 downto 0);
signal cpu_mreq_n : std_logic;
signal cpu_int_n  : std_logic;
signal cpu_iorq_n : std_logic;
signal cpu_di_mem   : std_logic_vector(7 downto 0);
signal cpu_addr_mod : std_logic_vector(15 downto 0);

signal reg4_we_n  : std_logic;
signal reg5_we_n  : std_logic;
signal reg6_we_n  : std_logic;
signal raz_int_n  : std_logic;

-- data bus from sram when read by cpu
signal sram_data_to_cpu : std_logic_vector(7 downto 0);

-- data bus from AY-3-8910
signal ym_8910_data : std_logic_vector(7 downto 0);

-- keyboard to joystick
signal kbd_int       : std_logic;
signal kbd_scan_code : unsigned(7 downto 0);
signal joy_pcfrldu   : std_logic_vector(6 downto 0) := (others => '0');

-- player I/O : one player only atm
signal player1  : std_logic_vector(7 downto 0);
signal coins    : std_logic_vector(7 downto 0);

-- line doubler I/O
signal video_i : std_logic_vector (7 downto 0);
signal video_o : std_logic_vector (7 downto 0);
signal hsync_o : std_logic;
signal vsync_o : std_logic;

-- frame counter for debug 
signal vsync_r : std_logic;
signal frame_counter : std_logic_vector(15 downto 0) := X"0000";

begin



------------------
-- video output
------------------
video_mux <= do_palette when is_big_sprite_on = '0' else do_big_sprite_palette;

video_i   <= video_mux when blank = '0' else (others => '0');

video_r     <= video_o(2 downto 0);
video_g     <= video_o(5 downto 3);
video_b     <= video_o(7 downto 6);

video_hs    <= hsync_o;
video_vs    <= vsync_o;

vga_r <= (std_logic_vector(video_r) & '0');
vga_g <= (std_logic_vector(video_g) & '0');
vga_b <= (std_logic_vector(video_b) & "00");


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

------------------
-- player controls
------------------
player1 <= ( joy_pcfrldu(3) & joy_pcfrldu(2) & joy_pcfrldu(1) & joy_pcfrldu(0) & joy_pcfrldu(4) & "000" );
coins   <= not( "00000" & joy_pcfrldu(5) & joy_pcfrldu(6) & '0');

-----------------------
-- cpu write addressing
-----------------------
reg4_we_n <= '0' when cpu_mreq_n = '0' and cpu_wr_n = '0' and cpu_addr(15 downto 11) = "10100" else '1';
reg5_we_n <= '0' when cpu_mreq_n = '0' and cpu_wr_n = '0' and cpu_addr(15 downto 11) = "10101" else '1';
reg6_we_n <= '0' when cpu_mreq_n = '0' and cpu_wr_n = '0' and cpu_addr(15 downto 11) = "10110" else '1';

---------------------------
-- enable/disable interrupt
---------------------------
process (cpu_clock)
begin
	if falling_edge(cpu_clock) then
		if cpu_addr(2 downto 0) = "000" and reg4_we_n = '0' then
			raz_int_n <= cpu_data(0);
		end if;
end if;
end process;

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

------------------------------------
-- mux cpu data mem read and io read
------------------------------------
with cpu_addr(15 downto 11) select 
	cpu_di_mem <=
		"00000000"       when "10110", -- dip switch
		player1          when "10100",
		coins            when "10111",
		sram_data_to_cpu when others;

cpu_di <= ym_8910_data when cpu_iorq_n = '0' else cpu_di_mem;

------------------------------------------------------
-- scrambled addressing mode for color ram 98XX (ckong)
------------------------------------------------------
with cpu_addr(15 downto 11) select
cpu_addr_mod <= "100110" & cpu_addr(10 downto 6) & cpu_addr(4 downto 0) when "10011",
								"100110" & cpu_addr(10 downto 6) & cpu_addr(4 downto 0) when "11011",
								cpu_addr when others;

-----------------------------
-- frame counter - debug
-----------------------------
--process(clock_12mhz)
--begin 
--	if rising_edge(clock_12mhz) then
--		vsync_r <= vsync;
--		
--		if vsync = '0' and vsync_r = '1' then
--			if frame_counter = X"FFFF" then
--				frame_counter <= X"0000";
--			else
--				frame_counter <= std_logic_vector(unsigned(frame_counter) + 1);
--			end if;
--		end if;
--		x_big_sprite <= frame_counter(9 downto 2);
--		big_sprite_color <= '0' & frame_counter(10) & "0000";
--	end if;
--end process;

------------------------------------
-- sram addressing scheme : 16 slots
------------------------------------
process(clock_12mhz)
begin
	if rising_edge(clock_12mhz) then
		sram_addr <= (others => '1');
		sram_we   <= '0';
		sram_data <= (others => 'Z');
		if loading = '1' then
			sram_addr <= "0000" & load_addr;
			sram_we   <= load_we;
			sram_data <= load_data;
		else
		------------------------------------------------- x sprite
		if    addr_state = "0000" then
--			sram_addr <= "0" & X"98" & "000" & sprite & "11"; -- bagman
				sram_addr <= "00000" & X"98" & "010" & sprite & "11"; -- ckong
		------------------------------------------------- y sprite
		elsif addr_state = "0001" then
--			sram_addr <= "0" & X"98" & "000" & sprite & "10"; -- bagman
				sram_addr <= "00000" & X"98" & "010" & sprite & "10"; -- ckong
		------------------------------------------------- cpu
		elsif addr_state = "0010" then
			sram_addr <= "00000" & cpu_addr_mod;
			if cpu_wr_n = '0' and cpu_mreq_n = '0' then
				sram_data <= cpu_data;
				sram_we <= '1';
			end if;
		------------------------------------------------- background/sprite tile code
		elsif addr_state = "0011" then
			if is_sprite = '1' then
--			sram_addr <= "0" & X"98" & "000" & sprite & "00"; -- bagman
				sram_addr <= "00000" & X"98" & "010" & sprite & "00"; -- ckong
			else
				sram_addr <= "00000" & X"9" & "00" & y_tile & x_tile;
			end if;
		------------------------------------------------- background/sprite color
		elsif addr_state = "0100" then
			if is_sprite = '1' then
--			sram_addr <= "0" & X"98" & "000" & sprite & "01"; -- bagman
				sram_addr <= "00000" & X"98" & "010" & sprite & "01"; -- ckong
			else
--			sram_addr <= "0" & X"9" & "00" & y_tile & x_tile; -- bagman
				sram_addr <= "00000" & X"9" & "10" & x_pixel(1) & y_tile(4 downto 1) & x_tile; -- ckong : scrambled addressing mode !
			end if;
		------------------------------------------------- big sprite x/y/color
		elsif addr_state = "0101" then
			if is_sprite = '1' then
				if sprite = "000" then
					sram_addr <= "00000" & X"987F"; -- X"98DF";
				end if;
				if sprite = "001" then
					sram_addr <= "00000" & X"987E"; -- X"98DE";
				end if;
				if sprite = "010" then
					sram_addr <= "00000" & X"987D"; -- X"98DD";
				end if;
			end if;
		------------------------------------------------- cpu
		elsif addr_state = "0110" then
			sram_addr <= "00000" & cpu_addr_mod;
			if cpu_wr_n = '0' and cpu_mreq_n = '0' then
				sram_data <= cpu_data;
				sram_we <= '1';
			end if;
		------------------------------------------------- background/sprite graph 1
		elsif addr_state = "0111" then
			sram_addr <= "00001000" & tile_code;
		------------------------------------------------- background/sprite graph 2
		elsif addr_state = "1000" then
			sram_addr <= "00001001" & tile_code;
		------------------------------------------------- big sprite tile code
		elsif addr_state = "1001" then
			sram_addr <= "00000" & X"88" & xy_big_sprite;
		------------------------------------------------- cpu
		elsif addr_state = "1010" then
			sram_addr <= "00000" & cpu_addr_mod;
			if cpu_wr_n = '0' and cpu_mreq_n = '0' then
				sram_data <= cpu_data;
				sram_we <= '1';
			end if;
		------------------------------------------------- big sprite graph 1
		elsif addr_state = "1011" then
			if big_sprite_color(5) ='0' then
				sram_addr <= "0000101000" & big_sprite_tile_code &     y_add_big_sprite(2 downto 0);
			else
				sram_addr <= "0000101000" & big_sprite_tile_code & not y_add_big_sprite(2 downto 0);
			end if;
		------------------------------------------------- big sprite graph 2
		elsif addr_state = "1100" then
			if big_sprite_color(5) ='0' then
				sram_addr <= "0000101001" & big_sprite_tile_code &     y_add_big_sprite(2 downto 0);
			else
				sram_addr <= "0000101001" & big_sprite_tile_code & not y_add_big_sprite(2 downto 0);
			end if;
		------------------------------------------------- n.u.
		elsif addr_state = "1101" then
		------------------------------------------------- cpu
		elsif addr_state ="1110" then
			sram_addr <= "00000" & cpu_addr_mod;
			if cpu_wr_n = '0' and cpu_mreq_n = '0' then
				sram_data <= cpu_data;
				sram_we <= '1';
			end if;
		------------------------------------------------- n.u.
		elsif addr_state = "1111" then
		-------------------------------------------------
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
					tile_code(10 downto 0) <= sram_data(5 downto 0) & not (y_add_sprite(3)) & (x_tile(0) xor sram_data(6)) & not(y_add_sprite(2 downto 0));
				else
					tile_code(10 downto 0) <= sram_data(5 downto 0) &      y_add_sprite(3)  & (x_tile(0) xor sram_data(6)) &     y_add_sprite(2 downto 0);
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

			is_sprite_r   <= is_sprite;
			tile_color_r  <= tile_color;
			
			tile_graph1_r <= tile_graph1;
			tile_graph2_r <= tile_graph2;
			if inv_sprite(0) = '1' and is_sprite = '1' then
				for i in 0 to 7 loop
					tile_graph1_r(i) <= tile_graph1(7-i);
					tile_graph2_r(i) <= tile_graph2(7-i);
				end loop;
			end if;

			keep_sprite <= '0';
			if (y_add_sprite(7 downto 4) = "1111") and (x_sprite /= X"00") and (y_sprite /= X"00") then
					keep_sprite <= '1';
			end if;
		end if;
	end if;
end process;

--------------------------------
-- sprite/ big sprite y position
--------------------------------
y_line           <= y_tile & y_pixel;
y_add_sprite     <= std_logic_vector(unsigned(y_line) + unsigned(y_sprite) + 1);
y_add_big_sprite <= std_logic_vector(unsigned(y_line) + unsigned(y_big_sprite));

------------------------------------------
-- read/write sprite line-memory addresing
------------------------------------------
process (clock_12mhz)
begin 
	if rising_edge(clock_12mhz) then

		if addr_state(0) = '1' then
			addr_ram_sprite <= std_logic_vector(unsigned(addr_ram_sprite) + to_unsigned(1,8));
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
pixel_color_r <= pixel_color when sprite_pixel_color(1 downto 0) = "00" else sprite_pixel_color;

----------------------------------
-- select big sprite tile address
----------------------------------
with big_sprite_color(5 downto 4) select
xy_big_sprite <=       y_add_big_sprite(6 downto 3)  & not(x_big_sprite_counter(7 downto 4)) when "00",
									not (y_add_big_sprite(6 downto 3)) & not(x_big_sprite_counter(7 downto 4)) when "10",
											 y_add_big_sprite(6 downto 3)  &    (x_big_sprite_counter(7 downto 4)) when "01",
									not (y_add_big_sprite(6 downto 3)) &    (x_big_sprite_counter(7 downto 4)) when others;

-------------------------------
-- sram reading big sprite data
-------------------------------
process (clock_12mhz)
begin 
	if rising_edge(clock_12mhz) then

		if addr_state = "0110" and is_sprite = '1' and sprite = "000" then
			x_big_sprite <= std_logic_vector(to_unsigned(172,8)-unsigned(sram_data));
		end if;

		if addr_state = "0110" and is_sprite = '1' and sprite = "001" then
			y_big_sprite <= sram_data;
		end if;

		if addr_state = "0110" and is_sprite = '1' and sprite = "010" then
			big_sprite_color <= sram_data(5 downto 0);
		end if;

		if addr_state = "1010" then
			big_sprite_tile_code <= sram_data;
		end if;

		if addr_state = "1100" then
			big_sprite_graph1 <= sram_data;
		end if;

		if addr_state = "1101" then
			big_sprite_graph2 <= sram_data;
		end if;

		if addr_state = "1000" and is_sprite = '1' and sprite = "001" then
			x_big_sprite_counter <= x_big_sprite & '1';
		else
			x_big_sprite_counter <= std_logic_vector(unsigned(x_big_sprite_counter) + to_unsigned(1,8));
		end if;

		if addr_state = "1000" then
			big_sprite_graph1_r1 <= big_sprite_graph1;
			big_sprite_graph2_r1 <= big_sprite_graph2;
			if big_sprite_color(4) = '1' then
				for i in 0 to 7 loop
					big_sprite_graph1_r1(i) <= big_sprite_graph1(7-i);
					big_sprite_graph2_r1(i) <= big_sprite_graph2(7-i);
				end loop;
			end if;
		end if;

		if x_big_sprite_counter(3 downto 1) = "111" and addr_state(0) = '1' then
			big_sprite_graph1_r2 <= big_sprite_graph1_r1;
			big_sprite_graph2_r2 <= big_sprite_graph2_r1;
		end if;

	end if;
end process;

-----------------------------------------------------------------
-- serialize big sprite graph to pixel + concatenate color
-----------------------------------------------------------------
process (clock_12mhz)
begin
	if rising_edge(clock_12mhz) then
		big_sprite_pixel_color <=	big_sprite_color(2 downto 0) & 
															big_sprite_graph1_r2(to_integer(unsigned(x_big_sprite_counter(3 downto 1)))) &
															big_sprite_graph2_r2(to_integer(unsigned(x_big_sprite_counter(3 downto 1))));

		if 	big_sprite_pixel_color(1 downto 0) /= "00" and y_add_big_sprite(7) = '1' and 
				x_big_sprite_counter >= (X"28" & '0')and 
				x_big_sprite_counter <  (X"A8" & '1') then
			is_big_sprite_on <= '1';
		else
			is_big_sprite_on <= '0';
		end if;
	end if;
end process;

-------------------------------------------------

--m_dac : entity work.dac
--generic map(msbi_g  => 12)
--port map(
--		clk_i => CLK_48mhz,
--		res_n_i => '1',
--		dac_i   => sound_string,
--		dac_o   => dac_o);
-------------------------------------------------
		
m_clock : entity work.clock
   port map
   (-- Clock in ports
    CLK_IN1 => CLK_IN,
    -- Clock out ports
    CLK_12mhz => clock_12mhz,
    CLK_48mhz => CLK_48mhz,
    -- Status and control signals
    RESET  => '0',
    LOCKED => open);
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

palette : entity work.ckong_palette
port map (
	addr => pixel_color_r,
	clk   => clock_12mhz,
	data       => do_palette 
);

big_sprite_palette : entity work.ckong_big_sprite_palette
port map (
	addr  => big_sprite_pixel_color,
	clk   => clock_12mhz,
	data  => do_big_sprite_palette 
);

Z80 : entity work.T80s
generic map(Mode => 0, T2Write => 1, IOWait => 1)
port map(
  RESET_n => not loading,
  CLK_n   => cpu_clock,
  WAIT_n  => '1',
  INT_n   => '1',
  NMI_n   => cpu_int_n,
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

ckong_sound : entity work.ckong_sound
port map(
  cpu_clock    => cpu_clock,
  cpu_addr     => cpu_addr,
  cpu_data     => cpu_data,
  cpu_iorq_n   => cpu_iorq_n,
  reg4_we_n    => reg4_we_n,
  reg5_we_n    => reg5_we_n,
  reg6_we_n    => reg6_we_n,
  ym_2149_data => ym_8910_data,
  sound_sample => sound_string
);



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

end architecture;