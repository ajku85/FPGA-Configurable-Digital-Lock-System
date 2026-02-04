library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Test bench entity is empty
entity Top_Level_tb is
end Top_Level_tb;

architecture Behavioral of Top_Level_tb is

    -- 1. Component declaration for the Unit Under Test (UUT)
    component Top_Level
        Port ( 
            clk_100mhz : in STD_LOGIC;
            reset : in STD_LOGIC;
            keypad_rows : in STD_LOGIC_VECTOR (3 downto 0);
            keypad_cols : out STD_LOGIC_VECTOR (3 downto 0);
            led_green : out STD_LOGIC;
            led_red : out STD_LOGIC;
            led_yellow : out STD_LOGIC
        );
    end component;

    -- 2. Signal declarations ("wires")
    signal tb_clk : STD_LOGIC := '0';
    signal tb_reset : STD_LOGIC := '0';
    signal tb_keypad_rows : STD_LOGIC_VECTOR (3 downto 0) := (others => '1');
    signal tb_keypad_cols : STD_LOGIC_VECTOR (3 downto 0);
    signal tb_led_green : STD_LOGIC;
    signal tb_led_red : STD_LOGIC;
    signal tb_led_yellow : STD_LOGIC;

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns; -- 100MHz clock

    -- 3. Constants for Keypad Simulation
    -- Key '1' (Col 0, Row 0)
    constant COL_1 : STD_LOGIC_VECTOR(3 downto 0) := "1110";
    constant ROW_1 : STD_LOGIC_VECTOR(3 downto 0) := "1110";
    -- Key '2' (Col 1, Row 0)
    constant COL_2 : STD_LOGIC_VECTOR(3 downto 0) := "1101";
    constant ROW_2 : STD_LOGIC_VECTOR(3 downto 0) := "1110";
    -- Key '3' (Col 2, Row 0)
    constant COL_3 : STD_LOGIC_VECTOR(3 downto 0) := "1011";
    constant ROW_3 : STD_LOGIC_VECTOR(3 downto 0) := "1110";
    -- Key '4' (Col 0, Row 1)
    constant COL_4 : STD_LOGIC_VECTOR(3 downto 0) := "1110";
    constant ROW_4 : STD_LOGIC_VECTOR(3 downto 0) := "1101";
    -- Key '5' (Col 1, Row 1)
    constant COL_5 : STD_LOGIC_VECTOR(3 downto 0) := "1101";
    constant ROW_5 : STD_LOGIC_VECTOR(3 downto 0) := "1101";
    -- Key '6' (Col 2, Row 1)
    constant COL_6 : STD_LOGIC_VECTOR(3 downto 0) := "1011";
    constant ROW_6 : STD_LOGIC_VECTOR(3 downto 0) := "1101";
    -- Key '7' (Col 0, Row 2)
    constant COL_7 : STD_LOGIC_VECTOR(3 downto 0) := "1110";
    constant ROW_7 : STD_LOGIC_VECTOR(3 downto 0) := "1011";
    -- Key '8' (Col 1, Row 2)
    constant COL_8 : STD_LOGIC_VECTOR(3 downto 0) := "1101";
    constant ROW_8 : STD_LOGIC_VECTOR(3 downto 0) := "1011";
    -- Key '*' (Col 0, Row 3)
    constant COL_STAR : STD_LOGIC_VECTOR(3 downto 0) := "1110";
    constant ROW_STAR : STD_LOGIC_VECTOR(3 downto 0) := "0111";

