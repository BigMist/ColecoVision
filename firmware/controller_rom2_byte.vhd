
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"08",x"d4",x"ff",x"30"),
     1 => (x"48",x"d0",x"ff",x"78"),
     2 => (x"26",x"78",x"e0",x"c0"),
     3 => (x"cc",x"c2",x"1e",x"4f"),
     4 => (x"e7",x"49",x"bf",x"df"),
     5 => (x"df",x"c2",x"87",x"c8"),
     6 => (x"bf",x"e8",x"48",x"c5"),
     7 => (x"c1",x"df",x"c2",x"78"),
     8 => (x"78",x"bf",x"ec",x"48"),
     9 => (x"bf",x"c5",x"df",x"c2"),
    10 => (x"ff",x"c3",x"49",x"4a"),
    11 => (x"2a",x"b7",x"c8",x"99"),
    12 => (x"b0",x"71",x"48",x"72"),
    13 => (x"58",x"cd",x"df",x"c2"),
    14 => (x"5e",x"0e",x"4f",x"26"),
    15 => (x"0e",x"5d",x"5c",x"5b"),
    16 => (x"c8",x"ff",x"4b",x"71"),
    17 => (x"c0",x"df",x"c2",x"87"),
    18 => (x"73",x"50",x"c0",x"48"),
    19 => (x"87",x"ee",x"e6",x"49"),
    20 => (x"c2",x"4c",x"49",x"70"),
    21 => (x"49",x"ee",x"cb",x"9c"),
    22 => (x"70",x"87",x"cc",x"cb"),
    23 => (x"c0",x"df",x"c2",x"4d"),
    24 => (x"c1",x"05",x"bf",x"97"),
    25 => (x"66",x"d0",x"87",x"e2"),
    26 => (x"c9",x"df",x"c2",x"49"),
    27 => (x"d6",x"05",x"99",x"bf"),
    28 => (x"49",x"66",x"d4",x"87"),
    29 => (x"bf",x"c1",x"df",x"c2"),
    30 => (x"87",x"cb",x"05",x"99"),
    31 => (x"fd",x"e5",x"49",x"73"),
    32 => (x"02",x"98",x"70",x"87"),
    33 => (x"c1",x"87",x"c1",x"c1"),
    34 => (x"87",x"c1",x"fe",x"4c"),
    35 => (x"e2",x"ca",x"49",x"75"),
    36 => (x"02",x"98",x"70",x"87"),
    37 => (x"df",x"c2",x"87",x"c6"),
    38 => (x"50",x"c1",x"48",x"c0"),
    39 => (x"97",x"c0",x"df",x"c2"),
    40 => (x"e3",x"c0",x"05",x"bf"),
    41 => (x"c9",x"df",x"c2",x"87"),
    42 => (x"66",x"d0",x"49",x"bf"),
    43 => (x"d6",x"ff",x"05",x"99"),
    44 => (x"c1",x"df",x"c2",x"87"),
    45 => (x"66",x"d4",x"49",x"bf"),
    46 => (x"ca",x"ff",x"05",x"99"),
    47 => (x"e4",x"49",x"73",x"87"),
    48 => (x"98",x"70",x"87",x"fc"),
    49 => (x"87",x"ff",x"fe",x"05"),
    50 => (x"fb",x"fa",x"48",x"74"),
    51 => (x"5b",x"5e",x"0e",x"87"),
    52 => (x"f8",x"0e",x"5d",x"5c"),
    53 => (x"4c",x"4d",x"c0",x"86"),
    54 => (x"c4",x"7e",x"bf",x"ec"),
    55 => (x"df",x"c2",x"48",x"a6"),
    56 => (x"c1",x"78",x"bf",x"cd"),
    57 => (x"c7",x"1e",x"c0",x"1e"),
    58 => (x"87",x"ce",x"fd",x"49"),
    59 => (x"98",x"70",x"86",x"c8"),
    60 => (x"ff",x"87",x"cd",x"02"),
    61 => (x"87",x"eb",x"fa",x"49"),
    62 => (x"e4",x"49",x"da",x"c1"),
    63 => (x"4d",x"c1",x"87",x"c0"),
    64 => (x"97",x"c0",x"df",x"c2"),
    65 => (x"87",x"cf",x"02",x"bf"),
    66 => (x"bf",x"d7",x"cc",x"c2"),
    67 => (x"c2",x"b9",x"c1",x"49"),
    68 => (x"71",x"59",x"db",x"cc"),
    69 => (x"c2",x"87",x"d4",x"fb"),
    70 => (x"4b",x"bf",x"c5",x"df"),
    71 => (x"bf",x"df",x"cc",x"c2"),
    72 => (x"87",x"e9",x"c0",x"05"),
    73 => (x"e3",x"49",x"fd",x"c3"),
    74 => (x"fa",x"c3",x"87",x"d4"),
    75 => (x"87",x"ce",x"e3",x"49"),
    76 => (x"ff",x"c3",x"49",x"73"),
    77 => (x"c0",x"1e",x"71",x"99"),
    78 => (x"87",x"e1",x"fa",x"49"),
    79 => (x"b7",x"c8",x"49",x"73"),
    80 => (x"c1",x"1e",x"71",x"29"),
    81 => (x"87",x"d5",x"fa",x"49"),
    82 => (x"f4",x"c5",x"86",x"c8"),
    83 => (x"c9",x"df",x"c2",x"87"),
    84 => (x"02",x"9b",x"4b",x"bf"),
    85 => (x"cc",x"c2",x"87",x"dd"),
    86 => (x"c7",x"49",x"bf",x"db"),
    87 => (x"98",x"70",x"87",x"d5"),
    88 => (x"c0",x"87",x"c4",x"05"),
    89 => (x"c2",x"87",x"d2",x"4b"),
    90 => (x"fa",x"c6",x"49",x"e0"),
    91 => (x"df",x"cc",x"c2",x"87"),
    92 => (x"c2",x"87",x"c6",x"58"),
    93 => (x"c0",x"48",x"db",x"cc"),
    94 => (x"c2",x"49",x"73",x"78"),
    95 => (x"87",x"cd",x"05",x"99"),
    96 => (x"e1",x"49",x"eb",x"c3"),
    97 => (x"49",x"70",x"87",x"f8"),
    98 => (x"c2",x"02",x"99",x"c2"),
    99 => (x"73",x"4c",x"fb",x"87"),
   100 => (x"05",x"99",x"c1",x"49"),
   101 => (x"f4",x"c3",x"87",x"cd"),
   102 => (x"87",x"e2",x"e1",x"49"),
   103 => (x"99",x"c2",x"49",x"70"),
   104 => (x"fa",x"87",x"c2",x"02"),
   105 => (x"c8",x"49",x"73",x"4c"),
   106 => (x"87",x"cd",x"05",x"99"),
   107 => (x"e1",x"49",x"f5",x"c3"),
   108 => (x"49",x"70",x"87",x"cc"),
   109 => (x"d5",x"02",x"99",x"c2"),
   110 => (x"d1",x"df",x"c2",x"87"),
   111 => (x"87",x"ca",x"02",x"bf"),
   112 => (x"c2",x"88",x"c1",x"48"),
   113 => (x"c0",x"58",x"d5",x"df"),
   114 => (x"4c",x"ff",x"87",x"c2"),
   115 => (x"49",x"73",x"4d",x"c1"),
   116 => (x"cd",x"05",x"99",x"c4"),
   117 => (x"49",x"f2",x"c3",x"87"),
   118 => (x"70",x"87",x"e3",x"e0"),
   119 => (x"02",x"99",x"c2",x"49"),
   120 => (x"df",x"c2",x"87",x"dc"),
   121 => (x"48",x"7e",x"bf",x"d1"),
   122 => (x"03",x"a8",x"b7",x"c7"),
   123 => (x"6e",x"87",x"cb",x"c0"),
   124 => (x"c2",x"80",x"c1",x"48"),
   125 => (x"c0",x"58",x"d5",x"df"),
   126 => (x"4c",x"fe",x"87",x"c2"),
   127 => (x"fd",x"c3",x"4d",x"c1"),
   128 => (x"f9",x"df",x"ff",x"49"),
   129 => (x"c2",x"49",x"70",x"87"),
   130 => (x"87",x"d5",x"02",x"99"),
   131 => (x"bf",x"d1",x"df",x"c2"),
   132 => (x"87",x"c9",x"c0",x"02"),
   133 => (x"48",x"d1",x"df",x"c2"),
   134 => (x"c2",x"c0",x"78",x"c0"),
   135 => (x"c1",x"4c",x"fd",x"87"),
   136 => (x"49",x"fa",x"c3",x"4d"),
   137 => (x"87",x"d6",x"df",x"ff"),
   138 => (x"99",x"c2",x"49",x"70"),
   139 => (x"87",x"d9",x"c0",x"02"),
   140 => (x"bf",x"d1",x"df",x"c2"),
   141 => (x"a8",x"b7",x"c7",x"48"),
   142 => (x"87",x"c9",x"c0",x"03"),
   143 => (x"48",x"d1",x"df",x"c2"),
   144 => (x"c2",x"c0",x"78",x"c7"),
   145 => (x"c1",x"4c",x"fc",x"87"),
   146 => (x"ac",x"b7",x"c0",x"4d"),
   147 => (x"87",x"d3",x"c0",x"03"),
   148 => (x"c1",x"48",x"66",x"c4"),
   149 => (x"7e",x"70",x"80",x"d8"),
   150 => (x"c0",x"02",x"bf",x"6e"),
   151 => (x"74",x"4b",x"87",x"c5"),
   152 => (x"c0",x"0f",x"73",x"49"),
   153 => (x"1e",x"f0",x"c3",x"1e"),
   154 => (x"f7",x"49",x"da",x"c1"),
   155 => (x"86",x"c8",x"87",x"cc"),
   156 => (x"c0",x"02",x"98",x"70"),
   157 => (x"df",x"c2",x"87",x"d8"),
   158 => (x"6e",x"7e",x"bf",x"d1"),
   159 => (x"c4",x"91",x"cb",x"49"),
   160 => (x"82",x"71",x"4a",x"66"),
   161 => (x"c5",x"c0",x"02",x"6a"),
   162 => (x"49",x"6e",x"4b",x"87"),
   163 => (x"9d",x"75",x"0f",x"73"),
   164 => (x"87",x"c8",x"c0",x"02"),
   165 => (x"bf",x"d1",x"df",x"c2"),
   166 => (x"87",x"e2",x"f2",x"49"),
   167 => (x"bf",x"e3",x"cc",x"c2"),
   168 => (x"87",x"dd",x"c0",x"02"),
   169 => (x"87",x"cb",x"c2",x"49"),
   170 => (x"c0",x"02",x"98",x"70"),
   171 => (x"df",x"c2",x"87",x"d3"),
   172 => (x"f2",x"49",x"bf",x"d1"),
   173 => (x"49",x"c0",x"87",x"c8"),
   174 => (x"c2",x"87",x"e8",x"f3"),
   175 => (x"c0",x"48",x"e3",x"cc"),
   176 => (x"f3",x"8e",x"f8",x"78"),
   177 => (x"5e",x"0e",x"87",x"c2"),
   178 => (x"0e",x"5d",x"5c",x"5b"),
   179 => (x"c2",x"4c",x"71",x"1e"),
   180 => (x"49",x"bf",x"cd",x"df"),
   181 => (x"4d",x"a1",x"cd",x"c1"),
   182 => (x"69",x"81",x"d1",x"c1"),
   183 => (x"02",x"9c",x"74",x"7e"),
   184 => (x"a5",x"c4",x"87",x"cf"),
   185 => (x"c2",x"7b",x"74",x"4b"),
   186 => (x"49",x"bf",x"cd",x"df"),
   187 => (x"6e",x"87",x"e1",x"f2"),
   188 => (x"05",x"9c",x"74",x"7b"),
   189 => (x"4b",x"c0",x"87",x"c4"),
   190 => (x"4b",x"c1",x"87",x"c2"),
   191 => (x"e2",x"f2",x"49",x"73"),
   192 => (x"02",x"66",x"d4",x"87"),
   193 => (x"de",x"49",x"87",x"c7"),
   194 => (x"c2",x"4a",x"70",x"87"),
   195 => (x"c2",x"4a",x"c0",x"87"),
   196 => (x"26",x"5a",x"e7",x"cc"),
   197 => (x"00",x"87",x"f1",x"f1"),
   198 => (x"00",x"00",x"00",x"00"),
   199 => (x"00",x"00",x"00",x"00"),
   200 => (x"00",x"00",x"00",x"00"),
   201 => (x"1e",x"00",x"00",x"00"),
   202 => (x"c8",x"ff",x"4a",x"71"),
   203 => (x"a1",x"72",x"49",x"bf"),
   204 => (x"1e",x"4f",x"26",x"48"),
   205 => (x"89",x"bf",x"c8",x"ff"),
   206 => (x"c0",x"c0",x"c0",x"fe"),
   207 => (x"01",x"a9",x"c0",x"c0"),
   208 => (x"4a",x"c0",x"87",x"c4"),
   209 => (x"4a",x"c1",x"87",x"c2"),
   210 => (x"4f",x"26",x"48",x"72"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

