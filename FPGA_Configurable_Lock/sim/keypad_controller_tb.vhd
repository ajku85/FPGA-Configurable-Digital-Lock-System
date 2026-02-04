library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Test bench entity
entity keypad_controller_tb is
end keypad_controller_tb;

architecture Behavioral of keypad_controller_tb is

    -- 1. Declare the component to test
    component keypad_controller
        Port ( 
            clk : in STD_LOGIC;
            rows : in STD_LOGIC_VECTOR (3 downto 0);
            cols : out STD_LOGIC_VECTOR (3 downto 0);
            key_value : out STD_LOGIC_VECTOR (3 downto 0);
            key_pressed : out STD_LOGIC
        );
    end component;

    -- 2. Create signals or wires to conect the component
    signal tb_clk : STD_LOGIC := '0';
    signal tb_rows : STD_LOGIC_VECTOR (3 downto 0) := "1111"; -- Steady, all rows are '1'
    signal tb_cols : STD_LOGIC_VECTOR (3 downto 0);
    signal tb_key_value : STD_LOGIC_VECTOR (3 downto 0);
    signal tb_key_pressed : STD_LOGIC;

    -- Constant for clocks period
    constant CLK_PERIOD : time := 10 ns; -- 10 ns = 100MHz (Like in the Basys 3)

begin

    -- 3. Instance the component to be tested
    -- Connect the cables from the test bench to the controller´s ports
    UUT : keypad_controller -- UUT = Unit Under Test (Unidad Bajo Prueba)
    Port map (
        clk => tb_clk,
        rows => tb_rows,
        cols => tb_cols,
        key_value => tb_key_value,
        key_pressed => tb_key_pressed
    );

    -- 4. Clock generation process
    -- Create a virtual clock signal that oscillates every 10ns
    clk_process : process
    begin
        tb_clk <= '0';
        wait for CLK_PERIOD / 2; -- Wait 5 ns
        tb_clk <= '1';
        wait for CLK_PERIOD / 2; -- Wait 5 ns more
    end process;

    -- 5. Stimulus Process (simulate the button presses)
    -- This process will simulate the pressing of multiple keys
    stimulus_process : process
    begin
        -- Initial state: no key pressed
        tb_rows <= "1111";
        wait for 1 ms; -- Wait 1 ms for system stabilization

        -- Simulate pressing key '1'
        -- Key '1' is located at Column 0 and Row 0
        -- The test bench must simulate physical behavior:
            -- When the scanner (tb_cols) sets Column 0 to '0' (1110) we respond by setting Row 0 to '0' (1110).
        report "--- Presionando Tecla '1' ---";
        -- We wait for the scanner to activate the column 0
        wait until tb_cols = "1110"; 
        tb_rows <= "1110"; -- Press the row 0
        
        -- Wait for key_pressed pulse to be detected 
        wait until rising_edge(tb_key_pressed);
        report "Tecla '1' detectada! Valor: " & integer'image(to_integer(unsigned(tb_key_value)));
        
        -- Release the key
        tb_rows <= "1111"; 
        wait for 1 ms; -- waiting time between keys

        -- Simulate the pressing of key '5'
        -- La tecla '5' está en la Columna 1, Fila 1
        report "--- Pressing key '5' ---";
        wait until tb_cols = "1101"; -- Wait for coulumn 1 to activate
        tb_rows <= "1101"; -- Press row 1
        
        wait until rising_edge(tb_key_pressed);
        report "Key '5' detected! Value: " & integer'image(to_integer(unsigned(tb_key_value)));
        
        tb_rows <= "1111";
        wait for 1 ms;

        -- Simulate the pressing of key '9'
        -- Key '9' is on column 2 and row 2
        report "--- Pressing key '9' ---";
        wait until tb_cols = "1011"; -- Wait for column 2 to activate
        tb_rows <= "1010"; -- Press row 2
        
        wait until rising_edge(tb_key_pressed);
        report "Key '9' detected! Value: " & integer'image(to_integer(unsigned(tb_key_value)));
        
        tb_rows <= "1111";
        wait for 1 ms;

        report "--- Simulation Finished! ---";
        wait; -- Stops the simualtion
    end process;

end Behavioral;