begin

    -- 4. Instantiate the Unit Under Test
    UUT : Top_Level
    Port map (
        clk_100mhz => tb_clk, reset => tb_reset,
        keypad_rows => tb_keypad_rows, keypad_cols => tb_keypad_cols,
        led_green => tb_led_green, led_red => tb_led_red, led_yellow => tb_led_yellow
    );

    -- 5. Clock generation process
    clk_process : process
    begin
        tb_clk <= '0'; wait for CLK_PERIOD / 2;
        tb_clk <= '1'; wait for CLK_PERIOD / 2;
    end process;
    
    -- 6. Stimulus process
    stimulus_process : process
        -- Helper procedure to simulate pressing a key
        procedure simulate_press(
            col_to_wait  : STD_LOGIC_VECTOR(3 downto 0);
            row_to_press : STD_LOGIC_VECTOR(3 downto 0)
        ) is
        begin
            wait until tb_keypad_cols = col_to_wait;
            tb_keypad_rows <= row_to_press;
            wait for 20 ms; -- Hold button for 20ms
            tb_keypad_rows <= "1111"; -- Release button
            wait for 50 ms; -- Time between key presses
        end procedure;
        
    begin
        report "--- Starting Full System Simulation (v2.0) ---";
        tb_reset <= '1'; wait for 100 ns;
        tb_reset <= '0'; wait for 1 us;
        report "Reset done. System in S_IDLE. Default key is 1-3-5-7.";

        -- TEST 1: Try default passcode (1-3-5-7). Should PASS.
        report "--- Test 1: Trying Default Passcode (1-3-5-7) ---";
        simulate_press(COL_1, ROW_1); -- '1'
        simulate_press(COL_3, ROW_3); -- '3'
        simulate_press(COL_5, ROW_5); -- '5'
        simulate_press(COL_7, ROW_7); -- '7'
        wait for 100 us; -- Give FSM time to transition
        if tb_led_green = '1' then
            report "SUCCESS (Test 1): Default key worked! Green LED is ON.";
        else
            report "FAILURE (Test 1): Default key FAILED! Green LED is OFF.";
        end if;
        wait for 600 ms; -- Wait for timer to return to IDLE

        -- TEST 2: Set NEW passcode to 2-4-6-8
        report "--- Test 2: Setting New Passcode to 2-4-6-8 ---";
        simulate_press(COL_STAR, ROW_STAR); -- '*'
        report "  Pressed '*'. FSM should be in S_SET_KEY_1.";
        simulate_press(COL_2, ROW_2); -- '2'
        simulate_press(COL_4, ROW_4); -- '4'
        simulate_press(COL_6, ROW_6); -- '6'
        simulate_press(COL_8, ROW_8); -- '8'
        report "New key 2-4-6-8 is set. FSM should be back in S_IDLE.";
        wait for 100 us;

        -- TEST 3: Try OLD passcode (1-3-5-7). Should FAIL.
        report "--- Test 3: Trying OLD Passcode (1-3-5-7) ---";
        simulate_press(COL_1, ROW_1); -- '1'
        simulate_press(COL_3, ROW_3); -- '3'
        simulate_press(COL_5, ROW_5); -- '5'
        simulate_press(COL_7, ROW_7); -- '7'
        wait for 100 us; -- Give FSM time to transition
        if tb_led_green = '0' and tb_led_red = '1' then
            report "SUCCESS (Test 3): Old key correctly FAILED! Red LED is ON.";
        else
            report "FAILURE (Test 3): Old key still worked! Green LED is ON.";
        end if;
        wait for 600 ms; -- Wait for timer to return to IDLE

        -- TEST 4: Try NEW passcode (2-4-6-8). Should PASS.
        report "--- Test 4: Trying NEW Passcode (2-4-6-8) ---";
        simulate_press(COL_2, ROW_2); -- '2'
        simulate_press(COL_4, ROW_4); -- '4'
        simulate_press(COL_6, ROW_6); -- '6'
        simulate_press(COL_8, ROW_8); -- '8'
        wait for 100 us; -- Give FSM time to transition
        if tb_led_green = '1' then
            report "SUCCESS (Test 4): New key worked! Green LED is ON.";
        else
            report "FAILURE (Test 4): New key FAILED! Green LED is OFF.";
        end if;
        wait for 600 ms; 

        report "--- Simulation v2.0 Finished ---";
        wait; -- Stop the simulation
    end process;

end Behavioral;