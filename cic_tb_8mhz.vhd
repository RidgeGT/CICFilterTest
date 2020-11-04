-- cic_tb_8mhz.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;
use STD.textio.all;
entity cic_tb_8mhz is
--  Port ( );
end cic_tb_8mhz;
architecture Behavioral of cic_tb_8mhz is
component cic is     
    generic(CI_SIZE : integer := 18;    -- cic input data width             
            CO_SIZE : integer := 30;    -- cic output data width             
            STAGES  : integer := 5);    
    port (clk     : in  std_logic;      -- system clock (80 Mhz)           
          ce      : in  std_logic;      -- clock enable           
          ce_r    : in  std_logic;      -- decimated clock by factor of 5 used in comb section           
          rst     : in  std_logic;      -- system reset           
          d       : in  std_logic_vector (CI_SIZE-1 downto 0);        -- input data           
          q       : out std_logic_vector (CO_SIZE-1 downto 0));       -- output data
end component; 
signal clk_sig,ce_r_sig: std_logic := '0';
signal rst_sig: std_logic := '0';
signal ce_sig: std_logic := '1';
signal d_sig: std_logic_vector(17 downto 0);
signal q_sig: std_logic_vector(29 downto 0);
constant cp: time := 12.5 ns;
begin
    DUT: cic
    port map(
        clk => clk_sig,
        ce => ce_sig,
        ce_r => ce_r_sig,
        rst => rst_sig,
        d => d_sig,
        q => q_sig
    );
    CLOCK_GEN:process(clk_sig)
        file file_out:text is out "C:\Users\kyle\Documents\Ridge\HOMEWORK\524\output.csv";
        variable output_line: line;
        variable output_temp: std_logic_vector(29 downto 0);
        variable input_temp: std_logic_vector(17 downto 0);
    begin
        clk_sig <= not clk_sig after cp/2;
        if(clk_sig' event and clk_sig = '1') then
            output_temp := q_sig;
            input_temp := d_sig;
            write(output_line,now);
            write(output_line,',');
            write(output_line,TO_INTEGER(signed(input_temp)));
            write(output_line,',');
            write(output_line,TO_INTEGER(signed(output_temp)));
            writeline(file_out,output_line);
        end if;
    end process;
    DECIMATED_CLOCK: process
    begin
        wait for 4*cp;
        ce_r_sig <= '1';
        wait for cp;
        ce_r_sig <='0';
    end process;
    
    RESET: process
    file file_out:text is out "C:\Users\kyle\Documents\Ridge\HOMEWORK\524\output.csv";
    variable outline:line;
    begin
        write(outline,string'("time,input,output,"));
        writeline(file_out,outline);
        rst_sig <= '1';
        wait for cp;
        rst_sig <= '0';
        wait;
    end process;
    
    STIM: process
    begin
        wait for cp;
        -- t = 0 ns
        d_sig <= (others => '0');
        wait for cp; -- t = 12.5 ns
        d_sig <= std_logic_vector(to_signed(77042,18));
        wait for cp; -- t = 25 ns
        d_sig <= std_logic_vector(to_signed(124656,18));
        wait for cp; -- t = 37.5 ns
        d_sig <= std_logic_vector(to_signed(124656,18));
        wait for cp; -- t = 50 ns
        d_sig <= std_logic_vector(to_signed(77042,18));
        wait for cp; -- t = 62.5 ns
        d_sig <= std_logic_vector(to_signed(0,18));
        wait for cp; -- t = 75 ns
        d_sig <= std_logic_vector(to_signed(-77042,18));
        wait for cp; -- t = 87.5 ns
        d_sig <= std_logic_vector(to_signed(-124656,18));
        wait for cp; -- t = 100 ns
        d_sig <= std_logic_vector(to_signed(-124656,18));
        wait for cp; -- t = 112.5 ns
        d_sig <= std_logic_vector(to_signed(-77042,18));
    end process;
end Behavioral;
 
