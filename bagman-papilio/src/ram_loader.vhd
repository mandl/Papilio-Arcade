---------------------------------------------------------------------------------
-- Ram loader - Dar - Feb 2014
---------------------------------------------------------------------------------

--------------------------------------------------------------------
--The original arcade hardware PCB contains 7 memory regions

-- cpu addressable space
 
-- - program                  rom  24Kx8, cpu only access                0x00000
-- - working ram              ram   3Kx8, cpu only access
-- - color/sprite-data        ram   1Kx8, cpu + (2 access / 8 pixels)
-- - background buffer        ram   1Kx8, cpu + (1 access / 8 pixels)

-- non cpu addressable region   

-- - background/sprite graphics      rom 8Kx16, (1 access / 8 pixels)    0x10000
--                                                                       0x12000

-- - background/sprite color palette rom 64x8 , (1 access / pixels)
-- - sound samples                   rom 8Kx8 , low rate


--   11  0000-5fff ROM
--   12  6000-67ff RAM
--   13  9000-93ff Video RAM
--   14  9800-9bff Color RAM
--   15  9800-981f Sprites (hidden portion of color RAM)
--   16  9c00-9fff ? (filled with 3f, not used otherwise)
library ieee;
use ieee.std_logic_1164.all, ieee.std_logic_unsigned.all, ieee.numeric_std.all;

entity ram_loader is
port(
	clock    : in std_logic;
	reset    : in std_logic;
	address  : out std_logic_vector(16 downto 0);
	data     : out std_logic_vector(7 downto 0);
	we       : out std_logic;
	loading  : out std_logic
);

end ram_loader;

architecture struct of ram_loader is

signal wr_addr      : std_logic_vector(16 downto 0) := (others => '0');
signal rd_addr      : std_logic_vector(14 downto 0) := (others => '0');
signal step_cnt     : integer range 0 to 7 := 0;
signal next_word    : std_logic := '0';
signal do_prog      : std_logic_vector(7 downto 0);
signal do_tile_bit0 : std_logic_vector(7 downto 0);
signal do_tile_bit1 : std_logic_vector(7 downto 0);

begin

program : entity work.bagman_program
port map(
	addr => rd_addr(14 downto 0),
	clk  => clock,
	data => do_prog 
);

tile_bit0 : entity work.bagman_tile_bit0
port map (
	addr => rd_addr(12 downto 0),
	clk  => clock,
	data => do_tile_bit0
);

tile_bit1 : entity work.bagman_tile_bit1
port map (
	addr => rd_addr(12 downto 0),
	clk  => clock,
	data => do_tile_bit1
);

address <= wr_addr;

with step_cnt select
	we <= next_word when 1,
				next_word when 2,
				next_word when 3,
				next_word when 4,
				next_word when 5,
				'0' when others;

with step_cnt select
	data <=	do_prog when 1,
					do_tile_bit0 when 2,
					do_tile_bit1 when 3,
					rd_addr(7 downto 0) when 4,
					"01" & rd_addr(9 downto 8) &"0001" when 5,
					"00000000" when others;

process(clock,reset)
begin
		if reset = '0' then
			wr_addr <= (others => '0');
			rd_addr <= (others => '0');
			step_cnt <= 0;
			next_word <= '0';
		else
			if rising_edge(clock) then
			
				next_word <= not next_word;
				if next_word = '1' then
					rd_addr <= rd_addr + '1';
					wr_addr <= wr_addr + '1';
					if step_cnt = 0 then                 -- step 0
						if rd_addr = X"3" then
							wr_addr <= (others => '0');
							loading <= '1';
						elsif rd_addr = X"7" then
							wr_addr <= "0" & X"0000";        -- program start
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt = 1 then              -- step 1
						if rd_addr = X"5FFF" then          -- program length
							wr_addr <= "1" & X"0000";        -- tile 0 start
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt = 2 then              -- step 2
						if rd_addr = X"1FFF" then          -- tile 0 length
							wr_addr <= "1" & X"2000";        -- tile 1 start
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt = 3 then              -- step 3
						if rd_addr = X"1FFF" then          -- tile 1 length
							wr_addr <= "0" & X"9040";        -- ram tile start
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt = 4 then              -- step 4
						if rd_addr = X"03FF" then          -- ram tile length
							wr_addr <= "0" & X"9800";        -- ram color start
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt = 5 then              -- step 5
						if rd_addr = X"03FF" then          -- ram color length
							wr_addr <= "1" & X"FFFF";        -- stop address
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt < 7 then              -- other steps
					step_cnt <= step_cnt + 1;
					else
						loading<= '0';
					end if;
				end if;

		end if;
	end if;
end process;

end struct;
