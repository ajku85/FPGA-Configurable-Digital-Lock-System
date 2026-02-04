library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Test bench entity is empty
entity fsm_controller_tb is
end fsm_controller_tb;

architecture Behavioral of fsm_controller_tb is

    -- 1. Component declaration for the Unit Under Test (UUT)
    component fsm_controller
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            key_pressed : in STD_LOGIC;
            key_value_in : in STD_LOGIC_VECTOR (3 downto 0);
            unlocked_led : out STD_LOGIC;
            locked_led : out STD_LOGIC;
            typing_led : out STD_LOGIC
        );
    end component;

    -- 2. Signal declarations ("wires") to connect to the UUT
    signal tb_clk : STD_LOGIC := '0';
    signal tb_reset : STD_LOGIC := '0';
    signal tb_key_pressed : STD_LOGIC := '0';
    signal tb_key_value_in : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
    signal tb_unlocked_led : STD_LOGIC;
    signal tb_locked_led : STD_LOGIC;
    signal tb_typing_led : STD_LOGIC;

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns; -- 100MHz clock

begin

    -- 3. Instantiate the Unit Under Test
    UUT : fsm_controller
    Port map (
        clk => tb_clk,
        reset => tb_reset,
        key_pressed => tb_key_pressed,
        key_value_in => tb_key_value_in,
        unlocked_led => tb_unlocked_led,
        locked_led => tb_locked_led,
        typing_led => tb_typing_led
    );

    -- 4. Clock generation process
    clk_process : process
    begin
        tb_clk <= '0';
        wait for CLK_PERIOD / 2; -- 5 ns
        tb_clk <= '1';
        wait for CLK_PERIOD / 2; -- 5 ns
    end process;

    -- 5. Stimulus process
    stimulus_process : process

        -- Helper procedure to simulate a single key press
        procedure send_key(key_val : STD_LOGIC_VECTOR(3 downto 0)) is
        begin
            wait until rising_edge(tb_clk);
            tb_key_value_in <= key_val;
            tb_key_pressed <= '1';
            wait until rising_edge(tb_clk);
            tb_key_pressed <= '0';
            -- The buggy line was removed from here
            wait for 10 us; -- Wait a bit between key presses
        end procedure;

    begin
        -- Start with a reset
        report "--- Starting Simulation ---";
        tb_reset <= '1';
        wait for 100 ns;
        tb_reset <= '0';
        wait until rising_edge(tb_clk);
        report "Reset done. FSM should be in S_IDLE.";

        wait for 1 us; -- Give FSM time to stabilize in IDLE

        -- TEST 1: Send the CORRECT passcode (1-3-5-7)
        report "--- Test 1: Sending Correct Passcode (1-3-5-7) ---";
        send_key("0001"); -- Send '1'
        report "Sent '1'. State should be S_READ_1. Typing LED should be ON.";

        send_key("0011"); -- Send '3'
        report "Sent '3'. State should be S_READ_2.";

        send_key("0101"); -- Send '5'
        report "Sent '5'. State should be S_READ_3.";

        send_key("0111"); -- Send '7'
        report "Sent '7'. FSM should now check the code.";

        -- Now, we wait for the FSM to go to S_UNLOCKED
        report "Waiting for Unlocked state...";
        wait for 100 us; -- Give the FSM time to transition

        if tb_unlocked_led = '1' then
             report "SUCCESS: Unlocked LED is ON!";
        else
             report "FAILURE: Unlocked LED did NOT turn on for correct code!";
        end if;

        -- Wait for the FSM timer to finish and return to IDLE
        wait for 510 ms; -- Wait for 0.51 seconds (timer is 0.5s)

        report "Timer should be finished. FSM should be back in S_IDLE.";

        -- TEST 2: Send an INCORRECT passcode (1-2-3-4)
        report "--- Test 2: Sending Incorrect Passcode (1-2-3-4) ---";
        send_key("0001"); -- Send '1'
        send_key("0010"); -- Send '2'
        send_key("0011"); -- Send '3'
        send_key("0100"); -- Send '4'

        report "Waiting for Fail state...";
        wait for 100 us; -- Give FSM time to transition

        if tb_locked_led = '1' and tb_unlocked_led = '0' then
            report "SUCCESS: Lock correctly failed (Locked LED is ON).";
        else
            report "FAILURE: Lock did not fail correctly!";
        end if;

        wait for 510 ms; -- Wait for timer to finish

        report "--- Simulation Finished ---";
        wait; -- Stop the simulation
    end process;

end architecture;