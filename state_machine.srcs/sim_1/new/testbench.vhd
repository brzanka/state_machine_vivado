library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity testbench is
end testbench;

architecture Behavioral of testbench is

component thermo is
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
end component;
signal display_select, cool, heat, a_c_on, furnace_on, fan_on, ac_ready, furnace_hot    : STD_LOGIC;
signal current_temp, desired_temp, temp_display				                            : STD_LOGIC_VECTOR(6 downto 0);
signal clk                                                                              : STD_LOGIC := '0';
begin
	clk <= not clk after 100 us; 
	DUT: thermo port map (  current_temp	=> current_temp, 
    					    desired_temp 	=> desired_temp, 
                            display_select 	=> display_select, 
                            cool 			=> cool, 
                            heat 			=> heat, 
                            clk 			=> clk,
                            furnace_hot     => furnace_hot,
                            ac_ready        =>ac_ready ,
                            temp_display 	=> temp_display, 
                            a_c_on 			=> a_c_on, 
                            furnace_on 		=> furnace_on,
                            fan_on		    => fan_on
                            );
    Testing: process
    begin 
    --setting initial values to inputs
        current_temp <= "0000101";
        desired_temp <= "0001010";
	  	display_select <= '0';		
        cool <= '0';			
        heat <= '0';							
        furnace_hot <= '0';			
        ac_ready <= '0';	    	
    --states change check - heat
        heat <= '1';
        wait for 1 ms;
        wait for 1 ms;
        furnace_hot <= '1';
        wait for 1 ms;
        heat <= '0';
        wait for 1 ms;
        furnace_hot <= '0';
        wait for 1 ms;
    --states change check - cool
        cool <= '1';
        wait for 1 ms;
        current_temp <= "0001111";
        wait for 1 ms;
        ac_ready <= '1';
        wait for 1 ms;
        cool <= '0';
        wait for 1 ms;
        ac_ready <= '0';
        wait for 1 ms;       
    --displaying check   
        display_select <= '1';
        wait for 1 ms;       
        assert temp_display = current_temp report  "Wrong temperature displayed!" severity error; -- severity note --- severity warning --- severity failure      
    end process Testing;

end Behavioral;
