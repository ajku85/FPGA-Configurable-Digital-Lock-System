library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_controller is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        key_pressed : in STD_LOGIC;
        key_value_in : in STD_LOGIC_VECTOR (3 downto 0);
        unlocked_led : out STD_LOGIC;
        locked_led : out STD_LOGIC;
        typing_led : out STD_LOGIC
    );
end fsm_controller;

architecture Behavioral of fsm_controller is

    -- 1. Define states
    type T_STATE is (
        S_IDLE,         -- Waiting for the first key (or '*' to set key)
        S_READ_1,       -- Reading 2nd key
        S_READ_2,       -- Reading 3rd key
        S_READ_3,       -- Reading 4th key (and checking)
        S_UNLOCKED,     -- Correct passcode state
        S_FAIL,         -- Incorrect passcode state
        S_SET_KEY_1,    -- Waiting for 1st key of new passcode
        S_SET_KEY_2,    -- Waiting for 2nd key of new passcode
        S_SET_KEY_3,    -- Waiting for 3rd key of new passcode
        S_SET_KEY_4     -- Waiting for 4th key of new passcode
    );
    signal current_state, next_state : T_STATE := S_IDLE;

    -- 2. Passcode storage
    -- The key is a signal (register), not a constant.
    -- It needs an initial default value (1-3-5-7)
    signal key_master_1 : STD_LOGIC_VECTOR(3 downto 0) := "0001"; -- '1'
    signal key_master_2 : STD_LOGIC_VECTOR(3 downto 0) := "0011"; -- '3'
    signal key_master_3 : STD_LOGIC_VECTOR(3 downto 0) := "0101"; -- '5'
    signal key_master_4 : STD_LOGIC_VECTOR(3 downto 0) := "0111"; -- '7'

    -- Registers for the user's attempt 
    signal key_reg_1 : STD_LOGIC_VECTOR(3 downto 0);
    signal key_reg_2 : STD_LOGIC_VECTOR(3 downto 0);
    signal key_reg_3 : STD_LOGIC_VECTOR(3 downto 0);

    -- 3. Timer
    signal timer_counter : integer range 0 to 50_000_000 := 0; -- 0.5 sec timer
    
    -- 4. Constants for special keys
    constant KEY_ASTERISK : STD_LOGIC_VECTOR(3 downto 0) := "1110"; -- Key '*' (14)

begin

    -- PROCESS 1: Synchronous Logic (State Memory and Registers)
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Reset** also resets the key to default
                current_state <= S_IDLE;
                timer_counter <= 0;
                key_master_1 <= "0001";
                key_master_2 <= "0011";
                key_master_3 <= "0101";
                key_master_4 <= "0111";
            else
                -- Update the state
                current_state <= next_state;
                
                -- Timer logic
                if (current_state = S_UNLOCKED) or (current_state = S_FAIL) then
                    if timer_counter < 50_000_000 then
                        timer_counter <= timer_counter + 1;
                    end if;
                else
                    timer_counter <= 0;
                end if;
                
                -- Key register logic (for opening the lock)
                if key_pressed = '1' then
                    case current_state is
                        when S_IDLE =>
                            key_reg_1 <= key_value_in;
                        when S_READ_1 =>
                            key_reg_2 <= key_value_in;
                        when S_READ_2 =>
                            key_reg_3 <= key_value_in;
                        when others =>
                            null;
                    end case;
                end if;
                
                -- Key master register logic (for setting the lock)
                if key_pressed = '1' then
                    case current_state is
                        when S_SET_KEY_1 =>
                            key_master_1 <= key_value_in; -- Write new 1st key
                        when S_SET_KEY_2 =>
                            key_master_2 <= key_value_in; -- Write new 2nd key
                        when S_SET_KEY_3 =>
                            key_master_3 <= key_value_in; -- Write new 3rd key
                        when S_SET_KEY_4 =>
                            key_master_4 <= key_value_in; -- Write new 4th key
                        when others =>
                            null;
                    end case;
                end if;
                
            end if;
        end if;
    end process;

    -- PROCESS 2: Combinational Logic (State Transition)
    process(current_state, key_pressed, timer_counter, key_value_in, key_reg_1, key_reg_2, key_reg_3,
            key_master_1, key_master_2, key_master_3, key_master_4) -- Must include new master keys
    begin
        next_state <= current_state; 

        case current_state is
            when S_IDLE =>
                if key_pressed = '1' then
                    if key_value_in = KEY_ASTERISK then
                        next_state <= S_SET_KEY_1; -- Go to "Set Key" mode
                    else
                        next_state <= S_READ_1; -- Go to "Open Lock" mode
                    end if;
                end if;
                
            -- "Open Lock" Path
            when S_READ_1 =>
                if key_pressed = '1' then
                    next_state <= S_READ_2;
                end if;
            when S_READ_2 =>
                if key_pressed = '1' then
                    next_state <= S_READ_3;
                end if;
            when S_READ_3 =>
                if key_pressed = '1' then
                    -- Check against the registers, not constants
                    if (key_reg_1 = key_master_1) and 
                       (key_reg_2 = key_master_2) and 
                       (key_reg_3 = key_master_3) and 
                       (key_value_in = key_master_4) then
                        next_state <= S_UNLOCKED; -- Correct password
                    else
                        next_state <= S_FAIL; -- Incorrect password
                    end if;
                end if;
                
            -- "Set Key" Path
            when S_SET_KEY_1 =>
                if key_pressed = '1' then
                    next_state <= S_SET_KEY_2;
                end if;
            when S_SET_KEY_2 =>
                if key_pressed = '1' then
                    next_state <= S_SET_KEY_3;
                end if;
            when S_SET_KEY_3 =>
                if key_pressed = '1' then
                    next_state <= S_SET_KEY_4;
                end if;
            when S_SET_KEY_4 =>
                if key_pressed = '1' then
                    next_state <= S_IDLE; -- New key is set then Return to idle.
                end if;

            -- "Result" Path
            when S_UNLOCKED =>
                if timer_counter = 50_000_000 then
                    next_state <= S_IDLE;
                end if;
            when S_FAIL =>
                if timer_counter = 50_000_000 then
                    next_state <= S_IDLE;
                end if;

        end case;
    end process;
    
    -- PROCESS 3: Output Logic (LED Control)
    process(current_state)
    begin
        unlocked_led <= '0';
        locked_led <= '0';
        typing_led <= '0';
        
        case current_state is
            when S_IDLE =>
                locked_led <= '1'; -- Red LED
                
            when S_READ_1 | S_READ_2 | S_READ_3 =>
                typing_led <= '1'; -- Yellow LED
            
            -- Make yellow LED blink when in "Set Key" mode
            when S_SET_KEY_1 | S_SET_KEY_2 | S_SET_KEY_3 | S_SET_KEY_4 =>
                -- We'll just turn it on solid for simulation.
                typing_led <= '1'; 

            when S_UNLOCKED =>
                unlocked_led <= '1'; -- Green LED
                
            when S_FAIL =>
                locked_led <= '1'; -- Red LED
                
        end case;
    end process;

end Behavioral;