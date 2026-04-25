library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity fir_filter_tb is
end fir_filter_tb;

architecture behavioral of fir_filter_tb is
    constant N_TAPS       : integer := 8;
    constant COEFF_WIDTH  : integer := 16;
    constant SAMPLE_WIDTH : integer := 16;
    constant OUT_WIDTH    : integer := SAMPLE_WIDTH + COEFF_WIDTH + 2;
    constant CLK_PERIOD   : time    := 10 ns;
    constant PI           : real    := 3.14159265358979;

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal x_in  : signed(SAMPLE_WIDTH-1 downto 0)  := (others => '0');
    signal y_out : signed(OUT_WIDTH-1 downto 0);
begin
    uut: entity work.fir_filter
        generic map (
            N_TAPS       => N_TAPS,
            COEFF_WIDTH  => COEFF_WIDTH,
            SAMPLE_WIDTH => SAMPLE_WIDTH
        )
        port map (
            clk   => clk,
            rst   => rst,
            x_in  => x_in,
            y_out => y_out
        );

    clk_process: process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    stim_process: process
        variable t    : real;
        variable low  : real;
        variable high : real;
    begin
        rst <= '1';
        wait for 30 ns;
        rst <= '0';
        wait for CLK_PERIOD;

        -- TEST 1: IMPULSE
        report "=== TEST 1: IMPULSE RESPONSE ===" severity note;
        x_in <= to_signed(32767, SAMPLE_WIDTH);
        wait for CLK_PERIOD;
        x_in <= (others => '0');
        wait for CLK_PERIOD * (N_TAPS + 2);

        -- TEST 2: STEP
        report "=== TEST 2: STEP RESPONSE ===" severity note;
        rst <= '1'; wait for 20 ns; rst <= '0';
        wait for CLK_PERIOD;
        x_in <= to_signed(1000, SAMPLE_WIDTH);
        wait for CLK_PERIOD * 20;
        x_in <= (others => '0');
        wait for CLK_PERIOD * 5;

        -- TEST 3: NOISY SINE
        report "=== TEST 3: NOISY SINE ===" severity note;
        rst <= '1'; wait for 20 ns; rst <= '0';
        wait for CLK_PERIOD;
        for i in 0 to 199 loop
            t    := real(i) / 100.0;
            low  := 10000.0 * sin(2.0 * PI * 0.05 * t);
            high := 10000.0 * sin(2.0 * PI * 0.4  * t);
            x_in <= to_signed(integer(low + high), SAMPLE_WIDTH);
            wait for CLK_PERIOD;
        end loop;

        report "=== ALL TESTS COMPLETE ===" severity note;
        wait;
    end process;
end behavioral;
