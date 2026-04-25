library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fir_filter is
    generic (
        N_TAPS       : integer := 8;
        COEFF_WIDTH  : integer := 16;
        SAMPLE_WIDTH : integer := 16
    );
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        x_in  : in  signed(SAMPLE_WIDTH-1 downto 0);
        y_out : out signed(SAMPLE_WIDTH+COEFF_WIDTH+1 downto 0)
    );
end fir_filter;

architecture behavioral of fir_filter is
    constant OUT_WIDTH : integer := SAMPLE_WIDTH + COEFF_WIDTH + 2;
    type coeff_array  is array (0 to N_TAPS-1) of signed(COEFF_WIDTH-1 downto 0);
    type sample_array is array (0 to N_TAPS-1) of signed(SAMPLE_WIDTH-1 downto 0);
    constant coeffs : coeff_array := (
        to_signed(287,  COEFF_WIDTH),
        to_signed(1571, COEFF_WIDTH),
        to_signed(5375, COEFF_WIDTH),
        to_signed(9151, COEFF_WIDTH),
        to_signed(9151, COEFF_WIDTH),
        to_signed(5375, COEFF_WIDTH),
        to_signed(1571, COEFF_WIDTH),
        to_signed(287,  COEFF_WIDTH)
    );
    signal shift_reg : sample_array := (others => (others => '0'));
begin
    process(clk)
        variable acc  : signed(OUT_WIDTH-1 downto 0);
        variable prod : signed(SAMPLE_WIDTH+COEFF_WIDTH-1 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                shift_reg <= (others => (others => '0'));
                y_out     <= (others => '0');
            else
                for i in N_TAPS-1 downto 1 loop
                    shift_reg(i) <= shift_reg(i-1);
                end loop;
                shift_reg(0) <= x_in;
                acc := (others => '0');
                for i in 0 to N_TAPS-1 loop
                    prod := shift_reg(i) * coeffs(i);
                    acc  := acc + resize(prod, OUT_WIDTH);
                end loop;
                y_out <= acc;
            end if;
        end if;
    end process;
end behavioral;
