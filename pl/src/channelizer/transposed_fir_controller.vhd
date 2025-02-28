
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.matrix_type.all;

entity transposed_fir_controller is
   generic (
      constant bypass_filter : std_logic;
      constant nr_taps       : integer;
      constant nr_subbands   : integer;
      constant nr_mics       : integer

   );
   port (
      clk            : in std_logic;
      rst            : in std_logic;
      data_in        : in matrix_16_24_type;
      data_in_valid  : in std_logic;
      data_out       : out matrix_16_24_type;
      data_out_valid : out std_logic;
      subband_out    : out std_logic_vector(7 downto 0)
   );
end entity;

architecture rtl of transposed_fir_controller is

   signal data_in_d   : matrix_16_24_type;
   signal data_fir_in : std_logic_vector(23 downto 0);

   type coeffs_type is array (nr_taps - 1 downto 0) of std_logic_vector(11 downto 0);
   type coeffs_all_type is array (nr_subbands - 1 downto 0) of coeffs_type;
   signal coeffs_all : coeffs_all_type := (
   (x"015", x"01B", x"024", x"030", x"042", x"059", x"078", x"09D", x"0CB", x"101", x"13E", x"183", x"1D0", x"222", x"27A", x"2D5", x"332", x"390", x"3ED", x"446", x"49A", x"4E7", x"52C", x"566", x"595", x"5B7", x"5CC", x"5D3", x"5CC", x"5B7", x"595", x"566", x"52C", x"4E7", x"49A", x"446", x"3ED", x"390", x"332", x"2D5", x"27A", x"222", x"1D0", x"183", x"13E", x"101", x"0CB", x"09D", x"078", x"059", x"042", x"030", x"024", x"01B", x"015"),
      (x"FD2", x"FC7", x"FB8", x"FA4", x"F8A", x"F6B", x"F48", x"F25", x"F03", x"EE6", x"ED4", x"ECE", x"EDA", x"EF9", x"F2E", x"F7A", x"FDB", x"050", x"0D5", x"166", x"1FC", x"291", x"31E", x"39D", x"407", x"457", x"489", x"499", x"489", x"457", x"407", x"39D", x"31E", x"291", x"1FC", x"166", x"0D5", x"050", x"FDB", x"F7A", x"F2E", x"EF9", x"EDA", x"ECE", x"ED4", x"EE6", x"F03", x"F25", x"F48", x"F6B", x"F8A", x"FA4", x"FB8", x"FC7", x"FD2"),
      (x"040", x"048", x"052", x"05B", x"061", x"05E", x"04E", x"02B", x"FF3", x"FA4", x"F41", x"ED0", x"E5B", x"DEE", x"D96", x"D62", x"D5C", x"D8D", x"DF9", x"E9D", x"F70", x"065", x"168", x"266", x"347", x"3F8", x"46A", x"491", x"46A", x"3F8", x"347", x"266", x"168", x"065", x"F70", x"E9D", x"DF9", x"D8D", x"D5C", x"D62", x"D96", x"DEE", x"E5B", x"ED0", x"F41", x"FA4", x"FF3", x"02B", x"04E", x"05E", x"061", x"05B", x"052", x"048", x"040"),
      (x"FBC", x"FBF", x"FC8", x"FDA", x"FFA", x"02B", x"06D", x"0B9", x"104", x"13D", x"151", x"131", x"0D3", x"037", x"F69", x"E83", x"DA5", x"CF5", x"C96", x"CA3", x"D26", x"E19", x"F62", x"0D8", x"249", x"37F", x"44E", x"496", x"44E", x"37F", x"249", x"0D8", x"F62", x"E19", x"D26", x"CA3", x"C96", x"CF5", x"DA5", x"E83", x"F69", x"037", x"0D3", x"131", x"151", x"13D", x"104", x"0B9", x"06D", x"02B", x"FFA", x"FDA", x"FC8", x"FBF", x"FBC"),
      (x"037", x"023", x"004", x"FDA", x"FA6", x"F71", x"F4A", x"F46", x"F76", x"FE1", x"07E", x"132", x"1D2", x"22C", x"217", x"17F", x"06F", x"F13", x"DB2", x"CA0", x"C24", x"C6E", x"D7E", x"F27", x"115", x"2E1", x"426", x"49B", x"426", x"2E1", x"115", x"F27", x"D7E", x"C6E", x"C24", x"CA0", x"DB2", x"F13", x"06F", x"17F", x"217", x"22C", x"1D2", x"132", x"07E", x"FE1", x"F76", x"F46", x"F4A", x"F71", x"FA6", x"FDA", x"004", x"023", x"037"),
      (x"FE2", x"007", x"032", x"05C", x"078", x"074", x"03E", x"FD4", x"F4B", x"ECE", x"E95", x"ECE", x"F88", x"0A2", x"1CE", x"2A4", x"2C6", x"207", x"081", x"E9A", x"CE5", x"BF8", x"C31", x"D95", x"FC8", x"224", x"3F0", x"49B", x"3F0", x"224", x"FC8", x"D95", x"C31", x"BF8", x"CE5", x"E9A", x"081", x"207", x"2C6", x"2A4", x"1CE", x"0A2", x"F88", x"ECE", x"E95", x"ECE", x"F4B", x"FD4", x"03E", x"074", x"078", x"05C", x"032", x"007", x"FE2"),
      (x"FFD", x"FD1", x"FAF", x"FA4", x"FC2", x"00F", x"07B", x"0DB", x"0F3", x"096", x"FC9", x"ECE", x"E17", x"E14", x"EF6", x"086", x"22E", x"32C", x"2F0", x"166", x"F10", x"CE0", x"BCC", x"C63", x"E80", x"151", x"3AE", x"499", x"3AE", x"151", x"E80", x"C63", x"BCC", x"CE0", x"F10", x"166", x"2F0", x"32C", x"22E", x"086", x"EF6", x"E14", x"E17", x"ECE", x"FC9", x"096", x"0F3", x"0DB", x"07B", x"00F", x"FC2", x"FA4", x"FAF", x"FD1", x"FFD"),
      (x"023", x"046", x"04B", x"026", x"FD7", x"F7C", x"F4E", x"F84", x"027", x"0F6", x"174", x"131", x"018", x"E9F", x"D9A", x"DC6", x"F4A", x"180", x"337", x"35D", x"1A5", x"ED4", x"C67", x"BC0", x"D5B", x"071", x"363", x"496", x"363", x"071", x"D5B", x"BC0", x"C67", x"ED4", x"1A5", x"35D", x"337", x"180", x"F4A", x"DC6", x"D9A", x"E9F", x"018", x"131", x"174", x"0F6", x"027", x"F84", x"F4E", x"F7C", x"FD7", x"026", x"04B", x"046", x"023"),
      (x"FC5", x"FBA", x"FDC", x"026", x"072", x"083", x"02C", x"F84", x"EF7", x"F0A", x"FEE", x"130", x"1EB", x"160", x"FA5", x"DC6", x"D29", x"E81", x"126", x"35B", x"379", x"12B", x"DD9", x"BC2", x"C70", x"F8F", x"310", x"494", x"310", x"F8F", x"C70", x"BC2", x"DD9", x"12B", x"379", x"35B", x"126", x"E81", x"D29", x"DC6", x"FA5", x"160", x"1EB", x"130", x"FEE", x"F0A", x"EF7", x"F84", x"02C", x"083", x"072", x"026", x"FDC", x"FBA", x"FC5"),
      (x"045", x"02E", x"FEC", x"FA4", x"F98", x"FF1", x"088", x"0DA", x"073", x"F6A", x"E90", x"ECF", x"048", x"1EA", x"231", x"086", x"E08", x"CD7", x"E3F", x"164", x"3BA", x"31D", x"FCB", x"C67", x"BD3", x"EB0", x"2B8", x"494", x"2B8", x"EB0", x"BD3", x"C67", x"FCB", x"31D", x"3BA", x"164", x"E3F", x"CD7", x"E08", x"086", x"231", x"1EA", x"048", x"ECF", x"E90", x"F6A", x"073", x"0DA", x"088", x"FF1", x"F98", x"FA4", x"FEC", x"02E", x"045"),
      (x"FC2", x"FF9", x"043", x"05C", x"012", x"F8D", x"F53", x"FD4", x"0C7", x"131", x"05B", x"ECF", x"E22", x"F5E", x"1A1", x"2A1", x"0FD", x"DFB", x"C9E", x"E9B", x"24B", x"404", x"1CB", x"D97", x"B90", x"DDE", x"25A", x"496", x"25A", x"DDE", x"B90", x"D97", x"1CB", x"404", x"24B", x"E9B", x"C9E", x"DFB", x"0FD", x"2A1", x"1A1", x"F5E", x"E22", x"ECF", x"05B", x"131", x"0C7", x"FD4", x"F53", x"F8D", x"012", x"05C", x"043", x"FF9", x"FC2"),
      (x"029", x"FDD", x"FAD", x"FDA", x"052", x"08F", x"01B", x"F46", x"F19", x"01F", x"160", x"132", x"F5A", x"DD5", x"EC0", x"17E", x"2E9", x"0ED", x"D76", x"CA1", x"FD0", x"391", x"361", x"F27", x"BAE", x"D20", x"1F5", x"499", x"1F5", x"D20", x"BAE", x"F27", x"361", x"391", x"FD0", x"CA1", x"D76", x"0ED", x"2E9", x"17E", x"EC0", x"DD5", x"F5A", x"132", x"160", x"01F", x"F19", x"F46", x"01B", x"08F", x"052", x"FDA", x"FAD", x"FDD", x"029"),
      (x"FF6", x"041", x"03E", x"FDA", x"F87", x"FD5", x"094", x"0BA", x"FBF", x"EC2", x"F60", x"132", x"1BF", x"FC9", x"DA4", x"E82", x"1C1", x"30D", x"02B", x"CA0", x"D69", x"1E8", x"42A", x"0D9", x"C2E", x"C7F", x"18B", x"499", x"18B", x"C7F", x"C2E", x"0D9", x"42A", x"1E8", x"D69", x"CA0", x"02B", x"30D", x"1C1", x"E82", x"DA4", x"FC9", x"1BF", x"132", x"F60", x"EC2", x"FBF", x"0BA", x"094", x"FD5", x"F87", x"FDA", x"03E", x"041", x"FF6"),
      (x"FE9", x"FB7", x"FF4", x"05C", x"048", x"FA1", x"F5A", x"02C", x"10C", x"05D", x"EBF", x"ECE", x"0FE", x"215", x"FE1", x"D5E", x"EBE", x"277", x"2C0", x"E9B", x"C30", x"F9B", x"3F5", x"26A", x"D03", x"C01", x"11D", x"498", x"11D", x"C01", x"D03", x"26A", x"3F5", x"F9B", x"C30", x"E9B", x"2C0", x"277", x"EBE", x"D5E", x"FE1", x"215", x"0FE", x"ECE", x"EBF", x"05D", x"10C", x"02C", x"F5A", x"FA1", x"048", x"05C", x"FF4", x"FB7", x"FE9"),
      (x"033", x"039", x"FD5", x"FA4", x"01D", x"095", x"009", x"F25", x"FA6", x"119", x"0DE", x"ECF", x"E74", x"106", x"249", x"F7A", x"D12", x"FB0", x"351", x"165", x"CB3", x"D71", x"2D2", x"39B", x"E1A", x"BAC", x"0AC", x"496", x"0AC", x"BAC", x"E1A", x"39B", x"2D2", x"D71", x"CB3", x"165", x"351", x"FB0", x"D12", x"F7A", x"249", x"106", x"E74", x"ECF", x"0DE", x"119", x"FA6", x"F25", x"009", x"095", x"01D", x"FA4", x"FD5", x"039", x"033"),
      (x"FBD", x"FEB", x"04E", x"026", x"F93", x"FBA", x"09D", x"07C", x"F29", x"F36", x"114", x"131", x"EB6", x"E53", x"172", x"23A", x"E7E", x"D33", x"176", x"35C", x"EB5", x"C25", x"105", x"43F", x"F59", x"B81", x"039", x"495", x"039", x"B81", x"F59", x"43F", x"105", x"C25", x"EB5", x"35C", x"176", x"D33", x"E7E", x"23A", x"172", x"E53", x"EB6", x"131", x"114", x"F36", x"F29", x"07C", x"09D", x"FBA", x"F93", x"026", x"04E", x"FEB", x"FBD"),
      (x"043", x"FEB", x"FB2", x"026", x"06D", x"FBA", x"F63", x"07C", x"0D7", x"F36", x"EEC", x"131", x"14A", x"E53", x"E8E", x"23A", x"182", x"D33", x"E8A", x"35C", x"14B", x"C25", x"EFB", x"43F", x"0A7", x"B81", x"FC7", x"495", x"FC7", x"B81", x"0A7", x"43F", x"EFB", x"C25", x"14B", x"35C", x"E8A", x"D33", x"182", x"23A", x"E8E", x"E53", x"14A", x"131", x"EEC", x"F36", x"0D7", x"07C", x"F63", x"FBA", x"06D", x"026", x"FB2", x"FEB", x"043"),
      (x"FCD", x"039", x"02B", x"FA4", x"FE3", x"095", x"FF7", x"F25", x"05A", x"119", x"F22", x"ECF", x"18C", x"106", x"DB7", x"F7A", x"2EE", x"FB0", x"CAF", x"165", x"34D", x"D71", x"D2E", x"39B", x"1E6", x"BAC", x"F54", x"496", x"F54", x"BAC", x"1E6", x"39B", x"D2E", x"D71", x"34D", x"165", x"CAF", x"FB0", x"2EE", x"F7A", x"DB7", x"106", x"18C", x"ECF", x"F22", x"119", x"05A", x"F25", x"FF7", x"095", x"FE3", x"FA4", x"02B", x"039", x"FCD"),
      (x"017", x"FB7", x"00C", x"05C", x"FB8", x"FA1", x"0A6", x"02C", x"EF4", x"05D", x"141", x"ECE", x"F02", x"215", x"01F", x"D5E", x"142", x"277", x"D40", x"E9B", x"3D0", x"F9B", x"C0B", x"26A", x"2FD", x"C01", x"EE3", x"498", x"EE3", x"C01", x"2FD", x"26A", x"C0B", x"F9B", x"3D0", x"E9B", x"D40", x"277", x"142", x"D5E", x"01F", x"215", x"F02", x"ECE", x"141", x"05D", x"EF4", x"02C", x"0A6", x"FA1", x"FB8", x"05C", x"00C", x"FB7", x"017"),
      (x"00A", x"041", x"FC2", x"FDA", x"079", x"FD5", x"F6C", x"0BA", x"041", x"EC2", x"0A0", x"132", x"E41", x"FC9", x"25C", x"E82", x"E3F", x"30D", x"FD5", x"CA0", x"297", x"1E8", x"BD6", x"0D9", x"3D2", x"C7F", x"E75", x"499", x"E75", x"C7F", x"3D2", x"0D9", x"BD6", x"1E8", x"297", x"CA0", x"FD5", x"30D", x"E3F", x"E82", x"25C", x"FC9", x"E41", x"132", x"0A0", x"EC2", x"041", x"0BA", x"F6C", x"FD5", x"079", x"FDA", x"FC2", x"041", x"00A"),
      (x"FD7", x"FDD", x"053", x"FDA", x"FAE", x"08F", x"FE5", x"F46", x"0E7", x"01F", x"EA0", x"132", x"0A6", x"DD5", x"140", x"17E", x"D17", x"0ED", x"28A", x"CA1", x"030", x"391", x"C9F", x"F27", x"452", x"D20", x"E0B", x"499", x"E0B", x"D20", x"452", x"F27", x"C9F", x"391", x"030", x"CA1", x"28A", x"0ED", x"D17", x"17E", x"140", x"DD5", x"0A6", x"132", x"EA0", x"01F", x"0E7", x"F46", x"FE5", x"08F", x"FAE", x"FDA", x"053", x"FDD", x"FD7"),
      (x"03E", x"FF9", x"FBD", x"05C", x"FEE", x"F8D", x"0AD", x"FD4", x"F39", x"131", x"FA5", x"ECF", x"1DE", x"F5E", x"E5F", x"2A1", x"F03", x"DFB", x"362", x"E9B", x"DB5", x"404", x"E35", x"D97", x"470", x"DDE", x"DA6", x"496", x"DA6", x"DDE", x"470", x"D97", x"E35", x"404", x"DB5", x"E9B", x"362", x"DFB", x"F03", x"2A1", x"E5F", x"F5E", x"1DE", x"ECF", x"FA5", x"131", x"F39", x"FD4", x"0AD", x"F8D", x"FEE", x"05C", x"FBD", x"FF9", x"03E"),
      (x"FBB", x"02E", x"014", x"FA4", x"068", x"FF1", x"F78", x"0DA", x"F8D", x"F6A", x"170", x"ECF", x"FB8", x"1EA", x"DCF", x"086", x"1F8", x"CD7", x"1C1", x"164", x"C46", x"31D", x"035", x"C67", x"42D", x"EB0", x"D48", x"494", x"D48", x"EB0", x"42D", x"C67", x"035", x"31D", x"C46", x"164", x"1C1", x"CD7", x"1F8", x"086", x"DCF", x"1EA", x"FB8", x"ECF", x"170", x"F6A", x"F8D", x"0DA", x"F78", x"FF1", x"068", x"FA4", x"014", x"02E", x"FBB"),
      (x"03B", x"FBA", x"024", x"026", x"F8E", x"083", x"FD4", x"F84", x"109", x"F0A", x"012", x"130", x"E15", x"160", x"05B", x"DC6", x"2D7", x"E81", x"EDA", x"35B", x"C87", x"12B", x"227", x"BC2", x"390", x"F8F", x"CF0", x"494", x"CF0", x"F8F", x"390", x"BC2", x"227", x"12B", x"C87", x"35B", x"EDA", x"E81", x"2D7", x"DC6", x"05B", x"160", x"E15", x"130", x"012", x"F0A", x"109", x"F84", x"FD4", x"083", x"F8E", x"026", x"024", x"FBA", x"03B"),
      (x"FDD", x"046", x"FB5", x"026", x"029", x"F7C", x"0B2", x"F84", x"FD9", x"0F6", x"E8C", x"131", x"FE8", x"E9F", x"266", x"DC6", x"0B6", x"180", x"CC9", x"35D", x"E5B", x"ED4", x"399", x"BC0", x"2A5", x"071", x"C9D", x"496", x"C9D", x"071", x"2A5", x"BC0", x"399", x"ED4", x"E5B", x"35D", x"CC9", x"180", x"0B6", x"DC6", x"266", x"E9F", x"FE8", x"131", x"E8C", x"0F6", x"FD9", x"F84", x"0B2", x"F7C", x"029", x"026", x"FB5", x"046", x"FDD"),
      (x"003", x"FD1", x"051", x"FA4", x"03E", x"00F", x"F85", x"0DB", x"F0D", x"096", x"037", x"ECE", x"1E9", x"E14", x"10A", x"086", x"DD2", x"32C", x"D10", x"166", x"0F0", x"CE0", x"434", x"C63", x"180", x"151", x"C52", x"499", x"C52", x"151", x"180", x"C63", x"434", x"CE0", x"0F0", x"166", x"D10", x"32C", x"DD2", x"086", x"10A", x"E14", x"1E9", x"ECE", x"037", x"096", x"F0D", x"0DB", x"F85", x"00F", x"03E", x"FA4", x"051", x"FD1", x"003"),
      (x"01E", x"007", x"FCE", x"05C", x"F88", x"074", x"FC2", x"FD4", x"0B5", x"ECE", x"16B", x"ECE", x"078", x"0A2", x"E32", x"2A4", x"D3A", x"207", x"F7F", x"E9A", x"31B", x"BF8", x"3CF", x"D95", x"038", x"224", x"C10", x"49B", x"C10", x"224", x"038", x"D95", x"3CF", x"BF8", x"31B", x"E9A", x"F7F", x"207", x"D3A", x"2A4", x"E32", x"0A2", x"078", x"ECE", x"16B", x"ECE", x"0B5", x"FD4", x"FC2", x"074", x"F88", x"05C", x"FCE", x"007", x"01E"),
      (x"FC9", x"023", x"FFC", x"FDA", x"05A", x"F71", x"0B6", x"F46", x"08A", x"FE1", x"F82", x"132", x"E2E", x"22C", x"DE9", x"17F", x"F91", x"F13", x"24E", x"CA0", x"3DC", x"C6E", x"282", x"F27", x"EEB", x"2E1", x"BDA", x"49B", x"BDA", x"2E1", x"EEB", x"F27", x"282", x"C6E", x"3DC", x"CA0", x"24E", x"F13", x"F91", x"17F", x"DE9", x"22C", x"E2E", x"132", x"F82", x"FE1", x"08A", x"F46", x"0B6", x"F71", x"05A", x"FDA", x"FFC", x"023", x"FC9"),
      (x"044", x"FBF", x"038", x"FDA", x"006", x"02B", x"F93", x"0B9", x"EFC", x"13D", x"EAF", x"131", x"F2D", x"037", x"097", x"E83", x"25B", x"CF5", x"36A", x"CA3", x"2DA", x"E19", x"09E", x"0D8", x"DB7", x"37F", x"BB2", x"496", x"BB2", x"37F", x"DB7", x"0D8", x"09E", x"E19", x"2DA", x"CA3", x"36A", x"CF5", x"25B", x"E83", x"097", x"037", x"F2D", x"131", x"EAF", x"13D", x"EFC", x"0B9", x"F93", x"02B", x"006", x"FDA", x"038", x"FBF", x"044"),
      (x"FC0", x"048", x"FAE", x"05B", x"F9F", x"05E", x"FB2", x"02B", x"00D", x"FA4", x"0BF", x"ED0", x"1A5", x"DEE", x"26A", x"D62", x"2A4", x"D8D", x"207", x"E9D", x"090", x"065", x"E98", x"266", x"CB9", x"3F8", x"B96", x"491", x"B96", x"3F8", x"CB9", x"266", x"E98", x"065", x"090", x"E9D", x"207", x"D8D", x"2A4", x"D62", x"26A", x"DEE", x"1A5", x"ED0", x"0BF", x"FA4", x"00D", x"02B", x"FB2", x"05E", x"F9F", x"05B", x"FAE", x"048", x"FC0"),
      (x"02E", x"FC7", x"048", x"FA4", x"076", x"F6B", x"0B8", x"F25", x"0FD", x"EE6", x"12C", x"ECE", x"126", x"EF9", x"0D2", x"F7A", x"025", x"050", x"F2B", x"166", x"E04", x"291", x"CE2", x"39D", x"BF9", x"457", x"B77", x"499", x"B77", x"457", x"BF9", x"39D", x"CE2", x"291", x"E04", x"166", x"F2B", x"050", x"025", x"F7A", x"0D2", x"EF9", x"126", x"ECE", x"12C", x"EE6", x"0FD", x"F25", x"0B8", x"F6B", x"076", x"FA4", x"048", x"FC7", x"02E"),
      (x"FEB", x"01B", x"FDC", x"030", x"FBE", x"059", x"F88", x"09D", x"F35", x"101", x"EC2", x"183", x"E30", x"222", x"D86", x"2D5", x"CCE", x"390", x"C13", x"446", x"B66", x"4E7", x"AD4", x"566", x"A6B", x"5B7", x"A34", x"5D3", x"A34", x"5B7", x"A6B", x"566", x"AD4", x"4E7", x"B66", x"446", x"C13", x"390", x"CCE", x"2D5", x"D86", x"222", x"E30", x"183", x"EC2", x"101", x"F35", x"09D", x"F88", x"059", x"FBE", x"030", x"FDC", x"01B", x"FEB")
   );

   signal coeffs_current : coeffs_type;

   --type result_line_mics_type is array (63 downto 0) of result_line_type;
   --type result_line_mics_band_type is array (M - 1 downto 0) of result_line_mics_type;
   --signal result_line_mics_band : result_line_mics_band_type;
   --signal result_line_mics        : result_line_mics_type;
   type line_data_72_type is array((nr_taps - 1) / 2 - 1 downto 0) of std_logic_vector(71 downto 0);
   signal write_line_data_72 : line_data_72_type;
   signal read_line_data_72  : line_data_72_type;

   type result_line_type is array (nr_taps - 2 downto 0) of std_logic_vector(35 downto 0);
   signal circular_buffer_read_data     : result_line_type;
   signal circular_buffer_write_data    : result_line_type;
   signal circular_buffer_write_en      : std_logic;
   signal circular_buffer_read_en       : std_logic;
   signal circular_buffer_write_address : std_logic_vector(15 downto 0);
   signal circular_buffer_read_address  : std_logic_vector(15 downto 0);

   signal result : std_logic_vector(35 downto 0);

   signal mic_counter  : unsigned(7 downto 0);
   signal band_counter : unsigned(7 downto 0);

   type state_type is (idle, load, run, run_2, save); -- Three states for the state-machine. See State-diagram for more information
   signal state   : state_type;
   signal state_1 : integer; -- Only for buggtesting

