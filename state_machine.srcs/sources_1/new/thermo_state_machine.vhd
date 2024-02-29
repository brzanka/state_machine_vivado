library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith;
---------------------------------------------------------------------------------------------------------------------------------------------------
entity thermo is
    Port (  current_temp	: in STD_LOGIC_VECTOR(6 downto 0);
		    desired_temp	: in STD_LOGIC_VECTOR(6 downto 0);
	  	  	display_select	: in STD_LOGIC;
          	cool			: in STD_LOGIC;
          	heat			: in STD_LOGIC;
          	clk 			: in STD_LOGIC;
            furnace_hot		: in STD_LOGIC;
            ac_ready    	: in STD_LOGIC;
	  	  	temp_display	: out STD_LOGIC_VECTOR(6 downto 0);
          	a_c_on			: out STD_LOGIC;
          	furnace_on		: out STD_LOGIC;
            fan_on			: out STD_LOGIC);
end thermo;
---------------------------------------------------------------------------------------------------------------------------------------------------
architecture Behavioral of thermo is
type THERMO_STATES is (IDLE, COOLON, ACNOWREADY, ACDONE, HEATON, FURNACENOWHOT, FURNACECOOL);
signal CURRENT_STATE, NEXT_STATE                                                                                     : THERMO_STATES;
signal display_select_reg, cool_reg, heat_reg, a_c_on_reg, furnace_on_reg, furnace_hot_reg, ac_ready_reg, fan_on_reg : STD_LOGIC;
signal current_temp_reg, desired_temp_reg, temp_display_reg															 : STD_LOGIC_VECTOR(6 downto 0);
signal countdown                                                                                                     : integer;
begin
	ClockRegistering: process(clk)
	begin
		if clk'event and clk = '1' then
		    CURRENT_STATE		<= NEXT_STATE;
		-- inputs
            display_select_reg	<= display_select;
            cool_reg			<= cool;
            heat_reg			<= heat;
            current_temp_reg	<= current_temp;
            desired_temp_reg	<= desired_temp;
            furnace_hot_reg     <= furnace_hot; 
            ac_ready_reg        <= ac_ready;
       -- outputs     
            temp_display		<= temp_display_reg;
            a_c_on	 			<= a_c_on_reg;
            furnace_on			<= furnace_on_reg;
            fan_on              <= fan_on_reg;
		end if;
	end process ClockRegistering;
	
	Display: process (current_temp_reg, desired_temp_reg, display_select_reg) is
	begin
        	if display_select_reg = '0' then
				temp_display_reg <= desired_temp_reg;
			else
				temp_display_reg <= current_temp_reg;
			end if;
	end process Display;
	
	StateMachine: process(CURRENT_STATE, cool_reg, heat_reg, current_temp_reg, desired_temp_reg, ac_ready_reg, furnace_hot_reg, countdown)
	begin
	NEXT_STATE <= IDLE;
    	case CURRENT_STATE is
        	when IDLE =>
            	if cool_reg = '1' and current_temp_reg > desired_temp_reg then
                	NEXT_STATE <= COOLON;
                elsif heat_reg = '1' and current_temp_reg < desired_temp_reg then
                    NEXT_STATE <= HEATON;
                end if;
			when COOLON =>
                NEXT_STATE <= COOLON;
                if ac_ready_reg = '1' then
                    NEXT_STATE <= ACNOWREADY;
                end if;
            when ACNOWREADY =>
                NEXT_STATE <= ACNOWREADY;
                if not(cool_reg = '1' and current_temp_reg > desired_temp_reg) then
                     NEXT_STATE <= ACDONE;
                end if;
            when ACDONE =>
                NEXT_STATE <= ACDONE;
                if ac_ready_reg = '0' then
                    NEXT_STATE <= IDLE;
                end if;
            when HEATON =>
                NEXT_STATE <= HEATON;
                if furnace_hot_reg = '1' then
                    NEXT_STATE <= FURNACENOWHOT;
                end if;          
            when FURNACENOWHOT =>
                NEXT_STATE <= FURNACENOWHOT;
                if not(heat_reg = '1' and current_temp_reg < desired_temp_reg) then
                    NEXT_STATE <= FURNACECOOL;
                end if;              
            when FURNACECOOL  =>
                NEXT_STATE <= FURNACECOOL;
                if furnace_hot_reg = '0' then
                    NEXT_STATE <= IDLE;
                end if;          
		end case;
	end process StateMachine;
	
	SetValues: process(clk)
	begin
	   if clk'event and clk = '1' then
	       	case NEXT_STATE is
        	   when IDLE =>
        	       furnace_on_reg  <= '0';
                   a_c_on_reg      <= '0';
                   fan_on_reg      <= '0';
        	   when COOLON =>
        	       furnace_on_reg  <= '0';
                   a_c_on_reg      <= '1';
                   fan_on_reg      <= '0';
        	   when ACNOWREADY =>
                   furnace_on_reg  <= '0';
                   a_c_on_reg      <= '1';
                   fan_on_reg      <= '1';        	   
        	   when ACDONE =>
                   furnace_on_reg  <= '0';
                   a_c_on_reg      <= '0';
                   fan_on_reg      <= '1';        	   
        	   when HEATON =>
                   furnace_on_reg  <= '1';
                   a_c_on_reg      <= '0';
                   fan_on_reg      <= '0';         	   
        	   when FURNACENOWHOT =>
                   furnace_on_reg  <= '1';
                   a_c_on_reg      <= '0';
                   fan_on_reg      <= '1';           	   
        	   when FURNACECOOL  =>
                   furnace_on_reg  <= '0';
                   a_c_on_reg      <= '0';
                   fan_on_reg      <= '1';           	   
        	end case;
        end if;
	end process SetValues;
	
	Counter: process(clk) is
	begin
	   if NEXT_STATE = FURNACECOOL or NEXT_STATE = ACDONE then
	       countdown <= countdown - 1;
	   elsif NEXT_STATE = FURNACENOWHOT then
	       countdown <= 10;
	   elsif NEXT_STATE = ACNOWREADY then
	       countdown <= 20;    
	   end if;
	end process;
end Behavioral;
