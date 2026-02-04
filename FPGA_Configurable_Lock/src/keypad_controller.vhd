library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- For controlers and arithmethic

entity keypad_controller is
    Port ( 
        clk : in STD_LOGIC; -- Clock on the board
        rows : in STD_LOGIC_VECTOR (3 downto 0); -- Row entries, with pull-up, active on low)
        cols : out STD_LOGIC_VECTOR (3 downto 0); -- Column exits (active in low)
        key_value : out STD_LOGIC_VECTOR (3 downto 0); -- Value  of the key (0-15)
        key_pressed : out STD_LOGIC -- New key pressed pulse
    );
end keypad_controller;

architecture Behavioral of keypad_controller is

    -- Frequency divider to make a slower clock
    signal clk_div_counter : integer range 0 to 50000 := 0; -- Counter to divide the 100MHz
    signal scan_clk : STD_LOGIC := '0'; -- Our clock, 100kHz

    -- Signals for keypad
    signal scan_index : integer range 0 to 3 := 0; -- Actual Column Index (0, 1, 2 OR 3)
    signal cols_internal : STD_LOGIC_VECTOR(3 downto 0) := "1110"; -- Internal signal for columns
    
    -- Signals to detect the key and handle debounce
    signal key_detected : STD_LOGIC := '0'; -- Says if there is a pressed key
    signal key_value_internal : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    
    -- Auntobounce logic part and singl pulses detection
    signal debounce_counter : integer range 0 to 20 := 0; -- Antibounce counter
    signal key_down : STD_LOGIC := '0'; -- Indicates a key is being pressed
    signal last_key_down : STD_LOGIC := '0'; -- Prevous state of the key down variable

begin

    -- Process 1: Frequency Divider
    -- Create a clock called 'scan_clk' that is slower (1kHz) from the 100MHz clock
    process(clk)
    begin
        if rising_edge(clk) then
            if clk_div_counter = 49999 then -- 100MHz / 50000 = 2kHz. (1kHz pulse)
                clk_div_counter <= 0;
                scan_clk <= not scan_clk; -- Generates slow clock pulse
            else
                clk_div_counter <= clk_div_counter + 1;
            end if;
        end if;
    end process;

    -- Process 2: Keyboard scanner
    -- USes the slow clock 'scan_clk' to change the active column
    process(scan_clk)
    begin
        if rising_edge(scan_clk) then
            -- Changes the '0' in the columns
            if scan_index = 3 then
                scan_index <= 0;
                cols_internal <= "1110"; -- Activates column 0
            elsif scan_index = 0 then
                scan_index <= 1;
                cols_internal <= "1101"; -- Activates column 1
            elsif scan_index = 1 then
                scan_index <= 2;
                cols_internal <= "1011"; -- Activates column 2
            else -- scan_index = 2
                scan_index <= 3;
                cols_internal <= "0111"; -- Activates column 3
            end if;
        end if;
    end process;
    
    -- Sets the active column to the output
    cols <= cols_internal;

    -- Process 3: Key detection and antibounce
    -- Checks constantly if a key is pressed and hanldes the antirebounce
    -- This process uses the fast clock 'clk' for it to be faster and more responsive
    process(clk)
        variable row_index : integer range 0 to 3;
        variable col_index : integer range 0 to 3;
    begin
        if rising_edge(clk) then
            -- Detection in '0'
            key_detected <= '0'; -- We assume there is no key pressed
            
            if rows(0) = '0' then
                key_detected <= '1';
                row_index := 0;
            elsif rows(1) = '0' then
                key_detected <= '1';
                row_index := 1;
            elsif rows(2) = '0' then
                key_detected <= '1';
                row_index := 2;
            elsif rows(3) = '0' then
                key_detected <= '1';
                row_index := 3;
            end if;
            
            -- We save the index where the column was active when the key was detected
            col_index := scan_index;

            -- Debounce logic and unique pulse detection
            last_key_down <= key_down; -- we save the previous state
            
            if key_detected = '1' then
                -- When a key is detetected we satrt the antidebounce counter
                if debounce_counter < 20 then
                    debounce_counter <= debounce_counter + 1;
                else
                    key_down <= '1'; -- Key is set and known as pressed
                    -- We mapped the rows and columns for the value (0-15)
                    -- (col_index * 4) + row_index. We used a simple mapping logic 
                    case col_index is
                        when 0 => -- Col 0 (Keys 1, 4, 7, *)
                            case row_index is
                                when 0 => key_value_internal <= "0001"; -- 1
                                when 1 => key_value_internal <= "0100"; -- 4
                                when 2 => key_value_internal <= "0111"; -- 7
                                when 3 => key_value_internal <= "1110"; -- * (14)
                                when others => key_value_internal <= "1111";
                            end case;
                        when 1 => -- Col 1 (Keys 2, 5, 8, 0)
                            case row_index is
                                when 0 => key_value_internal <= "0010"; -- 2
                                when 1 => key_value_internal <= "0101"; -- 5
                                when 2 => key_value_internal <= "1000"; -- 8
                                when 3 => key_value_internal <= "0000"; -- 0
                                when others => key_value_internal <= "1111";
                            end case;
                        when 2 => -- Col 2 (Keys 3, 6, 9, #)
                            case row_index is
                                when 0 => key_value_internal <= "0011"; -- 3
                                when 1 => key_value_internal <= "0110"; -- 6
                                when 2 => key_value_internal <= "1001"; -- 9
                                when 3 => key_value_internal <= "1111"; -- # (15)
                                when others => key_value_internal <= "1111";
                            end case;
                        when 3 => -- Col 3 (keys A, B, C, D)
                            case row_index is
                                when 0 => key_value_internal <= "1010"; -- A (10)
                                when 1 => key_value_internal <= "1011"; -- B (11)
                                when 2 => key_value_internal <= "1100"; -- C (12)
                                when 3 => key_value_internal <= "1101"; -- D (13)
                                when others => key_value_internal <= "1111";
                            end case;
                        when others =>
                            key_value_internal <= "1111"; -- Value 'F' (error)
                    end case;
                end if;
            else
                --  If no key is detected the antidebounce is restarted
                debounce_counter <= 0;
                key_down <= '0';
            end if;

            -- Single pulse output:
            -- It activates ONLY in the exact cicle where the key goes from "no pressed"(last_key_down='0') to "pressed" (key_down='1')
            if key_down = '1' and last_key_down = '0' then
                key_pressed <= '1';
                key_value <= key_value_internal; -- Send the key value to the output
            else
                key_pressed <= '0';
            end if;

        end if;
    end process;

end Behavioral;