begin

   process (clk)
   begin
      if rising_edge(clk) then
         if data_in_valid = '1' then
            data_in_d <= data_in;
         end if;

         if rst = '1' then
            state          <= idle;
            data_out_valid <= '0';
            mic_counter    <= (others => '0');
            band_counter   <= (others => '0');

            circular_buffer_read_address  <= (others => '0');
            circular_buffer_write_address <= (others => '0');

         else
            state          <= state;
            data_out_valid <= '0';
            mic_counter    <= mic_counter;
            band_counter   <= band_counter;

            circular_buffer_write_en <= '0';
            circular_buffer_read_en  <= '0';

            case state is
               when idle =>

                  if (data_in_valid = '1') then
                     state <= load;
                  end if;

               when load =>
                  state       <= run;
                  data_fir_in <= data_in_d(to_integer(mic_counter));

                  coeffs_current <= coeffs_all(to_integer(band_counter));

                  circular_buffer_read_address <= std_logic_vector(mic_counter + band_counter * nr_mics);
                  circular_buffer_read_en      <= '1';

               when run =>
                  state <= run_2;

               when run_2 =>
                  state <= save;

               when save =>

                  if bypass_filter = '0' then
                     data_out(to_integer(mic_counter)) <= result(35 downto 12);
                     circular_buffer_write_address     <= std_logic_vector(mic_counter + band_counter * nr_mics);
                     circular_buffer_write_en          <= '1';
                  else
                     -- bypass filter function (set in top file)
                     data_out(to_integer(mic_counter)) <= data_in_d(to_integer(mic_counter));
                  end if;

                  if mic_counter < nr_mics - 1 then
                     state       <= load;
                     mic_counter <= mic_counter + 1;
                  else
                     data_out_valid <= '1';
                     subband_out    <= std_logic_vector(band_counter);

                     if band_counter < nr_subbands - 1 then
                        state        <= load;
                        mic_counter  <= (others => '0');
                        band_counter <= band_counter + 1;
                     else
                        state        <= idle;
                        mic_counter  <= (others => '0');
                        band_counter <= (others => '0');
                     end if;
                  end if;

               when others =>
                  null;
            end case;

         end if;
      end if;
   end process;

   comb : process (circular_buffer_write_data, read_line_data_72)
   begin
      for i in 0 to (nr_taps - 1) / 2 - 1 loop
         write_line_data_72(i) <= circular_buffer_write_data(i * 2) & circular_buffer_write_data(i * 2 + 1);
      end loop;

      for i in 0 to (nr_taps - 1) / 2 - 1 loop
         circular_buffer_read_data(2 * i)     <= read_line_data_72(i)(71 downto 36);
         circular_buffer_read_data(2 * i + 1) <= read_line_data_72(i)(35 downto 0);
      end loop;
   end process;

   circular_mega_buffer_bram_gen : for i in 0 to (nr_taps - 1) / 2 - 1 generate
      circular_mega_buffer_bram_inst : entity work.circular_mega_buffer_bram
         generic map(
            nr_subbands => nr_subbands,
            nr_mics     => nr_mics
         )
         port map(
            clk             => clk,
            write_address   => circular_buffer_write_address,
            write_en        => circular_buffer_write_en,
            write_line_data => write_line_data_72(i),
            read_address    => circular_buffer_read_address,
            read_en         => circular_buffer_read_en,
            read_line_data  => read_line_data_72(i)
         );
   end generate;

   transposed_fir_dsp_first : entity work.transposed_fir_dsp
      port map(
         clk       => clk,
         sample_in => data_fir_in,
         coeff     => coeffs_current(nr_taps - 1), --reversed taps in a transposed filter (dose not matter if we have symetri in coeffs)
         data_sum => (others => '0'),
         result    => circular_buffer_write_data(0)
      );

   transposed_fir_gen : for i in 1 to nr_taps - 2 generate
      transposed_fir_dsp_inst : entity work.transposed_fir_dsp
         port map(
            clk       => clk,
            sample_in => data_fir_in,
            coeff     => coeffs_current(nr_taps - 1 - i),
            data_sum  => circular_buffer_read_data(i - 1),
            result    => circular_buffer_write_data(i)
         );
   end generate;

   transposed_fir_dsp_last : entity work.transposed_fir_dsp
      port map(
         clk       => clk,
         sample_in => data_fir_in,
         coeff     => coeffs_current(0),
         data_sum  => circular_buffer_read_data(nr_taps - 2),
         result    => result
      );

   state_num : process (state) -- Only for findig buggs in gtkwave
   begin
      if state = idle then
         state_1 <= 0;
         --elsif state = load_coeff then
         --   state_1 <= 1;
      elsif state = load then
         state_1 <= 1;
      elsif state = run then
         state_1 <= 2;
      elsif state = run_2 then
         state_1 <= 3;
      elsif state = save then
         state_1 <= 4;
      end if;
   end process;

end architecture;