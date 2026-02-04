library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- This is the main entity
-- Its ports are the real physical connections to the real world
entity Top_Level is
    Port ( 
        clk_100mhz : in STD_LOGIC; -- Main 100MHz clock from the board
        reset : in STD_LOGIC; -- A physical reset button
        keypad_rows : in STD_LOGIC_VECTOR (3 downto 0); -- Physical pins for keypad rows
        keypad_cols : out STD_LOGIC_VECTOR (3 downto 0); -- Physical pins for keypad columns
        led_green : out STD_LOGIC; -- Physical green LED
        led_red : out STD_LOGIC; -- Physical red LED
        led_yellow : out STD_LOGIC -- Physical yellow LED
    );
end Top_Level;

architecture Behavioral of Top_Level is

    -- 1. Declare the "keypad_controller" component
    component keypad_controller
        Port ( 
            clk : in STD_LOGIC;
            rows : in STD_LOGIC_VECTOR (3 downto 0);
            cols : out STD_LOGIC_VECTOR (3 downto 0);
            key_value : out STD_LOGIC_VECTOR (3 downto 0);
            key_pressed : out STD_LOGIC
        );
    end component;
    
    -- 2. Declare the fsm_controller component
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

    -- 3. Create internal connections to connect the components . The signals will connect the keypad reader to the brain instance.
    signal w_key_pressed : STD_LOGIC;
    signal w_key_value : STD_LOGIC_VECTOR (3 downto 0);

begin

    -- 4. Instantiate the keypad controller
    Keypad_Instance : keypad_controller
    Port map (
        -- Component Port ---> Top_Level Port
        clk         => clk_100mhz,    -- Connect the reader's clock to the main clock
        rows        => keypad_rows,   -- Connect to the physical keypad rows
        cols        => keypad_cols,   -- Connect to the physical keypad columns
        key_value   => w_key_value,   -- Send the output value to the internal wire
        key_pressed => w_key_pressed  -- Send the output pulse to the internal wire
    );

    -- 5. Instantiate the FSM controller
    Brain_Instance : fsm_controller
    Port map (
        -- Component Port ---> Top_Level Port or Wire
        clk            => clk_100mhz,     -- Connect the brain's clock to the main clock
        reset          => reset,          -- Connect to the physical reset button
        key_pressed    => w_key_pressed,  -- Connect to the key_pressed wire from the reader
        key_value_in   => w_key_value,    -- Connect to the key_value wire from the reader
        unlocked_led   => led_green,      -- Connect the brain's unlocked signal to the physical green LED
        locked_led     => led_red,        -- Connect to the physical red LED
        typing_led     => led_yellow      -- Connect to the physical yellow LED
    );

end Behavioral;