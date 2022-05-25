library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic	(
	ADDR_WIDTH : integer := 8; -- ROM's address width (words, not bytes)
	COL_WIDTH  : integer := 8;  -- Column width (8bit -> byte)
	NB_COL     : integer := 4  -- Number of columns in memory
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

architecture arch of controller_rom2 is

-- type word_t is std_logic_vector(31 downto 0);
type ram_type is array (0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(NB_COL * COL_WIDTH - 1 downto 0);

signal ram : ram_type :=
(

     0 => x"08d4ff30",
     1 => x"48d0ff78",
     2 => x"2678e0c0",
     3 => x"ccc21e4f",
     4 => x"e749bfdf",
     5 => x"dfc287c8",
     6 => x"bfe848c5",
     7 => x"c1dfc278",
     8 => x"78bfec48",
     9 => x"bfc5dfc2",
    10 => x"ffc3494a",
    11 => x"2ab7c899",
    12 => x"b0714872",
    13 => x"58cddfc2",
    14 => x"5e0e4f26",
    15 => x"0e5d5c5b",
    16 => x"c8ff4b71",
    17 => x"c0dfc287",
    18 => x"7350c048",
    19 => x"87eee649",
    20 => x"c24c4970",
    21 => x"49eecb9c",
    22 => x"7087cccb",
    23 => x"c0dfc24d",
    24 => x"c105bf97",
    25 => x"66d087e2",
    26 => x"c9dfc249",
    27 => x"d60599bf",
    28 => x"4966d487",
    29 => x"bfc1dfc2",
    30 => x"87cb0599",
    31 => x"fde54973",
    32 => x"02987087",
    33 => x"c187c1c1",
    34 => x"87c1fe4c",
    35 => x"e2ca4975",
    36 => x"02987087",
    37 => x"dfc287c6",
    38 => x"50c148c0",
    39 => x"97c0dfc2",
    40 => x"e3c005bf",
    41 => x"c9dfc287",
    42 => x"66d049bf",
    43 => x"d6ff0599",
    44 => x"c1dfc287",
    45 => x"66d449bf",
    46 => x"caff0599",
    47 => x"e4497387",
    48 => x"987087fc",
    49 => x"87fffe05",
    50 => x"fbfa4874",
    51 => x"5b5e0e87",
    52 => x"f80e5d5c",
    53 => x"4c4dc086",
    54 => x"c47ebfec",
    55 => x"dfc248a6",
    56 => x"c178bfcd",
    57 => x"c71ec01e",
    58 => x"87cefd49",
    59 => x"987086c8",
    60 => x"ff87cd02",
    61 => x"87ebfa49",
    62 => x"e449dac1",
    63 => x"4dc187c0",
    64 => x"97c0dfc2",
    65 => x"87cf02bf",
    66 => x"bfd7ccc2",
    67 => x"c2b9c149",
    68 => x"7159dbcc",
    69 => x"c287d4fb",
    70 => x"4bbfc5df",
    71 => x"bfdfccc2",
    72 => x"87e9c005",
    73 => x"e349fdc3",
    74 => x"fac387d4",
    75 => x"87cee349",
    76 => x"ffc34973",
    77 => x"c01e7199",
    78 => x"87e1fa49",
    79 => x"b7c84973",
    80 => x"c11e7129",
    81 => x"87d5fa49",
    82 => x"f4c586c8",
    83 => x"c9dfc287",
    84 => x"029b4bbf",
    85 => x"ccc287dd",
    86 => x"c749bfdb",
    87 => x"987087d5",
    88 => x"c087c405",
    89 => x"c287d24b",
    90 => x"fac649e0",
    91 => x"dfccc287",
    92 => x"c287c658",
    93 => x"c048dbcc",
    94 => x"c2497378",
    95 => x"87cd0599",
    96 => x"e149ebc3",
    97 => x"497087f8",
    98 => x"c20299c2",
    99 => x"734cfb87",
   100 => x"0599c149",
   101 => x"f4c387cd",
   102 => x"87e2e149",
   103 => x"99c24970",
   104 => x"fa87c202",
   105 => x"c849734c",
   106 => x"87cd0599",
   107 => x"e149f5c3",
   108 => x"497087cc",
   109 => x"d50299c2",
   110 => x"d1dfc287",
   111 => x"87ca02bf",
   112 => x"c288c148",
   113 => x"c058d5df",
   114 => x"4cff87c2",
   115 => x"49734dc1",
   116 => x"cd0599c4",
   117 => x"49f2c387",
   118 => x"7087e3e0",
   119 => x"0299c249",
   120 => x"dfc287dc",
   121 => x"487ebfd1",
   122 => x"03a8b7c7",
   123 => x"6e87cbc0",
   124 => x"c280c148",
   125 => x"c058d5df",
   126 => x"4cfe87c2",
   127 => x"fdc34dc1",
   128 => x"f9dfff49",
   129 => x"c2497087",
   130 => x"87d50299",
   131 => x"bfd1dfc2",
   132 => x"87c9c002",
   133 => x"48d1dfc2",
   134 => x"c2c078c0",
   135 => x"c14cfd87",
   136 => x"49fac34d",
   137 => x"87d6dfff",
   138 => x"99c24970",
   139 => x"87d9c002",
   140 => x"bfd1dfc2",
   141 => x"a8b7c748",
   142 => x"87c9c003",
   143 => x"48d1dfc2",
   144 => x"c2c078c7",
   145 => x"c14cfc87",
   146 => x"acb7c04d",
   147 => x"87d3c003",
   148 => x"c14866c4",
   149 => x"7e7080d8",
   150 => x"c002bf6e",
   151 => x"744b87c5",
   152 => x"c00f7349",
   153 => x"1ef0c31e",
   154 => x"f749dac1",
   155 => x"86c887cc",
   156 => x"c0029870",
   157 => x"dfc287d8",
   158 => x"6e7ebfd1",
   159 => x"c491cb49",
   160 => x"82714a66",
   161 => x"c5c0026a",
   162 => x"496e4b87",
   163 => x"9d750f73",
   164 => x"87c8c002",
   165 => x"bfd1dfc2",
   166 => x"87e2f249",
   167 => x"bfe3ccc2",
   168 => x"87ddc002",
   169 => x"87cbc249",
   170 => x"c0029870",
   171 => x"dfc287d3",
   172 => x"f249bfd1",
   173 => x"49c087c8",
   174 => x"c287e8f3",
   175 => x"c048e3cc",
   176 => x"f38ef878",
   177 => x"5e0e87c2",
   178 => x"0e5d5c5b",
   179 => x"c24c711e",
   180 => x"49bfcddf",
   181 => x"4da1cdc1",
   182 => x"6981d1c1",
   183 => x"029c747e",
   184 => x"a5c487cf",
   185 => x"c27b744b",
   186 => x"49bfcddf",
   187 => x"6e87e1f2",
   188 => x"059c747b",
   189 => x"4bc087c4",
   190 => x"4bc187c2",
   191 => x"e2f24973",
   192 => x"0266d487",
   193 => x"de4987c7",
   194 => x"c24a7087",
   195 => x"c24ac087",
   196 => x"265ae7cc",
   197 => x"0087f1f1",
   198 => x"00000000",
   199 => x"00000000",
   200 => x"00000000",
   201 => x"1e000000",
   202 => x"c8ff4a71",
   203 => x"a17249bf",
   204 => x"1e4f2648",
   205 => x"89bfc8ff",
   206 => x"c0c0c0fe",
   207 => x"01a9c0c0",
   208 => x"4ac087c4",
   209 => x"4ac187c2",
   210 => x"4f264872",
  others => ( x"00000000")
);

-- Xilinx Vivado attributes
attribute ram_style: string;
attribute ram_style of ram: signal is "block";

signal q_local : std_logic_vector((NB_COL * COL_WIDTH)-1 downto 0);

signal wea : std_logic_vector(NB_COL - 1 downto 0);

begin

	output:
	for i in 0 to NB_COL - 1 generate
		q((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= q_local((i+1) * COL_WIDTH - 1 downto i * COL_WIDTH);
	end generate;
    
    -- Generate write enable signals
    -- The Block ram generator doesn't like it when the compare is done in the if statement it self.
    wea <= bytesel when we = '1' else (others => '0');

    process(clk)
    begin
        if rising_edge(clk) then
            q_local <= ram(to_integer(unsigned(addr)));
            for i in 0 to NB_COL - 1 loop
                if (wea(NB_COL-i-1) = '1') then
                    ram(to_integer(unsigned(addr)))((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) <= d((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH);
                end if;
            end loop;
        end if;
    end process;

end arch;
