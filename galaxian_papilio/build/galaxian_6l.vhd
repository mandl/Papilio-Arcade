-- generated with romgen v3.04 by MikeJ
-- dummy rom. random rom data. avoid map to optimise this rom away;
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

--library UNISIM;
	--use UNISIM.Vcomponents.all;

entity GALAXIAN_6L is
port (
	CLK  : in  std_logic;
	ENA  : in  std_logic;
	ADDR : in  std_logic_vector(4 downto 0);
	DATA : out std_logic_vector(7 downto 0)
	);
end;

architecture RTL of GALAXIAN_6L is


	type ROM_ARRAY is array(0 to 31) of std_logic_vector(7 downto 0);
	signal ROM : ROM_ARRAY := (
		x"51",x"E3",x"D4",x"72",x"B2",x"94",x"68",x"E5", -- 0x0000
		x"EB",x"06",x"91",x"F7",x"51",x"DA",x"A0",x"53", -- 0x0008
		x"0A",x"7B",x"AD",x"D0",x"17",x"C7",x"12",x"E8", -- 0x0010
		x"7E",x"FD",x"32",x"53",x"5A",x"00",x"D9",x"2B"  -- 0x0018
	);
	attribute ram_style : string;
	attribute ram_style of ROM : signal is "block";

begin

	p_rom : process(CLK,ADDR)
	begin
		if (rising_edge(CLK)) then
		if (ENA = '1') then
  			DATA <= ROM(to_integer(unsigned(ADDR)));
		end if;
		 end if;
	end process;
end RTL;
