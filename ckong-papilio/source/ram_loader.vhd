---------------------------------------------------------------------------------
-- Ram loader - Dar - Feb 2014
---------------------------------------------------------------------------------
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
signal step_cnt     : integer range 0 to 10 := 0;
signal next_word    : std_logic := '0';

signal do_prog                 : std_logic_vector(7 downto 0);
signal do_prog2                 : std_logic_vector(7 downto 0);
signal do_tile_bit0            : std_logic_vector(7 downto 0);
signal do_tile_bit1            : std_logic_vector(7 downto 0);
signal do_big_sprite_tile_bit0 : std_logic_vector(7 downto 0);
signal do_big_sprite_tile_bit1 : std_logic_vector(7 downto 0);

begin

program : entity work.ckong_program
port map (
	addr  => rd_addr(13 downto 0),
	clk   => clock,
	data  => do_prog
);

program2 : entity work.ckong_program2
port map (
	addr  => rd_addr(12 downto 0),
	clk   => clock,
	data  => do_prog2
);

tile_bit0 : entity work.ckong_tile_bit0
port map (
	addr  => rd_addr(12 downto 0),
	clk   => clock,
	data  => do_tile_bit0
);

tile_bit1 : entity work.ckong_tile_bit1
port map (
	addr  => rd_addr(12 downto 0),
	clk   => clock,
	data  => do_tile_bit1
);

big_sprite_tile_bit0 : entity work.ckong_big_sprite_tile_bit0
port map (
	addr  => rd_addr(10 downto 0),
	clk   => clock,
	data  => do_big_sprite_tile_bit0
);

big_sprite_tile_bit1 : entity work.ckong_big_sprite_tile_bit1
port map (
	addr  => rd_addr(10 downto 0),
	clk   => clock,
	data  => do_big_sprite_tile_bit1
);

address <= wr_addr;

with step_cnt select
	we <= next_word when 1,
				next_word when 2,
				next_word when 3,
				next_word when 4,
				next_word when 5,
				next_word when 6,
				next_word when 7,
				next_word when 8,
				'0' when others;

with step_cnt select
	data <=	   do_prog                            when 1,
	            do_prog2                            when 2,
					do_tile_bit0                       when 3,
					do_tile_bit1                       when 4,
					rd_addr(7 downto 0)                when 5,
					"01" & rd_addr(9 downto 8) &"0001" when 6,
					do_big_sprite_tile_bit0            when 7,
					do_big_sprite_tile_bit1            when 8,
					"00000000"                    when others;

process(clock,reset)
begin
		if reset = '0' then
			wr_addr   <= (others => '0');
			rd_addr   <= (others => '0');
			step_cnt  <= 0;
			next_word <= '0';
		else
			if rising_edge(clock) then
			
				next_word <= not next_word;
				if next_word = '1' then
					rd_addr <= rd_addr + '1';
					wr_addr <= wr_addr + '1';
					if step_cnt = 0 then           -- step 0
						if rd_addr = X"3" then
							wr_addr <= (others => '0');
							loading <= '1';
						elsif rd_addr = X"7" then
							wr_addr <= "0" & X"0000";  -- program start address
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt = 1 then        -- step 1
						if rd_addr = X"4000" then    -- program length
							wr_addr <= "0" & X"4000";  -- programm2 start address
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt = 2 then         -- step 2
						if rd_addr = X"2000" then    -- program length
							wr_addr <= "1" & X"0000";  -- tile 0 start address
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;	
						
					elsif step_cnt = 3 then        -- step 3
						if rd_addr = X"2000" then    -- tile 0 length
							wr_addr <= "1" & X"2000";  -- tile 1 start address
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt = 4 then        -- step 4
						if rd_addr = X"2000" then    -- tile 1 length
							wr_addr <= "0" & X"9040";  -- ram tile start address
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt = 5 then        -- step 5
						if rd_addr = X"0400" then    -- ram tile length
							wr_addr <= "0" & X"9800";  -- ram color start address
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt = 6 then        -- step 6
						if rd_addr = X"0400" then    -- ram color length
							wr_addr <= "1" & X"4000";  -- big sprite tile 0 start address
							rd_addr <= (others => '0'); --
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt = 7 then        -- step 7
						if rd_addr = X"0800" then    -- big sprite tile 0 length
							wr_addr <= "1" & X"4800";  -- big sprite tile 1 start address
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt = 8 then        -- step 8
						if rd_addr = X"0800" then    -- big sprite tile 1 length
							wr_addr <= "1" & X"FFFF";  -- stop address
							rd_addr <= (others => '0');
							step_cnt <= step_cnt + 1;
						end if;
					elsif step_cnt < 9 then        -- other steps
						step_cnt <= step_cnt + 1;
					else
						loading<= '0';
					end if;
				end if;

		end if;
	end if;
end process;

end struct;
